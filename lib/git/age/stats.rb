# typed: false
# frozen_string_literal: true

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
        max = dates.max_by { |_, value| value[:code] }
        { bigger: { date: max[0], lines: max[1][:code] } }
      rescue StandardError
        nil
      end

      def code_to_test_ratio
        stats = dates.reduce({ code: 0, test: 0 }) do |memo, data|
          memo[:code] += data[1][:code]
          memo[:test] += data[1][:test]
          memo
        end

        { code: stats[:code], test: stats[:test], ratio: (stats[:test] / stats[:code].to_f).round(2) }
      rescue StandardError
        { code: 0, test: 0, ratio: 0.0 }
      end

      private

      def dates
        @data.dates
      rescue StandardError
        []
      end

      def commit_date(order = nil)
        cmd = "git log #{order} --pretty=format:%ad --date=short | head -n1"
        IO.popen(cmd, &:read).chomp.strip
      end
    end
  end
end
