CC = gcc

PROG = cipher decipher findkey

# Cible par défaut : tout compiler
all: libcrypto.a $(PROG)

# Bibliothèque
libcrypto.a: crypto.o
	ar rcs libcrypto.a crypto.o

crypto.o: crypto.c crypto.h
	$(CC) -c crypto.c

cipher: cipher.o libcrypto.a
	$(CC)  -o cipher cipher.o -L. -lcrypto

decipher: decipher.o libcrypto.a
	$(CC)  -o decipher decipher.o -L. -lcrypto

findkey: findkey.o libcrypto.a
	$(CC)  -o findkey findkey.o -L. -lcrypto

%.o: %.c crypto.h
	$(CC)  -c $<

# Nettoyage
clean:
	rm -f *.o libcrypto.a $(PROG)
