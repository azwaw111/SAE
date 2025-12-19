#!/bin/bash

# Variables : 
DOSSIER_TOOLBOX=".sh-toolbox"
FICHIER_INVENTAIRE="$DOSSIER_TOOLBOX/archives"
DOSSIER_TEMPORAIRE="/tmp/analyse-toolbox"

DOSSIER_LOGS_RELATIF="var/log/auth.log"
DOSSIER_DONNEES_RELATIF="data"

FICHIERS_MODIFIES=()
FICHIERS_EPARGNES=()

# 1. Vérification de l’environnement
if [ ! -d "$DOSSIER_TOOLBOX" ]; then
    echo "Erreur (1) : Dossier $DOSSIER_TOOLBOX manquant."
    exit 1
fi

if [ ! -f "$FICHIER_INVENTAIRE" ]; then
    echo "Erreur (2) : Fichier d’inventaire absent."
    exit 2
fi

# 2. Sélection de l’archive 
echo "=== Archives disponibles ==="
ls "$DOSSIER_TOOLBOX" | grep ".tar.gz"
echo "Choisissez une archive à vérifier : "
read ARCHIVE_CHOISIE

CHEMIN_ARCHIVE="$DOSSIER_TOOLBOX/$ARCHIVE_CHOISIE"

if [ ! -f "$CHEMIN_ARCHIVE" ]; then
    echo "Erreur (2) : Archive '$ARCHIVE_CHOISIE' introuvable."
    exit 2
fi

# 3. Décompression
rm -rf "$DOSSIER_TEMPORAIRE"
mkdir -p "$DOSSIER_TEMPORAIRE"

if ! tar -xzf "$CHEMIN_ARCHIVE" -C "$DOSSIER_TEMPORAIRE"; then
    echo "Erreur (3) : Impossible de décompresser."
    exit 3
fi

# 4. Analyse des journaux
CHEMIN_LOG="$DOSSIER_TEMPORAIRE/$DOSSIER_LOGS_RELATIF"

if [ ! -f "$CHEMIN_LOG" ]; then
    echo "Erreur (4) : Fichier de logs absent."
    rm -rf "$DOSSIER_TEMPORAIRE"
    exit 4
fi

DERNIERE_CONNEXION_ADMIN=$(grep "Accepted" "$CHEMIN_LOG" | grep "admin" | tail -n 1)

if [ -z "$DERNIERE_CONNEXION_ADMIN" ]; then
    echo "Erreur (4) : Aucune connexion admin détectée."
    rm -rf "$DOSSIER_TEMPORAIRE"
    exit 4
fi

ANNEE_COURANTE=$(date +%Y)
DATE_CONNEXION=$(echo "$DERNIERE_CONNEXION_ADMIN" | awk -v annee="$ANNEE_COURANTE" '{print $1" "$2" "annee" "$3}')
TIMESTAMP_INTRUSION=$(date -d "$DATE_CONNEXION" +%s)

echo "Dernière connexion admin : $DATE_CONNEXION"

# 5. Classification des fichiers (Logique Script 2)
CHEMIN_DONNEES="$DOSSIER_TEMPORAIRE/$DOSSIER_DONNEES_RELATIF"

if [ ! -d "$CHEMIN_DONNEES" ] || [ -z "$(ls -A "$CHEMIN_DONNEES")" ]; then
    echo "Erreur (5) : Dossier data absent ou vide."
    rm -rf "$DOSSIER_TEMPORAIRE"
    exit 5
fi

while read -r FICHIER; do
    TIMESTAMP_FICHIER=$(date -r "$FICHIER" +%s)

    if [ "$TIMESTAMP_FICHIER" -ge "$TIMESTAMP_INTRUSION" ]; then
        FICHIERS_MODIFIES+=("$FICHIER")
    else
        PROPRIETAIRE=$(stat -c %U "$FICHIER")
        DROITS_SYMBOLIQUES=$(stat -c %A "$FICHIER")

        # Vérifie que le propriétaire n'est pas admin et pas d'écriture groupe/autres
        if [ "$PROPRIETAIRE" != "admin" ] && \
           [[ "${DROITS_SYMBOLIQUES:5:1}" != "w" && "${DROITS_SYMBOLIQUES:8:1}" != "w" ]]; then
            FICHIERS_EPARGNES+=("$FICHIER")
        fi
    fi
done < <(find "$CHEMIN_DONNEES" -type f)

# 6. Affichage des fichiers modifiés :
echo ""
echo "=== Fichiers modifiés (ls -ls) ==="
if [ "${#FICHIERS_MODIFIES[@]}" -eq 0 ]; then
    echo "Aucun fichier modifié trouvé."
else
    for f in "${FICHIERS_MODIFIES[@]}"; do
        ls -ls "$f"
    done
fi

# 7. Recherche de duplicatas :
echo ""
echo "=== Recherche de duplicatas (clair / chiffré) ==="
trouve=0

for fichier_modifie in "${FICHIERS_MODIFIES[@]}"; do
    nom_modifie=$(basename "$fichier_modifie")
    taille_modifie=$(stat -c %s "$fichier_modifie")
    date_modifie=$(stat -c %y "$fichier_modifie")

    for fichier_epargne in "${FICHIERS_EPARGNES[@]}"; do
        nom_epargne=$(basename "$fichier_epargne")
        taille_epargne=$(stat -c %s "$fichier_epargne")

        if [ "$nom_modifie" = "$nom_epargne" ] && [ "$taille_modifie" -eq "$taille_epargne" ]; then

            echo "---------------------------------------------"
            echo "[CHIFFRÉ]"
            echo "  Chemin : ${fichier_modifie#$DOSSIER_TEMPORAIRE/}"
            echo "  Taille : $taille_modifie octets"
            echo "  Modifié: $date_modifie"
            echo ""
            echo "[CLAIR]"
            echo "  Chemin : ${fichier_epargne#$DOSSIER_TEMPORAIRE/}"
            echo "  Taille : $taille_epargne octets"
            echo "---------------------------------------------"
            echo ""

            trouve=1
        fi
    done
done

[ "$trouve" -eq 0 ] && echo "Aucun duplicata trouvé."

echo "Analyse terminée."
exit 0
