#!/bin/bash
#0 Vérifications
# Vérifier si le dossier .sh-toolbox existe
if [ ! -d ".sh-toolbox" ]; then
  echo "Erreur: dossier .sh-toolbox manquant"
  exit 1
fi
# Vérifier si le fichier archives existe
if [ ! -f ".sh-toolbox/archives" ]; then
  echo "Erreur: fichier archives manquant"
  exit 2
fi


#1. Proposer la liste des archives disponibles
echo "Archives disponibles :"
ls .sh-toolbox
read -p "Sélectionnez une archive : " archive

if [ ! -f ".sh-toolbox/$archive" ]; then
    echo "Erreur : l'archive $archive est introuvable"
    exit 2
fi




# 2. Décompresser l’archive dans un dossier temporaire
rm -rf "/tmp/toolbox-check"
mkdir -p "/tmp/toolbox-check"

# On tente la décompression de l’archive choisie
# Si la commande échoue, on affiche un message et on quitte avec le code 3
if ! tar -xzf ".sh-toolbox/$archive" -C "/tmp/toolbox-check"; then
    echo "Erreur : la décompression a échoué"
    exit 3
fi




#3 : Parcourir le fichier des logs

logfile="/tmp/toolbox-check/var/log/auth.log"

# Vérifier si le fichier existe
if [ ! -f "$logfile" ]; then
    echo "Erreur : fichier des logs manquant"
    exit 4
fi

# Si le fichier existe, on peut le parcourir
echo "Fichier des logs trouvé : $logfile"
echo "Contenu (premières lignes) :"
head -n 10 "$logfile"


#4 : Dernière connexion de l’utilisateur admin

last_cnx=$(grep "admin" "$logfile" | tail -n 1)

# Vérifier si une connexion a été trouvée
if [ -z "$last_cnx" ]; then
    echo "Erreur : aucune connexion admin trouvée dans les logs"
    exit 4
fi

# Afficher la ligne complète
echo "Dernière connexion de l’utilisateur admin :"
echo "$last_cnx"

# Extraire la date et l’heure
last_date=$(echo "$last_cnx" | awk '{print $1,$2,$3}')
echo "Date et heure de la dernière connexion : $last_date"
# Exemple : "Dec 5 00:12:34"


#5 : Fichiers modifiés après la dernière connexion admin
# Convertir la date en seconds
last_timestamp=$(date -d "$last_date" +%s)

# Parcourir tous les fichiers du dossier data/
for file in /tmp/toolbox-check/data/*; do
    # Récupérer la date de modification du fichier en timestamp
    file_timestamp=$(date -r "$file" +%s)

    # Comparer avec la date de la dernière connexion
    if [ "$file_timestamp" -gt "$last_timestamp" ]; then
        echo "Fichier modifié après la dernière connexion admin : $file"
    fi
done




#6 : Fichiers non modifiés mais identiques en nom et taille

for file in /tmp/toolbox-check/data/*; do
    file_timestamp=$(date -r "$file" +%s)

    # Vérifier si le fichier est modifié après la connexion
    if [ "$file_timestamp" -gt "$last_timestamp" ]; then
        # Récupérer le nom et la taille du fichier modifié
        filename=$(basename "$file")
        filesize=$(stat -c %s "$file")

        # Chercher les fichiers non modifiés avec même nom et taille
        for other in /tmp/toolbox-check/data/*; do
            other_timestamp=$(date -r "$other" +%s)
            other_name=$(basename "$other")
            other_size=$(stat -c %s "$other")

            if [ "$other_timestamp" -le "$last_timestamp" ] && \
               [ "$other_name" = "$filename" ] && \
               [ "$other_size" -eq "$filesize" ]; then
                echo "Fichier non modifié correspondant : $other"
            fi
        done
    fi
done

##################################

#!/bin/bash
# ============================
# Script : verifier-archive.sh
# ============================

# 0. Vérifications préliminaires
if [ ! -d ".sh-toolbox" ]; then
  echo "Erreur: dossier .sh-toolbox manquant"
  exit 1
fi

if [ ! -f ".sh-toolbox/archives" ]; then
  echo "Erreur: fichier archives manquant"
  exit 2
fi

# 1. Proposer la liste des archives disponibles
echo "=== Archives disponibles ==="
for f in .sh-toolbox/*.tar.gz; do
    echo "$(basename "$f")"
done

read -p "Sélectionnez une archive (nom complet) : " archive

if [ ! -f ".sh-toolbox/$archive" ]; then
    echo "Erreur : l'archive $archive est introuvable"
    exit 2
fi

# 2. Décompresser l’archive dans un dossier temporaire
rm -rf "/tmp/toolbox-check"
mkdir -p "/tmp/toolbox-check"

if ! tar -xzf ".sh-toolbox/$archive" -C "/tmp/toolbox-check"; then
    echo "Erreur : la décompression a échoué"
    exit 3
fi

# 3. Vérifier le fichier des logs
fichier_log="/tmp/toolbox-check/var/log/auth.log"
if [ ! -f "$fichier_log" ]; then
    echo "Erreur : fichier des logs manquant"
    exit 4
fi

# 4. Dernière connexion de l’utilisateur admin
derniere_ligne=$(grep "admin" "$fichier_log" | grep "Accepted" | tail -n 1)
if [ -z "$derniere_ligne" ]; then
    echo "Erreur : aucune connexion admin trouvée"
    exit 4
fi

echo "Dernière connexion admin :"
echo "$derniere_ligne"

# Extraire la date et l’heure (ajout de l’année courante)
annee=$(date +%Y)
derniere_date=$(echo "$derniere_ligne" | awk -v annee="$annee" '{print $1" "$2" "annee" "$3}')
echo "Date et heure : $derniere_date"

timestamp_connexion=$(date -d "$derniere_date" +%s)

# 5. Vérifier le dossier data
dossier_data="/tmp/toolbox-check/data"
if [ ! -d "$dossier_data" ] || [ -z "$(ls -A "$dossier_data")" ]; then
    echo "Erreur : dossier data absent ou vide"
    exit 5
fi

# 6. Fichiers modifiés après la dernière connexion
echo "=== Fichiers modifiés après la connexion ==="
fichiers_modifies=()
for fichier in "$dossier_data"/*; do
    ts_fichier=$(date -r "$fichier" +%s)
    if [ "$ts_fichier" -gt "$timestamp_connexion" ]; then
        echo "Fichier modifié : $fichier"
        fichiers_modifies+=("$fichier")
    fi
done

# 7. BONUS – Fichiers identiques non modifiés
echo "=== Fichiers intacts identiques ==="
for fichier_modifie in "${fichiers_modifies[@]}"; do
    nom_fichier=$(basename "$fichier_modifie")
    taille_fichier=$(stat -c %s "$fichier_modifie")

    for autre in "$dossier_data"/*; do
        ts_autre=$(date -r "$autre" +%s)
        nom_autre=$(basename "$autre")
        taille_autre=$(stat -c %s "$autre")

        if [ "$ts_autre" -le "$timestamp_connexion" ] && \
           [ "$nom_autre" = "$nom_fichier" ] && \
           [ "$taille_autre" -eq "$taille_fichier" ]; then
            echo "Fichier intact identique : $autre"
        fi
    done
done

# 8. Fin
exit 0









