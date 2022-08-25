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
        max = @data.dates.max_by { |key, value| value }
        { bigger: { date: max[0], lines: max[1] } }
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
