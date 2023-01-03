require 'date'
require 'io/console'

module Git
  module Age
    class Main
      attr_reader :dates, :files

      def initialize
        STDOUT.puts "Waiting, analysing your repository ..."
        options = Git::Age::Options.instance

        @dates   = Hash.new { |hash, key| hash[key] = { code: 0, test: 0 } }
        @files   = fill_files
        @winsize = IO.console.winsize
        @test    = options.test
        @code    = options.code
        @mapfile = options.map ? File.open("/tmp/git-age.map", 'w') : nil
        @authors = options.authors ? Hash.new(0) : nil

        @test_regexp = @test ? %r{^#{@test}} : nil
        @code_regexp = @code ? %r{^#{@code}} : nil
      end

      def run
        read_files
        sort_dates
        create_csv
        create_image
        show_stats
      rescue => e
        STDERR.puts "Error: #{e}"
        puts e.backtrace
      end

      private

      def file_type(file)
        return :t if @test_regexp && file.match(@test_regexp)

        return :c unless @code_regexp

         @code_regexp && file.match(@code_regexp) ? :c : :u
      end

      def read_files
        cnt     = 0
        total   = @files.size

        @files.each do |file|
          cnt += 1
          next unless text?(file)

          print "Checking [#{cnt}/#{total}] #{file} ...".ljust(@winsize[1]) + "\r"

          begin
            IO.popen("git blame #{file} | iconv -t utf8") do |io|
              io.read.split("\n")
            end.each do |line|
              matches = line.match(/[\w^]+\s\((?<author>[\w\s]+)(?<date>\d{4}-\d{2})-\d{2}/)
              next unless matches

              tokens   = line.strip.split(')')
              contents = tokens[1..-1].join.strip.chomp
              next if contents.size == 0

              type = file_type(file)
              @mapfile << "#{file}[#{type}]: #{line}\n" if @mapfile

              @dates[matches[:date]][:test] += 1 if type == :t
              @dates[matches[:date]][:code] += 1 if type == :c

              @authors[matches[:author].strip.chomp] += 1 if @authors
            end
          rescue => exc
            print "Error on file: #{file}: #{exc}\r"
          end
        end

        @mapfile.close if @mapfile
        write_authors if @authors
      rescue => e
        STDERR.puts "Error reading files: #{e}"
      end

      def write_authors
        path = Git::Age::Options.instance.authors
        STDOUT.puts "\nWriting authors file #{path} ..."

        File.open(path, 'w') do |file|
          @authors.each do |author, lines|
            file << "#{author}: #{lines}\n"
          end
        end
      end

      def sort_dates
        @dates = @dates.sort_by { |k, v| k }
      end

      def create_csv
        output = Git::Age::Options.instance.output
        STDOUT.puts "Creating CSV file #{output} with #{@dates.size} lines ...".ljust(@winsize[1])

        File.open(output, 'w') do |file|
          header = "\"date\",\"code\""
          header << ",\"test\"" if @test
          file << "#{header}\n"

          @dates.each do |key, data|
            line = "\"#{key}\",#{data[:code]}"
            line << ",#{data[:test]}" if @test
            file << "#{line}\n"
          end
        end
      rescue => e
        STDERR.puts "Error creating CSV file: #{e}"
      end

      def create_image
        options   = Options.instance
        processor = {
          'graph-cli' => Git::Age::GraphCli
        }[options.processor]

        unless processor
          STDERR.puts "Image processor not supported: #{options.processor}"
          return
        end

        unless processor.present?
          STDERR.puts "Image processor #{options.processor} is not installed"
          return
        end

        processor.create(options.output)
      end

      def fill_files
        branch = Git::Age::Options.instance.branch
        STDOUT.puts "Reading files info from #{branch} branch ..."

        IO.popen("git ls-tree -r #{branch} --name-only") do |io|
          io.read.split("\n")
        end
      rescue => e
        STDERR.puts "Error while searching for Git controlled files: #{e}"
      end

      def text?(file)
        IO.popen("file -i -b #{file}") do |io|
          io.read
        end.match?(/\Atext/)
      end

      def show_stats
        stats  = Git::Age::Stats.new(self)
        first  = Date.parse(stats.first_commit)
        last   = Date.parse(stats.last_commit)
        diff   = (last - first).to_i + 1
        ustats = stats.unchanged_stats

        puts "First commit in: #{first}"
        puts "Last  commit in: #{last}"
        puts "Repository has #{diff} days with commits"
        puts "Month with more code lines unchanged: #{ustats[:bigger][:date]} (#{ustats[:bigger][:lines]} lines)"

        if @test_regexp && @code_regexp
          ratio = stats.code_to_test_ratio
          puts "Code to test ratio: 1:#{ratio[:ratio]} (#{ratio[:code]}/#{ratio[:test]})"
        end
      end
    end
  end
end
