#!/bin/bash

# 1. Vérifier le dossier
if [ ! -d ".sh-toolbox" ]; then
    echo "Problème : le dossier .sh-toolbox est manquant."
    read -p "Voulez-vous le recréer ? (oui/non) " rep
    if [ "$rep" = "oui" ]; then
        if ! mkdir ".sh-toolbox"; then
            echo "Erreur : impossible de créer .sh-toolbox"
            exit 1
        fi
        echo "Dossier recréé."
    fi
fi

# 2. Vérifier le fichier archives
if [ ! -f ".sh-toolbox/archives" ]; then
    echo "Problème : le fichier archives est manquant."
    read -p "Voulez-vous le recréer ? (oui/non) " rep
    if [ "$rep" = "oui" ]; then
        if ! echo 0 > ".sh-toolbox/archives"; then
            echo "Erreur : impossible de créer archives"
            exit 2
        fi
        echo "Fichier archives recréé."
    fi
fi

# 3. Vérifier les archives mentionnées
tail -n +2 ".sh-toolbox/archives" | while IFS=: read -r archive_name date key; do
    [ -z "$archive_name" ] && continue
    if [ ! -f ".sh-toolbox/$archive_name" ]; then
        echo "Problème : l’archive $archive_name est mentionnée mais absente."
        read -p "Voulez-vous supprimer cette entrée ? (oui/non) " rep
        if [ "$rep" = "oui" ]; then
            grep -v "^$archive_name:" ".sh-toolbox/archives" > ".sh-toolbox/archives.tmp"
            mv ".sh-toolbox/archives.tmp" ".sh-toolbox/archives"
            echo "Entrée supprimée."
        fi
    fi
done

# 4. Vérifier les archives présentes mais non mentionnées
for file in .sh-toolbox/*.tar.gz; do
    [ -e "$file" ] || continue
    archive_name=$(basename "$file")
    if ! grep -q "^$archive_name:" ".sh-toolbox/archives"; then
        echo "Problème : l’archive $archive_name est présente mais non mentionnée."
        read -p "Voulez-vous l’ajouter ? (oui/non) " rep
        if [ "$rep" = "oui" ]; then
            date_ajout=$(date +"%Y%m%d-%H%M%S")
            echo "$archive_name:$date_ajout:" >> ".sh-toolbox/archives"
            echo "Entrée ajoutée."
        fi
    fi
done

# 5. Mise à jour du compteur
count=$(tail -n +2 ".sh-toolbox/archives" | wc -l)
sed -i "1s/.*/$count/" ".sh-toolbox/archives"
echo "Compteur mis à jour : $count"

exit 0
