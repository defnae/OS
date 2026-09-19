// bootloader/headers/efi.h

#ifndef EFI_H
#define EFI_H

/* 2: Overview */

/* 2.3: Calling Conventions */

/* 2.3.1: Data Types */

typedef __UINT8_TYPE__ BOOLEAN;

typedef __PTRDIFF_TYPE__ INTN;
typedef __SIZE_TYPE__ UINTN;

typedef __INT8_TYPE__ INT8;
typedef __UINT8_TYPE__ UINT8;

typedef __INT16_TYPE__ INT16;
typedef __UINT16_TYPE__ UINT16;

typedef __INT32_TYPE__ INT32;
typedef __UINT32_TYPE__ UINT32;

typedef __INT64_TYPE__ INT64;
typedef __UINT64_TYPE__ UINT64;

typedef char CHAR8;
typedef __UINT16_TYPE__ CHAR16;

typedef void VOID;

typedef struct {
    UINT32 Data1;
    UINT16 Data2;
    UINT16 Data3;
    UINT8 Data4[8];
} EFI_GUID;

typedef UINTN EFI_STATUS;

typedef VOID *EFI_HANDLE;
typedef VOID *EFI_EVENT;

typedef UINT64 EFI_LBA;
typedef UINTN EFI_TPL;

typedef UINT64 EFI_PHYSICAL_ADDRESS;
typedef UINT64 EFI_VIRTUAL_ADDRESS;

#define TRUE ((BOOLEAN) 1)
#define FALSE ((BOOLEAN) 0)

#define IN
#define OUT
#define OPTIONAL

#define CONST const

#ifdef __x86_64__
#define EFIAPI __attribute__((ms_abi))
#else
#define EFIAPI
#endif

/* Forward Declarations */

typedef struct _EFI_SYSTEM_TABLE EFI_SYSTEM_TABLE;
typedef struct _EFI_BOOT_SERVICES EFI_BOOT_SERVICES;
typedef struct _EFI_RUNTIME_SERVICES EFI_RUNTIME_SERVICES;
typedef struct _EFI_CONFIGURATION_TABLE EFI_CONFIGURATION_TABLE;
typedef struct _EFI_MEMORY_DESCRIPTOR EFI_MEMORY_DESCRIPTOR;
typedef struct _EFI_OPEN_PROTOCOL_INFORMATION_ENTRY EFI_OPEN_PROTOCOL_INFORMATION_ENTRY;
typedef struct _EFI_TIME EFI_TIME;
typedef struct _EFI_TIME_CAPABILITIES EFI_TIME_CAPABILITIES;
typedef struct _EFI_CAPSULE_HEADER EFI_CAPSULE_HEADER;
typedef struct _EFI_DEVICE_PATH_PROTOCOL EFI_DEVICE_PATH_PROTOCOL;
typedef struct _EFI_SIMPLE_TEXT_INPUT_PROTOCOL EFI_SIMPLE_TEXT_INPUT_PROTOCOL;
typedef struct _SIMPLE_TEXT_OUTPUT_MODE SIMPLE_TEXT_OUTPUT_MODE;
typedef struct _EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL;
typedef struct _EFI_GRAPHICS_OUTPUT_PROTOCOL EFI_GRAPHICS_OUTPUT_PROTOCOL;
typedef struct _EFI_BLOCK_IO_PROTOCOL EFI_BLOCK_IO_PROTOCOL;
typedef struct _EFI_LOAD_FILE_PROTOCOL EFI_LOAD_FILE_PROTOCOL;
typedef struct _EFI_LOAD_FILE2_PROTOCOL EFI_LOAD_FILE2_PROTOCOL;
typedef struct _EFI_SIMPLE_FILE_SYSTEM_PROTOCOL EFI_SIMPLE_FILE_SYSTEM_PROTOCOL;
typedef struct _EFI_FILE_PROTOCOL EFI_FILE_PROTOCOL;
typedef struct _EFI_DISK_IO_PROTOCOL EFI_DISK_IO_PROTOCOL;
typedef struct _EFI_STORAGE_SECURITY_COMMAND_PROTOCOL EFI_STORAGE_SECURITY_COMMAND_PROTOCOL;

/* 7.1: Event, Timer, and Task Priority Services (Helper Types) */

/* 7.1.1: EFI_EVENT_NOTIFY */
typedef VOID (EFIAPI *EFI_EVENT_NOTIFY) (
    IN EFI_EVENT Event,
    IN VOID *Context
);

/* 7.1.2: EFI_TIMER_DELAY */
typedef UINTN EFI_TIMER_DELAY;
#define TimerCancel 0
#define TimerPeriodic 1
#define TimerRelative 2

/* 7.2: Memory Allocation Services (Helper Types) */

/* 7.2.1: EFI_ALLOCATE_TYPE */
typedef UINTN EFI_ALLOCATE_TYPE;
#define AllocateAnyPages 0
#define AllocateMaxAddress 1
#define AllocateAddress 2
#define MaxAllocateType 3

/* 7.2.2: EFI_MEMORY_TYPE */
typedef UINTN EFI_MEMORY_TYPE;
#define EfiReservedMemoryType 0
#define EfiLoaderCode 1
#define EfiLoaderData 2
#define EfiBootServicesCode 3
#define EfiBootServicesData 4
#define EfiRuntimeServicesCode 5
#define EfiRuntimeServicesData 6
#define EfiConventionalMemory 7
#define EfiUnusableMemory 8
#define EfiACPIReclaimMemory 9
#define EfiACPIMemoryNVS 10
#define EfiMemoryMappedIO 11
#define EfiMemoryMappedIOPortSpace 12
#define EfiPalCode 13
#define EfiPersistentMemory 14
#define EfiUnacceptedMemoryType 15
#define EfiMaxMemoryType 16

/* 7.2.3: EFI_MEMORY_DESCRIPTOR */
typedef struct _EFI_MEMORY_DESCRIPTOR {
    UINT32 Type;
    EFI_PHYSICAL_ADDRESS PhysicalStart;
    EFI_VIRTUAL_ADDRESS VirtualStart;
    UINT64 NumberOfPages;
    UINT64 Attribute;
} EFI_MEMORY_DESCRIPTOR;

/* 7.3: Protocol Handler Services (Helper Types) */

/* 7.3.1: EFI_INTERFACE_TYPE */
typedef UINTN EFI_INTERFACE_TYPE;
#define EFI_NATIVE_INTERFACE 0

/* 7.3.2: EFI_LOCATE_SEARCH_TYPE */
typedef UINTN EFI_LOCATE_SEARCH_TYPE;
#define AllHandles 0
#define ByRegisterNotify 1
#define ByProtocol 2

/* 7.3.3: EFI_OPEN_PROTOCOL_INFORMATION_ENTRY */
typedef struct _EFI_OPEN_PROTOCOL_INFORMATION_ENTRY {
    EFI_HANDLE AgentHandle;
    EFI_HANDLE ControllerHandle;
    UINT32 Attributes;
    UINT32 OpenCount;
} EFI_OPEN_PROTOCOL_INFORMATION_ENTRY;

#define EFI_OPEN_PROTOCOL_BY_HANDLE_PROTOCOL 0x00000001
#define EFI_OPEN_PROTOCOL_GET_PROTOCOL 0x00000002
#define EFI_OPEN_PROTOCOL_TEST_PROTOCOL 0x00000004
#define EFI_OPEN_PROTOCOL_BY_CHILD_CONTROLLER 0x00000008
#define EFI_OPEN_PROTOCOL_BY_DRIVER 0x00000010
#define EFI_OPEN_PROTOCOL_EXCLUSIVE 0x00000020

/* 8.3: Time Services (Helper Types) */

/* 8.3.1: EFI_TIME */
typedef struct _EFI_TIME {
    UINT16 Year;
    UINT8 Month;
    UINT8 Day;
    UINT8 Hour;
    UINT8 Minute;
    UINT8 Second;
    UINT8 Pad1;
    UINT32 Nanosecond;
    INT16 TimeZone;
    UINT8 Daylight;
    UINT8 Pad2;
} EFI_TIME;

/* 8.3.2: EFI_TIME_CAPABILITIES */
typedef struct _EFI_TIME_CAPABILITIES {
    UINT32 Resolution;
    UINT32 Accuracy;
    BOOLEAN SetsToZero;
} EFI_TIME_CAPABILITIES;

/* 8.5: Miscellaneous Runtime Services (Helper Types) */

/* 8.5.1: EFI_RESET_TYPE */
typedef UINTN EFI_RESET_TYPE;
#define EfiResetCold 0
#define EfiResetWarm 1
#define EfiResetShutdown 2
#define EfiResetPlatformSpecific 3

/* 8.5.2: EFI_CAPSULE_HEADER */
typedef struct _EFI_CAPSULE_HEADER {
    EFI_GUID CapsuleGuid;
    UINT32 HeaderSize;
    UINT32 Flags;
    UINT32 CapsuleImageSize;
} EFI_CAPSULE_HEADER;

/* 12.3: Simple Text Input Protocol (Helper Types) */

