#!/bin/bash

# Vérifier si le dossier existe
if [ ! -d ".sh-toolbox" ]; then
    mkdir ".sh-toolbox" 
    if [ "$?" -ne 0 ] ; then 
        echo "Erreur : impossible de créer le dossier";
        exit 1;
    fi
    echo "Dossier .sh-toolbox créé"
else
    echo "Le dossier .sh-toolbox existe déjà"
fi

# Vérifier si le fichier existe
if [ ! -f ".sh-toolbox/archives" ]; then
    echo 0 > ".sh-toolbox/archives"
    if [ "$?" -ne 0 ] ; then 
        echo "Erreur : impossible de créer le dossier";
        exit 1;
    fi
    echo "Fichier archives créé"
else
    echo "Le fichier archives existe déjà"
fi
# Vérifier que le dossier contient uniquement archives
contenu=$(ls -A .sh-toolbox)
if [ "$contenu" != "archives" ]; then
    echo "Erreur : le dossier .sh-toolbox contient autre chose que le fichier archives"
    exit 2
fi

echo "Initialisation réussie"
exit 0
