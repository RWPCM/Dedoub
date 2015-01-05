#!/usr/bin/env ruby

# ETAPES

# On part de 70 k fichiers dans n (plusieurs dizaines) répertoires
# Objectif in fine : deux arborescences de répertoires :
# - la première par année, et pour chaque année, un seul niveau de sous-répertoires
# dont le titre est évocateur (lieu et/ou date et/ou thème). Dans cette arborescence ne figurent que des versions sources
# des fichiers photo (pas de doublon)
# - la seconde par dossiers thématiques (un seul niveau de sous-répertoires /dossiers thématiques/thème n/).
# Chaque fichier de ces dossiers thématiques est le doublon d'un fichier source contenu dans le dossiers Années

# Phase 1 : mise de côté des répertoires en doublon
# Etape numéro 1 : lister tous les répertoires avec leur arborescence complète et leur taille totale - FAIT
# Etape numéro 2 : détecter les répertoires potentiellement en doublon, ie dont le nombre et la taille totale des fichiers est identique - FAIT
# Etape 2bis : générer automatiquement les commandes shell diff -q permettant de comparer les répertoires doublons (par exemple si 3 doublons, comparaison 2 avec 1 et 3 avec 1)
# Etape 2ter (manuelle) : pour chacun des doublons, décider du nom de répertoire approprié, réduire l'arborescence le cas échéant, décider de conserver ou pas le doublon
# les renommer "[Répertoire] - doublonné"
# Etape numéro 3 : indexer les répertoires doublonnés, par groupes de doublons
# Etape numéro 4 : manuellement, choisir dans chaque groupe de doublons un répertoire "source"
# Etape numéro 5 : manuellement, insérer dans un fichier .txt dans le répertoire source le chemin
# des répertoires en doublon du répertoire source, si cela apporte une information utile
# Etape numéro 6 : placer les répertoires en doublon de côté, dans un répertoire "Doublons"

# Phase 2 : construire l'architecture cible des répertoires
# (sans doute à faire manuellement)

# Phase 3 : dans le répertoire par années, éliminer les doublons de fichiers

# ********************************************************************************************************************

# CODE

require 'find'
require 'fileutils'
require 'csv' # this class provides a complete interface to CSV files and data

#
# confirmation de l'exactitude du répertoire à traiter (fourni en premier argument)
def confirm_rep(input_rep)
    puts "Le fichier à traiter est #{input_rep}."
    puts "confirmez en tapant Entrée, sinon faites CTRL-C(^C) pour interrompre"
    
    $stdin.gets
    
end

# création du tableau arr2 avec les chemins complets des répertoires, leur nombre de fichiers et leur taille totale des fichiers
# à partir du tableau simple des répertoires arr1
# rep_abs est le chemin absolu du répertoire traité
def scan_rep(arr1, arr2, rep_abs)
arr1.each {|d|
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
    arr2 << [chemin, nb_fichiers, size]
}
end

#
#écriture du répertoire analysé et du tableau de ses sous-répertoires dans un fichier texte
def ecriture_fichier_texte(titre, rep_ana, tab_rep)
    puts "Entrez le nom du fichier de sortie (sans extension) :"
    filename = $stdin.gets.chomp
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
# détecte les doublons potentiels : les répertoires ayant des nombres de fichiers
# et des tailles totales de fichiers identiques
def detect_rep_doublon(tab_rep, doub_rep)
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
    
    doub_rep_index.each { |t| # t est un tableau d'index de répertoires en doublon ["2", "3", "4"] par exemple
        doub_temp = Array.new
        t.each {|e|
            doub_temp << tab_rep[e.to_i]
            }
    doub_rep << doub_temp # ajout à doub_rep d'un tableau de doublons (tableau de tableaux) du type [["/toto", 3, 15678], ["/tata", 3, 15678]]
    }
end

#
# génère la liste des commandes "diff -q rep 1 rep 2" à exécuter manuellement par le shell
def generate_bash_diff(rep_ana, doub_rep)
    puts "Entrez le nom du fichier de sortie (sans extension) :"
    filename = $stdin.gets.chomp
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

#
# équivalent Ruby de shell diff - en cours - ne fonctionne pas
def diff_reps(rep1, rep2)
    if !rep1.exists? || !rep2.exists? 
        puts "L'un au moins des deux repertoires n'existe pas"
    else
        
    end
    
        #code
end

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
repertoire_analyse = File.absolute_path(ARGV.first) # sauvegarde du répertoire en cours
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

scan_rep(tab_rep, liste_rep, repertoire_analyse) # remplissage du tableau liste_rep
#puts "Liste remplie : #{liste_rep}"
#detect_rep_doublon(liste_rep, doublons_rep)
#puts "Ecriture de la liste des repertoires doublons dans un fichier texte de votre choix" ; ecriture_fichier_texte("Liste des doublons supposes", repertoire_analyse, doublons_rep)
#puts "Ecriture de la liste des commandes shell diff dans un fichier texte de votre choix" ; generate_bash_diff(repertoire_analyse, doublons_rep)
#puts "Enregistrement du nombre de repertoires dans le fichier log_dedoub" ; log_rep(log_dedoub, tab_rep.length, doublons_rep.length)
#puts "Execution des commandes diff -d" ; exec_diff(log_dedoub) # ne fonctionne pas encore, pb avec exec voir exec_diff



# *********************************************************************************************

# ROUTINES NON UTILISEES

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
    
    target = CSV.open("#{filename}.CSV", 'w') do |csv| # Ouverture en écriture, ajout de l'extension CSV
        arr.each {|e|
            csv << e # écriture des lignes   
        }
    end
end
#
#routine de sortie lisible d'un tableau de tableaux de répertoires [["/toto/zozo", 3, 16578], [...]]
def sortie_pretty(tab_rep)
    tab_rep.each { |v|
    puts "Chemin : #{v[0]}, Nombre de fichiers : #{v[1]}, Taille totale des fichiers : #{v[2]}}"
    }
end