/* 12.3.1: Scan Codes */
#define SCAN_UP 0x0001
#define SCAN_DOWN 0x0002
#define SCAN_RIGHT 0x0003
#define SCAN_LEFT 0x0004
#define SCAN_HOME 0x0005
#define SCAN_END 0x0006
#define SCAN_INSERT 0x0007
#define SCAN_DELETE 0x0008
#define SCAN_PAGE_UP 0x0009
#define SCAN_PAGE_DOWN 0x000A
#define SCAN_F1 0x000B
#define SCAN_F2 0x000C
#define SCAN_F10 0x0014
#define SCAN_ESC 0x0017

/* 12.3.2: EFI_INPUT_KEY */
typedef struct {
    UINT16 ScanCode;
    CHAR16 UnicodeChar;
} EFI_INPUT_KEY;

/* 12.4: Simple Text Output Protocol (Helper Types) */

/* 12.4.1: Foreground Colors */
#define EFI_BLACK 0x00
#define EFI_BLUE 0x01
#define EFI_GREEN 0x02
#define EFI_CYAN 0x03
#define EFI_RED 0x04
#define EFI_MAGENTA 0x05
#define EFI_BROWN 0x06
#define EFI_LIGHTGRAY 0x07
#define EFI_BRIGHT 0x08
#define EFI_DARKGRAY 0x08
#define EFI_LIGHTBLUE 0x09
#define EFI_LIGHTGREEN 0x0A
#define EFI_LIGHTCYAN 0x0B
#define EFI_LIGHTRED 0x0C
#define EFI_LIGHTMAGENTA 0x0D
#define EFI_YELLOW 0x0E
#define EFI_WHITE 0x0F

/* 12.4.2: Background Colors */
#define EFI_BACKGROUND_BLACK 0x00
#define EFI_BACKGROUND_BLUE 0x10
#define EFI_BACKGROUND_GREEN 0x20
#define EFI_BACKGROUND_CYAN 0x30
#define EFI_BACKGROUND_RED 0x40
#define EFI_BACKGROUND_MAGENTA 0x50
#define EFI_BACKGROUND_BROWN 0x60
#define EFI_BACKGROUND_LIGHTGRAY 0x70

/* 12.4.3: SIMPLE_TEXT_OUTPUT_MODE */
typedef struct _SIMPLE_TEXT_OUTPUT_MODE {
    INT32 MaxMode;
    INT32 Mode;
    INT32 Attribute;
    INT32 CursorColumn;
    INT32 CursorRow;
    BOOLEAN CursorVisible;
} SIMPLE_TEXT_OUTPUT_MODE;

/* 12.9: Graphics Output Protocol (Helper Types) */

/* 12.9.1: EFI_PIXEL_BITMASK */
typedef struct {
    UINT32 RedMask;
    UINT32 GreenMask;
    UINT32 BlueMask;
    UINT32 ReservedMask;
} EFI_PIXEL_BITMASK;

/* 12.9.1: EFI_GRAPHICS_PIXEL_FORMAT */
typedef UINTN EFI_GRAPHICS_PIXEL_FORMAT;
#define PixelRedGreenBlueReserved8BitPerColor 0
#define PixelBlueGreenRedReserved8BitPerColor 1
#define PixelBitMask 2
#define PixelBltOnly 3
#define PixelFormatMax 4

/* 12.9.1: EFI_GRAPHICS_OUTPUT_BLT_OPERATION */
typedef UINTN EFI_GRAPHICS_OUTPUT_BLT_OPERATION;
#define EfiBltVideoFill 0
#define EfiBltVideoToBltBuffer 1
#define EfiBltBufferToVideo 2
#define EfiBltVideoToVideo 3
#define EfiGraphicsOutputBltOperationMax 4

/* 12.9.1: EFI_GRAPHICS_OUTPUT_BLT_PIXEL */
typedef struct {
    UINT8 Blue;
    UINT8 Green;
    UINT8 Red;
    UINT8 Reserved;
} EFI_GRAPHICS_OUTPUT_BLT_PIXEL;

/* 12.9.1: EFI_GRAPHICS_OUTPUT_MODE_INFORMATION */
typedef struct {
    UINT32 Version;
    UINT32 HorizontalResolution;
    UINT32 VerticalResolution;
    EFI_GRAPHICS_PIXEL_FORMAT PixelFormat;
    EFI_PIXEL_BITMASK PixelInformation;
    UINT32 PixelsPerScanLine;
} EFI_GRAPHICS_OUTPUT_MODE_INFORMATION;

/* 12.9.2: EFI_GRAPHICS_OUTPUT_PROTOCOL_MODE */
typedef struct {
    UINT32 MaxMode;
    UINT32 Mode;
    EFI_GRAPHICS_OUTPUT_MODE_INFORMATION *Info;
    UINTN SizeOfInfo;
    EFI_PHYSICAL_ADDRESS FrameBufferBase;
    UINTN FrameBufferSize;
} EFI_GRAPHICS_OUTPUT_PROTOCOL_MODE;

/* 13.1: Block I/O Protocol (Helper Types) */

/* 13.1.1: EFI_BLOCK_IO_MEDIA */
typedef struct {
    UINT32 MediaId;
    BOOLEAN RemovableMedia;
    BOOLEAN MediaPresent;
    BOOLEAN LogicalPartition;
    BOOLEAN ReadOnly;
    BOOLEAN WriteCaching;
    UINT32 BlockSize;
    UINT32 IoAlign;
    EFI_LBA LastBlock;
    EFI_LBA LowestAlignedLba;
    UINT32 LogicalBlocksPerPhysicalBlock;
    UINT32 OptimalTransferLengthGranularity;
} EFI_BLOCK_IO_MEDIA;

/* 13.5: EFI File Protocol (Helper Types) */

/* 13.5.15: EFI_FILE_IO_TOKEN */
typedef struct {
    EFI_EVENT Event;
    EFI_STATUS Status;
    UINTN BufferSize;
    VOID *Buffer;
} EFI_FILE_IO_TOKEN;

/* 13.5.16: EFI_FILE_INFO */
typedef struct {
    UINT64 Size;
    UINT64 FileSize;
    UINT64 PhysicalSize;
    EFI_TIME CreateTime;
    EFI_TIME LastAccessTime;
    EFI_TIME ModificationTime;
    UINT64 Attribute;
    CHAR16 FileName[];
} EFI_FILE_INFO;

/* 4: EFI System Table */

/* 4.1: UEFI Image Entry Point */

/* 4.1.1: EFI_IMAGE_ENTRY_POINT */
typedef EFI_STATUS (EFIAPI *EFI_IMAGE_ENTRY_POINT) (
    IN EFI_HANDLE ImageHandle,
    IN EFI_SYSTEM_TABLE *SystemTable
);

/* 4.2: EFI Table Header */

/* 4.2.1: EFI_TABLE_HEADER */
typedef struct {
    UINT64 Signature;
    UINT32 HeaderSize;
    UINT32 Revision;
    UINT32 CRC32;
    UINT32 Reserved;
} EFI_TABLE_HEADER;

/* 4.3: EFI System Table */

/* 4.3.1: EFI_SYSTEM_TABLE */
typedef struct _EFI_SYSTEM_TABLE {
    EFI_TABLE_HEADER Hdr;
    CHAR16 *FirmwareVendor;
    UINT32 FirmwareRevision;
    EFI_HANDLE ConsoleInHandle;
    EFI_SIMPLE_TEXT_INPUT_PROTOCOL *ConIn;
    EFI_HANDLE ConsoleOutHandle;
    EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL *ConOut;
    EFI_HANDLE StandardErrorHandle;
    EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL *StdErr;
    EFI_RUNTIME_SERVICES *RuntimeServices;
    EFI_BOOT_SERVICES *BootServices;
    UINTN NumberOfTableEntries;
    EFI_CONFIGURATION_TABLE *ConfigurationTable;
} EFI_SYSTEM_TABLE;

/* 7: Services - Boot Services */

/* 7.1: Event, Timer, and Task Priority Services */

/* 7.1.1: EFI_BOOT_SERVICES.CreateEvent() */
typedef EFI_STATUS (EFIAPI *EFI_CREATE_EVENT) (
    IN UINT32 Type,
    IN EFI_TPL NotifyTpl,
    IN EFI_EVENT_NOTIFY NotifyFunction OPTIONAL,
    IN VOID *NotifyContext OPTIONAL,
    OUT EFI_EVENT *Event
);

/* 7.1.2: EFI_BOOT_SERVICES.CreateEventEx() */
typedef EFI_STATUS (EFIAPI *EFI_CREATE_EVENT_EX) (
    IN UINT32 Type,
    IN EFI_TPL NotifyTpl,
    IN EFI_EVENT_NOTIFY NotifyFunction OPTIONAL,
    IN CONST VOID *NotifyContext OPTIONAL,
    IN CONST EFI_GUID *EventGroup OPTIONAL,
    OUT EFI_EVENT *Event
);

/* 7.1.3: EFI_BOOT_SERVICES.CloseEvent() */
typedef EFI_STATUS (EFIAPI *EFI_CLOSE_EVENT) (
    IN EFI_EVENT Event
);

/* 7.1.4: EFI_BOOT_SERVICES.SignalEvent() */
typedef EFI_STATUS (EFIAPI *EFI_SIGNAL_EVENT) (
    IN EFI_EVENT Event
);

