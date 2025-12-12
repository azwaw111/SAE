# Projet : Chiffrement et Déchiffrement Base64 + Vigenère

## Langage C — Compétence C2



## Guide d'utilisation

### Cas d'un fichier texte

Supposons `exemple.txt` :


base64 exemple.txt > exemple.b64
echo -n "CleSAE2025" | base64
./cipher "<clé encodée en base64>" exemple.b64
base64 -d exemple.b64 > output.bin


Ceci constitue le **processus d'infection** d'un fichier.

### Cas d'une image

Supposons `exemple2.jpg` :

base64 exemple2.jpg > image.b64
./cipher "<clé encodée en base64>" image.b64
base64 -d image.b64 > image_chiffree.bin


Le processus est identique pour tout type de fichier.

### Exemple rapide 


base64 exemple2.jpg > exemple.b
./cipher Q2xlUFFMjAyNQ== exemple.b
base64 -d exemple.b > out.bin
base64 out.bin > out.v

base64 exemple2.jpg > exemple.b
./findkey exemple.b out.v


### Processus inverse : déchiffrement


echo -n "CleSAE2025" | base64
./decipher "<clé encodée en base64>" exemple.b64
base64 -d exemple.b64 > output.txt

Nous recommandons d'utiliser `cat` pour afficher le contenu des fichiers générés.

### Utilisation de findkey

./findkey clair.b64 chiffre.b64



La clé est affichée sur **stdout** et sa taille sur **stderr**.



## 1. Introduction

Ce projet consiste à développer trois outils en langage C permettant :

* le chiffrement d’un fichier encodé en Base64 ;
* le déchiffrement d’un fichier encodé en Base64 ;
* la détermination automatique de la clé utilisée pour le chiffrement.

Le chiffrement repose sur une variante du chiffre de **Vigenère mod 64**, appliqué sur l’alphabet Base64.
Une bibliothèque statique (`libcrypto.a`) regroupe les fonctions communes afin de faciliter leur réutilisation.



## 2. Contexte et principe du chiffrement

Le processus complet de chiffrement utilisé dans le sujet est le suivant :

1. Encodage du fichier en Base64 (réalisé en dehors du programme).
2. Application d’un chiffrement de Vigenère mod 64 sur l’alphabet Base64.
3. Décodage Base64 (réalisé en dehors du programme).

L’alphabet utilisé est :


ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/


Les caractères `=` (padding Base64) ne doivent **pas** être modifiés.



## 3. Architecture du projet

### 3.1. Fichiers fournis

| Fichier       | Description                       |
| ------------- | --------------------------------- |
| `cipher.c`    | Programme de chiffrement          |
| `decipher.c`  | Programme de déchiffrement        |
| `findkey.c`   | Détermination de la clé           |
| `crypto.c`    | Implémentation du Vigenère mod 64 |
| `crypto.h`    | Déclarations et alphabet Base64   |
| `makefile`    | Compilation automatisée           |
| `libcrypto.a` | Bibliothèque statique générée     |

### 3.2. Bibliothèque statique

La bibliothèque `libcrypto.a` contient les fonctions :

* `vigenereEnc`
* `vigenereDec`
* `indice_base64`

Elle est générée automatiquement par le Makefile.



## 4. Fonctionnement des programmes

### 4.1. Programme `cipher`

**Commande :**


./cipher <cle_base64> <fichier_base64>


**Fonctionnement :**

* Lecture complète du fichier.
* Nettoyage de la clé (suppression des `=` finaux).
* Application du Vigenère mod 64.
* Réécriture du fichier avec le texte chiffré.

Les caractères `=`, `\n`, `\r`, `\t` sont ignorés ou recopiés tels quels.



### 4.2. Programme `decipher`

**Commande :**


./decipher <cle_base64> <fichier_base64>


**Fonctionnement :**

* Construction d’une **clé inverse** :

  
  K' = (64 - K) mod 64
  
* Réutilisation de la fonction de chiffrement avec cette clé inverse.
* Réécriture du fichier avec le texte déchiffré.



### 4.3. Programme `findkey`

**Commande :**


./findkey <clair_base64> <chiffre_base64>


**Fonctionnement :**

1. Lecture simultanée des deux fichiers.
2. Calcul du décalage pour chaque caractère :

   
   diff = (C - P + 64) mod 64
   
3. Détermination de la période de la clé.
4. Affichage :

   * clé → **stdout**
   * taille → **stderr**



## 5. Compilation

Le projet utilise un Makefile permettant :

* `make` : compilation complète
* `make cipher` : compilation du programme `cipher`
* `make clean` : suppression des fichiers objets et exécutables

La bibliothèque statique `libcrypto.a` est générée automatiquement.





## 6. Conclusion

Ce projet permet de manipuler des fichiers, des algorithmes simples de chiffrement, des buffers mémoire et un Makefile complet. Il constitue une base solide pour intégrer ultérieurement ces fonctionnalités dans des programmes plus complexes.



## Documentation

Ce document regroupe toutes les informations nécessaires à l'utilisation et à la compréhension du projet.

## Outils utilisés

* GCC
* Make
* Encodage Base64 (outil système)
* Bibliothèque statique `libcrypto.a`

## Description

Ceci est un projet pour un but éducatif dans le cadre du projet SAE.

## Compilation

Voir section dédiée plus haut (`make`, `make clean`, etc.).

## Guide d'utilisation

Reportez-vous à la section **Guide d'utilisation** en début de document pour les cas texte et image.

## Remarque

Nous recommandons fortement d’utiliser `cat` pour afficher le contenu généré par les commandes (`clair.b64`, `image.b64`, fichiers décodés, etc.).

