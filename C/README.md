Projet : Chiffrement et Déchiffrement Base64 + Vigenère

Langage C — Compétence C2

1. Introduction

Ce projet consiste à développer trois outils en langage C permettant :

le chiffrement d’un fichier encodé en Base64 ;

le déchiffrement d’un fichier encodé en Base64 ;

la détermination automatique de la clé utilisée pour le chiffrement.

Le chiffrement repose sur une variante du chiffre de Vigenère mod 64, appliqué sur l’alphabet Base64.Une bibliothèque statique (libcrypto.a) regroupe les fonctions communes afin de faciliter leur réutilisation.

2. Contexte et principe du chiffrement

Le processus complet de chiffrement utilisé dans le sujet est le suivant :

Encodage du fichier en Base64 (réalisé en dehors du programme).

Application d’un chiffrement de Vigenère mod 64 sur l’alphabet Base64.

Décodage Base64 (réalisé en dehors du programme).

L’alphabet utilisé est :

ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/

Les caractères = (padding Base64) ne doivent pas être modifiés.

3. Architecture du projet

3.1. Fichiers fournis

Fichier

Description

cipher.c

Programme de chiffrement

decipher.c

Programme de déchiffrement

findkey.c

Détermination de la clé

crypto.c

Implémentation du Vigenère mod 64

crypto.h

Déclarations et alphabet Base64

makefile

Compilation automatisée

libcrypto.a

Bibliothèque statique générée

3.2. Bibliothèque statique

La bibliothèque libcrypto.a contient les fonctions :

vigenereEnc

vigenereDec

indice_base64

Elle est générée automatiquement par le Makefile.

4. Fonctionnement des programmes

4.1. Programme cipher

Commande :

./cipher <cle_base64> <fichier_base64>

Fonctionnement :

Lecture complète du fichier.

Nettoyage de la clé (suppression des = finaux).

Application du Vigenère mod 64.

Réécriture du fichier avec le texte chiffré.

Les caractères =, \n, \r, \t sont ignorés ou recopiés tels quels.

4.2. Programme decipher

Commande :

./decipher <cle_base64> <fichier_base64>

Fonctionnement :

Construction d’une clé inverse :

K' = (64 - K) mod 64

Réutilisation de la fonction de chiffrement avec cette clé inverse.

Réécriture du fichier avec le texte déchiffré.

4.3. Programme findkey

Commande :

./findkey <clair_base64> <chiffre_base64>

Fonctionnement :

Lecture simultanée des deux fichiers.

Calcul du décalage pour chaque caractère :

diff = (C - P + 64) mod 64

Détermination de la période de la clé.

Affichage :

clé → stdout

taille → stderr

5. Compilation

Le projet utilise un Makefile permettant :

make : compilation complète

make cipher : compilation du programme cipher

make clean : suppression des fichiers objets et exécutables

La bibliothèque statique libcrypto.a est générée automatiquement.

6. Choix d’implémentation

Quelques décisions importantes :

Lecture en deux passes dans cipher.c pour déterminer la taille du fichier.

Nettoyage systématique de la clé Base64.

Ignorer les caractères non pertinents (\n, \r, \t).

Construction d’une clé inverse pour le déchiffrement.

Tableau de taille fixe dans findkey (suffisant pour les besoins du projet).

7. Limites et améliorations possibles

Limites actuelles

Pas de gestion des fichiers binaires.

Tableau statique dans findkey.

Pas de vérification stricte de la validité Base64.

Lecture complète en mémoire (pas optimisé pour très gros fichiers).

Améliorations envisageables

Support des fichiers binaires (rb / wb).

Allocation dynamique pour findkey.

Détection de clé robuste même en présence de bruit.

Ajout d’un mode verbose.

8. Conclusion

Ce projet permet de manipuler des fichiers, des algorithmes simples de chiffrement, des buffers mémoire et un Makefile complet.Il constitue une base solide pour intégrer ultérieurement ces fonctionnalités dans des programmes plus complexes.