/* 7.1.5: EFI_BOOT_SERVICES.WaitForEvent() */
typedef EFI_STATUS (EFIAPI *EFI_WAIT_FOR_EVENT) (
    IN UINTN NumberOfEvents,
    IN EFI_EVENT *Event,
    OUT UINTN *Index
);

/* 7.1.6: EFI_BOOT_SERVICES.CheckEvent() */
typedef EFI_STATUS (EFIAPI *EFI_CHECK_EVENT) (
    IN EFI_EVENT Event
);

/* 7.1.7: EFI_BOOT_SERVICES.SetTimer() */
typedef EFI_STATUS (EFIAPI *EFI_SET_TIMER) (
    IN EFI_EVENT Event,
    IN EFI_TIMER_DELAY Type,
    IN UINT64 TriggerTime
);

/* 7.1.8: EFI_BOOT_SERVICES.RaiseTPL() */
typedef EFI_TPL (EFIAPI *EFI_RAISE_TPL) (
    IN EFI_TPL NewTpl
);

/* 7.1.9: EFI_BOOT_SERVICES.RestoreTPL() */
typedef VOID (EFIAPI *EFI_RESTORE_TPL) (
    IN EFI_TPL OldTpl
);

/* 7.2: Memory Allocation Services */

/* 7.2.1: EFI_BOOT_SERVICES.AllocatePages() */
typedef EFI_STATUS (EFIAPI *EFI_ALLOCATE_PAGES) (
    IN EFI_ALLOCATE_TYPE Type,
    IN EFI_MEMORY_TYPE MemoryType,
    IN UINTN Pages,
    IN OUT EFI_PHYSICAL_ADDRESS *Memory
);

/* 7.2.2: EFI_BOOT_SERVICES.FreePages() */
typedef EFI_STATUS (EFIAPI *EFI_FREE_PAGES) (
    IN EFI_PHYSICAL_ADDRESS Memory,
    IN UINTN Pages
);

/* 7.2.3: EFI_BOOT_SERVICES.GetMemoryMap() */
typedef EFI_STATUS (EFIAPI *EFI_GET_MEMORY_MAP) (
    IN OUT UINTN *MemoryMapSize,
    OUT EFI_MEMORY_DESCRIPTOR *MemoryMap,
    OUT UINTN *MapKey,
    OUT UINTN *DescriptorSize,
    OUT UINT32 *DescriptorVersion
);

/* 7.2.4: EFI_BOOT_SERVICES.AllocatePool() */
typedef EFI_STATUS (EFIAPI *EFI_ALLOCATE_POOL) (
    IN EFI_MEMORY_TYPE PoolType,
    IN UINTN Size,
    OUT VOID **Buffer
);

/* 7.2.5: EFI_BOOT_SERVICES.FreePool() */
typedef EFI_STATUS (EFIAPI *EFI_FREE_POOL) (
    IN VOID *Buffer
);

/* 7.3: Protocol Handler Services */

/* 7.3.2: EFI_BOOT_SERVICES.InstallProtocolInterface() */
typedef EFI_STATUS (EFIAPI *EFI_INSTALL_PROTOCOL_INTERFACE) (
    IN OUT EFI_HANDLE *Handle,
    IN EFI_GUID *Protocol,
    IN EFI_INTERFACE_TYPE InterfaceType,
    IN VOID *Interface
);

/* 7.3.3: EFI_BOOT_SERVICES.UninstallProtocolInterface() */
typedef EFI_STATUS (EFIAPI *EFI_UNINSTALL_PROTOCOL_INTERFACE) (
    IN EFI_HANDLE Handle,
    IN EFI_GUID *Protocol,
    IN VOID *Interface
);

/* 7.3.4: EFI_BOOT_SERVICES.ReinstallProtocolInterface() */
typedef EFI_STATUS (EFIAPI *EFI_REINSTALL_PROTOCOL_INTERFACE) (
    IN EFI_HANDLE Handle,
    IN EFI_GUID *Protocol,
    IN VOID *OldInterface,
    IN VOID *NewInterface
);

/* 7.3.5: EFI_BOOT_SERVICES.RegisterProtocolNotify() */
typedef EFI_STATUS (EFIAPI *EFI_REGISTER_PROTOCOL_NOTIFY) (
    IN EFI_GUID *Protocol,
    IN EFI_EVENT Event,
    OUT VOID **Registration
);

/* 7.3.6: EFI_BOOT_SERVICES.LocateHandle() */
typedef EFI_STATUS (EFIAPI *EFI_LOCATE_HANDLE) (
    IN EFI_LOCATE_SEARCH_TYPE SearchType,
    IN EFI_GUID *Protocol OPTIONAL,
    IN VOID *SearchKey OPTIONAL,
    IN OUT UINTN *BufferSize,
    OUT EFI_HANDLE *Buffer
);

/* 7.3.7: EFI_BOOT_SERVICES.HandleProtocol() */
typedef EFI_STATUS (EFIAPI *EFI_HANDLE_PROTOCOL) (
    IN EFI_HANDLE Handle,
    IN EFI_GUID *Protocol,
    OUT VOID **Interface
);

/* 7.3.8: EFI_BOOT_SERVICES.LocateDevicePath() */
typedef EFI_STATUS (EFIAPI *EFI_LOCATE_DEVICE_PATH) (
    IN EFI_GUID *Protocol,
    IN OUT EFI_DEVICE_PATH_PROTOCOL **DevicePath,
    OUT EFI_HANDLE *Device
);

/* 7.3.9: EFI_BOOT_SERVICES.OpenProtocol() */
typedef EFI_STATUS (EFIAPI *EFI_OPEN_PROTOCOL) (
    IN EFI_HANDLE Handle,
    IN EFI_GUID *Protocol,
    OUT VOID **Interface OPTIONAL,
    IN EFI_HANDLE AgentHandle,
    IN EFI_HANDLE ControllerHandle,
    IN UINT32 Attributes
);

/* 7.3.10: EFI_BOOT_SERVICES.CloseProtocol() */
typedef EFI_STATUS (EFIAPI *EFI_CLOSE_PROTOCOL) (
    IN EFI_HANDLE Handle,
    IN EFI_GUID *Protocol,
    IN EFI_HANDLE AgentHandle,
    IN EFI_HANDLE ControllerHandle
);

/* 7.3.11: EFI_BOOT_SERVICES.OpenProtocolInformation() */
typedef EFI_STATUS (EFIAPI *EFI_OPEN_PROTOCOL_INFORMATION) (
    IN EFI_HANDLE Handle,
    IN EFI_GUID *Protocol,
    OUT EFI_OPEN_PROTOCOL_INFORMATION_ENTRY **EntryBuffer,
    OUT UINTN *EntryCount
);

/* 7.3.12: EFI_BOOT_SERVICES.ConnectController() */
typedef EFI_STATUS (EFIAPI *EFI_CONNECT_CONTROLLER) (
    IN EFI_HANDLE ControllerHandle,
    IN EFI_HANDLE *DriverImageHandle OPTIONAL,
    IN EFI_DEVICE_PATH_PROTOCOL *RemainingDevicePath OPTIONAL,
    IN BOOLEAN Recursive
);

/* 7.3.13: EFI_BOOT_SERVICES.DisconnectController() */
typedef EFI_STATUS (EFIAPI *EFI_DISCONNECT_CONTROLLER) (
    IN EFI_HANDLE ControllerHandle,
    IN EFI_HANDLE DriverImageHandle OPTIONAL,
    IN EFI_HANDLE ChildHandle OPTIONAL
);

/* 7.3.14: EFI_BOOT_SERVICES.ProtocolsPerHandle() */
typedef EFI_STATUS (EFIAPI *EFI_PROTOCOLS_PER_HANDLE) (
    IN EFI_HANDLE Handle,
    OUT EFI_GUID ***ProtocolBuffer,
    OUT UINTN *ProtocolBufferCount
);

/* 7.3.15: EFI_BOOT_SERVICES.LocateHandleBuffer() */
typedef EFI_STATUS (EFIAPI *EFI_LOCATE_HANDLE_BUFFER) (
    IN EFI_LOCATE_SEARCH_TYPE SearchType,
    IN EFI_GUID *Protocol OPTIONAL,
    IN VOID *SearchKey OPTIONAL,
    OUT UINTN *NoHandles,
    OUT EFI_HANDLE **Buffer
);

/* 7.3.16: EFI_BOOT_SERVICES.LocateProtocol() */
typedef EFI_STATUS (EFIAPI *EFI_LOCATE_PROTOCOL) (
    IN EFI_GUID *Protocol,
    IN VOID *Registration OPTIONAL,
    OUT VOID **Interface
);

/* 7.3.17: EFI_BOOT_SERVICES.InstallMultipleProtocolInterfaces() */
typedef EFI_STATUS (EFIAPI *EFI_INSTALL_MULTIPLE_PROTOCOL_INTERFACES) (
    IN OUT EFI_HANDLE *Handle,
    ...
);

/* 7.3.18: EFI_BOOT_SERVICES.UninstallMultipleProtocolInterfaces() */
typedef EFI_STATUS (EFIAPI *EFI_UNINSTALL_MULTIPLE_PROTOCOL_INTERFACES) (
    IN EFI_HANDLE Handle,
    ...
);

