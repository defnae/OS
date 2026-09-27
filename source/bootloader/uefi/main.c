// source/bootloader/uefi/main.c

#include <bootloader/uefi/headers/efi.h>

#define SECTION(x) __attribute__((section(x)))

#define noaof register

typedef struct {
    UINT32 H[8];
    UINT8 Buffer[64];
    UINT32 BufferLen;
    UINT64 TotalLen;
} SHA256;

typedef struct {
    SHA256 Hash;
    UINT32 Samples;
} ENTROPY;

static UINT32 SHA256K[64] = {
    0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
    0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
    0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0fbcf, 0x76f988da,
    0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
    0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
    0xa2bfe8a1, 0xa81a664f, 0xc19bf174, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
    0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb3, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
    0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2
};

typedef struct {
    EFI_SYSTEM_TABLE *SystemTable;

    ENTROPY EntropyData;
    ENTROPY *Entropy;
} Globals;

static Globals GlobalData;
static Globals *G = &GlobalData;

static VOID init_sha(SHA256 *);
static VOID init_entropy(VOID);
static VOID mix_entropy(UINT64);
static VOID store64(UINT8 [], UINT64);
static VOID store32(UINT8 [], UINT32);
static VOID update_sha(SHA256 *, UINT8 *, UINTN);
static VOID block_sha(UINT32 [8], UINT8 [64]);
static UINT32 rotl32(UINT32, UINT32);
static UINT32 rotr32(UINT32, UINT32);
static VOID store32_be(UINT8 *, UINT32);
static UINT32 load32(UINT8 *);

static UINT64 ReadCycleCounter(VOID)
{
#if defined(__x86_64__) || defined(__i386__)
    UINT32 Lo, Hi;
    __asm__ __volatile__ ("rdtsc" : "=a" (Lo), "=d" (Hi));
    return ((UINT64) Hi << 32) | Lo;
#elif defined(__aarch64__)
    UINT64 Value;
    __asm__ __volatile__ ("mrs %0, cntvct_el0" : "=r" (Value));
    return Value;
#elif defined(__arm__)
    UINT32 Lo, Hi;
    __asm__ __volatile__ ("mrrc p15, 1, %0, %1, c14" : "=r" (Lo), "=r" (Hi));
    return ((UINT64) Hi << 32) | Lo;
#elif defined(__riscv) && __riscv_xlen == 64
    UINT64 Value;
    __asm__ __volatile__ ("rdtime %0" : "=r" (Value));
    return Value;
#elif defined(__loongarch64)
    UINT64 Value;
    __asm__ __volatile__ ("rdtime.d %0, $zero" : "=r" (Value));
    return Value;
#else
#   error "ReadCycleCounter: unsupported architecture"
#endif
}

SECTION(".text.efi_main")
EFIAPI EFI_STATUS efi_main(ImageHandle, SystemTable)
IN EFI_HANDLE ImageHandle;
IN EFI_SYSTEM_TABLE *SystemTable;
{
    (void) ImageHandle;

    G->SystemTable = SystemTable;
    G->Entropy = &G->EntropyData;

    init_entropy();
    mix_entropy((UINT64) (UINTN) ImageHandle);
    mix_entropy((UINT64) (UINTN) SystemTable);

    G->SystemTable->ConOut->OutputString(G->SystemTable->ConOut, L"Hello, world!\r\n");

    return EFI_SUCCESS;
}

SECTION(".text")

static VOID init_sha(Context)
SHA256 *Context;
{
    Context->H[0] = 0x6a09e667;
    Context->H[1] = 0xbb67ae85;
    Context->H[2] = 0x3c6ef372;
    Context->H[3] = 0xa54ff53a;
    Context->H[4] = 0x510e527f;
    Context->H[5] = 0x9b05688c;
    Context->H[6] = 0x1f83d9ab;
    Context->H[7] = 0x5be0cd19;

    Context->BufferLen = 0;
    Context->TotalLen = 0;

    return;
}

