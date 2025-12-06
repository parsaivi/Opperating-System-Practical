CC = gcc
CFLAGS = -Wall -Wextra -std=c99 -MMD -MP
TARGET = zocker

SRCDIR = src
SOURCES = $(wildcard $(SRCDIR)/*.c)
OBJECTS = $(SOURCES:.c=.o)
DEPS = $(OBJECTS:.o=.d)

$(TARGET): $(OBJECTS)
	$(CC) $(CFLAGS) -o $@ $^
	sudo setcap cap_sys_admin+ep $(TARGET)

-include $(DEPS)

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(TARGET) $(OBJECTS) $(DEPS)

.PHONY: clean
