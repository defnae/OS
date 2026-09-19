// source/bootloader/uefi/main.c

#include <bootloader/uefi/headers/efi.h>

EFIAPI efi_main(EFI_HANDLE ImageHandle, EFI_SYSTEM_TABLE *SystemTable) {
    (void) ImageHandle;

    SystemTable->ConOut->OutputString(SystemTable->ConOut, L"Hello, world!\r\n");

    while (TRUE);

    return 0;
}
