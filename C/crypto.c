#include "crypto.h"

int indice_base64(char caractere) {
    char *p = strchr(ALPHABET, caractere);
    return p ? (int)(p - ALPHABET) : -1;
}


void vigenereEnc(const char *entree, const char *cle, char *sortie) {
    unsigned int i, taille = strlen(cle);
    for (i = 0; entree[i] != '\0'; i++) {
        if (entree[i] == '=') {
            sortie[i] = '=';
            continue;
        }
        int indiceCaractereEntree = indice_base64(entree[i]);
        int indiceCaractereCle = indice_base64(cle[i % taille]);
        if (indiceCaractereEntree < 0 || indiceCaractereCle < 0) {
            sortie[i] = entree[i];
            continue;
        }
        int indiceCaractereChiffre = (indiceCaractereEntree + indiceCaractereCle) % 64;
        sortie[i] = ALPHABET[indiceCaractereChiffre];
    }
    sortie[i] = '\0';
}



void vigenereDec(const char *entree, const char *cle, char *sortie) {
    unsigned int i, taille = strlen(cle);
    char cleInverse[taille + 1];
    for (i = 0; cle[i] != '\0'; i++) {
        int indiceCaractereCle = indice_base64(cle[i]);
        int indiceCleInverse = (64 - indiceCaractereCle) % 64;
        cleInverse[i] = ALPHABET[indiceCleInverse];
    }
    cleInverse[i] = '\0';
    vigenereEnc(entree, cleInverse, sortie);
}

