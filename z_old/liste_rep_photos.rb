#!/usr/bin/env ruby



require 'find'
require 'fileutils'
require 'csv' # This class provides a complete interface to CSV files and data
require 'digest' # This module provides a framework for message digest libraries

#
# confirmation de l'exactitude du répertoire à traiter (fourni en premier argument)
def confirm_rep(input_rep)
    puts "Le fichier à traiter est #{input_rep}."
    puts "Confirmez en tapant Entrée, sinon faites CTRL-C(^C) pour interrompre"
    
    $stdin.gets
    
end

# création du tableau liste_rep avec les chemins complets des répertoires, leur nombre de fichiers et leur taille totale des fichiers
# à partir du tableau simple des répertoires arr1
# rep_abs est le chemin absolu du répertoire traité
def scan_rep(arr, rep_abs)
    unless arr.is_a? Array
        raise ArgumentError,
            "#{ arr } n'est pas un tableau."
    end
    
    liste_rep = Array.new
    
    arr.each {|d|
        chemin = File.absolute_path(d, rep_abs) # détermination du chemin absolu du répertoire, en partant de répertoire donné en argument
        size = 0
        nb_fichiers = 0
        # calcul récursif de la taille totale des fichiers du répertoire (et donc de ses sous-répertoires)
        puts "Chemin :\n"
        puts "#{chemin}"
        puts "\n"
        Find.find(chemin) {|f|
            if !File.directory?(f) # uniquement pour les fichiers qui ne sont pas des répertoires
            #puts "working on : #{f}"
            size += File.size(f) if File.file?(f)
            nb_fichiers +=1
            end
        }
        # pour chaque répertoire, assignation du chemin absolu, du nombre de fichiers, de la taille totale des fichiers
        liste_rep << [chemin, nb_fichiers, size]
    }
    liste_rep
end

#
#écriture du répertoire analysé et du tableau de ses sous-répertoires dans un fichier texte
def ecriture_fichier_texte(titre, rep_ana, tab_rep)
    puts "Entrez le nom du fichier de sortie (sans extension) ; 'log_' sera placé en tête :"
    filename = "log_#{$stdin.gets.chomp}"
    puts "Nous allons effacer #{filename}."
    puts "Si vous ne voulez pas l'effacer, tapez CTRL-C (^C)." # CTRL-C interrompt le programme"
    puts "Pour continuer, tapez RETURN."
    
    $stdin.gets 
    
    puts "En cours d'ouverture ..."
    target = open(filename, 'w') # Ouverture en écriture
    
        #formatter = "%{une}; %{deux}; %{trois}; %{quatre}" # Prépare le format des lignes
    
        target.write("Analyse du repertoire #{rep_ana}\n\n #{titre}\n\n")
        tab_rep.each {|v|
        target.write(v)
        target.write("\n\n")
        #target.write(formatter % {une: v[:chemin], deux: v[:nb_fichiers], trois: v[:size], quatre: "\n"})
        }
    
    puts "et enfin, nous fermons le fichier."
    target.close
end

#
# REFAIRE UN ALGO PLUS SIMPLE AVEC DEUX TABLEAUX DECALES 
# détecte les doublons potentiels : les répertoires ayant des nombres de fichiers
# et des tailles totales de fichiers identiques
def detect_rep_doublon(tab_rep)
   doub_rep_index_red = Array.new # tableau temporaire des index avec doublons et redondances
   doub_rep_index = Array.new # tableau temporaire des index avec doublons sans redondances
   
   tab_rep = tab_rep.sort! { |x, y| x[2] <=> y[2] } # range les répertoires par taille totale de fichiers croissante
   #tab_rep.each {|t| puts "#{t}" }
   n = tab_rep.length - 1
    for i in 1..n do
        prev = i - 1
        if tab_rep[i][2] == tab_rep[prev][2] && tab_rep[i][1] == tab_rep[prev][1] # cas où taille et nb de fichiers sont identiques
            doub_rep_index_red << ["#{prev}", "#{i}"].to_a # le tableau temporaire contient des paires de doublons 
        end
    end

    # dédoublement des index par transition
    doub_rep_index[0] = doub_rep_index_red[0] # initialisation du tableau sans redondances des doublons
    unless doub_rep_index_red.length < 2
        p = doub_rep_index_red.length - 1
        for j in 1..p
            prev = j - 1
            if doub_rep_index_red[prev][-1] == doub_rep_index_red[j][0] # cas de doublon transitif
                doub_rep_index[-1].concat( doub_rep_index_red[j] ).uniq! # concaténation avec le dernier élément du tableau définitif
            else
                doub_rep_index << doub_rep_index_red[j] # ajout d'une paire
            end 
        end
    end
    
    # refaire avec collect
    doub_rep_index.each { |t| # t est un tableau d'index de répertoires en doublon ["2", "3", "4"] par exemple
        doub_temp = Array.new
        t.each {|e|
            doub_temp << tab_rep[e.to_i]
            }
    doub_rep << doub_temp # ajout à doub_rep d'un tableau de doublons (tableau de tableaux) du type [["/toto", 3, 15678], ["/tata", 3, 15678]]
    }
    doub_rep
