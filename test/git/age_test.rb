require "test_helper"
require_relative '../../lib/git/age/version.rb'

class Git::AgeTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil Git::Age::VERSION
  end
end
