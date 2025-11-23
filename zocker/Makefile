CC = gcc
CFLAGS = -Wall -Wextra -std=c99
TARGET = zocker
SOURCES = main.c

$(TARGET): $(SOURCES)
	$(CC) $(CFLAGS) -o $(TARGET) $(SOURCES)
	sudo setcap cap_sys_admin+ep $(TARGET)

clean:
	rm -f $(TARGET)

.PHONY: clean