end

#
# génère la liste des commandes "diff -q rep 1 rep 2" à exécuter manuellement par le shell
def generate_bash_diff(rep_ana, doub_rep)
    puts "Entrez le nom du fichier de sortie (sans extension) ; 'log_' sera ajouté en tête :"
    filename = "log_#{$stdin.gets.chomp}"
    puts "Nous allons effacer #{filename}."
    puts "Si vous ne voulez pas l'effacer, tapez CTRL-C (^C)." # CTRL-C interrompt le programme"
    puts "Pour continuer, tapez RETURN."
    
    $stdin.gets 
    
    puts "En cours d'ouverture ..."
    target = open(filename, 'w') # Ouverture en écriture
    
        formatter = "%{une} \"%{deux}\" \"%{trois}\" %{quatre}" # Prépare le format des lignes
    
        target.write("Liste des commandes shell diff pour verifier les repertoires doublons de #{rep_ana}\n\n")
        doub_rep.each {|e|
        n = e.length - 1
        for i in 1..n
            target.write(formatter % {une: "diff -q", deux: "#{e[0][0]}", trois: "#{e[i][0]}", quatre: "\n\n"})
        end
        }
    
    puts "et enfin, nous fermons le fichier."
    target.close
end
#
# log du nombre de répertoires et du nombre de doublons
def log_rep(filename, nb_rep, nb_doub)
    log = open(filename, 'a') #avec le mode 'a', write écrit si le fichier n'existe pas, et ajoute s'il existe
    log.write("Le nombre de repertoires et sous-repertoires (non compris lui-meme) est de : #{nb_rep}.\n")
    log.write("Le nombre d'ensemble de doublons est de #{nb_doub}.\n")
    log.close
end

# refaire avec collect
# population du hash aller { md5fichier1: chemin complet du fichier1, md5fichier2: chemin complet du fichier2 } pour un répertoire, et du hash retour
# rep = répertoire traité, h_aller = le hash aller, h_retour = le hash retour
def populate_md5_hashes (rep, h_aller, h_retour)
    rep.each {|f|
        if f.file?            
             md5 = Digest::MD5.file f
             h_aller[md5] = "#{File.absolute_path(f)}"
             h_retour["#{File.absolute_path(f)}"] = md5
        end
    }   
end

#
#


#
# exécute les commandes diff -q et enregistre le résultat - en cours, à définir
def exec_diff(log_file)
    puts "Entrez le nom du fichier contenant les commandes 'diff -q' :"
    filename = $stdin.gets.chomp
    puts "En cours d'ouverture ..."
    source = open(filename, 'r') # Ouverture en lecture
    log = open(log_file, 'a') # Ouverture en append du fichier log
    a = source.readlines # readlines produit un tableau, avec chacune des lignes
    n = a.length - 1
    for i in 0..n # ne fonctionne pas, reprendre
        if a[i].include? "diff -q "
        log.write(a[i].to_s)
        exec("#{a[i]} >> log_dedoub")
        end
    end
    source.close
    log.close
end

# *********************************************************************************************

# MAIN

# *********************************************************************************************

# tab_rep : tableau de l'ensemble récursif des répertoires du répertoire entré comme argument,
# non compris ce répertoire
tab_rep = Array.new

# sauvegarde du chemin absolu du répertoire entré comme argument, confirmation de ce répertoire
repertoire_analyse = File.absolute_path(ARGV.first) # sauvegarde du répertoire entré comme argument
confirm_rep(repertoire_analyse)
puts "Le repertoire analysé est :\n"
puts repertoire_analyse
puts "\n"

