CC = gcc
CFLAGS = -Wall -Wextra -g
OBJECTS = filesystem.o cli.o

all: myfs

myfs: $(OBJECTS)
	$(CC) $(CFLAGS) -o myfs $(OBJECTS)

filesystem.o: filesystem.c filesystem.h
	$(CC) $(CFLAGS) -c filesystem.c

main.o: main.c filesystem.h
	$(CC) $(CFLAGS) -c main.c

cli.o: cli.c filesystem.h
	$(CC) $(CFLAGS) -c cli.c	

clean:
	rm -f *.o myfs filesys.db

run: myfs
	./myfs

.PHONY: all clean run