/* 7.4: Image Services */

/* 7.4.1: EFI_BOOT_SERVICES.LoadImage() */
typedef EFI_STATUS (EFIAPI *EFI_IMAGE_LOAD) (
    IN BOOLEAN BootPolicy,
    IN EFI_HANDLE ParentImageHandle,
    IN EFI_DEVICE_PATH_PROTOCOL *DevicePath OPTIONAL,
    IN VOID *SourceBuffer OPTIONAL,
    IN UINTN SourceSize,
    OUT EFI_HANDLE *ImageHandle
);

/* 7.4.2: EFI_BOOT_SERVICES.StartImage() */
typedef EFI_STATUS (EFIAPI *EFI_IMAGE_START) (
    IN EFI_HANDLE ImageHandle,
    OUT UINTN *ExitDataSize,
    OUT CHAR16 **ExitData OPTIONAL
);

/* 7.4.3: EFI_BOOT_SERVICES.UnloadImage() */
typedef EFI_STATUS (EFIAPI *EFI_IMAGE_UNLOAD) (
    IN EFI_HANDLE ImageHandle
);

/* 7.4.5: EFI_BOOT_SERVICES.Exit() */
typedef EFI_STATUS (EFIAPI *EFI_EXIT) (
    IN EFI_HANDLE ImageHandle,
    IN EFI_STATUS ExitStatus,
    IN UINTN ExitDataSize,
    IN CHAR16 *ExitData OPTIONAL
);

/* 7.4.6: EFI_BOOT_SERVICES.ExitBootServices() */
typedef EFI_STATUS (EFIAPI *EFI_EXIT_BOOT_SERVICES) (
    IN EFI_HANDLE ImageHandle,
    IN UINTN MapKey
);

/* 7.5: Miscellaneous Boot Services */

/* 7.5.1: EFI_BOOT_SERVICES.SetWatchdogTimer() */
typedef EFI_STATUS (EFIAPI *EFI_SET_WATCHDOG_TIMER) (
    IN UINTN Timeout,
    IN UINT64 WatchdogCode,
    IN UINTN DataSize,
    IN CHAR16 *WatchdogData OPTIONAL
);

/* 7.5.2: EFI_BOOT_SERVICES.Stall() */
typedef EFI_STATUS (EFIAPI *EFI_STALL) (
    IN UINTN Microseconds
);

/* 7.5.3: EFI_BOOT_SERVICES.CopyMem() */
typedef VOID (EFIAPI *EFI_COPY_MEM) (
    IN VOID *Destination,
    IN VOID *Source,
    IN UINTN Size
);

/* 7.5.4: EFI_BOOT_SERVICES.SetMem() */
typedef VOID (EFIAPI *EFI_SET_MEM) (
    IN VOID *Buffer,
    IN UINTN Size,
    IN UINT8 Value
);

/* 7.5.5: EFI_BOOT_SERVICES.GetNextMonotonicCount() */
typedef EFI_STATUS (EFIAPI *EFI_GET_NEXT_MONOTONIC_COUNT) (
    OUT UINT64 *Count
);

/* 7.5.6: EFI_BOOT_SERVICES.InstallConfigurationTable() */
typedef EFI_STATUS (EFIAPI *EFI_INSTALL_CONFIGURATION_TABLE) (
    IN EFI_GUID *Guid,
    IN VOID *Table
);

/* 7.5.7: EFI_BOOT_SERVICES.CalculateCrc32() */
typedef EFI_STATUS (EFIAPI *EFI_CALCULATE_CRC32) (
    IN VOID *Data,
    IN UINTN DataSize,
    OUT UINT32 *Crc32
);

/* 4.4: EFI Boot Services Table */

/* 4.4.1: EFI_BOOT_SERVICES */
typedef struct _EFI_BOOT_SERVICES {
    EFI_TABLE_HEADER Hdr;

    /* 7.1: Task Priority Services */
    EFI_RAISE_TPL RaiseTPL;
    EFI_RESTORE_TPL RestoreTPL;

    /* 7.2: Memory Services */
    EFI_ALLOCATE_PAGES AllocatePages;
    EFI_FREE_PAGES FreePages;
    EFI_GET_MEMORY_MAP GetMemoryMap;
    EFI_ALLOCATE_POOL AllocatePool;
    EFI_FREE_POOL FreePool;

    /* 7.1: Event & Timer Services */
    EFI_CREATE_EVENT CreateEvent;
    EFI_SET_TIMER SetTimer;
    EFI_WAIT_FOR_EVENT WaitForEvent;
    EFI_SIGNAL_EVENT SignalEvent;
    EFI_CLOSE_EVENT CloseEvent;
    EFI_CHECK_EVENT CheckEvent;

    /* 7.3: Protocol Handler Services */
    EFI_INSTALL_PROTOCOL_INTERFACE InstallProtocolInterface;
    EFI_REINSTALL_PROTOCOL_INTERFACE ReinstallProtocolInterface;
    EFI_UNINSTALL_PROTOCOL_INTERFACE UninstallProtocolInterface;
    EFI_HANDLE_PROTOCOL HandleProtocol;
    VOID *Reserved;
    EFI_REGISTER_PROTOCOL_NOTIFY RegisterProtocolNotify;
    EFI_LOCATE_HANDLE LocateHandle;
    EFI_LOCATE_DEVICE_PATH LocateDevicePath;
    EFI_INSTALL_CONFIGURATION_TABLE InstallConfigurationTable;

    /* 7.4: Image Services */
    EFI_IMAGE_LOAD LoadImage;
    EFI_IMAGE_START StartImage;
    EFI_EXIT Exit;
    EFI_IMAGE_UNLOAD UnloadImage;
    EFI_EXIT_BOOT_SERVICES ExitBootServices;

    /* 7.5: Miscellaneous Services */
    EFI_GET_NEXT_MONOTONIC_COUNT GetNextMonotonicCount;
    EFI_STALL Stall;
    EFI_SET_WATCHDOG_TIMER SetWatchdogTimer;

    /* 7.3: DriverSupport Services */
    EFI_CONNECT_CONTROLLER ConnectController;
    EFI_DISCONNECT_CONTROLLER DisconnectController;

    /* 7.3: Open and Close Protocol Services */
    EFI_OPEN_PROTOCOL OpenProtocol;
    EFI_CLOSE_PROTOCOL CloseProtocol;
    EFI_OPEN_PROTOCOL_INFORMATION OpenProtocolInformation;

    /* 7.3: Library Services */
    EFI_PROTOCOLS_PER_HANDLE ProtocolsPerHandle;
    EFI_LOCATE_HANDLE_BUFFER LocateHandleBuffer;
    EFI_LOCATE_PROTOCOL LocateProtocol;
    EFI_INSTALL_MULTIPLE_PROTOCOL_INTERFACES InstallMultipleProtocolInterfaces;
    EFI_UNINSTALL_MULTIPLE_PROTOCOL_INTERFACES UninstallMultipleProtocolInterfaces;

    /* 7.5: 32-bit CRC Services */
    EFI_CALCULATE_CRC32 CalculateCrc32;

    /* 7.5: Miscellaneous Services (Continued) */
    EFI_COPY_MEM CopyMem;
    EFI_SET_MEM SetMem;
    EFI_CREATE_EVENT_EX CreateEventEx;
} EFI_BOOT_SERVICES;

/* 8: Services - Runtime Services */

/* 8.2: Variable Services */

/* 8.2.1: EFI_RUNTIME_SERVICES.GetVariable() */
typedef EFI_STATUS (EFIAPI *EFI_GET_VARIABLE) (
    IN CHAR16 *VariableName,
    IN EFI_GUID *VendorGuid,
    OUT UINT32 *Attributes OPTIONAL,
    IN OUT UINTN *DataSize,
    OUT VOID *Data OPTIONAL
);

/* 8.2.2: EFI_RUNTIME_SERVICES.GetNextVariableName() */
typedef EFI_STATUS (EFIAPI *EFI_GET_NEXT_VARIABLE_NAME) (
    IN OUT UINTN *VariableNameSize,
    IN OUT CHAR16 *VariableName,
    IN OUT EFI_GUID *VendorGuid
);

/* 8.2.3: EFI_RUNTIME_SERVICES.SetVariable() */
typedef EFI_STATUS (EFIAPI *EFI_SET_VARIABLE) (
    IN CHAR16 *VariableName,
    IN EFI_GUID *VendorGuid,
    IN UINT32 Attributes,
    IN UINTN DataSize,
    IN VOID *Data
);

/* 8.2.4: EFI_RUNTIME_SERVICES.QueryVariableInfo() */
typedef EFI_STATUS (EFIAPI *EFI_QUERY_VARIABLE_INFO) (
    IN UINT32 Attributes,
    OUT UINT64 *MaximumVariableStorageSize,
    OUT UINT64 *RemainingVariableStorageSize,
    OUT UINT64 *MaximumVariableSize
);

/* 8.3: Time Services */

