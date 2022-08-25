require 'singleton'

module Git
  module Age
    class Options
      include Singleton
      attr_accessor :branch, :output, :title, :processor, :image, :xtitle, :ytitle, :map

      def initialize
        @branch    = 'master'
        @output    = 'git-age.csv'
        @title     = 'Git age statistics'
        @processor = 'graph-cli'
        @image     = 'git-age.png'
        @xtitle    = 'Dates'
        @ytitle    = 'Lines'
        @map       = false
      end
    end
  end
end
