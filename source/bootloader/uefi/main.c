// source/bootloader/uefi/main.c

#include <headers/def.h>
#include <bootloader/uefi/headers/efi.h>

#define NORETURN __attribute__((noreturn))

EFIAPI NORETURN EFI_STATUS efi_main(ImageHandle, SystemTable)
EFI_HANDLE ImageHandle;
EFI_SYSTEM_TABLE *SystemTable;
{
    (void) ImageHandle;

    SystemTable->ConOut->OutputString(SystemTable->ConOut, L"Hello, world!\r\n");

    while (TRUE);

    /* return EFI_SUCCESS; */
}
