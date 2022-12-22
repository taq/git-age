module Git
  module Age
    class Stats
      def initialize(data)
        @data = data
      end

      def first_commit
        commit_date('--reverse')
      end

      def last_commit
        commit_date
      end

      def unchanged_stats
        max = @data.dates.max_by { |key, value| value[:code] }
        { bigger: { date: max[0], lines: max[1][:code] } }
      end

      def code_to_test_ratio
        stats = @data.dates.reduce({code: 0, test: 0}) do |memo, data|
          memo[:code] += data[1][:code]
          memo[:test] += data[1][:test]
          memo
        end

        { code: stats[:code], test: stats[:test], ratio: (stats[:test].to_f / stats[:code].to_f).round(2) }
      rescue
        { code: 0, test: 0, ratio: 0.0 }
      end

      private

      def commit_date(order = nil)
        cmd = "git log #{order} --pretty=format:%ad --date=short | head -n1"

        IO.popen(cmd) do |io|
          io.read.chomp.strip
        end
      end
    end
  end
end
