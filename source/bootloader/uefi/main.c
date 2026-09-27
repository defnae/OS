// source/bootloader/uefi/main.c

#include <bootloader/uefi/headers/efi.h>

typedef struct {
    EFI_SYSTEM_TABLE *SystemTable;
} Globals;

static Globals GlobalData;
static Globals *G = &GlobalData;

#define SECTION(x) __attribute__((section(x)))

SECTION(".text.efi_main")
EFIAPI EFI_STATUS efi_main(ImageHandle, SystemTable)
IN EFI_HANDLE ImageHandle;
IN EFI_SYSTEM_TABLE *SystemTable;
{
    (void) ImageHandle;

    G->SystemTable = SystemTable;

    G->SystemTable->ConOut->OutputString(G->SystemTable->ConOut, L"Hello, world!\r\n");

    return EFI_SUCCESS;
}