/* 8.3.1: EFI_RUNTIME_SERVICES.GetTime() */
typedef EFI_STATUS (EFIAPI *EFI_GET_TIME) (
    OUT EFI_TIME *Time,
    OUT EFI_TIME_CAPABILITIES *Capabilities OPTIONAL
);

/* 8.3.2: EFI_RUNTIME_SERVICES.SetTime() */
typedef EFI_STATUS (EFIAPI *EFI_SET_TIME) (
    IN EFI_TIME *Time
);

/* 8.3.3: EFI_RUNTIME_SERVICES.GetWakeupTime() */
typedef EFI_STATUS (EFIAPI *EFI_GET_WAKEUP_TIME) (
    OUT BOOLEAN *Enabled,
    OUT BOOLEAN *Pending,
    OUT EFI_TIME *Time
);

/* 8.3.4: EFI_RUNTIME_SERVICES.SetWakeupTime() */
typedef EFI_STATUS (EFIAPI *EFI_SET_WAKEUP_TIME) (
    IN BOOLEAN Enable,
    IN EFI_TIME *Time OPTIONAL
);

/* 8.4: Virtual Memory Services */

/* 8.4.1: EFI_RUNTIME_SERVICES.SetVirtualAddressMap() */
typedef EFI_STATUS (EFIAPI *EFI_SET_VIRTUAL_ADDRESS_MAP) (
    IN UINTN MemoryMapSize,
    IN UINTN DescriptorSize,
    IN UINT32 DescriptorVersion,
    IN EFI_MEMORY_DESCRIPTOR *VirtualMap
);

/* 8.4.2: EFI_RUNTIME_SERVICES.ConvertPointer() */
typedef EFI_STATUS (EFIAPI *EFI_CONVERT_POINTER) (
    IN UINTN DebugDisposition,
    IN VOID **Address
);

/* 8.5: Miscellaneous Runtime Services */

/* 8.5.1: EFI_RUNTIME_SERVICES.ResetSystem() */
typedef VOID (EFIAPI *EFI_RESET_SYSTEM) (
    IN EFI_RESET_TYPE ResetType,
    IN EFI_STATUS ResetStatus,
    IN UINTN DataSize,
    IN VOID *ResetData OPTIONAL
);

/* 8.5.2: EFI_RUNTIME_SERVICES.GetNextHighMonotonicCount() */
typedef EFI_STATUS (EFIAPI *EFI_GET_NEXT_HIGH_MONO_COUNT) (
    OUT UINT32 *HighCount
);

/* 8.5.3: EFI_RUNTIME_SERVICES.UpdateCapsule() */
typedef EFI_STATUS (EFIAPI *EFI_UPDATE_CAPSULE) (
    IN EFI_CAPSULE_HEADER **CapsuleHeaderArray,
    IN UINTN CapsuleCount,
    IN EFI_PHYSICAL_ADDRESS ScatterGatherList OPTIONAL
);

/* 8.5.4: EFI_RUNTIME_SERVICES.QueryCapsuleCapabilities() */
typedef EFI_STATUS (EFIAPI *EFI_QUERY_CAPSULE_CAPABILITIES) (
    IN EFI_CAPSULE_HEADER **CapsuleHeaderArray,
    IN UINTN CapsuleCount,
    OUT UINT64 *MaximumCapsuleSize,
    OUT EFI_RESET_TYPE *ResetType
);

/* 4.5: EFI Runtime Services Table */

/* 4.5.1: EFI_RUNTIME_SERVICES */
typedef struct _EFI_RUNTIME_SERVICES {
    EFI_TABLE_HEADER Hdr;

    /* 8.3: Time Services */
    EFI_GET_TIME GetTime;
    EFI_SET_TIME SetTime;
    EFI_GET_WAKEUP_TIME GetWakeupTime;
    EFI_SET_WAKEUP_TIME SetWakeupTime;

    /* 8.4: Virtual Memory Services */
    EFI_SET_VIRTUAL_ADDRESS_MAP SetVirtualAddressMap;
    EFI_CONVERT_POINTER ConvertPointer;

    /* 8.2: Variable Services */
    EFI_GET_VARIABLE GetVariable;
    EFI_GET_NEXT_VARIABLE_NAME GetNextVariableName;
    EFI_SET_VARIABLE SetVariable;

    /* 8.5: Miscellaneous Services */
    EFI_GET_NEXT_HIGH_MONO_COUNT GetNextHighMonotonicCount;
    EFI_RESET_SYSTEM ResetSystem;

    /* 8.5.3: UEFI 2.0 Capsule Services */
    EFI_UPDATE_CAPSULE UpdateCapsule;
    EFI_QUERY_CAPSULE_CAPABILITIES QueryCapsuleCapabilities;

    /* 8.2.4: Miscellaneous UEFI 2.0 Service */
    EFI_QUERY_VARIABLE_INFO QueryVariableInfo;
} EFI_RUNTIME_SERVICES;

/* 4.6: EFI Configuration Table & Properties Table */

/* 4.6.1: EFI_CONFIGURATION_TABLE */
typedef struct _EFI_CONFIGURATION_TABLE {
    EFI_GUID VendorGuid;
    VOID *VendorTable;
} EFI_CONFIGURATION_TABLE;

/* 9: Protocols - EFI Loaded Image */

/* 9.1: EFI Loaded Image Protocol */

/* 9.1.1: EFI_LOADED_IMAGE_PROTOCOL */
typedef struct _EFI_LOADED_IMAGE_PROTOCOL {
    UINT32 Revision;
    EFI_HANDLE ParentHandle;
    EFI_SYSTEM_TABLE *SystemTable;

    /* 9.1.1: Source location of the image */
    EFI_HANDLE DeviceHandle;
    EFI_DEVICE_PATH_PROTOCOL *FilePath;
    VOID *Reserved;

    /* 9.1.1: Image's load options */
    UINT32 LoadOptionsSize;
    VOID *LoadOptions;

    /* 9.1.1: Location where image was loaded */
    VOID *ImageBase;
    UINT64 ImageSize;
    EFI_MEMORY_TYPE ImageCodeType;
    EFI_MEMORY_TYPE ImageDataType;
    EFI_IMAGE_UNLOAD Unload;
} EFI_LOADED_IMAGE_PROTOCOL;

/* 10: Protocols — Device Path Protocol */

/* 10.2: EFI Device Path Protocol */

typedef struct _EFI_DEVICE_PATH_PROTOCOL {
    UINT8 Type;
    UINT8 SubType;
    UINT8 Length[2];
} EFI_DEVICE_PATH_PROTOCOL;


/* 12: Protocols — Console Support */

/* 12.1: Console I/O Protocol */

/* 12.1.2: ConsoleIn Definition */
#define Null L'\0'
#define BS L'\b'
#define TAB L'\t'
#define LF L'\n'
#define CR L'\r'

/* 12.3: Simple Text Input Protocol */

/* 12.3.2: EFI_SIMPLE_TEXT_INPUT_PROTOCOL.Reset() */
typedef EFI_STATUS (EFIAPI *EFI_INPUT_RESET) (
    IN EFI_SIMPLE_TEXT_INPUT_PROTOCOL *This,
    IN BOOLEAN ExtendedVerification
);

/* 12.3.3: EFI_SIMPLE_TEXT_INPUT_PROTOCOL.ReadKeyStroke() */
typedef EFI_STATUS (EFIAPI *EFI_INPUT_READ_KEY) (
    IN EFI_SIMPLE_TEXT_INPUT_PROTOCOL *This,
    OUT EFI_INPUT_KEY *Key
);

/* 12.3.1: EFI_SIMPLE_TEXT_INPUT_PROTOCOL */
typedef struct _EFI_SIMPLE_TEXT_INPUT_PROTOCOL {
    EFI_INPUT_RESET Reset;
    EFI_INPUT_READ_KEY ReadKeyStroke;
    EFI_EVENT WaitForKey;
} EFI_SIMPLE_TEXT_INPUT_PROTOCOL;

/* 12.4: Simple Text Output Protocol */

/* 12.4.2: EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL.Reset() */
typedef EFI_STATUS (EFIAPI *EFI_TEXT_RESET) (
    IN EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL *This,
    IN BOOLEAN ExtendedVerification
);

/* 12.4.3: EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL.OutputString() */
typedef EFI_STATUS (EFIAPI *EFI_TEXT_STRING) (
    IN EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL *This,
    IN CHAR16 *String
);

/* 12.4.4: EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL.TestString() */
typedef EFI_STATUS (EFIAPI *EFI_TEXT_TEST_STRING) (
    IN EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL *This,
    IN CHAR16 *String
);

/* 12.4.5: EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL.QueryMode() */
typedef EFI_STATUS (EFIAPI *EFI_TEXT_QUERY_MODE) (
    IN EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL *This,
    IN UINTN ModeNumber,
    OUT UINTN *Columns,
    OUT UINTN *Rows
);

/* 12.4.6: EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL.SetMode() */
typedef EFI_STATUS (EFIAPI *EFI_TEXT_SET_MODE) (
    IN EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL *This,
    IN UINTN ModeNumber
);

/* 12.4.7: EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL.SetAttribute() */
typedef EFI_STATUS (EFIAPI *EFI_TEXT_SET_ATTRIBUTE) (
    IN EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL *This,
    IN UINTN Attribute
);

