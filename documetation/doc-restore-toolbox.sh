Le script restore-toolbox.sh permet de diagnostiquer et restaurer l’environnement de travail utilisé par les autres scripts (ls-toolbox.sh, import-archive.sh, etc.). Il vérifie la cohérence entre le dossier .sh-toolbox, le fichier archives, et les archives réellement présentes, puis propose à l’utilisateur de corriger les problèmes détectés.
⚙️ Fonctionnalités principales

    Vérification du dossier .sh-toolbox

        Si le dossier est absent → message d’erreur.

        Propose à l’utilisateur de le recréer.

    Vérification du fichier archives

        Si le fichier est absent → message d’erreur.

        Propose à l’utilisateur de le recréer avec un compteur initial à 0.

    Contrôle des archives mentionnées dans archives

        Parcourt le fichier archives (ignore la première ligne qui contient le compteur).

        Vérifie que chaque archive listée existe réellement dans .sh-toolbox.

        Si une archive est mentionnée mais absente → propose de supprimer l’entrée correspondante.

    Contrôle des archives présentes mais non mentionnées

        Liste les fichiers .tar.gz dans .sh-toolbox.

        Vérifie que chacun est mentionné dans archives.

        Si une archive est présente mais non listée → propose de l’ajouter avec la date courante.

    Mise à jour du compteur

        Recalcule le nombre d’archives listées dans archives.

        Met à jour la première ligne du fichier archives avec ce nouveau compteur.

🔢 Codes de retour

    0 → restauration effectuée sans erreur.

    1 → impossible de créer le dossier .sh-toolbox.

    2 → impossible de créer le fichier archives.

    3 → incohérence détectée et non corrigée (archive manquante ou non mentionnée).
