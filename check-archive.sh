#!/bin/bash

# 0. Vérifications 
if [ ! -d ".sh-toolbox" ]; then
  echo "Erreur: dossier .sh-toolbox manquant"
  exit 1
fi

if [ ! -f ".sh-toolbox/archives" ]; then
  echo "Erreur: fichier archives manquant"
  exit 2
fi

# 1. Proposer la liste des archives disponibles
echo "Archives disponibles"
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

# . Vérifier le dossier data
dossier_data="/tmp/toolbox-check/data"
if [ ! -d "$dossier_data" ] || [ -z "$(ls -A "$dossier_data")" ]; then
    echo "Erreur : dossier data absent ou vide"
    exit 5
fi

# 5. Fichiers modifiés après la dernière connexion
echo "Fichiers modifiés après la connexion"
fichiers_modifies=()
for fichier in "$dossier_data"/*; do
    ts_fichier=$(date -r "$fichier" +%s)
    if [ "$ts_fichier" -gt "$timestamp_connexion" ]; then
        echo "Fichier modifié : $fichier"
        fichiers_modifies+=("$fichier")
    fi
done

# 6. BONUS – Fichiers identiques non modifiés
echo "Fichiers intacts identiques"
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
exit 0
