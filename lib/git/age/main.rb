require 'date'
require 'io/console'

module Git
  module Age
    class Main
      attr_reader :dates, :files

      def initialize
        STDOUT.puts "Waiting, analysing your repository ..."

        @dates   = Hash.new(0)
        @files   = files
        @winsize = IO.console.winsize
      end

      def run
        read_files
        sort_dates
        create_csv
        create_image
        show_stats
      rescue => e
        STDERR.puts "Error: #{e}"
      end

      private

      def read_files
        cnt     = 0
        total   = @files.size
        mapfile = Git::Age::Options.instance.map ? File.open("/tmp/git-age.map", 'w') : nil

        @files.each do |file|
          cnt += 1
          next unless text?(file)

          print "Checking [#{cnt}/#{total}] #{file} ...".ljust(@winsize[1]) + "\r"

          begin
            IO.popen("git blame #{file} | iconv -t utf8") do |io|
              io.read.split("\n")
            end.each do |line|
              matches = line.match(/[\w^]+\s\([\w\s]+(?<date>\d{4}-\d{2})-\d{2}/)
              next unless matches

              mapfile << "#{file}: #{line}\n" if mapfile

              @dates[matches[:date]] += 1
            end
          rescue => blame
            print "Error on file: #{file}\r"
          end
        end

        mapfile.close if mapfile
      rescue => e
        STDERR.puts "Error reading files: #{e}"
      end

      def sort_dates
        @dates = @dates.sort_by { |k, v| k }
      end

      def create_csv
        output = Git::Age::Options.instance.output
        STDOUT.puts "Creating CSV file #{output} ...".ljust(@winsize[1])

        File.open(output, 'w') do |file|
          file << "\"date\",\"lines\"\n"

          @dates.each do |key, value|
            file << "\"#{key}\",#{value}\n"
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

      def files
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
        diff   = (last - first).to_i
        ustats = stats.unchanged_stats

        puts "First commit in: #{first}"
        puts "Last  commit in: #{last}"
        puts "Repository is #{diff} days old"
        puts "Month with more lines unchanged: #{ustats[:bigger][:date]} (#{ustats[:bigger][:lines]} lines)"
      end
    end
  end
end
