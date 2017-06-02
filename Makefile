PLATFORM=$(shell uname -s)
ARCH=$(shell uname -m)
SCHEME=chez

ifeq ($(PLATFORM),Darwin)
  FORMAT=macho32
  NASM=/usr/local/bin/nasm
#  PREFIX=--prefix _
  CC=gcc
  MAKE=make
  CFLAGS=-Wall -pedantic -g -ggdb -m32
endif

tests := $(wildcard test-*.ss)
bins := $(tests:.ss=.out)

# Run each test program and echo exit code
all: $(bins)
	for b in $(bins); do \
		./$$b; echo $$?; \
	done;

# Link objects into an executable
%.out: %.o boot.o
	$(CC) $(CFLAGS) -o $@ $^

# Compile the boot wrapper. boot.c implements main()
boot.o: boot.c
	$(CC) $(CFLAGS) -c -o boot.o boot.c

# Assemble each file into an object file
%.o: %.asm
	$(NASM) -f $(FORMAT) $^ -o $@

# Compile each scheme program into instructions for the assembler
%.asm: %.ss
	@./tests-driver.scm $^ > $@

clean:
	rm -v *.o *.out *.asm

# Targets clean and all are not real artifacts
.PHONY: clean all

# Prevent automatic removal of intermediate files
.PRECIOUS: %.asm
