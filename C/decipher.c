#include "crypto.h"



int main(int argc, char *argv[]) {
    if (argc != 3) {
        fprintf(stderr, "Utilisation : %s <cle> <fichier_entree_base64>\n", argv[0]);
        return 1;
    }

    char *cle = argv[1];
    int longueur_cle = strlen(cle);

    FILE *fichier_entree = fopen(argv[2], "r");
    if (!fichier_entree) {
        perror("Erreur ouverture fichier");
        return 1;
    }

    int caractere, indice_cle = 0;
    while ((caractere = fgetc(fichier_entree)) != EOF) {
        if (caractere == '=') {
            putchar(caractere);
            continue;
        }
        int indice_chiffre = indice_base64((char)caractere);
        if (indice_chiffre < 0) continue;

        int indice_cle_val = indice_base64(cle[indice_cle]);
        int indice_plain = (indice_chiffre - indice_cle_val + 64) % 64;

        putchar(ALPHABET[indice_plain]);

        indice_cle = (indice_cle + 1) % longueur_cle;
    }

    fclose(fichier_entree);
    return 0;
}
