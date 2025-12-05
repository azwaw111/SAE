#!/bin/bash
# Vérifier qu'un paramètre est passé
if [ $# -ne 1 ]; then
        echo "Erreur : vous n'avez pas passé de parametres"
        exit 2
fi

# Vérifier que le dossier .sh-toolbox existe
if [ ! -d ".sh-toolbox" ]; then
        echo "Erreur le dossier .sh-toolbox n'existe pas"
        exit 1
fi
# Vérifier que l'archive existe au chemin donné
if [ ! -f "$1" ]; then
    echo "Erreur : L'archive $1 n'existe pas"
    exit 2
fi

# Récupérer le nom de l'archive
nom_archive=$(basename "$1")

# Vérifier si un fichier du même nom existe déjà
if [ -f ".sh-toolbox/$nom_archive" ]; then
        echo "Le fichier $nom_archive existe déja"
        read -p "Voulez-vous écraser le fichier? y/n" reponse
        if [ "$reponse" = "y" ]; then
                cp "$1" ".sh-toolbox/$nom_archive"
                if [ $? -ne 0 ]; then
                        echo "Erreur : problème lors de la copie"
                        exit 3
                fi
                echo "Le fichier $nom_archive a été écrasé avec succès."
              
        else
                echo "Copie annulée"
                exit 0
        fi
else
        echo "Aucun fichier nommé $nom_archive dans .sh-toolbox"
        echo "Copie de l'archive en cours..."
        cp "$1" ".sh-toolbox/$nom_archive"
        # Vérifier si la copie a réussi
    if [ $? -ne 0 ]; then # $? c'est le code de retour de la derniere commande si 0=succés
        echo "Erreur : problème lors de la copie"
        exit 3
    fi

    echo "Archive copiée avec succès dans .sh-toolbox"
fi
# Mise à jour du fichier archives
ARCHIVES=".sh-toolbox/archives"
if [ ! -f "$ARCHIVES" ]; then
        echo "0" > "$ARCHIVES"
fi
#Lire le compteur actuel (premiere ligne)
count=$(head -n 1 "$ARCHIVES")
count=$((count+1))
#Générer la date au format yyyymmdd-hhmmss
date=$(date +"%Y%m%d-%H%M%S")
# Mettre à jour le fichier archives :
# - première ligne = nouveau compteur
# - conserver les anciennes lignes (sauf la première)
# - ajouter la nouvelle entrée
{
        echo "$count"
        tail -n +2 "$ARCHIVES"
        echo "$nom_archive:$date:"
} > "$ARCHIVES.tmp" && mv "$ARCHIVES.tmp" "$ARCHIVES"

#vérifier si la mise a jour a réussi
if [ $? -ne 0 ]; then
    echo "Erreur : problème lors de la mise à jour du fichier archives"
    exit 4
fi
echo "Le fichier archives a été mis à jour."
exit 0
