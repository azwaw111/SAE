#include "crypto.h"

int main(int argc, char *argv[])
{
    if (argc != 3) {
        fprintf(stderr, "Utilisation : %s <cle_base64> <fichier_base64>\n", argv[0]);
        return 1;
    }

    const char *cle = argv[1];
    const char *fichier = argv[2];

    FILE *f = fopen(fichier, "r");
    if (!f) { perror("Erreur ouverture"); return 1; }

    fseek(f, 0, SEEK_END);
    long taille = ftell(f);
    rewind(f);

    char *entree = malloc(taille + 1);
    char *sortie = malloc(taille + 1);

    fread(entree, 1, taille, f);
    entree[taille] = '\0';
    fclose(f);

    // Déchiffrement
    vigenereDec(entree, cle, sortie);

    f = fopen(fichier, "w");
    fwrite(sortie, 1, strlen(sortie), f);
    fclose(f);

    free(entree);
    free(sortie);

    printf("Déchiffrement terminé.\n");
    return 0;
}
