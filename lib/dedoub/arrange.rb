#!/usr/bin/env ruby

require_relative './scan'

# detects duplicates among folders, or among files within a folder

module Arrange
   
    class Tab_rep < Array
    
        attr_reader :rep, :tabrep
        
        def initialize ( rep )
            #if rep.is_a? Scan::Rep
                @rep = rep
            #else
            #end
        end
    
        def compute_tab_rep
            rep.each {|chemin, h| self << [ h, chemin ] }
            return self
        end
        
        def merge_dups
            self.sort! { | e, f | (e[0][:size] <=> f[0][:size]) * 10 + (e[0][:total_nb_of_files] <=> f[0][:total_nb_of_files]) }
            arr = Array.new
            arr[0] = self[0]
            if self.length >=2
                n = self.length - 1
                for i in 1..n
                    if arr[-1][0] == self[i][0]
                        arr[-1] << self[i][1]
                    else
                        arr << self[i]
                    end
                end
            end
            return arr
        end
    
    end
    
end
























#module Dedoub
#    class Tab < Array
#        
#        attr_reader :sorted
#        attr_reader :shifted
#        attr_reader :doublons
#        
#        def initialize
#            @sorted = self.sort { |x, y| x[2] <=> y[2] } # sorts folders by total size of files
#            @shifted = sorted.slice(1..-1) # shifted is sorted array shifted by 1
#            @doublons = Hash.new
#        end
#        
#        def self.find_doublons_suspects
#            until @shifted.empty? do
#                if @sorted[0][1..2] == @shifted[0][1..2]
#                        @doublons[@sorted[0] << @sorted[0] << @shifted[0]
#                        @shifted = @shifted.slice(1..-1)
#                        
#                    else
#                        
#                    
#                    end
#                    
#                end
#                
#            
#            end   
#        end
#    end
#end