/* 12.4.8: EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL.ClearScreen() */
typedef EFI_STATUS (EFIAPI *EFI_TEXT_CLEAR_SCREEN) (
    IN EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL *This
);

/* 12.4.9: EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL.SetCursorPosition() */
typedef EFI_STATUS (EFIAPI *EFI_TEXT_SET_CURSOR_POSITION) (
    IN EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL *This,
    IN UINTN Column,
    IN UINTN Row
);

/* 12.4.10: EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL.EnableCursor() */
typedef EFI_STATUS (EFIAPI *EFI_TEXT_ENABLE_CURSOR) (
    IN EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL *This,
    IN BOOLEAN Visible
);

/* 12.4.1: EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL */
typedef struct _EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL {
    EFI_TEXT_RESET Reset;
    EFI_TEXT_STRING OutputString;
    EFI_TEXT_TEST_STRING TestString;
    EFI_TEXT_QUERY_MODE QueryMode;
    EFI_TEXT_SET_MODE SetMode;
    EFI_TEXT_SET_ATTRIBUTE SetAttribute;
    EFI_TEXT_CLEAR_SCREEN ClearScreen;
    EFI_TEXT_SET_CURSOR_POSITION SetCursorPosition;
    EFI_TEXT_ENABLE_CURSOR EnableCursor;
    SIMPLE_TEXT_OUTPUT_MODE *Mode;
} EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL;

/* 12.9: Graphics Output Protocol */

/* 12.9.2.1: EFI_GRAPHICS_OUTPUT_PROTOCOL.QueryMode() */
typedef EFI_STATUS (EFIAPI *EFI_GRAPHICS_OUTPUT_PROTOCOL_QUERY_MODE) (
    IN EFI_GRAPHICS_OUTPUT_PROTOCOL *This,
    IN UINT32 ModeNumber,
    OUT UINTN *SizeOfInfo,
    OUT EFI_GRAPHICS_OUTPUT_MODE_INFORMATION **Info
);

/* 12.9.2.2: EFI_GRAPHICS_OUTPUT_PROTOCOL.SetMode() */
typedef EFI_STATUS (EFIAPI *EFI_GRAPHICS_OUTPUT_PROTOCOL_SET_MODE) (
    IN EFI_GRAPHICS_OUTPUT_PROTOCOL *This,
    IN UINT32 ModeNumber
);

/* 12.9.2.3: EFI_GRAPHICS_OUTPUT_PROTOCOL.Blt() */
typedef EFI_STATUS (EFIAPI *EFI_GRAPHICS_OUTPUT_PROTOCOL_BLT) (
    IN EFI_GRAPHICS_OUTPUT_PROTOCOL *This,
    IN OUT EFI_GRAPHICS_OUTPUT_BLT_PIXEL *BltBuffer OPTIONAL,
    IN EFI_GRAPHICS_OUTPUT_BLT_OPERATION BltOperation,
    IN UINTN SourceX,
    IN UINTN SourceY,
    IN UINTN DestinationX,
    IN UINTN DestinationY,
    IN UINTN Width,
    IN UINTN Height,
    IN UINTN Delta OPTIONAL
);

/* 12.9.2: EFI_GRAPHICS_OUTPUT_PROTOCOL */
typedef struct _EFI_GRAPHICS_OUTPUT_PROTOCOL {
    EFI_GRAPHICS_OUTPUT_PROTOCOL_QUERY_MODE QueryMode;
    EFI_GRAPHICS_OUTPUT_PROTOCOL_SET_MODE SetMode;
    EFI_GRAPHICS_OUTPUT_PROTOCOL_BLT Blt;
    EFI_GRAPHICS_OUTPUT_PROTOCOL_MODE *Mode;
} EFI_GRAPHICS_OUTPUT_PROTOCOL;

/* 13: Protocols — Media Access */

/* 13.1: Block I/O Protocol */

/* 13.1.2: EFI_BLOCK_IO_PROTOCOL.Reset() */
typedef EFI_STATUS (EFIAPI *EFI_BLOCK_RESET) (
    IN EFI_BLOCK_IO_PROTOCOL *This,
    IN BOOLEAN ExtendedVerification
);

/* 13.1.3: EFI_BLOCK_IO_PROTOCOL.ReadBlocks() */
typedef EFI_STATUS (EFIAPI *EFI_BLOCK_READ) (
    IN EFI_BLOCK_IO_PROTOCOL *This,
    IN UINT32 MediaId,
    IN EFI_LBA LBA,
    IN UINTN BufferSize,
    OUT VOID *Buffer
);

/* 13.1.4: EFI_BLOCK_IO_PROTOCOL.WriteBlocks() */
typedef EFI_STATUS (EFIAPI *EFI_BLOCK_WRITE) (
    IN EFI_BLOCK_IO_PROTOCOL *This,
    IN UINT32 MediaId,
    IN EFI_LBA LBA,
    IN UINTN BufferSize,
    IN VOID *Buffer
);

/* 13.1.5: EFI_BLOCK_IO_PROTOCOL.FlushBlocks() */
typedef EFI_STATUS (EFIAPI *EFI_BLOCK_FLUSH) (
    IN EFI_BLOCK_IO_PROTOCOL *This
);

/* 13.1.1: EFI_BLOCK_IO_PROTOCOL */
typedef struct _EFI_BLOCK_IO_PROTOCOL {
    UINT64 Revision;
    EFI_BLOCK_IO_MEDIA *Media;
    EFI_BLOCK_RESET Reset;
    EFI_BLOCK_READ ReadBlocks;
    EFI_BLOCK_WRITE WriteBlocks;
    EFI_BLOCK_FLUSH FlushBlocks;
} EFI_BLOCK_IO_PROTOCOL;

/* 13.2: Load File Protocol */

/* 13.2.2: EFI_LOAD_FILE_PROTOCOL.LoadFile() */
typedef EFI_STATUS (EFIAPI *EFI_LOAD_FILE) (
    IN EFI_LOAD_FILE_PROTOCOL *This,
    IN EFI_DEVICE_PATH_PROTOCOL *FilePath,
    IN BOOLEAN BootPolicy,
    IN OUT UINTN *BufferSize,
    IN VOID *Buffer OPTIONAL
);

/* 13.2.1: EFI_LOAD_FILE_PROTOCOL */
typedef struct _EFI_LOAD_FILE_PROTOCOL {
    EFI_LOAD_FILE LoadFile;
} EFI_LOAD_FILE_PROTOCOL;

/* 13.3: Load File 2 Protocol */

/* 13.3.1: EFI_LOAD_FILE2_PROTOCOL */
typedef struct _EFI_LOAD_FILE2_PROTOCOL {
    EFI_LOAD_FILE LodeFile;
} EFI_LOAD_FILE2_PROTOCOL;

/* 13.4: Simple File System Protocol */

/* 13.4.2: EFI_SIMPLE_FILE_SYSTEM_PROTOCOL.OpenVolume() */
typedef EFI_STATUS (EFIAPI *EFI_SIMPLE_FILE_SYSTEM_PROTOCOL_OPEN_VOLUME) (
    IN EFI_SIMPLE_FILE_SYSTEM_PROTOCOL *This,
    OUT EFI_FILE_PROTOCOL **Root
);

/* 13.4.1: EFI_SIMPLE_FILE_SYSTEM_PROTOCOL */
typedef struct _EFI_SIMPLE_FILE_SYSTEM_PROTOCOL {
    UINT64 Revision;
    EFI_SIMPLE_FILE_SYSTEM_PROTOCOL_OPEN_VOLUME OpenVolume;
} EFI_SIMPLE_FILE_SYSTEM_PROTOCOL;

/* 13.5: EFI File Protocol */

/* 13.5.2: EFI_FILE_PROTOCOL.Open() */
typedef EFI_STATUS (EFIAPI *EFI_FILE_OPEN) (
    IN EFI_FILE_PROTOCOL *This,
    OUT EFI_FILE_PROTOCOL **NewHandle,
    IN CHAR16 *FileName,
    IN UINT64 OpenMode,
    IN UINT64 Attributes
);

/* 13.5.3: EFI_FILE_PROTOCOL.Close() */
typedef EFI_STATUS (EFIAPI *EFI_FILE_CLOSE) (
    IN EFI_FILE_PROTOCOL *This
);

/* 13.5.4: EFI_FILE_PROTOCOL.Delete() */
typedef EFI_STATUS (EFIAPI *EFI_FILE_DELETE) (
    IN EFI_FILE_PROTOCOL *This
);

/* 13.5.5: EFI_FILE_PROTOCOL.Read() */
typedef EFI_STATUS (EFIAPI *EFI_FILE_READ) (
    IN EFI_FILE_PROTOCOL *This,
    IN OUT UINTN *BufferSize,
    OUT VOID *Buffer
);

/* 13.5.6: EFI_FILE_PROTOCOL.Write() */
typedef EFI_STATUS (EFIAPI *EFI_FILE_WRITE) (
    IN EFI_FILE_PROTOCOL *This,
    IN OUT UINTN *BufferSize,
    IN VOID *Buffer
);

