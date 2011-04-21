CC=gcc
CFLAGS=-O2

OBJ=nss_pow.o

%.o: %.c
	$(CC) -Wall -fPIC -c -o $@ $< $(CFLAGS)

libnss_pow.so.2: $(OBJ)
	$(CC) -shared -o $@ $^ -Wl,-soname,libnss_pow.so.2 $(CFLAGS)

clean:
	rm -f *.o *~ libnss_pow.so.2
