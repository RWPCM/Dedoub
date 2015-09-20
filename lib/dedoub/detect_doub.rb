#!/usr/bin/env ruby

module Detect_doub

    class Doublon < Array

        attr_reader :sorted
        attr_reader :doublons

        def initialize (rep_trie)
            @sorted = rep_trie
            @doublons = Array.new
            if @sorted.length >= 2
                sorted_gauche = @sorted
                sorted_gauche.pop
                sorted_droite = @sorted
                sorted_droite.shift
                compute_doublons( sorted_gauche, sorted_droite )
            else
                raise "Moins de 2 repertoires, pas de doublon"
            end
        end


        # Algorithme ci-dessous à débugger
        def compute_doublons (sorted_gauche, sorted_droite)
            l = sorted_gauche.length-1
            for i in 0..l 
                if ( sorted_droite.length >= 1 && sorted_gauche[0][1][:"total_size"] == sorted_droite[0][1][:"total_size"] )
                    @doublons.push(["Doublon(s) de #{sorted_gauche[0][0]}", "#{sorted_droite[0][0]}"])
                    sorted_droite.shift
                    while ( sorted_droite.length >= 1 && sorted_gauche[0][1][:"total_size"] == sorted_droite[0][1][:"total_size"] )
                        @doublons[-1].push("#{sorted_droite[0][0]}")
                        sorted_droite.shift
                    end
                    sorted_gauche.shift
                else
                    sorted_gauche.shift
                    sorted_droite.shift
                end
                i += 1
                $stdout.puts "#{i} : #{@doublons[-1]}"
            end
            @doublons
        end
    end
end







# module Dedoub
#     class Tab < Array
        
#         attr_reader :sorted
#         attr_reader :shifted
#         attr_reader :doublons
        
#         def initialize
#             @sorted = self.sort { |x, y| x[2] <=> y[2] } # sorts folders by total size of files
#             @shifted = sorted.slice(1..-1) # shifted is sorted array shifted by 1
#             @doublons = Hash.new
#         end
        
#         def self.find_doublons_suspects
#             until @shifted.empty? do
#                 if @sorted[0][1..2] == @shifted[0][1..2]
#                         @doublons[@sorted[0] << @sorted[0] << @shifted[0]
#                         @shifted = @shifted.slice(1..-1)
                        
#                     else
                        
                    
#                 end
                    
#             end
                
            
#         end   
#     end
        
        
        
        
# # REFAIRE UN ALGO PLUS SIMPLE AVEC DEUX TABLEAUX DECALES 
# # détecte les doublons potentiels : les répertoires ayant des nombres de fichiers
# # et des tailles totales de fichiers identiques
# def detect_rep_doublon(tab_rep)
#    doub_rep_index_red = Array.new # tableau temporaire des index avec doublons et redondances
#    doub_rep_index = Array.new # tableau temporaire des index avec doublons sans redondances
   
#    tab_rep = tab_rep.sort! { |x, y| x[2] <=> y[2] } # range les répertoires par taille totale de fichiers croissante
#    #tab_rep.each {|t| puts "#{t}" }
#    n = tab_rep.length - 1
#     for i in 1..n do
#         prev = i - 1
#         if tab_rep[i][2] == tab_rep[prev][2] && tab_rep[i][1] == tab_rep[prev][1] # cas o taille et nb de fichiers sont identiques
#             doub_rep_index_red << ["#{prev}", "#{i}"].to_a # le tableau temporaire contient des paires de doublons 
#         end
#     end

#     # dédoublement des index par transition
#     doub_rep_index[0] = doub_rep_index_red[0] # initialisation du tableau sans redondances des doublons
#     unless doub_rep_index_red.length < 2
#         p = doub_rep_index_red.length - 1
#         for j in 1..p
#             prev = j - 1
#             if doub_rep_index_red[prev][-1] == doub_rep_index_red[j][0] # cas de doublon transitif
#                 doub_rep_index[-1].concat( doub_rep_index_red[j] ).uniq! # concaténation avec le dernier élément du tableau définitif
#             else
#                 doub_rep_index << doub_rep_index_red[j] # ajout d'une paire
#             end 
#         end
#     end
    
#     # refaire avec collect
#     doub_rep_index.each { |t| # t est un tableau d'index de répertoires en doublon ["2", "3", "4"] par exemple
#         doub_temp = Array.new
#         t.each {|e|
#             doub_temp << tab_rep[e.to_i]
#             }
#     doub_rep << doub_temp # ajout ˆ doub_rep d'un tableau de doublons (tableau de tableaux) du type [["/toto", 3, 15678], ["/tata", 3, 15678]]
#     }
#     doub_rep
# end