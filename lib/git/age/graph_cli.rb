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
        STDOUT.puts "Creating image #{options.image} ..."

        cmd = "graph #{input} --bar -o #{options.image} --title '#{options.title}' --xlabel='#{options.xtitle}' --ylabel='#{options.ytitle}' --xtick-fontsize 5 --time-format-output '%Y-%m-%d' --legend='#{legend}' 2> /dev/null"
        rst = IO.popen(cmd) do |io|
          io.read
        end
      end
    end
  end
end
