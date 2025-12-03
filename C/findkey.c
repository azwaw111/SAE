#include "crypto.h"


int main(int argc, char *argv[]) {
    if (argc != 3) {
        fprintf(stderr, "Utilisation : %s <fichier_clair_base64> <fichier_chiffre_base64>\n", argv[0]);
        return 1;
    }

    FILE *fichier_clair = fopen(argv[1], "r");
    FILE *fichier_chiffre = fopen(argv[2], "r");
    if (!fichier_clair || !fichier_chiffre) {
        perror("Erreur ouverture fichier");
        return 1;
    }

    char caractere_clair, caractere_chiffre;
    int decalages[10000]; // tableau des décalages
    int taille = 0;

    while ((caractere_clair = fgetc(fichier_clair)) != EOF &&
           (caractere_chiffre = fgetc(fichier_chiffre)) != EOF) {
        if (caractere_clair == '=' || caractere_chiffre == '=') continue;

        int indice_clair = indice_base64(caractere_clair);
        int indice_chiffre = indice_base64(caractere_chiffre);
        if (indice_clair < 0 || indice_chiffre < 0) continue;

        int diff = (indice_chiffre - indice_clair + 64) % 64;
        decalages[taille++] = diff;
    }

    fclose(fichier_clair);
    fclose(fichier_chiffre);

    // Déterminer la période de la clé
    int periode = 1;
    for (int k = 1; k <= taille; k++) {
        int valide = 1;
        for (int i = 0; i < taille; i++) {
            if (decalages[i] != decalages[i % k]) {
                valide = 0;
                break;
            }
        }
        if (valide) {
            periode = k;
            break;
        }
    }

    // Afficher la clé
    for (int i = 0; i < periode; i++) {
        putchar(ALPHABET[decalages[i]]);
    }
    putchar('\n');

    fprintf(stderr, "%d\n", periode);

    return 0;
}
