PLATFORM=$(shell uname -s)
ARCH=$(shell uname -m)
SCHEME=chez

ifeq ($(PLATFORM),Darwin)
#  LLC=/usr/local/Cellar/llvm/4.0.0_1/bin/llc
  NASM=nasm -f macho32
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
%.o: %.s
	$(NASM) -o $@ $^
#	$(LLC) -filetype=obj -march=x86 $^ -o $@

# Compile each scheme program into instructions for the assembler
%.s: %.ss
	$(SCHEME) compiler2.scm $^ > $@
#	@./tests-driver.scm $^ > $@

clean:
	rm -v *.o *.out *.s

# Targets clean and all are not real artifacts
.PHONY: clean all

# Prevent automatic removal of intermediate files
.PRECIOUS: %.asm %.s