static VOID init_entropy(VOID)
{
    init_sha(&G->Entropy->Hash);
    G->Entropy->Samples = 0;

    return;
}

static VOID mix_entropy(Context)
UINT64 Context;
{
    static UINT8 Sample[16];

    store64(Sample, ReadCycleCounter());
    store64(Sample + 8, Context);

    update_sha(&G->Entropy->Hash, Sample, sizeof(Sample));

    G->Entropy->Samples++;

    return;
}

static VOID store64(P, V)
UINT8 P[];
UINT64 V;
{
    store32(P, (UINT32) V);
    store32(P + 4, (UINT32) (V >> 32));

    return;
}

static VOID store32(P, V)
UINT8 P[];
UINT32 V;
{
    P[0] = (UINT8) V;
    P[1] = (UINT8) (V >> 8);
    P[2] = (UINT8) (V >> 16);
    P[3] = (UINT8) (V >> 24);

    return;
}

static VOID update_sha(Context, Data, Len)
SHA256 *Context;
UINT8 *Data;
UINTN Len;
{
    Context->TotalLen += Len;
    while (Len--) {
        Context->Buffer[Context->BufferLen++] = *Data++;
        if (Context->BufferLen == 64) {
            block_sha(Context->H, Context->Buffer);
            Context->BufferLen = 0;
        }
    }

    return;
}

static VOID block_sha(H, Block)
UINT32 H[8];
UINT8 Block[64];
{
    noaof UINT32 a, b, c, d, e, f, g, h;
    noaof UINT32 T1, T2;

    static UINT32 W[64];

    noaof UINTN i;

    for (i = 0; i < 16; i++) W[i] = load32(Block + i * 4);
    for (i = 16; i < 64; i++) {
        W[i] = W[i - 16] + W[i - 7] +
            (rotr32(W[i - 15], 7) ^ rotr32(W[i - 15], 18) ^ (W[i - 15] >> 3)) +
            (rotr32(W[i - 2], 17) ^ rotr32(W[i - 2], 19) ^ (W[i - 2] >> 10));
    }

    a = H[0]; b = H[1]; c = H[2]; d = H[3]; e = H[4]; f = H[5]; g = H[6]; h = H[7];

    for (i = 0; i < 64; i++) {
        T1 = h + (rotr32(e, 6) ^ rotr32(e, 11) ^ rotr32(e, 25)) + ((e & f) ^ (~e & g)) + SHA256K[i] + W[i];
        T2 = (rotr32(a, 2) ^ rotr32(a, 13) ^ rotr32(a, 22)) + ((a & b) ^ (a & c) ^ (b & c));

        h = g; g = f; f = e;
        e = d + T1;
        d = c; c = b; b = a;
        a = T1 + T2;
    }

    H[0] += a; H[1] += b; H[2] += c; H[3] += d; H[4] += e; H[5] += f; H[6] += g; H[7] += h;

    return;
}

static UINT32 rotl32(X, N)
UINT32 X, N;
{
    return (X << N) | (X >> (32 - N));
}

static UINT32 rotr32(X, N)
UINT32 X, N;
{
    return (X >> N) | (X << (32 - N));
}

static VOID store32_be(P, V)
UINT8 *P;
UINT32 V;
{
    P[0] = (UINT8) (V >> 24);
    P[1] = (UINT8) (V >> 16);
    P[2] = (UINT8) (V >> 8);
    P[3] = (UINT8) V;

    return;
}

static UINT32 load32_be(P)
UINT8 *P;
{
    return ((UINT32) P[0] << 24) | ((UINT32) P[1] << 16) | ((UINT32) P[2] << 8) | (UINT32) P[3];
}

static UINT32 load32(P)
UINT8 *P;
{
    return (UINT32) P[0] | ((UINT32) P[1] << 8) | ((UINT32) P[2] << 16) | ((UINT32) P[3] << 24);
}
