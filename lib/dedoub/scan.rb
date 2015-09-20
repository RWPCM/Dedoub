#!/usr/bin/env ruby

require 'find'
require 'fileutils'
require 'digest'
require 'io/console'

# takes directory that needs to be analyzed
# defines which properties of subdirectories we want to use to detect redundant directories or files (default : File.stat, total size, total number of files)
# lists all its subdirectories
# creates hash with full path of each subdirectory as key, and its properties

# takes simple directory (with no subdirectory)
# creates hash with full path of file as key, and its properties

# takes file and property keys, creates hash with full path of file as key, and its properties. Computes properties


module Scan
    # Classe pour les répertoires du cas général (contenant des sous-répertoires)
    class Repertoire_de_tete < File

        attr_reader :full_path
        attr_reader :liste_rep # hash with all subdirectories as keys
        attr_reader :property_keys # property keys of each subdirectory of self
        
        @@default_property_keys = [ "file_stat", "total_size", "total_nb_of_files", "total_nb_of_subdirectories" ]
        
        def initialize ( chemin )
            @full_path = File.absolute_path( chemin )
            @liste_rep = Hash.new
            @property_keys = Array.new 
        end
        
        def liste_complete # yields hash with absolute paths of subdirectories as keys, and nil values
            Dir.chdir(@full_path) {
               Dir.glob("**/*/").each { |r| # ensemble récursif des répertoires du répertoire courant
                   @liste_rep [ File.absolute_path(r, @full_path).to_sym ] = nil # les clés du hash liste_rep sont les noms complets des répertoires, en partant du répertoire donné en argument
               }
            }
            @liste_rep
        end
        
        def enter_property_keys # proc à développer pour laisser le choix entre des propriétés (size, nb_files, md5, ...)
            $stdout.puts "Entrez les propriétés pour l'analyse de / Please enter properties for analysing #{@full_path} : "
            # @property_keys = gets.chomp.downcase.split(' ') # Bug : regarder comment ouvrir le standard input
            @property_keys = @@default_property_keys # if @property_keys.empty?
        end
        
    end
    
    class Rep < Hash
        
        attr_reader :chemin # absolute path of directory
        attr_reader :properties # properties hash of directory
        
        def initialize ( chemin, property_keys )
            @chemin = chemin
            @properties = Hash.new
            self[ @chemin.to_sym ] = @properties
            property_keys.each { |pk| @properties[ pk.to_sym ] = nil }
        end
             
        def compute_properties
            ch = @chemin
            @properties.each { |pk, v|
                case
                when pk == :file_stat
                    @properties[pk] = File::Stat.new(ch)
                when pk == :total_size
                    v = 0
                    Find.find(ch) {|f|
                        v += File.size(f) if (!File.directory?(f) && File.file?(f))
                    }
                    @properties[pk] = v
                when pk == :total_nb_of_files
                    v = 0
                    Find.find(ch) {|f|
                       v += 1 if (!File.directory?(f) && File.file?(f))
                    }
                    @properties[pk] = v
                when pk == :total_nb_of_subdirectories
                    v = 0
                    Find.find(ch) { |f| v +=1 if File.directory?(f) }
                    @properties[pk] = v
                else
                    puts "Property key #{pk} unknown, deleted" ; @properties.delete(pk)
                end
            }
            @properties
        end
        
    end
    
    # Classe pour les répertoires qui ne possèdent pas de sous-répertoire - utilité ????
    class Repertoire_simple < File

        attr_reader :full_path
        attr_reader :liste_files # hash with all files as keys
        attr_reader :file_property_keys # property keys of each subdirectory of self
        
        @@default_file_property_keys = ["file_stat", "size", "md5"] 
        
        def initialize ( chemin )
            @full_path = File.absolute_path( chemin )
            @liste_files = Hash.new
            @property_keys = Array.new 
        end
        
        def liste_complete # yields hash with absolute paths of contained files (except "." files) as keys, and nil values
            Dir.chdir("#{@full_path}") {
               Dir.glob("*").each { |r| # ensemble récursif des répertoires du répertoire courant
                   @liste_files [ File.absolute_path(r, @full_path).to_sym ] = nil # les clés du hash liste_rep sont les noms complets des répertoires, en partant du répertoire donné en argument
               }
            }
            @liste_files
        end
        
        def enter_property_keys # proc à développer pour laisser le choix entre des propriétés (size, nb_files, md5, ...)
            $stdin.puts "Entrez les propriétés pour l'analyse de / Please enter properties for analysing #{@full_path} :"
            @file_property_keys = gets.chomp.downcase.split(' ') # Bug ici, il faut d'abord ouvrir le stream
            @file_property_keys = @@default_file_property_keys if @file_property_keys.empty?
        end
        
    end
    
    # Classe pour les fichiers
    class Fich < File
        
        attr_reader :chemin # absolute path of file
        attr_reader :properties # properties hash of file
        
        def initialize ( chemin, property_keys )
            @chemin = chemin
            @properties = Hash.new
            self[ @chemin.to_sym ] = @properties
            property_keys.each { |pk| @properties[ pk.to_sym ] = nil }
        end
             
        def compute_properties
            @properties.each_key { |pk|
                case
                when pk == file_stat
                    @properties [ pk ] = File.stat( @chemin )
                when pk == :size
                    @properties [ pk ] = File.size( @chemin )
                when pk == :md5
                    @properties [ pk ] = Digest::MD5.hexdigest( File.read ( @chemin ) )
                else
                    puts "Property key #{pk} unknown, deleted" ; @properties.delete(pk)
                end
            }
            @properties
        end
        
    end  
    
end