# remplissage de tab_rep
Dir.chdir("#{ARGV.first}") {
    tab_rep = Dir.glob("**/*/") # ensemble récursif des répertoires du répertoire courant
} # ensortie de bloc, chdir retourne au répertoire courant d'origine
#puts "Le repertoire #{repertoire_analyse} contient #{tab_rep.length} repertoires et sous-repertoires (non compris lui-meme)"
#puts "Resultat de dir.glob = #{tab_rep}" #OK

# création d'un array destiné à contenir les chemins complets des répertoires,
# et des infos pour chacun d'entre eux de la forme [["/Users/Famille/Dropbox/rep2", nb_fichiers, taille totale des fichiers], [...]]
liste_rep = Array.new

# création d'un tableau destiné à contenir les doublons (ou doublons potentiels) de répertoires
# sous la forme [[["/Users/Famille/Dropbox/rep2", 2, 10], ["/toto", 2, 10]], [...]]
doublons_rep = Array.new

# création d'un fichier d'enregistrement des opérations
log_dedoub = File.new("log_dedoub", 'w')
log_dedoub.write("\nLog du nombre de repertoires et de doublons de #{repertoire_analyse} et des operations de dedoublonnage\n")
log_dedoub.close

liste_rep = scan_rep(tab_rep, repertoire_analyse) # remplissage du tableau liste_rep
#puts "Liste remplie : #{liste_rep}"
doublons_rep = detect_rep_doublon(liste_rep)
puts "Ecriture de la liste des repertoires doublons dans un fichier texte de votre choix" ; ecriture_fichier_texte("Liste des doublons supposes", repertoire_analyse, doublons_rep)
puts "Ecriture de la liste des commandes shell diff dans un fichier texte de votre choix" ; generate_bash_diff(repertoire_analyse, doublons_rep)
puts "Enregistrement du nombre de repertoires dans le fichier log_dedoub" ; log_rep(log_dedoub, tab_rep.length, doublons_rep.length)
#puts "Execution des commandes diff -d" ; exec_diff(log_dedoub) # ne fonctionne pas encore, pb avec exec voir exec_diff

# *********************************************************************************************

# TESTS

#
# confirmation de l'exactitude du répertoire à traiter (fourni en premier argument)
puts "Entrer un nom de répertoire : "
filename = $stdin.gets.chomp
confirm_rep(filename)




# *********************************************************************************************

# PROCEDURES NON UTILISEES

#
# écriture d'un hash dans un fichier csv
def ecriture_hash_csv(h)
    puts "Entrez le nom du fichier de sortie (sans extension) :"
    filename = $stdin.gets.chomp
    puts "Nous allons effacer #{filename}."
    puts "Si vous ne voulez pas l'effacer, tapez CTRL-C (^C)." # CTRL-C interrompt le programme"
    puts "Pour continuer, tapez RETURN."
    
    $stdin.gets 
    
    puts "En cours d'ouverture ..."
 
 # refaire avec collect   
    target = CSV.open("#{filename}.CSV", 'w') do |csv| # Ouverture en écriture, ajout de l'extension CSV
        a = csv
        h.each {|k, v|
            arr = v.to_a # conversion de chaque hash en tableau
        a << arr # écriture des lignes
        }
    end
end

#
# écriture d'un array dans un fichier csv
def ecriture_tab_csv(arr)
    puts "Entrez le nom du fichier de sortie (sans extension) :"
    filename = $stdin.gets.chomp
    puts "Nous allons effacer #{filename}."
    puts "Si vous ne voulez pas l'effacer, tapez CTRL-C (^C)." # CTRL-C interrompt le programme"
    puts "Pour continuer, tapez RETURN."
    
    $stdin.gets 
    
    puts "En cours d'ouverture ..."
    
  # refaire avec collect
    target = CSV.open("#{filename}.CSV", 'w') do |csv| # Ouverture en écriture, ajout de l'extension CSV
        arr.each {|e|
            csv << e # écriture des lignes   
        }
    end
end
#
# refaire avec collect
#routine de sortie lisible d'un tableau de tableaux de répertoires [["/toto/zozo", 3, 16578], [...]]
def sortie_pretty(tab_rep)
    tab_rep.each { |v|
    puts "Chemin : #{v[0]}, Nombre de fichiers : #{v[1]}, Taille totale des fichiers : #{v[2]}}"
    }
end