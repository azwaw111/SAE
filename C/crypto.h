#ifndef CRYPTO_H
#define CRYPTO_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Alphabet Base64 sans le caractère '='
#define ALPHABET "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

int indice_base64(char caractere); 
void vigenereEnc(const char *entree, const char *cle, char *sortie);
void vigenereDec(const char *entree, const char *cle, char *sortie);

#endif
