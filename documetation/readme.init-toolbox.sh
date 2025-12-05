# création du fichier
touch init-toolbox.sh

#ajouter les droits de lecture/ecriture/et execution
chmod u+wxr init-toolbox.sh

#ouverture du fichier
nano init-toolbox.sh

#contenu du script init-toolbox.sh et guide d 'utilisation:
1-Vérification du dossier .sh-toolbox
if [ ! -d ".sh-toolbox" ]; then
    mkdir ".sh-toolbox"
    if [ "$?" -ne 0 ]; then
        echo "Erreur : impossible de créer le dossier"
        exit 1
    fi
    echo "Dossier .sh-toolbox créé"
else
    echo "Le dossier .sh-toolbox existe déjà"
fi

Vérifie si le dossier caché .sh-toolbox existe.
S’il n’existe pas → il est créé avec mkdir.
Si la création échoue → message d’erreur et sortie avec code 1.
Sinon → affiche que le dossier est créé.
Si le dossier existe déjà → affiche un message d’information

2-Vérification du fichier archives
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

Vérifie si le fichier archives existe.
S’il n’existe pas → il est créé et initialisé avec la valeur 0.
Si la création échoue → message d’erreur et sortie avec code 1.
Sinon → affiche que le fichier est créé.
Si le fichier existe déjà → affiche un message d’information.

3-Vérification du contenu du dossier
contenu=$(ls -A .sh-toolbox)
if [ "$contenu" != "archives" ]; then
    echo "Erreur : le dossier .sh-toolbox contient autre chose que le fichier archives"
    exit 2
fi
Vérifie que le dossier .sh-toolbox ne contient que le fichier archives.
Si autre chose est présent → message d’erreur et sortie avec code 2.

4-Message final
echo "Initialisation réussie"
exit 0

Indique que toutes les vérifications sont passées avec succès.
Sortie avec code 0.

5-Exemple d’utilisation
commande d'execution au terminal:
./init-toolbox.sh
a)cas de base:
Dossier .sh-toolbox créé
Fichier archives créé
Initialisation réussie
b)cas ou le dossier existe déjà:
Le dossier .sh-toolbox existe déjà
Le fichier archives existe déjà
Initialisation réussie
c)cas d'erreur:
Erreur : le dossier .sh-toolbox contient autre chose que le fichier archives
d)cas rare:
mkdir renvoi une erreur lors de la creation de dossier:
Erreur : impossible de créer le dossier
echo 0 > ".sh-toolbox/archives" renvoi une erreur lors de la creation de dossier:
Erreur : impossible de créer le fichier 
Le script s’arrête avec code retour 1.
