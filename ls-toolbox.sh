
Liste des archives importées:
#!/bin/bash

# Vérifier si le dossier .sh-toolbox existe
if [ ! -d ".sh-toolbox" ]; then
    echo "Erreur : le dossier .sh-toolbox n'existe pas"
    exit 1
fi

# Vérifier si le fichier archives existe
if [ ! -f ".sh-toolbox/archives" ]; then
    echo "Erreur : le fichier archives n'existe pas"
    exit 2
fi

# Parcourir le fichier archives (ignorer la première ligne = compteur)
while IFS=: read -r archive_name date key; do
    [ -z "$archive_name" ] && continue

    if [ -z "$key" ]; then
        cle="clé inconnue"
    else 
        cle="clé connue"
    fi 

    echo "Archive : $archive_name | Date : $date | $cle"

    # BONUS : vérifier si archive mentionnée existe réellement
    if [ ! -f ".sh-toolbox/$archive_name" ] ; then
        echo "Erreur : l'archive $archive_name est mentionnée mais absente"
        exit 3
    fi
done < <(tail -n +2 ".sh-toolbox/archives")

# BONUS : vérifier si une archive existe mais n'est pas mentionnée
for fichier in .sh-toolbox/*.tar.gz; do
    [ -e "$fichier" ] || continue
    archive_name=$(basename "$fichier")
    if ! grep -q "^$archive_name:" ".sh-toolbox/archives"; then 
        echo "Avertissement : l'archive $archive_name est présente mais non mentionnée"
        exit 3
    fi
done

exit 0
