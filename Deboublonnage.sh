#!/bin/sh

# A partir d'une liste de commandes "diff -q" dans un fichier texte, les faire tourner pour faire les comparaisons entre répertoires réputés doublons
# $1 est le fichier contenant les commandes "diff -q" générées par Ruby 
run_diff() {
    grep "^diff.*" "$1" > Temp/commandes_seules # sélectionne les lignes commençant par diff, les met dans le fichier commandes_seules
    echo "Résultat des commandes diff -q\n" > resultats_diff
    while read line
    do
        echo "\n" >> resultats_diff
        eval "$line" >> resultats_diff
        echo "\n" >> resultats_diff
    done < Temp/commandes_seules # exécute le while pour chaque ligne de commandes_seules
    echo "Terminé"
}
IFS="
" # permet d'éviter les problèmes avec les blancs dans les noms de fichiers
run_diff $1


#Regarder ce code intéressant :
#
#find . -type d | while read file; do echo $file; done
#However, doesn't work if the file-name contains newlines.
#The above is the only solution I know of when you actually want to have the directory name
#in a variable.
#
#If you just want to execute some command, use xargs.
#
#find . -type d -print0 | xargs -0 echo 'The directory is: '
#
#  	 	
#No need for xargs, see find -exec ... {} + –  Charles Duffy Nov 19 '08 at 5:53
	 	
#@Charles: for large numbers of files, xargs is much more efficient:
# it only spawns one process.
# The -exec option forks a new process for each file,
# which can be an order of magnitude slower. –  Adam Rosenfield Nov 19 '08 at 5:54
#	 	
#I like xargs more. These two essentially seem to do the same both,
#while xargs has more options, like running in parallel –  Johannes Schaub - litb Nov 19 '08 at 5:57
#	 	
#Adam, no that '+' one will aggregate as many filenames as possible and then executes.
#but it will not have such neat functions as running in parallel :) –  Johannes Schaub - litb Nov 19 '08 at 5:57
#	 	
#Note that if you want to do something with the filenames, you're going to have to quote them.
#E.g.: find . -type d | while read file; do ls "$file"; done –  David Moles Nov 14 '12 at 19:13
#
#



# VIEUX CODE - remplacé par Ruby
#       ||||||||||||||||
#       vvvvvvvvvvvvvvvv

