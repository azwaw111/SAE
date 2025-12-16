check-archive.sh                                                                                                                                                                                                                                                                                                      
#!/bin/bash

DOSSIER_TOOLBOX=".sh-toolbox"
FICHIER_INVENTAIRE="$DOSSIER_TOOLBOX/archives"
DOSSIER_TEMPORAIRE="/tmp/analyse-toolbox"

DOSSIER_LOGS_RELATIF="var/log/auth.log"
DOSSIER_DONNEES_RELATIF="data"

FICHIERS_MODIFIES=()
FICHIERS_EPARGNES=()

echo "=== Vérification de l’environnement ==="
if [ ! -d "$DOSSIER_TOOLBOX" ]; then
    echo "Erreur (1) : Dossier $DOSSIER_TOOLBOX manquant."
    exit 1
fi



if [ ! -f "$FICHIER_INVENTAIRE" ]; then
    echo "Erreur (2) : Fichier d’inventaire absent."
    exit 2
fi

echo ""
echo "=== Sélection de l’archive ==="
echo "Archives disponibles :"

for fichier in "$DOSSIER_TOOLBOX"/*.tar.gz; do
    [ -e "$fichier" ] && echo "  - $(basename "$fichier")"
done

read -p "Nom exact de l’archive à analyser : " ARCHIVE_CHOISIE
CHEMIN_ARCHIVE="$DOSSIER_TOOLBOX/$ARCHIVE_CHOISIE"

if [ ! -f "$CHEMIN_ARCHIVE" ]; then
    echo "Erreur (2) : Archive '$ARCHIVE_CHOISIE' introuvable."
    exit 2
fi

echo ""
echo "=== Décompression de l’archive ==="
rm -rf "$DOSSIER_TEMPORAIRE"
mkdir -p "$DOSSIER_TEMPORAIRE"

if ! tar -xzf "$CHEMIN_ARCHIVE" -C "$DOSSIER_TEMPORAIRE"; then
    echo "Erreur (3) : Impossible de décompresser."
    exit 3
fi

echo "Décompression réussie."

echo ""
echo "=== Analyse des journaux ==="
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

echo "Dernière connexion admin :"
echo "$DERNIERE_CONNEXION_ADMIN"

ANNEE_COURANTE=$(date +%Y)
DATE_CONNEXION=$(echo "$DERNIERE_CONNEXION_ADMIN" | awk -v annee="$ANNEE_COURANTE" '{print $1" "$2" "annee" "$3}')
TIMESTAMP_INTRUSION=$(date -d "$DATE_CONNEXION" +%s)

echo "Intrusion estimée : $DATE_CONNEXION"
echo "Référence timestamp : $TIMESTAMP_INTRUSION"

echo ""
echo "=== Classification des fichiers ==="
CHEMIN_DONNEES="$DOSSIER_TEMPORAIRE/$DOSSIER_DONNEES_RELATIF"

if [ ! -d "$CHEMIN_DONNEES" ] || [ -z "$(ls -A "$CHEMIN_DONNEES")" ]; then
    echo "Erreur (5) : Dossier data absent ou vide."
    rm -rf "$DOSSIER_TEMPORAIRE"
    exit 5
fi

while read -r FICHIER; do
    TIMESTAMP_FICHIER=$(date -r "$FICHIER" +%s)

    if [ "$TIMESTAMP_FICHIER" -gt "$TIMESTAMP_INTRUSION" ]; then
        FICHIERS_MODIFIES+=("$FICHIER")
    else
        PROPRIETAIRE=$(stat -c %U "$FICHIER")
        DROITS_SYMBOLIQUES=$(stat -c %A "$FICHIER")

        if [ "$PROPRIETAIRE" != "admin" ] && ! echo "$DROITS_SYMBOLIQUES" | grep -q 'w'; then
            FICHIERS_EPARGNES+=("$FICHIER")
        fi
    fi
done < <(find "$CHEMIN_DONNEES" -type f)

echo ""
echo "▶ Fichiers modifiés :"
if [ ${#FICHIERS_MODIFIES[@]} -eq 0 ]; then
    echo "  Aucun fichier modifié."
else
    for f in "${FICHIERS_MODIFIES[@]}"; do
        echo "  [MODIFIÉ] ${f#$DOSSIER_TEMPORAIRE/}"µ
        ls -l "$f"
    done
fi

echo ""
echo "▶ Fichiers épargnés :"
if [ ${#FICHIERS_EPARGNES[@]} -eq 0 ]; then
    echo "  Aucun fichier épargné."
else
    for f in "${FICHIERS_EPARGNES[@]}"; do
        echo "  [ÉPARGNÉ] ${f#$DOSSIER_TEMPORAIRE/}"
    done
fi

echo ""
echo "=== Recherche de duplicatas intacts ==="
trouve=0
for fichier_modifie in "${FICHIERS_MODIFIES[@]}"; do
    nom_modifie=$(basename "$fichier_modifie")
    taille_modifie=$(stat -c %s "$fichier_modifie")

    for fichier_epargne in "${FICHIERS_EPARGNES[@]}"; do
        nom_epargne=$(basename "$fichier_epargne")
        taille_epargne=$(stat -c %s "$fichier_epargne")

        if [ "$nom_modifie" = "$nom_epargne" ] && [ "$taille_modifie" -eq "$taille_epargne" ]; then
            echo "  [ORIGINAL] $nom_epargne ($taille_epargne octets)"
            trouve=1
        fi
    done
done

[ "$trouve" -eq 0 ] && echo "  Aucun duplicata trouvé."

echo ""
echo "=== Nettoyage ==="
rm -rf "$DOSSIER_TEMPORAIRE"
echo "Analyse terminée."

exit 0
