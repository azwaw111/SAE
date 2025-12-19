#!/bin/bash
# ==============================
# Configuration
# ==============================
TOOLBOX=".sh-toolbox"
ARCHIVES_FILE="$TOOLBOX/archives"
TMP="/tmp/restore-work"
DEST="$1"

# ==============================
# Vérifications initiales
# ==============================
[ -z "$DEST" ] && { echo "[!] Dossier destination manquant"; exit 2; }
[ ! -d "$TOOLBOX" ] && { echo "[!] Dossier .sh-toolbox absent"; exit 1; }
mkdir -p "$DEST" || { echo "[!] Impossible de créer $DEST"; exit 2; }

# CRITIQUE : Forcer les permissions de TOUT le dossier destination
chmod -R u+rwx "$DEST" 2>/dev/null

echo "=== Restauration archive ==="

# ==============================
# Choix de l'archive
# ==============================
archives=($(ls "$TOOLBOX"/*.tar.gz 2>/dev/null))
[ ${#archives[@]} -eq 0 ] && { echo "[!] Aucune archive"; exit 4; }

echo "Archives disponibles :"
for i in "${!archives[@]}"; do
    echo "$((i+1))) $(basename ${archives[$i]})"
done

read -p "Numero de l'archive : " n </dev/tty
ARCHIVE="${archives[$((n-1))]}"
[ -z "$ARCHIVE" ] && exit 4
echo "[*] Archive choisie : $(basename "$ARCHIVE")"

# ==============================
# Extraction
# ==============================
rm -rf "$TMP"
mkdir -p "$TMP"
echo "[*] Extraction de l'archive..."
tar -xzf "$ARCHIVE" -C "$TMP" || exit 4

# ==============================
# Détection timestamp attaque
# ==============================
LOG="$TMP/var/log/auth.log"
[ ! -f "$LOG" ] && { echo "[!] auth.log manquant"; exit 4; }

echo "[*] Recherche du timestamp de l'attaque..."
LAST=$(grep "Accepted" "$LOG" | grep admin | tail -n 1)
ANNEE=$(date +%Y)
TS=$(date -d "$(echo "$LAST" | awk -v a="$ANNEE" '{print $1" "$2" "a" "$3}')" +%s)
echo "[*] Timestamp attaque : $TS ($(date -d "@$TS"))"

# ==============================
# Recherche d'un couple clair/chiffré
# ==============================
echo "[*] Recherche d'un couple clair / chiffré..."
PAIR_C=""
PAIR_E=""

for f in $(find "$TMP/data" -type f); do
    [ "$(date -r $f +%s)" -ge "$TS" ] || continue
    base=$(basename "$f")
    size=$(stat -c %s "$f")
    
    for g in $(find "$TMP/data" -type f); do
        [ "$(date -r "$g" +%s)" -lt "$TS" ] || continue
        [ "$(basename "$g")" = "$base" ] || continue
        [ "$(stat -c %s "$g")" = "$size" ] || continue
        PAIR_C="$g"
        PAIR_E="$f"
        break 2
    done
done

[ -z "$PAIR_C" ] && { echo "[!] Aucun couple trouvé"; exit 4; }
echo "[*] Couple trouvé :"
echo "    Clair    : $PAIR_C"
echo "    Chiffré  : $PAIR_E"

# ==============================
# Recherche de la clé
# ==============================
echo "[*] Encodage Base64 pour findkey..."
base64 "$PAIR_C" > "$TMP/clair.b64"
base64 "$PAIR_E" > "$TMP/chiffre.b64"

# Récupération de la clé en Base64 sur stdout
CLE_B64=$(./findkey "$TMP/clair.b64" "$TMP/chiffre.b64" 2>/dev/null)
[ -z "$CLE_B64" ] && { echo "[!] Clé introuvable"; exit 4; }
echo "[*] Clé trouvée (Base64) : $CLE_B64"

# ==============================
# Détection du type de clé
# ==============================
echo "[*] Détection du type de clé..."

CLE_BRUTE=$(echo "$CLE_B64" | base64 -d -w 0 2>/dev/null)
[ -z "$CLE_BRUTE" ] && { echo "[!] Erreur décodage clé"; exit 4; }

if echo "$CLE_BRUTE" | grep -qP '^[\x20-\x7E\x09\x0A\x0D]*$'; then
    echo "[*] Type de clé : texte imprimable"
    echo "[*] Clé décodée : $CLE_BRUTE"
else
    echo "[*] Type de clé : binaire"
fi
# ==============================
# Décision scénario client
# ==============================
ARCHIVE_NAME=$(basename "$ARCHIVE")

if [[ "$ARCHIVE_NAME" == client1-* ]]; then
    KEY_TYPE="s"
else
    KEY_TYPE="f"
fi
# ==============================
# Stockage dans archives
# ==============================
dateRestore=$(date +%Y%m%d-%H%M%S)
sed -i "/^$ARCHIVE_NAME:/d" "$ARCHIVES_FILE" 2>/dev/null

if [ "$KEY_TYPE" = "s" ]; then
    echo "$ARCHIVE_NAME:$dateRestore:$CLE_BRUTE:s" >> "$ARCHIVES_FILE" || exit 3
    echo "[*] Clé stockée dans $ARCHIVES_FILE"
else
    keyDir="$TOOLBOX/${ARCHIVE_NAME%.tar.gz}"
    mkdir -p "$keyDir"   
    ./findkey "$TMP/clair.b64" "$TMP/chiffre.b64" -o "$keyDir/KEY" || exit 3
    echo "$ARCHIVE_NAME:$dateRestore::f" >> "$ARCHIVES_FILE" || exit 3
    echo "[*] Clé stockée dans $keyDir/KEY"
fi

# ==============================
# Restauration des fichiers
# ==============================
echo "[*] Début restauration..."

while read -r f; do
    rel="${f#$TMP/}"
    cible="$DEST/$rel"
    
    # Création du répertoire parent
    dir_parent="$(dirname "$cible")"
    mkdir -p "$dir_parent"
    
    # CORRECTION : Forcer les permissions du chemin complet
    # On remonte l'arborescence depuis $DEST jusqu'au répertoire parent
    chemin="$DEST"
    IFS='/' read -ra PARTS <<< "${dir_parent#$DEST/}"
    for part in "${PARTS[@]}"; do
        chemin="$chemin/$part"
        chmod u+rwx "$chemin" 2>/dev/null
    done
    
    # Vérification des permissions avant restauration
    PROPRIETAIRE=$(stat -c %U "$f")
    DROITS_SYMBOLIQUES=$(stat -c %A "$f")

    # Si le propriétaire n'est pas "admin" et que le fichier est protégé en écriture pour groupe/autres, on l'épargne
    if [ "$PROPRIETAIRE" != "admin" ] && \
       [[ "${DROITS_SYMBOLIQUES:5:1}" != "w" && "${DROITS_SYMBOLIQUES:8:1}" != "w" ]]; then
        echo "[*] Fichier épargné (propriétaire non admin ou pas d'écriture groupe/autres) : $f"
        continue  # Passe au fichier suivant sans restauration
    fi
    
    # Vérification si fichier existant
    if [ -f "$cible" ]; then
        # Forcer permission sur le fichier existant AVANT de demander
        chmod u+rw "$cible" 2>/dev/null
        read -p "Ecraser $rel ? (y/n) " r </dev/tty
        [ "$r" != "y" ] && { echo "[!] $rel ignoré"; continue; }
    fi
    
    # Fichier chiffré ou non
    if [ "$(date -r "$f" +%s)" -ge "$TS" ]; then
        echo "[*] Déchiffrement : $rel"
        base64 "$f" > "$TMP/in.b64"
        ./decipher "$CLE_B64" "$TMP/in.b64"
        base64 -d "$TMP/in.b64" > "$cible" || { echo "[!] Erreur écriture $cible"; exit 4; }
        chmod u+rw "$cible" 2>/dev/null
    else
        echo "[*] Copie : $rel"
        cp "$f" "$cible" || { echo "[!] Erreur copie vers $cible"; exit 4; }
        chmod u+rw "$cible" 2>/dev/null
    fi
    
    echo "[ok] $rel"
done < <(find "$TMP/data" -type f)

# ==============================
# Nettoyage
# ==============================
rm -rf "$TMP"
echo "[*] Restauration terminée"
exit 0
