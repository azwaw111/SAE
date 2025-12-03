CC = gcc
CFLAGS = -Wall -Wextra

PROG = cipher decipher findkey



# Bibliothèque


libcrypto.a: crypto.o
	ar rcs libcrypto.a crypto.o

crypto.o: crypto.c crypto.h
	$(CC) $(CFLAGS) -c crypto.c

cipher: cipher.o libcrypto.a
	$(CC) $(CFLAGS) -o cipher cipher.o -L. -lcrypto

decipher: decipher.o libcrypto.a
	$(CC) $(CFLAGS) -o decipher decipher.o -L. -lcrypto

findkey: findkey.o libcrypto.a
	$(CC) $(CFLAGS) -o findkey findkey.o -L. -lcrypto

%.o: %.c crypto.h
	$(CC) $(CFLAGS) -c $<



# Nettoyage

clean:
	rm -f *.o libcrypto.a
	rm $(PROG)
