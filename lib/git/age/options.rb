require 'singleton'

module Git
  module Age
    class Options
      include Singleton
      attr_accessor :branch, :output, :title, :processor, :image, :xtitle,
        :ytitle, :map, :test, :code, :type, :authors

      def initialize
        @branch    = 'master'
        @output    = 'git-age.csv'
        @title     = 'Git age statistics'
        @processor = 'graph-cli'
        @image     = 'git-age.png'
        @xtitle    = 'Dates'
        @ytitle    = 'Lines'
        @test      = nil
        @code      = nil
        @type      = 'bar'
        @map       = false
        @authors   = nil
      end
    end
  end
end
