// source/kernel/main.c

#include <headers/typ.h>

#define true ((unsigned byte) 1)

#ifdef __x86_64__
#define ABI __attribute__((ms_abi))
#else
#define ABI
#endif

#define NORETURN __attribute__((noreturn))

ABI NORETURN void kmain(void) {
    while (true);

    /* return; */
}
