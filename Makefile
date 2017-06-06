PLATFORM=$(shell uname -s)
ARCH=$(shell uname -m)
SCHEME=chez

ifeq ($(PLATFORM),Darwin)
  CC=/usr/local/bin/gcc-7
  NASM=nasm -f macho32
  MAKE=make
  CFLAGS=-Wall -pedantic -g -ggdb -m32 -lc -Wl,-no_pie
endif

tests := $(wildcard test-*.ss)
bins := $(tests:.ss=.bin)

# Run each test program and echo exit code
all: clean $(bins)
	for b in $(bins); do \
		./$$b; echo $$?; \
	done;

# Link objects into an executable
%.bin: %.o boot.o
	$(CC) $(CFLAGS) -o $@ $^

# Compile the boot wrapper. boot.c implements main()
boot.o: boot.c
	$(CC) $(CFLAGS) -c -o boot.o boot.c

# Assemble each file into an object file
%.o: %.s
	$(NASM) -g -o $@ $^

# Compile each scheme program into instructions for the assembler
%.s: %.ss
	$(SCHEME) --script $^ > $@

clean:
	rm -vf *.o *.bin *.s

# Targets clean and all are not real artifacts
.PHONY: clean all

# Prevent automatic removal of intermediate files
.PRECIOUS: %.s %.o
