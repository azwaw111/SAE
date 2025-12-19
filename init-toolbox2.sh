#!/bin/bash

# Vérification et compilation des binaires

# Liste des binaires à vérifier
for bin in decipher findkey; do

    # Si le binaire n'existe pas
    if [ ! -x "$bin" ]; then
        echo "Binaire $bin manquant, compilation..."

        # 10 : fichier source manquant
        if [ ! -f "src/$bin.c" ]; then
            echo "Erreur : fichier source $bin.c introuvable"
            exit 10
        fi

        # 11 : compilateur absent
        if ! command -v gcc >/dev/null 2>&1; then
            echo "Erreur : compilateur gcc indisponible"
            exit 11
        fi

        # Compilation via Makefile si présent
        if [ -f "src/Makefile" ]; then
            echo "Compilation via Makefile..."
            (cd src && make "$bin" >/dev/null 2>&1)
            status=$?

            # Déplacer le binaire si généré dans src/
            if [ -f "src/$bin" ]; then
                mv "src/$bin" .
            fi
        else
            # Compilation manuelle
            echo "Compilation manuelle..."
            gcc "src/$bin.c" -o "$bin"
            status=$?
        fi

        # 12 : compilation échouée
        if [ $status -ne 0 ]; then
            echo "Erreur : compilation de $bin échouée"
            exit 12
        fi

        echo "Binaire $bin compilé avec succès."
    else
        echo "Binaire $bin déjà présent."
    fi

done

# PARTIE ORIGINALE

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
        echo "Erreur : impossible de créer le fichier";
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