/* 13.5.7: EFI_FILE_PROTOCOL.GetPosition() */
typedef EFI_STATUS (EFIAPI *EFI_FILE_GET_POSITION) (
    IN EFI_FILE_PROTOCOL *This,
    OUT UINT64 *Position
);

/* 13.5.8: EFI_FILE_PROTOCOL.SetPosition() */
typedef EFI_STATUS (EFIAPI *EFI_FILE_SET_POSITION) (
    IN EFI_FILE_PROTOCOL *This,
    IN UINT64 Position
);

/* 13.5.9: EFI_FILE_PROTOCOL.GetInfo() */
typedef EFI_STATUS (EFIAPI *EFI_FILE_GET_INFO) (
    IN EFI_FILE_PROTOCOL *This,
    IN EFI_GUID *InformationType,
    IN OUT UINTN *BufferSize,
    OUT VOID *Buffer
);

/* 13.5.10: EFI_FILE_PROTOCOL.SetInfo() */
typedef EFI_STATUS (EFIAPI *EFI_FILE_SET_INFO) (
    IN EFI_FILE_PROTOCOL *This,
    IN EFI_GUID *InformationType,
    IN UINTN BufferSize,
    IN VOID *Buffer
);

/* 13.5.11: EFI_FILE_PROTOCOL.Flush() */
typedef EFI_STATUS (EFIAPI *EFI_FILE_FLUSH) (
    IN EFI_FILE_PROTOCOL *This
);

/* 13.5.12: EFI_FILE_PROTOCOL.OpenEx() */
typedef EFI_STATUS (EFIAPI *EFI_FILE_OPEN_EX) (
    IN EFI_FILE_PROTOCOL *This,
    OUT EFI_FILE_PROTOCOL **NewHandle,
    IN CHAR16 *FileName,
    IN UINT64 OpenMode,
    IN UINT64 Attributes,
    IN OUT EFI_FILE_IO_TOKEN *Token
);

/* 13.5.13: EFI_FILE_PROTOCOL.ReadEx() */
typedef EFI_STATUS (EFIAPI *EFI_FILE_READ_EX) (
    IN EFI_FILE_PROTOCOL *This,
    IN OUT EFI_FILE_IO_TOKEN *Token
);

/* 13.5.14: EFI_FILE_PROTOCOL.WriteEx() */
typedef EFI_STATUS (EFIAPI *EFI_FILE_WRITE_EX) (
    IN EFI_FILE_PROTOCOL *This,
    IN OUT EFI_FILE_IO_TOKEN *Token
);

/* 13.5.15: EFI_FILE_PROTOCOL.FlushEx() */
typedef EFI_STATUS (EFIAPI *EFI_FILE_FLUSH_EX) (
    IN EFI_FILE_PROTOCOL *This,
    IN OUT EFI_FILE_IO_TOKEN *Token
);

/* 13.5.1: EFI_FILE_PROTOCOL */
typedef struct _EFI_FILE_PROTOCOL {
    UINT64 Revision;
    EFI_FILE_OPEN Open;
    EFI_FILE_CLOSE Close;
    EFI_FILE_DELETE Delete;
    EFI_FILE_READ Read;
    EFI_FILE_WRITE Write;
    EFI_FILE_GET_POSITION GetPosition;
    EFI_FILE_SET_POSITION SetPosition;
    EFI_FILE_GET_INFO GetInfo;
    EFI_FILE_SET_INFO SetInfo;
    EFI_FILE_FLUSH Flush;
    EFI_FILE_OPEN_EX OpenEx;
    EFI_FILE_READ_EX ReadEx;
    EFI_FILE_WRITE_EX WriteEx;
    EFI_FILE_FLUSH_EX FlushEx;
} EFI_FILE_PROTOCOL;

/* 13.7: Disk I/O Protocol */

/* 13.7.2: EFI_DISK_IO_PROTOCOL.ReadDisk() */
typedef EFI_STATUS (EFIAPI *EFI_DISK_READ) (
    IN EFI_DISK_IO_PROTOCOL *This,
    IN UINT32 MediaId,
    IN UINT64 Offset,
    IN UINT64 BufferSize,
    OUT VOID *Buffer
);

/* 13.7.3: EFI_DISK_IO_PROTOCOL.WriteDisk() */
typedef EFI_STATUS (EFIAPI *EFI_DISK_WRITE) (
    IN EFI_DISK_IO_PROTOCOL *This,
    IN UINT32 MediaId,
    IN UINT64 Offset,
    IN UINT64 BufferSize,
    IN VOID *Buffer
);

/* 13.7.1: EFI_DISK_IO_PROTOCOL */
typedef struct _EFI_DISK_IO_PROTOCOL {
    UINT64 Revision;
    EFI_DISK_READ ReadDisk;
    EFI_DISK_WRITE WriteDisk;
} EFI_DISK_IO_PROTOCOL;

/* 13.14: Storage Security Command Protocol */

/* 13.14.2: EFI_STORAGE_SECURITY_COMMAND_PROTOCOL.ReceiveData() */
typedef EFI_STATUS (EFIAPI *EFI_STORAGE_SECURITY_RECEIVE_DATA) (
    IN EFI_STORAGE_SECURITY_COMMAND_PROTOCOL *This,
    IN UINT32 MediaId,
    IN UINT64 Timeout,
    IN UINT8 SecurityProtocolId,
    IN UINT16 SecurityProtocolSpecificData,
    IN UINT64 PayloadSize,
    OUT VOID *PayloadBuffer,
    OUT UINT64 *PayloadTransferSize
);

/* 13.14.3: EFI_STORAGE_SECURITY_COMMAND_PROTOCOL.SendData() */
typedef EFI_STATUS (EFIAPI *EFI_STORAGE_SECURITY_SEND_DATA) (
    IN EFI_STORAGE_SECURITY_COMMAND_PROTOCOL *This,
    IN UINT32 MediaId,
    IN UINT64 Timeout,
    IN UINT8 SecurityProtocolId,
    IN UINT16 SecurityProtocolSpecificData,
    IN UINT64 PayloadSize,
    IN VOID *PayloadBuffer
);

/* 13.14.1: EFI_STORAGE_SECURITY_COMMAND_PROTOCOL */
typedef struct _EFI_STORAGE_SECURITY_COMMAND_PROTOCOL {
    EFI_STORAGE_SECURITY_RECEIVE_DATA ReceiveData;
    EFI_STORAGE_SECURITY_SEND_DATA SendData;
} EFI_STORAGE_SECURITY_COMMAND_PROTOCOL;

/* 13.5: EFI File Protocol Definitions */

/* Open Modes */

#define EFI_FILE_MODE_READ 0x0000000000000001ULL
#define EFI_FILE_MODE_WRITE 0x0000000000000002ULL
#define EFI_FILE_MODE_CREATE 0x8000000000000000ULL

/* Attributes */

#define EFI_FILE_READ_ONLY 0x0000000000000001ULL
#define EFI_FILE_HIDDEN 0x0000000000000002ULL
#define EFI_FILE_SYSTEM 0x0000000000000004ULL
#define EFI_FILE_RESERVED 0x0000000000000008ULL
#define EFI_FILE_DIRECTORY 0x0000000000000010ULL
#define EFI_FILE_ARCHIVE 0x0000000000000020ULL
#define EFI_FILE_VALID_ATTR 0x0000000000000037ULL

/* File Info IDs */

#define EFI_FILE_INFO_ID {0x09576e92, 0x6d3f, 0x11d2, {0x8e, 0x39, 0x00, 0xa0, 0xc9, 0x69, 0x72, 0x3b}}
#define EFI_FILE_SYSTEM_INFO_ID {0x09576e93, 0x6d3f, 0x11d2, {0x8e, 0x39, 0x00, 0xa0, 0xc9, 0x69, 0x72, 0x3b}}
#define EFI_FILE_SYSTEM_VOLUME_LABEL_ID {0xdb47d7d3, 0xfe81, 0x11d2, {0x8e, 0x35, 0x00, 0xa0, 0xc9, 0x69, 0x72, 0x3b}}

/* 7.2.3: Memory Attributes */

#define EFI_MEMORY_UC 0x0000000000000001ULL
#define EFI_MEMORY_WC 0x0000000000000002ULL
#define EFI_MEMORY_WT 0x0000000000000004ULL
#define EFI_MEMORY_WB 0x0000000000000008ULL
#define EFI_MEMORY_UCE 0x0000000000000010ULL
#define EFI_MEMORY_WP 0x0000000000001000ULL
#define EFI_MEMORY_RP 0x0000000000002000ULL
#define EFI_MEMORY_XP 0x0000000000004000ULL
#define EFI_MEMORY_NV 0x0000000000008000ULL
#define EFI_MEMORY_MORE_RELIABLE 0x0000000000010000ULL
#define EFI_MEMORY_RO 0x0000000000020000ULL
#define EFI_MEMORY_SP 0x0000000000040000ULL
#define EFI_MEMORY_CPU_CRYPTO 0x0000000000080000ULL
#define EFI_MEMORY_HOT_PLUGGABLE 0x0000000000100000ULL
#define EFI_MEMORY_RUNTIME 0x8000000000000000ULL
#define EFI_MEMORY_ISA_VALID 0x4000000000000000ULL
#define EFI_MEMORY_ISA_MASK 0x0FFFF00000000000ULL

