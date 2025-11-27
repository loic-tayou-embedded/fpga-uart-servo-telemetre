# Fichier .do : script de simulation en langage tcl/tk

### Supprimer la bibliothèque work si elle existe
if {[file exists "work"]} {
    file delete -force work
}

### Créer et mapper la bibliothèque work
vlib work
#vmap work work

# compilation des fichiers vhdl, l'ordre de compilation est important
# commencer par le package (s’il y en a),
# les composants, le top-level et enfin le test-bench

vcom -93 ../src/TELEMETRE.vhd
vcom -93 TELEMETRE_tb.vhd

# lancer la simulation avec le nom du testbench (s’il existe)
# sinon avec le nom du top-level design
# pour chacun des cas précisez le nom de l’entité, pas le nom du fichier
# entre parenthèse vous pouvez préciser le nom de l’architecture

vsim -voptargs="+acc" work.TELEMETRE_tb

# accéder aux signaux internes optimisés : vsim -voptargs="+acc" work.nom_entity

# pour visualiser tous les signaux du design :
view signals
add wave *

### Lancer la simulation complète
run -all

### Fermer proprement la simulation
#quit -sim