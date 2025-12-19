#include "crypto.h"
#include <string.h>
#include <stdlib.h>



int main(int argc, char *argv[]) {
    char *fichier_clair_path = NULL;
    char *fichier_chiffre_path = NULL;
    char *output_file = NULL;

    // Parsing des arguments
    if (argc == 3) {
        fichier_clair_path = argv[1];
        fichier_chiffre_path = argv[2];
    } else if (argc == 5 && strcmp(argv[3], "-o") == 0) {
        fichier_clair_path = argv[1];
        fichier_chiffre_path = argv[2];
        output_file = argv[4];
    } else {
        fprintf(stderr,
            "Utilisation : %s <fichier_clair_base64> <fichier_chiffre_base64> [-o fichier_sortie]\n",
            argv[0]);
        return 1;
    }

    FILE *fichier_clair = fopen(fichier_clair_path, "r");
    FILE *fichier_chiffre = fopen(fichier_chiffre_path, "r");
    if (!fichier_clair || !fichier_chiffre) {
        perror("Erreur ouverture fichier");
        return 1;
    }

    int capacite = 1024;
    int *decalages = malloc(capacite * sizeof(int));
    if (!decalages) {
        fprintf(stderr, "Erreur allocation mémoire\n");
        return 1;
    }

    char caractere_clair, caractere_chiffre;
    int taille = 0;

    while ((caractere_clair = fgetc(fichier_clair)) != EOF &&
       (caractere_chiffre = fgetc(fichier_chiffre)) != EOF) {

    if (caractere_clair == '=' || caractere_chiffre == '=')
        break;  // STOP dès qu'on atteint le padding

    int indice_clair = indice_base64(caractere_clair);
    int indice_chiffre = indice_base64(caractere_chiffre);
    if (indice_clair < 0 || indice_chiffre < 0)
        continue;

    if (taille >= capacite) {
        capacite *= 2;
        int *tmp = realloc(decalages, capacite * sizeof(int));
        if (!tmp) {
            fprintf(stderr, "Erreur realloc\n");
            free(decalages);
            return 1;
        }
        decalages = tmp;
    }

    decalages[taille++] = (indice_chiffre - indice_clair + 64) % 64;
}


    fclose(fichier_clair);
    fclose(fichier_chiffre);

    if (taille == 0) {
        fprintf(stderr, "Erreur : aucun décalage valide\n");
        free(decalages);
        return 1;
    }
    //  Recherche de la période MINIMALE  
     int periode = taille; 
     for (int k = 1; k <= taille ; ++k) { 
     int valide = 1; 
     for (int i = 0; i < taille-1; ++i) { 
        if (decalages[i] != decalages[i % k])
         { valide = 0; break; } } 
         if (valide){
             periode = k;
              break;
         }
     }



    unsigned char *cle = malloc(periode);
    if (!cle) {
        fprintf(stderr, "Erreur allocation clé\n");
        free(decalages);
        return 1;
    }

    for (int i = 0; i < periode; i++) {
        cle[i] = ALPHABET[decalages[i]];
    }

    if (output_file) {
        FILE *out = fopen(output_file, "wb");
        if (!out) {
            perror("Erreur fichier sortie");
            free(decalages);
            free(cle);
            return 1;
        }
        fwrite(cle, 1, periode, out);
        fclose(out);
    } else {
        fwrite(cle, 1, periode, stdout);
        putchar('\n');
    }

    fprintf(stderr, "%d\n", periode);

    free(decalages);
    free(cle);
    return 0;
}
