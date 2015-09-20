#!/usr/bin/env ruby

require 'minitest/autorun'
require_relative '../lib/dedoub/arrange'

class TestArrange < MiniTest::Test
 
    attr_reader :tab_rep
    
    def setup
        @tab_rep = Arrange::Tab_rep.new( { :"Rep12"=>{:size=>1340, :total_nb_of_files=>10}, \
                :"Rep2"=>{:size=>1500, :total_nb_of_files=>10}, \
                :"Rep3"=>{:size=>1340, :total_nb_of_files=>8}, \
                :"Rep11"=>{:size=>1600, :total_nb_of_files=>15}, \
                :"Rep5"=>{:size=>1340, :total_nb_of_files=>13}, \
                :"Rep6"=>{:size=>1340, :total_nb_of_files=>30}, \
                :"Rep10"=>{:size=>1600, :total_nb_of_files=>15}, \
                :"Rep8"=>{:size=>1340, :total_nb_of_files=>12}, \
                :"Rep9"=>{:size=>1340, :total_nb_of_files=>10}, \
                :"Rep7"=>{:size=>1600, :total_nb_of_files=>15}, \
                :"Rep4"=>{:size=>1340, :total_nb_of_files=>10}, \
                :"Rep1"=>{:size=>1340, :total_nb_of_files=>3} } )
    end
    
    def test_1init
        assert_equal "{:Rep12=>{:size=>1340, :total_nb_of_files=>10}, :Rep2=>{:size=>1500, :total_nb_of_files=>10}, :Rep3=>{:size=>1340, :total_nb_of_files=>8}, :Rep11=>{:size=>1600, :total_nb_of_files=>15}, :Rep5=>{:size=>1340, :total_nb_of_files=>13}, :Rep6=>{:size=>1340, :total_nb_of_files=>30}, :Rep10=>{:size=>1600, :total_nb_of_files=>15}, :Rep8=>{:size=>1340, :total_nb_of_files=>12}, :Rep9=>{:size=>1340, :total_nb_of_files=>10}, :Rep7=>{:size=>1600, :total_nb_of_files=>15}, :Rep4=>{:size=>1340, :total_nb_of_files=>10}, :Rep1=>{:size=>1340, :total_nb_of_files=>3}}", @tab_rep.rep.to_s
    end
    
    def test_2compute_tab_rep
        assert_equal "[[{:size=>1340, :total_nb_of_files=>10}, :Rep12], [{:size=>1500, :total_nb_of_files=>10}, :Rep2], [{:size=>1340, :total_nb_of_files=>8}, :Rep3], [{:size=>1600, :total_nb_of_files=>15}, :Rep11], [{:size=>1340, :total_nb_of_files=>13}, :Rep5], [{:size=>1340, :total_nb_of_files=>30}, :Rep6], [{:size=>1600, :total_nb_of_files=>15}, :Rep10], [{:size=>1340, :total_nb_of_files=>12}, :Rep8], [{:size=>1340, :total_nb_of_files=>10}, :Rep9], [{:size=>1600, :total_nb_of_files=>15}, :Rep7], [{:size=>1340, :total_nb_of_files=>10}, :Rep4], [{:size=>1340, :total_nb_of_files=>3}, :Rep1]]", @tab_rep.compute_tab_rep.to_s
    end
    
    def test_3merge_dups
        assert_equal  "[[{:size=>1340, :total_nb_of_files=>3}, :Rep1], [{:size=>1340, :total_nb_of_files=>8}, :Rep3], [{:size=>1340, :total_nb_of_files=>10}, :Rep4, :Rep9, :Rep12], [{:size=>1340, :total_nb_of_files=>12}, :Rep8], [{:size=>1340, :total_nb_of_files=>13}, :Rep5], [{:size=>1340, :total_nb_of_files=>30}, :Rep6], [{:size=>1500, :total_nb_of_files=>10}, :Rep2], [{:size=>1600, :total_nb_of_files=>15}, :Rep11, :Rep7, :Rep10]]", @tab_rep.compute_tab_rep.merge_dups.to_s
    end
    
    def test_that_will_be_skipped
        skip "test this later"
    end
    
end


#Mocks

#class MemeAsker
#    def initialize(meme)
#      @meme = meme
#    end
#
#    def ask(question)
#      method = question.tr(" ","_") + "?"
#      @meme.__send__(method)
#    end
#  end
#
#  require "minitest/autorun"
#
#  describe MemeAsker do
#    before do
#      @meme = Minitest::Mock.new
#      @meme_asker = MemeAsker.new @meme
#    end
#
#    describe "#ask" do
#      describe "when passed an unpunctuated question" do
#        it "should invoke the appropriate predicate method on the meme" do
#          @meme.expect :will_it_blend?, :return_value
#          @meme_asker.ask "will it blend"
#          @meme.verify
#        end
#      end
#    end
#  end

#class Meme
#    def i_can_has_cheezburger?
#      "OHAI!"
#    end
#
#    def will_it_blend?
#      "YES!"
#    end
#end



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