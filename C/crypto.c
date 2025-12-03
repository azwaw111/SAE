#include "crypto.h"
#include "crypto.h"

const char *ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

int indice_base64(char caractere) {
    char *p = strchr(ALPHABET, caractere);
    return p ? (int)(p - ALPHABET) : -1;
}