## On part de 70 k fichiers dans n (plusieurs dizaines) répertoires
## Objectif in fine : deux arborescences de répertoires :
## - la première par année, et pour chaque année, un seul niveau de sous-répertoires
## dont le titre est évocateur (lieu et/ou date et/ou thème). Dans cette arborescence ne figurent que des versions sources
## des fichiers photo (pas de doublon)
## - la seconde par dossiers thématiques (un seul niveau de sous-répertoires /dossiers thématiques/thème n/).
## Chaque fichier de ces dossiers thématiques est le doublon d'un fichier source contenu dans le dossiers Années
#
## Phase 1 : mise de côté des répertoires en doublon
## Etape numéro 1 : lister tous les répertoires avec leur arborescence complète et leur taille totale
## Etape numéro 2 : détecter les répertoires en doublon, ie dont le contenu est identique ;
## les renommer "[Répertoire] - doublonné"
## Etape numéro 3 : indexer les répertoires doublonnés, par groupes de doublons
## Etape numéro 4 : manuellement, choisir dans chaque groupe de doublons un répertoire "source"
## Etape numéro 5 : manuellement, insérer dans un fichier .txt dans le répertoire source le chemin
## des répertoires en doublon du répertoire source, si cela apporte une information utile
## Etape numéro 6 : placer les répertoires en doublon de côté, dans un répertoire "Doublons"
#
## Phase 2 : construire l'architecture cible des répertoires
## (sans doute à faire manuellement)
#
## Phase 3 : dans le répertoire par années, éliminer les doublons de fichiers
#
#
## CODAGE
#
## variables globales
#
#NB_REP=0 # décompte des répertoires
#NB_FICHIERS=0 # décompte des fichiers
#CHEMIN="$PWD"
#
#echo $NB_REP
#echo $NB_FICHIERS
#echo $CHEMIN
#
## infos_rep -- inscrit nom et taille du répertoire
## $1=le répertoire (chemin absolu)
## $2=le fichier de destination
#
#infos_rep() {
#    echo "$1"
#    if [ -e "$1" ] ; then
#        if [ -d  "$1" ] ; then # vérifie que $1 existe et est un répertoire
#        NB_REP="$(expr "$NB_REP" '+' '1')" # incrémente le décompte des répertoires
#        echo "$1" >> $2 # inscrit le nom du répertoire
#        ls -l $("$1") | grep "total.*" | sed 's/total //' >> $2 # capture la taille du répertoire et l'ajoute à la ligne suivante
#        fi
#    fi
#}
#
## liste_rep -- lance infos_rep récursivement pour les sous-répertoires
## $1=le répertoire à scanner
## $2=le fichier de destination
#
#liste_rep() {
#    # save current directory then cd to "$1"
#    pushd "$1" >/dev/null
#    # for each non-hidden (i.e. not starting with .) file/directory...
#    for file in * ; do
#         # run infos_rep if directory name and if it really exists...
#        if [ -e "$file" ] ; then
#            if [ -d "$file" ] ; then
#            infos_rep "$PWD/$file" "$2"
#            fi
#        fi
#        #if directory, go down and list directory contents too
#        test -d "$file" && liste_rep "$file" $2
#    done
#  # restore directory
#  popd >/dev/null
#}  
#    
#    
##    cd "$1"
##    infos_rep "$1" $2
##    for i in * ; do
##        SENTIER="$1/"$i""
##        liste_rep "$SENTIER" $2
##        SENTIER="$1"
##    #    #echo $CHEMIN/"$i"
##    #    #infos_rep "$CHEMIN/"$i"" $1
##    done
##}
#
#liste_rep "$CHEMIN" $1
#echo $NB_REP
#
#
#
#
## Trouvé sur Stackoverflow :
#
##my_ls -- recursively list given directory's contents and subdirectories
## $1=directory whose contents to list
## $2=indentation when listing
##my_ls() {
##  # save current directory then cd to "$1"
##  pushd "$1" >/dev/null
##  # for each non-hidden (i.e. not starting with .) file/directory...
##  for file in * ; do
##    # print file/directory name if it really exists...
##    test -e "$file" && echo "$2$file"
##    # if directory, go down and list directory contents too
##    test -d "$file" && my_ls "$file" "$2  "
##  done
##  # restore directory
##  popd >/dev/null
##}
#
## recursively list files in current
##  directory and subdirectories
##my_ls .
##As an exercise you can think of how to modify the above script to print full paths to files (instead of just indented file/dirnames),
## possibly getting rid of pushd/popd (and of the need for the second parameter $2) in the process.
##
##Remove the test -e "$file" && condition (only leave the echo) and see what happens.
##
##Remove the double-quotes around "$file" and see what happens when the directory
##whose contents you are listing contains filenames with spaces in them.
##Add set -x at the top of the script (or invoke it as sh -x scriptname.sh instead) to turn on debug output
##and see what's happening in detail (to redirect debug output to a file, run sh -x scriptname.sh 2>debugoutput.txt).
##
##To also list hidden files (e.g. .bashrc):
##
##...
##for file in * .?* ; do
##  if [ "$file" != ".." ] ; then
##    test -e ...
##    test -d ...
##  fi
##done
##...
##Note the use of != (string comparison) instead of -ne (numeric comparison.)
##
##Another technique would be to spawn subshells instead of using pushd/popd:
##
##my_ls() {
##  # everything in between roundbrackets runs in a separatly spawned sub-shell
##  (
##    # change directory in sub-shell; does not affect parent shell's cwd
##    cd "$1"
##    for file in ...
##      ...
##    done
##  )
##}
##Note that on some shell implementations there is a hard limit (~4k) on the number of characters which can be passed as an argument to for (or to any builtin, or external command for that matter.) Since the shell expands, inline, * to a list of all matching filenames before actually performing for on it,
##you can run into trouble if * is expanded inside a directory with a lot of files (same trouble you'll run into when running, say ls * in the same directory, e.g. get an error like Command too long.)
#
## Numéro 11 tests avec Test ou son équivalent [ condition ]
## test -d file true if file is directory
#
##if [ -d $1 ] ; then
##    ls .
##else
##    echo "not a directory"
##fi
#
