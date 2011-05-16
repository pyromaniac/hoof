CC=gcc
CFLAGS=-O2

OBJ=nss_hoof.o

%.o: %.c
	$(CC) -Wall -fPIC -c -o $@ $< $(CFLAGS)

libnss_hoof.so.2: $(OBJ)
	$(CC) -shared -o $@ $^ -Wl,-soname,libnss_hoof.so.2 $(CFLAGS)

clean:
	rm -f *.o *~ libnss_hoof.so.2

install:
	ln -sf $(CURDIR)/libnss_hoof.so.2 /lib

uninstall:
	rm /lib/libnss_hoof.so.2
