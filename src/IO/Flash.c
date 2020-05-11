#include "Flash.h"
#include "IO.h"
#include "m28w160ect.h"
#include "MicroTime.h"

#define FLASH_WRITE_TIMEOUT_IN_MICROSECONDS 5000

void Flash_Create(void)
{
}

void Flash_Destroy(void)
{
}

static int writeError(int status)
{
    IO_Write(CommandRegister, Reset);
    if (status & VppErrorBit)
        return FLASH_VPP_ERROR;
    else if (status & ProgramErrorBit)
        return FLASH_PROGRAM_ERROR;
    else if (status & BlockProtectionErrorBit)
        return FLASH_PROTECTED_BLOCK_ERROR;
    else
        return FLASH_UNKNOWN_PROGRAM_ERROR;
}

int Flash_Write(ioAddress offset, ioData data)
{
    ioData status = 0;
    uint32_t timestamp = MicroTime_Get();

    IO_Write(CommandRegister, ProgramCommand);
    IO_Write(offset, data);

    status = IO_Read(StatusRegister);
    while ((status & ReadyBit) == 0)
    {
        if (MicroTime_Get() - timestamp >= FLASH_WRITE_TIMEOUT_IN_MICROSECONDS)
            return FLASH_TIMEOUT_ERROR;
        status = IO_Read(StatusRegister);
    }

    if (status != ReadyBit)
        return writeError(status);

    if (data != IO_Read(offset))
        return FLASH_READ_BACK_ERROR;

    return FLASH_SUCCESS;
}