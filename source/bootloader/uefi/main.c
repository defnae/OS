// source/bootloader/uefi/main.c

#include "../../headers/def.h"
#include "headers/efi.h"

#define EFI_ERROR(Status) (((INTN) (Status)) < 0)

#define DEVICE_PATH_NODE_LENGTH(node) ((UINT16) ((node)->Length[0] | ((node)->Length[1] << 8)))

#define END_DEVICE_PATH_TYPE 0x7F
#define END_ENTIRE_DEVICE_PATH_SUBTYPE 0xFF
#define END_INSTANCE_DEVICE_PATH_SUBTYPE 0x01

typedef struct {
    EFI_LOADED_IMAGE_PROTOCOL *LoadedImage;
    EFI_SIMPLE_FILE_SYSTEM_PROTOCOL *FileSystem;
    EFI_HANDLE Partition;
} Globals;

static Globals GlobalData;
static Globals *G = &GlobalData;

static EFIAPI EFI_DEVICE_PATH_PROTOCOL *last_node(EFI_DEVICE_PATH_PROTOCOL *);

EFIAPI EFI_STATUS efi_main(ImageHandle, SystemTable)
EFI_HANDLE ImageHandle;
EFI_SYSTEM_TABLE *SystemTable;
{
    EFI_STATUS Status;

    EFI_DEVICE_PATH_PROTOCOL *ESPPath;
    EFI_DEVICE_PATH_PROTOCOL *ESPLastNode;
    UINTN ESPPrefixLen;

    UINTN HandleCount;
    EFI_HANDLE *Handles;

    UINTN i;

    Status = SystemTable->BootServices->OpenProtocol(ImageHandle, &EfiLoadedImageProtocolGuid, (VOID **) &G->LoadedImage, ImageHandle, NULL, EFI_OPEN_PROTOCOL_BY_HANDLE_PROTOCOL);

    if (EFI_ERROR(Status)) {
        SystemTable->ConOut->OutputString(SystemTable->ConOut, L"Failed to open Loaded Image Protocol.\r\n");

        return Status;
    }

    Status = SystemTable->BootServices->OpenProtocol(G->LoadedImage->DeviceHandle, &EfiDevicePathProtocolGuid, (VOID **) &ESPPath, ImageHandle, NULL, EFI_OPEN_PROTOCOL_BY_HANDLE_PROTOCOL);

    if (EFI_ERROR(Status)) {
        SystemTable->ConOut->OutputString(SystemTable->ConOut, L"Failed to get ESP device path.\r\n");

        return Status;
    }

    if (!ESPPath) {
        SystemTable->ConOut->OutputString(SystemTable->ConOut, L"ESP device path is NULL.\r\n");

        return EFI_NOT_FOUND;
    }

    ESPLastNode = last_node(ESPPath);

    if (!ESPLastNode) {
        SystemTable->ConOut->OutputString(SystemTable->ConOut, L"Invalid ESP device path.\r\n");

        return EFI_DEVICE_ERROR;
    }

    ESPPrefixLen = (UINTN) ((UINT8 *) ESPLastNode - (UINT8 *) ESPPath);

    Status = SystemTable->BootServices->LocateHandleBuffer(ByProtocol, &EfiSimpleFileSystemProtocolGuid, NULL, &HandleCount, &Handles);

    if (EFI_ERROR(Status)) {
        SystemTable->ConOut->OutputString(SystemTable->ConOut, L"Failed to locate filesystem handles.\r\n");

        return Status;
    }

    for (i = 0; i < HandleCount; i++) {
        EFI_DEVICE_PATH_PROTOCOL *CandidatePath, *CandidateLastNode;
        UINTN CandidatePrefixLen;
        BOOLEAN Same;
        UINTN j;

        CandidatePath = NULL;

        Status = SystemTable->BootServices->OpenProtocol(Handles[i], &EfiDevicePathProtocolGuid, (VOID **) &CandidatePath, ImageHandle, NULL, EFI_OPEN_PROTOCOL_BY_HANDLE_PROTOCOL);

        if (EFI_ERROR(Status)) continue;

        if (!CandidatePath) continue;

        CandidateLastNode = last_node(CandidatePath);

        if (!CandidateLastNode) continue;

        CandidatePrefixLen = (UINTN) ((UINT8 *) CandidateLastNode - (UINT8 *) CandidatePath);

        if (CandidatePrefixLen != ESPPrefixLen) continue;

        Same = TRUE;

        for (j = 0; j < ESPPrefixLen; j++) if (((UINT8 *) ESPPath)[j] != ((UINT8 *) CandidatePath)[j]) {
            Same = FALSE;

            break;
        }

        if (Same) {
            G->Partition = Handles[i];

            break;
        }
    }

    SystemTable->BootServices->FreePool(Handles);

    if (!G->Partition) {
        SystemTable->ConOut->OutputString(SystemTable->ConOut, L"Failed to find kernel partition.\r\n");

        return EFI_NOT_FOUND;
    }

    Status = SystemTable->BootServices->OpenProtocol(G->Partition, &EfiSimpleFileSystemProtocolGuid, (VOID **) &G->FileSystem, ImageHandle, NULL, EFI_OPEN_PROTOCOL_BY_HANDLE_PROTOCOL);

    if (EFI_ERROR(Status)) {
        SystemTable->ConOut->OutputString(SystemTable->ConOut, L"Failed to open file system.\r\n");

        return Status;
    }

    EFI_FILE_PROTOCOL *Root;
    EFI_FILE_PROTOCOL *Kernel;

    Status = G->FileSystem->OpenVolume(
        G->FileSystem,
        &Root
    );

    if (EFI_ERROR(Status)) {
        SystemTable->ConOut->OutputString(SystemTable->ConOut, L"Failed to open filesystem volume.\r\n");

        return Status;
    }

    Status = Root->Open(Root, &Kernel, L"kernel", EFI_FILE_MODE_READ, 0);

    if (EFI_ERROR(Status)) {
        SystemTable->ConOut->OutputString(SystemTable->ConOut, L"Failed to open kernel.\r\n");

        return Status;
    }

    SystemTable->ConOut->OutputString(SystemTable->ConOut, L"Kernel opened successfully!\r\n");

    while (TRUE);

    return EFI_SUCCESS;
}

static EFIAPI EFI_DEVICE_PATH_PROTOCOL *last_node(dp)
EFI_DEVICE_PATH_PROTOCOL *dp;
{
    EFI_DEVICE_PATH_PROTOCOL *prev;

    if (!dp) return NULL;
    prev = dp;

    while (!(dp->Type == END_DEVICE_PATH_TYPE &&
         dp->SubType == END_ENTIRE_DEVICE_PATH_SUBTYPE)) {
             UINT16 Length;

             Length = DEVICE_PATH_NODE_LENGTH(dp);
             if (Length < 4) return NULL;

             prev = dp;

             dp = (EFI_DEVICE_PATH_PROTOCOL *) ((UINT8 *) dp + Length);
         }

    return prev;
}
