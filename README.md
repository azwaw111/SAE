          **Partie Bash**
          **Compétence C3**

## 📝 Description Générale du Projet

Ce projet met en place une boîte à ouils Bash permettant de gérer des archives .tar.gz issues d’un environnement compromis. Les scripts permettent de :
    Initialiser l’environnement de travail
    Importer et gérer des archives
    Lister et restaurer l’environnement
    Analyser les archives pour identifier les fichiers impactés
    
> **ℹ️ Contexte Scolaire (SAE) :** Ce projet a été conçu dans le cadre d'une Situation d'Apprentissage et d'Évaluation (SAE) pour les étudiants. Son but principal est **d'apprendre et de mettre en pratique** les concepts de l'analyse après attaque, de la gestion de fichiers.

-----

## 🟢 Statut du Projet et Technologies
#Statut 
En développement

### Pré-requis et Technologies Utilisées

Ce projet est entièrement basé sur des scripts **Bash**, utilisant des utilitaires standards des systèmes **Linux** (tels que `grep`, `awk`, `sed`, `date`, `tar`, `stat`).
Les scripts doivent être placés dans le dossier de travail de la SAE.
-----

##  Concepts Fondamentaux

La Toolbox utilise un environnement caché et auto-géré dans le répertoire d'exécution :

  * **Dossier de Stockage :** `.sh-toolbox`
      * contient toutes les archives importées
  * **Fichier d'Index :** `.sh-toolbox/archives`
      * Index des preuves. La première ligne est un **compteur** ;
      * les lignes suivantes sont au format       `nom_archive:date_ajout:clé`.

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
| **`init-toolbox.sh`** | Initialise l’environnement .sh-toolbox et crée le fichier archives | `./init-toolbox.sh` | **Préparation** |
| **`import-archive.sh`** | Importe une archive (simple, une à la fois, avec confirmation)I | `./import-archive.sh <cheminarchive.tar.gz>` | **Stockage de Preuve** |
| **`importe-archive2.sh`** | Version améliorée : mode force (-f) et importation multiple  | `./importe-archive2.sh [-f] <arch1> [arch2] ...` | **Stockage en Vrac** |
| **`ls-toolbox.sh`** | Diagnostic (liste + détection incohérences) | `./ls-toolbox.sh` | **Vérification de Cohérence** |
| **`restore-toolbox.sh`** | Réparation (corrige incohérences, met à jour compteur) | `./restore-toolbox.sh` | **Intégrité de la Chaîne de Preuve** |
| **`check-archive.sh`** | Analyse des archives pour identifier fichiers modifiés/non modifiés | `./check-archive.sh` | **Analyse d'Impact** |

### Focus : Le Script d'Audit (`check-archive.sh`)

Ce script est au cœur de l'analyse post-attaque. Il utilise les **timestamps (Mtime)** des fichiers pour déterminer ce qui a été modifié par l'attaquant.

**Étapes de l'Audit :**

1.  Propose une liste des archives disponibles dans la Toolbox.
2.  Décompresse l'archive sélectionnée dans un répertoire temporaire.
3.  Analyse le log (`var/log/auth.log` dans l'archive) pour trouver l'heure de la **dernière connexion réussie de l'utilisateur `admin`**.
4.  Compare ce temps de connexion avec les **Mtime** de tous les fichiers présents dans le dossier `data` de l'archive.
5.  **Résultat :** Liste les fichiers dont la modification est **postérieure** à cette connexion (fichiers potentiellement impactés).

-----

##  Bugs Connus et FAQ

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

**Auteur :** zerrouak , Aziz
**Année :** [Année de la SAE]
**Licence :** Ce projet est distribué sous la licence **[À Compléter : ex. MIT, GPLv3]**.
