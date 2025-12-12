#include "crypto.h"


int indice_base64(char c) { 
  char *p = strchr(ALPHABET, c);     
  return p ? (int)(p - ALPHABET) : -1;   
}

void vigenereEnc(const char *entree, const char *cle_base64, char *sortie)
{
    // 1 Nettoyer la clé : enlever tous les '=' de fin
    int len_cle = strlen(cle_base64); // savoir la longueur de la clé 
    while (len_cle > 0 && cle_base64[len_cle - 1] == '=') {
        len_cle--; // mise de la taile de la clé 
    }

    char *cle = malloc(len_cle + 1); // reservation  une place pour \0
    strncpy(cle, cle_base64, len_cle);
    cle[len_cle] = '\0';

    int iCle = 0; // indice pour la clé
    int k=0;// indice de sortie

    for (int i = 0; entree[i] != '\0'; i++) {
        if (entree[i] == '\n' || entree[i] == '\r'|| entree[i]=='\t') continue;
        
        // 2 Si caractère '=' dans le fichier, on le recopie
        if (entree[i] == '=') {
            sortie[k++] = '=';
            continue;
        }

        // 3 Indices Base64
        int indice_clair = indice_base64(entree[i]);
        if (indice_clair < 0) { // sécurité
            sortie[k++] = entree[i];
            continue;
        }

        int idx_key = indice_base64(cle[iCle]);
        if (idx_key < 0) { // sécurité, devrait pas arriver
            idx_key = 0;
        }

        // 4 Application de Vigenère mod 64
        int indice_chiffre = (indice_clair + idx_key) % 64;
        sortie[k++] = ALPHABET[indice_chiffre];

        // 5 vancer l'indice de clé
        iCle = (iCle + 1) % len_cle;
    }

    sortie[k] = '\0';

    free(cle);
}

void vigenereDec(const char *entree, const char *cle_base64, char *sortie)
{
    // Nettoyer la clé de fin '='
    int len_cle = strlen(cle_base64);
    while (len_cle > 0 && cle_base64[len_cle - 1] == '=') {
        len_cle--;
    }

    // Construire la clé inverse
    char *cle_inverse = malloc(len_cle + 1);
    for (int i = 0; i < len_cle; i++) {
        int idx_key = indice_base64(cle_base64[i]);
        if (idx_key < 0) idx_key = 0;
        int inv = (64 - idx_key) % 64;
        cle_inverse[i] = ALPHABET[inv];
    }
    cle_inverse[len_cle] = '\0';

    // Réutiliser la fonction de chiffrement avec la clé inverse
    vigenereEnc(entree, cle_inverse, sortie);
    

    free(cle_inverse);
}
