require('./scan')
require('./manipule')
require('./detect_doub')

# Calcul des propriétés du répertoire de tête et de chacun de ses sous-répertoires
# Produit le hash liste_rep, contenant les propriétés pour chacun des chemins de répertoire
r = Scan::Repertoire_de_tete.new("/Users/Regis/Desktop/Essais manipulations fichiers photo")
r.liste_complete
# $stdout.puts "#{r.liste_rep}"
r.enter_property_keys
r.liste_rep.each_key { |k|
	rep = Scan::Rep.new(k.to_s, r.property_keys)
	rep.compute_properties
	r.liste_rep[k] = rep.properties
	}

# Production d'un tableau par tri du hash liste_rep 
# par total_size (taille totale des ses fichiers et sous-fichiers)
# On obtient un tableau : [[:chemin1, {file_stat: xxx, total_size: 109678, etc}], [:chemin2, etc]]
l = Manipule::Rep_trie.new(r.liste_rep)
l.tri_par_total_size
# l.rep_trie.each { |e| $stdout.puts "#{e[1][:total_size]} : #{e[0]}" }
$stdout.puts "\n #{l.rep_trie} \n "

# Identifie les doublons par total_size
d = Detect_doub::Doublon.new(l.rep_trie)
$stdout.puts d.doublons