/* Appendix D: Status Codes */

#define EFI_SUCCESS 0

/* Errors */

#define EFI_LOAD_ERROR ((EFI_STATUS) (0x8000000000000000ULL | (1)))
#define EFI_INVALID_PARAMETER ((EFI_STATUS) (0x8000000000000000ULL | (2)))
#define EFI_UNSUPPORTED ((EFI_STATUS) (0x8000000000000000ULL | (3)))
#define EFI_BAD_BUFFER_SIZE ((EFI_STATUS) (0x8000000000000000ULL | (4)))
#define EFI_BUFFER_TOO_SMALL ((EFI_STATUS) (0x8000000000000000ULL | (5)))
#define EFI_NOT_READY ((EFI_STATUS) (0x8000000000000000ULL | (6)))
#define EFI_DEVICE_ERROR ((EFI_STATUS) (0x8000000000000000ULL | (7)))
#define EFI_WRITE_PROTECTED ((EFI_STATUS) (0x8000000000000000ULL | (8)))
#define EFI_OUT_OF_RESOURCES ((EFI_STATUS) (0x8000000000000000ULL | (9)))
#define EFI_VOLUME_CORRUPTED ((EFI_STATUS) (0x8000000000000000ULL | (10)))
#define EFI_VOLUME_FULL ((EFI_STATUS) (0x8000000000000000ULL | (11)))
#define EFI_NO_MEDIA ((EFI_STATUS) (0x8000000000000000ULL | (12)))
#define EFI_MEDIA_CHANGED ((EFI_STATUS) (0x8000000000000000ULL | (13)))
#define EFI_NOT_FOUND ((EFI_STATUS) (0x8000000000000000ULL | (14)))
#define EFI_ACCESS_DENIED ((EFI_STATUS) (0x8000000000000000ULL | (15)))
#define EFI_NO_RESPONSE ((EFI_STATUS) (0x8000000000000000ULL | (16)))
#define EFI_NO_MAPPING ((EFI_STATUS) (0x8000000000000000ULL | (17)))
#define EFI_TIMEOUT ((EFI_STATUS) (0x8000000000000000ULL | (18)))
#define EFI_NOT_STARTED ((EFI_STATUS) (0x8000000000000000ULL | (19)))
#define EFI_ALREADY_STARTED ((EFI_STATUS) (0x8000000000000000ULL | (20)))
#define EFI_ABORTED ((EFI_STATUS) (0x8000000000000000ULL | (21)))
#define EFI_ICMP_ERROR ((EFI_STATUS) (0x8000000000000000ULL | (22)))
#define EFI_TFTP_ERROR ((EFI_STATUS) (0x8000000000000000ULL | (23)))
#define EFI_PROTOCOL_ERROR ((EFI_STATUS) (0x8000000000000000ULL | (24)))
#define EFI_INCOMPATIBLE_VERSION ((EFI_STATUS) (0x8000000000000000ULL | (25)))
#define EFI_SECURITY_VIOLATION ((EFI_STATUS) (0x8000000000000000ULL | (26)))
#define EFI_CRC_ERROR ((EFI_STATUS) (0x8000000000000000ULL | (27)))
#define EFI_END_OF_MEDIA ((EFI_STATUS) (0x8000000000000000ULL | (28)))
#define EFI_END_OF_FILE ((EFI_STATUS) (0x8000000000000000ULL | (31)))
#define EFI_INVALID_LANGUAGE ((EFI_STATUS) (0x8000000000000000ULL | (32)))
#define EFI_COMPROMISED_DATA ((EFI_STATUS) (0x8000000000000000ULL | (33)))
#define EFI_IP_ADDRESS_CONFLICT ((EFI_STATUS) (0x8000000000000000ULL | (34)))
#define EFI_HTTP_ERROR ((EFI_STATUS) (0x8000000000000000ULL | (35)))

/* Warnings */

#define EFI_WARN_UNKNOWN_GLYPH ((EFI_STATUS) 1)
#define EFI_WARN_DELETE_FAILURE ((EFI_STATUS) 2)
#define EFI_WARN_WRITE_FAILURE ((EFI_STATUS) 3)
#define EFI_WARN_BUFFER_TOO_SMALL ((EFI_STATUS) 4)
#define EFI_WARN_STALE_DATA ((EFI_STATUS) 5)
#define EFI_WARN_FILE_SYSTEM ((EFI_STATUS) 6)
#define EFI_WARN_RESET_REQUIRED ((EFI_STATUS) 7)

/* GUIDs */

/* 9.1: EFI Loaded Image Protocol */
#define EFI_LOADED_IMAGE_PROTOCOL_GUID { 0x5B1B31A1, 0x9562, 0x11D2, { 0x8E, 0x3F, 0x00, 0xA0, 0xC9, 0x69, 0x72, 0x3B } }

static EFI_GUID EfiLoadedImageProtocolGuid = EFI_LOADED_IMAGE_PROTOCOL_GUID;

/* 10.2: EFI Device Path Protocol */
#define EFI_DEVICE_PATH_PROTOCOL_GUID { 0x09576E91, 0x6D3F, 0x11D2, { 0x8E, 0x39, 0x00, 0xA0, 0xC9, 0x69, 0x72, 0x3B}}

static EFI_GUID EfiDevicePathProtocolGuid = EFI_DEVICE_PATH_PROTOCOL_GUID;

/* 12.3: Simple Text Input Protocol */
#define EFI_SIMPLE_TEXT_INPUT_PROTOCOL_GUID { 0x387477C1, 0x69C7, 0x11D2, { 0x8E, 0x39, 0x00, 0xA0, 0xC9, 0x69, 0x72, 0x3B } }

static EFI_GUID EfiSimpleTextInputProtocolGuid = EFI_SIMPLE_TEXT_INPUT_PROTOCOL_GUID;

/* 12.4: Simple Text Output Protocol */
#define EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL_GUID { 0x387477C2, 0x69C7, 0x11D2, { 0x8E, 0x39, 0x00, 0xA0, 0xC9, 0x69, 0x72, 0x3B } }

static EFI_GUID EfiSimpleTextOutputProtocolGuid = EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL_GUID;

/* 12.9: Graphics Output Protocol */
#define EFI_GRAPHICS_OUTPUT_PROTOCOL_GUID { 0x9042A9DE, 0x23DC, 0x4A38, { 0x96, 0xFB, 0x7A, 0xDE, 0xD0, 0x80, 0x51, 0x6A } }

static EFI_GUID EfiGraphicsOutputProtocolGuid = EFI_GRAPHICS_OUTPUT_PROTOCOL_GUID;

/* 13.1: Block I/O Protocol */
#define EFI_BLOCK_IO_PROTOCOL_GUID { 0x964E5B21, 0x6459, 0x11D2, { 0x8E, 0x39, 0x00, 0xA0, 0xC9, 0x69, 0x72, 0x3B } }

static EFI_GUID EfiBlockIoProtocolGuid = EFI_BLOCK_IO_PROTOCOL_GUID;

/* 13.2: Load File Protocol */
#define EFI_LOAD_FILE_PROTOCOL_GUID { 0x56EC3091, 0x2760, 0x11D2, { 0x8E, 0x92, 0x00, 0xA0, 0xC9, 0x69, 0x72, 0x3B } }

static EFI_GUID EfiLoadFileProtocolGuid = EFI_LOAD_FILE_PROTOCOL_GUID;

/* 13.3: Load File 2 Protocol */
#define EFI_LOAD_FILE2_PROTOCOL_GUID { 0x4006C0C1, 0xFCB3, 0x403E, { 0x99, 0x6D, 0x4A, 0x6C, 0x87, 0x24, 0xE0, 0x6D } }

static EFI_GUID EfiLoadFile2ProtocolGuid = EFI_LOAD_FILE2_PROTOCOL_GUID;

/* 13.4: Simple File System Protocol */
#define EFI_SIMPLE_FILE_SYSTEM_PROTOCOL_GUID { 0x964E5B22, 0x6459, 0x11D2, { 0x8E, 0x39, 0x00, 0xA0, 0xC9, 0x69, 0x72, 0x3B } }

static EFI_GUID EfiSimpleFileSystemProtocolGuid = EFI_SIMPLE_FILE_SYSTEM_PROTOCOL_GUID;

/* 13.7: Disk I/O Protocol */
#define EFI_DISK_IO_PROTOCOL_GUID { 0xCE345171, 0xBA0B, 0x11D2, { 0x8E, 0x4F, 0x00, 0xA0, 0xC9, 0x69, 0x72, 0x3B } }

static EFI_GUID EfiDiskIoProtocolGuid = EFI_DISK_IO_PROTOCOL_GUID;

/* 13.14: Storage Security Command Protocol */
#define EFI_STORAGE_SECURITY_COMMAND_PROTOCOL_GUID { 0xC88B0B6D, 0x0DFC, 0x49A7, { 0x9C, 0xB4, 0x49, 0x07, 0x4B, 0x4C, 0x3A, 0x78 } }

static EFI_GUID EfiStorageSecurityCommandProtocolGuid = EFI_STORAGE_SECURITY_COMMAND_PROTOCOL_GUID;

#endif /* EFI_H */
