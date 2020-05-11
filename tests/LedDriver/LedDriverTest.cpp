#include "CppUTest/TestHarness.h"

extern "C"
{
#include "LedDriver.h"
#include "RuntimeErrorStub.h"
}

TEST_GROUP(LedDriver)
{
    uint16_t virtualLeds;

    void setup()
    {
        LedDriver_Create(&virtualLeds);
    }
    void teardown()
    {
        LedDriver_Destroy();
    }
};
