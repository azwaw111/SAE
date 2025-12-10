#include "crypto.h"


int main(int argc, char *argv[])
{
    if (argc != 3) {
        printf("Utilisation : %s <fichier> <cle>\n", argv[0]);
        return 1;
    }

    const char *cle = argv[1];
    const char *nomFichier = argv[2];

    // --- Ouverture fichier ---
    FILE *fichier = fopen(nomFichier, "r");
    if (!fichier) {
        perror("Erreur ouverture fichier");
        return 1;
    }


    // --- Lecture du fichier caractère par caractère pour connaître sa taille ---
    unsigned int taille = 0;
    int c;

    while ((c = fgetc(fichier)) != EOF) {
        taille++;
    }


    // retour au début du fichier → on ferme puis on rouvre
    fclose(fichier);



    fichier = fopen(nomFichier, "r");
    if (!fichier) {
        perror("Erreur réouverture fichier");
        return 1;
    }


    // --- Allocation buffer Lecture + Ecriture ---
    char *bufferEntree = malloc(taille + 1);
    char *bufferSortie = malloc(taille + 1);

    if (!bufferEntree || !bufferSortie) {
        printf("Erreur malloc\n");
        fclose(fichier);
        return 1;
    }

    
    // --- Lecture du fichier pour la deuxieme fois 
    for (unsigned int i = 0; i < taille; i++) {
        bufferEntree[i] = fgetc(fichier);
    }
    bufferEntree[taille] = '\0';

    fclose(fichier);

    // --- Appel du chiffrement ---
    vigenereEnc(bufferEntree, cle, bufferSortie);

    // --- Réécriture du fichier avec le texte chiffré ---
    fichier = fopen(nomFichier, "w");
    if (!fichier) {
        perror("Erreur ouverture fichier en écriture");
        free(bufferEntree);
        free(bufferSortie);
        return 1;
    }

    fputs(bufferSortie, fichier);

    fclose(fichier);
    free(bufferEntree);
    free(bufferSortie);

    printf("Chiffrement terminé.\n");

    return 0;
}
