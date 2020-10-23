# Filename : Makefile
# Author   : Nikolaos Kavvadias 2007-2020
# Copyright: (C) 2007-2020 Nikolaos Kavvadias

CC = gcc
CFLAGS = -Wall -Wextra -pedantic -O2
EXE= .exe

all: mprfgen$(EXE)

mprfgen$(EXE): mprfgen.o
	$(CC) mprfgen.o -o mprfgen$(EXE)

mprfgen.o: mprfgen.c
	$(CC) $(CFLAGS) -c mprfgen.c

tidy:
	rm -f *.o

clean:
	rm -f *.o mprfgen$(EXE)
