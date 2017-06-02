#include <stdlib.h>   /* posix_memalign */
#include <unistd.h>   /* sysconf */
#include <sys/mman.h> /* mprotect */
#include <stdio.h>    /* perror */
extern int scheme_entry(void *, size_t);

int dummy(void *m, size_t s) {
  printf("%p, %ld\n", m, s);
  return 0;
}

int main(int argc, char *argv[]) {

  /* allocate memory with base address an exact multiple of alignment (power of 2) */
  void *mem = NULL;
  size_t size = 8192;
  size_t alignment = sysconf(_SC_PAGE_SIZE);

  if (posix_memalign(&mem, alignment, size) != 0) {
    perror("posix_memalign");
  }
  if (mprotect(mem, size, PROT_READ | PROT_WRITE | PROT_EXEC) != 0) {
    perror("mprotect");
  }

  return scheme_entry(mem, size);
  /*return dummy(mem, size);*/

}
