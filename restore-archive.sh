#!/bin/bash
# restore-archive.sh
# Script de restauration d’archives chiffrées


# QUESTION 1: Vérifier la présence du dossier .sh-toolbox
if [ ! -d ".sh-toolbox" ]; then
    echo "Erreur : le dossier .sh-toolbox est introuvable."
    exit 1
fi

# QUESTION 1: Vérifier l’argument (dossier destination)
if [ $# -ne 1 ]; then
    echo "Usage : $0 <dossier_destination>"
    exit 1
fi

DEST="$1"

# QUESTION 1: Créer le dossier de destination si nécessaire
if [ ! -d "$DEST" ]; then
    mkdir -p "$DEST"
    if [ $? -ne 0 ]; then
        echo "Erreur : impossible de créer le dossier de destination."
        exit 2
    fi
fi

echo "Environnement initialisé."
echo "Dossier de destination : $DEST"
echo

# QUESTION 2: Demander à l’utilisateur quelle archive restaurer
echo "Archives disponibles :"
ls .sh-toolbox/*.tar.gz 2>/dev/null | sed 's#.sh-toolbox/##'

echo -n "Archive à restaurer : "
read ARCHIVE

# Vérifier que l’archive existe physiquement
if [ ! -f ".sh-toolbox/$ARCHIVE" ]; then
    echo "Erreur : l’archive '$ARCHIVE' est introuvable."
    exit 4
fi

# QUESTION 3: Vérifier que l’archive est enregistrée dans le fichier archives
ARCHIVES_FILE=".sh-toolbox/archives"

if [ ! -f "$ARCHIVES_FILE" ]; then
    echo "Erreur : fichier archives introuvable."
    exit 3
fi

LINE=$(grep "^$ARCHIVE:" "$ARCHIVES_FILE")

if [ -z "$LINE" ]; then
    echo "Erreur : l’archive n’est pas enregistrée dans archives."
    exit 3
fi

ARCH_KEY=$(echo "$LINE" | cut -d':' -f3)
ARCH_TYPE=$(echo "$LINE" | cut -d':' -f4)

echo "Type de clé : $ARCH_TYPE"
echo

# QUESTION 3: Extraire l’archive dans un dossier temporaire
TMPDIR=$(mktemp -d)

tar -xzf ".sh-toolbox/$ARCHIVE" -C "$TMPDIR"
if [ $? -ne 0 ]; then
    echo "Erreur : extraction de l’archive impossible."
    exit 4
fi

echo "Archive extraite dans : $TMPDIR"
echo

# QUESTION 3: Détecter les fichiers chiffrés
ENCRYPTED_FILES=$(find "$TMPDIR" -type f -name "*.enc")

if [ -z "$ENCRYPTED_FILES" ]; then
    echo "Aucun fichier chiffré trouvé."
    exit 4
fi

echo "Fichiers chiffrés détectés :"
echo "$ENCRYPTED_FILES"
echo

# QUESTION 4: Appeler findkey pour retrouver la clé
KEYDIR=".sh-toolbox/$(basename "$ARCHIVE" .tar.gz)"

if [ "$ARCH_TYPE" = "f" ]; then
    mkdir -p "$KEYDIR"
    KEYFILE="$KEYDIR/KEY"
else
    KEYFILE="/tmp/KEY_$$"
fi

./findkey ".sh-toolbox/$ARCHIVE" -o "$KEYFILE"
if [ $? -ne 0 ]; then
    echo "Erreur : findkey a échoué."
    exit 4
fi

KEY=$(cat "$KEYFILE")

echo "Clé récupérée."
echo

# QUESTION 5: Mettre à jour le fichier archives avec la nouvelle clé
NEWLINE="$ARCHIVE:$(date +%Y%m%d-%H%M%S):$KEY:$ARCH_TYPE"

sed -i "s|^$ARCHIVE:.*|$NEWLINE|" "$ARCHIVES_FILE"
if [ $? -ne 0 ]; then
    echo "Erreur : mise à jour du fichier archives impossible."
    exit 3
fi

echo "Fichier archives mis à jour."
echo

# QUESTION 6: Déchiffrer les fichiers avec decipher
for FILE in $ENCRYPTED_FILES; do
    REL_PATH="${FILE#$TMPDIR/}"
    OUT_PATH="$DEST/$REL_PATH"
    OUT_DIR=$(dirname "$OUT_PATH")

    mkdir -p "$OUT_DIR"

    if [ -f "$OUT_PATH" ]; then
        echo -n "Le fichier $OUT_PATH existe déjà. Écraser ? (o/n) "
        read REP
        if [ "$REP" != "o" ]; then
            echo "Fichier ignoré."
            continue
        fi
    fi

    ./decipher "$FILE" "$OUT_PATH" "$KEY"
    if [ $? -ne 0 ]; then
        echo "Erreur : déchiffrement impossible pour $FILE"
        exit 4
    fi


    echo "Fichier restauré : $OUT_PATH"
done

# QUESTION 6: Nettoyage final
rm -rf "$TMPDIR"

if [ "$ARCH_TYPE" = "s" ]; then
    rm -f "$KEYFILE"
fi

echo
echo "Restauration terminée avec succès."
exit 0
