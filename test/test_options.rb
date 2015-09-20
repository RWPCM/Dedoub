#!/usr/bin/env ruby

require 'minitest/autorun'
require_relative '../lib/dedoub/options'

class TestOptions < MiniTest::Test
 
    attr_reader :options
    
    def test_empty
        @options = Dedoub::DedoubOptions.parse(["--list .bab,.tot,.cha"])
        assert_equal Dedoub::DedoubOptions::DEFAULT_PHOTO_FILE_EXTENSIONS, @options.list
    end

    def test_liste_ext
        @options = Dedoub::DedoubOptions.parse(["--list" [".bab",".tot",".cha"], "toto"])
        assert_equal [".bab", ".tot", ".cha"], @options.list
    end
    
end


#describe Dedoub::Options do
#  before do
#    @options = Dedoub::Options.new({})
#  end
#
#  describe "when asked about cheeseburgers" do
#    it "must respond positively" do
#      @photo_file_extensions?.must_equal Dedoub::Options::DEFAULT_PHOTO_FILE_EXTENSIONS
#    end
#  end
#
#  describe "when asked about blending possibilities" do
#    it "won't say no" do
#      @meme.will_it_blend?.wont_match /^no/i
#    end
#  end
#end