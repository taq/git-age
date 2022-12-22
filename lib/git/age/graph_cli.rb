module Git
  module Age
    class GraphCli
      def self.present?
        IO.popen('which graph') do |io|
          io.read
        end.strip.size != 0
      end

      def self.create(input)
        options = Git::Age::Options.instance
        legend  = options.test ? 'code' : ''
        type    = options.type == 'bar' ? '--bar' : ''
        STDOUT.puts "Creating image #{options.image} ..."

        cmd = "graph #{input} #{type} -o #{options.image} --title '#{options.title}' --xlabel='#{options.xtitle}' --ylabel='#{options.ytitle}' --xtick-fontsize 5 --time-format-output '%Y-%m' --legend='#{legend}' 2> /dev/null"
        IO.popen(cmd) do |io|
          io.read
        end
      end
    end
  end
end
