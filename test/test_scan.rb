#!/usr/bin/env ruby

require 'minitest/autorun'
require_relative '../lib/dedoub/scan'

class TestScan < MiniTest::Test
 
    attr_reader :rep_de_tete
    attr_reader :rep
    attr_reader :rep_simple
    attr_reader :fichier
    
    def setup
        @rep_de_tete = Scan::Repertoire_de_tete.new(".")
        @rep = Scan::Rep.new("./dossier_test", ["total_size", "total_nb_of_files", "total_nb_of_subdirectories", "zozo"])
        @rep_simple = Scan::Repertoire_simple.new("./dossier_test/rep4b/rep43")
        @fichier = Scan::Fich.new("./dossier_test/rep1a/rep12/toto.txt", ["size", "md5"])
    end
    
    def test_init_repertoire_de_tete
        assert_equal "{}", @rep_de_tete.liste_rep.to_s
    end
    
    def test_init_property_keys
        assert_equal [ "total_size", "total_nb_of_files", "total_nb_of_subdirectories" ].to_s, @rep_de_tete.property_keys.to_s
    end
    
    def test_liste_complete_of_leaf
        assert_equal nil, @rep_de_tete.liste_complete[:"/Users/Famille/Dropbox/60-Software_Dev/Projects/Dedoub/test/dossier_test/rep1a"]
    end
    
    def test_init_Rep
       assert_equal "#{{ :"total_size"=>nil, :"total_nb_of_files"=>nil, :"total_nb_of_subdirectories"=>nil, :"zozo"=>nil }}", @rep.properties.to_s
    end
    
    def test_properties_test_folder
        assert_equal "#{{:total_size=>614373007, :total_nb_of_files=>243, :total_nb_of_subdirectories=>21}}", @rep.compute_properties.to_s
    end
    
    def test_liste_complete_leaf
        assert_equal "#{{:"/Users/Regis/Dropbox/60-Software_Dev/Projects/Dedoub/test/dossier_test/rep4b/rep43/bibi.txt"=>nil, :"/Users/Regis/Dropbox/60-Software_Dev/Projects/Dedoub/test/dossier_test/rep4b/rep43/zaza.txt"=>nil, :"/Users/Regis/Dropbox/60-Software_Dev/Projects/Dedoub/test/dossier_test/rep4b/rep43/zouzou.txt"=>nil}}", @rep_simple.liste_complete.to_s
    end
    
    def test_fich_properties
        assert_equal "#{{:size=>11, :md5=>"a43320313014a931cbc5397e87783bd0"}}", @fichier.compute_properties.to_s
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