#!/usr/bin/env ruby

require('./scan')

# Ce module fournit des méthodes pour manipuler le hash de type :
# {"chemin de fichier": {propriété1: zerezrzerz, propriété2: fgjdklgjdlgj, etc}}
module Manipule

	class Rep_trie

		attr_accessor :rep 
		attr_accessor :rep_trie

		def initialize ( rep )
			@rep = rep
			@rep_trie = Array.new
		end

		def tri_par_file_stat
			@rep_trie = @rep.sort_by { |k, v| v[:file_stat] }
		end

		def tri_par_total_size
			@rep_trie = @rep.sort_by { |k, v| v[:total_size] }
		end
	end

end


