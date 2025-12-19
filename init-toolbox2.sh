#!/bin/bash

###############################################
# 1. Initialisation du dossier .sh-toolbox
###############################################

# Vérifier si le dossier existe
if [ ! -d ".sh-toolbox" ]; then
    mkdir ".sh-toolbox"
    if [ "$?" -ne 0 ]; then
        echo "Erreur : impossible de créer le dossier .sh-toolbox"
        exit 1
    fi
    echo "Dossier .sh-toolbox créé"
else
    echo "Le dossier .sh-toolbox existe déjà"
fi

# Vérifier si le fichier archives existe
if [ ! -f ".sh-toolbox/archives" ]; then
    echo 0 > ".sh-toolbox/archives"
    if [ "$?" -ne 0 ]; then
        echo "Erreur : impossible de créer le fichier archives"
        exit 1
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

###############################################
# 2. Vérification et compilation des binaires
###############################################

SRC_DIR="src"
BIN_DEC="decipher"
BIN_FIND="findkey"
SRC_DEC="$SRC_DIR/decipher.c"
SRC_FIND="$SRC_DIR/findkey.c"

# Vérifier la présence des fichiers sources
if [ ! -f "$SRC_DEC" ] || [ ! -f "$SRC_FIND" ]; then
    echo "Erreur : fichiers sources manquants dans src/"
    exit 10
fi

# Vérifier la présence du compilateur
if ! command -v gcc >/dev/null 2>&1; then
    echo "Erreur : compilateur gcc indisponible"
    exit 11
fi

# Fonction de compilation
compile_binary() {
    local src="$1"
    local out="$2"

    echo "Compilation de $out..."
    gcc "$src" -o "$out"
    if [ "$?" -ne 0 ]; then
        echo "Erreur : échec de compilation pour $out"
        exit 12
    fi
    echo "Binaire $out compilé avec succès"
}

# Compiler decipher si absent
if [ ! -x "$BIN_DEC" ]; then
    compile_binary "$SRC_DEC" "$BIN_DEC"
else
    echo "Binaire decipher déjà présent"
fi

# Compiler findkey si absent
if [ ! -x "$BIN_FIND" ]; then
    compile_binary "$SRC_FIND" "$BIN_FIND"
else
    echo "Binaire findkey déjà présent"
fi

###############################################
# 3. Fin du script
###############################################

echo "Initialisation réussie"
exit 0
