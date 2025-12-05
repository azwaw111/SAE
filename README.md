# 📚 Toolbox SAE - Audit et Gestion Forensique d'Archives 

## 📝 Description Générale du Projet

Ce projet est une **boîte à outils (Toolbox) de scripts Bash** conçue spécifiquement pour la gestion centralisée et l'audit forensique d'archives `.tar.gz` reçues après un incident de sécurité.

> **ℹ️ Contexte Scolaire (SAE) :** Ce projet a été conçu dans le cadre d'une Situation d'Apprentissage et d'Évaluation (SAE) pour les étudiants. Son but principal est **d'apprendre et de mettre en pratique** les concepts de l'analyse forensique, de la gestion de fichiers, de l'indexation de données et de l'automatisation via des scripts Shell robustes.

Elle fournit des outils pour organiser les preuves (archives) et effectuer des analyses rapides basées sur la corrélation entre les logs de connexion et les *timestamps* des fichiers.

-----

## 🟢 Statut du Projet et Technologies

### Statut

**Développement Terminé (Version 1.0 - Prêt pour l'analyse)**.

### Technologies Utilisées

Ce projet est entièrement basé sur des scripts **Bash**, utilisant des utilitaires standards des systèmes **GNU/Linux** et **macOS** (tels que `grep`, `awk`, `sed`, `date`, `tar`, `stat`).

-----

## ⚙️ Exigences concernant l’environnement

Pour l'intégration et l'exécution, vous devez disposer :

  * D'un environnement **GNU/Linux** ou **macOS**.
  * De l'interpréteur **Bash**.
  * Des outils de base **GNU Core Utilities** pour garantir la bonne exécution des commandes complexes de gestion de date (`date -d`) et de fichiers.

-----

## 🔑 Concepts Fondamentaux

La Toolbox utilise un environnement caché et auto-géré dans le répertoire d'exécution :

  * **Dossier de Stockage :** `.sh-toolbox`
      * Le dépôt centralisé des archives à analyser.
  * **Fichier d'Index :** `.sh-toolbox/archives`
      * Index des preuves. La première ligne est un **compteur** ; les lignes suivantes sont au format `nom_archive:date_ajout:clé`.

-----

## 🛠️ Instructions pour l'Installation et l'Utilisation

### 1\. Initialisation (Préparation de l'environnement)

Exécutez cette commande une seule fois pour créer la structure de la Toolbox :

```bash
./init-toolbox.sh
```

### 2\. Guide des Scripts (Mode d'emploi)

| Nom du Script | Objectif | Syntaxe | Rôle dans l'Audit |
| :--- | :--- | :--- | :--- |
| **`init-toolbox.sh`** | Crée le dossier `.sh-toolbox` et l'index `archives`. | `./init-toolbox.sh` | **Préparation** |
| **`import-archive.sh`** | Importe **une seule** archive de preuve. | `./import-archive.sh <chemin/archive.tar.gz>` | **Stockage de Preuve** |
| **`importe-archive2.sh`** | Importe **plusieurs** archives. | `./importe-archive2.sh [-f] <arch1> [arch2] ...` | **Stockage en Vrac** |
| **`ls-toolbox.sh`** | Affiche l'inventaire et vérifie l'intégrité de l'index. | `./ls-toolbox.sh` | **Vérification de Cohérence** |
| **`restore-toolbox.sh`** | **Restauration Interactive** : Répare les incohérences entre les fichiers et l'index. | `./restore-toolbox.sh` | **Intégrité de la Chaîne de Preuve** |
| **`check-archive.sh`** | **Audit Forensique Principal** : Analyse les logs d'une archive pour identifier les fichiers modifiés après la dernière connexion `admin`. | `./check-archive.sh` | **Analyse d'Impact** |

### Focus : Le Script d'Audit (`check-archive.sh`)

Ce script est au cœur de l'analyse post-attaque. Il utilise les **timestamps (Mtime)** des fichiers pour déterminer ce qui a été modifié par l'attaquant.

**Étapes de l'Audit :**

1.  Propose une liste des archives disponibles dans la Toolbox.
2.  Décompresse l'archive sélectionnée dans un répertoire temporaire.
3.  Analyse le log (`var/log/auth.log` dans l'archive) pour trouver l'heure de la **dernière connexion réussie de l'utilisateur `admin`**.
4.  Compare ce temps de connexion avec les **Mtime** de tous les fichiers présents dans le dossier `data` de l'archive.
5.  **Résultat :** Liste les fichiers dont la modification est **postérieure** à cette connexion (fichiers potentiellement impactés).

-----

## 🐛 Bugs Connus et FAQ

### Bugs Connus

  * **Gestion de l'Année :** Le script `check-archive.sh` utilise l'année courante pour contextualiser la date de connexion des logs (si le log n'inclut que le mois et le jour). Ceci peut entraîner une erreur d'analyse si les logs de l'archive datent de l'année précédente.
  * **Dépendance à `tar.gz` :** L'outil est strictement limité aux archives au format `.tar.gz`.

### FAQ (Foire aux Questions)

**Q : Que se passe-t-il si j'oublie d'utiliser `init-toolbox.sh` ?**
R : Tous les autres scripts renverront une erreur avec le code de retour `1` ou `2`, car ils dépendent de l'existence du dossier `.sh-toolbox` et du fichier `archives`. Utilisez `restore-toolbox.sh` pour les recréer de manière interactive.

**Q : Comment contourner un problème lors de l'importation ?**
R : Si `import-archive.sh` ou `importe-archive2.sh` signale un conflit de nom, utilisez l'option **`-f`** avec `importe-archive2.sh` pour forcer l'écrasement de l'ancienne preuve par la nouvelle.

-----

## 🤝 Collaboration Souhaitée

Nous sommes ouverts aux contributions, notamment pour améliorer la portabilité des commandes `date` ou pour élargir le support à d'autres formats d'archives.

### Comment Contribuer :

Veuillez ouvrir une **Issue** pour discuter de tout bogue ou fonctionnalité avant de soumettre une **Pull Request**.

-----

## ⚖️ Droits d’Auteurs et Licence

**Auteur :** [Votre Nom ou celui de l'Équipe SAE]
**Année :** [Année de la SAE]
**Licence :** Ce projet est distribué sous la licence **[À Compléter : ex. MIT, GPLv3]**.
