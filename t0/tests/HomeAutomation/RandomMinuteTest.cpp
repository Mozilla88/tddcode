#include "string.h"
#include "CppUTest/TestHarness.h"

extern "C"
{
#include "RandomMinute.h"
#include <stdio.h>
}

//START: TestGroup
enum { BOUND=30 };

TEST_GROUP(RandomMinute)
{
    int minute;
    void setup()
    {
        RandomMinute_Create(BOUND);
        srand(1);
    }
    void AssertMinuteIsInRange()
    {
        if (minute < -BOUND || minute > BOUND)
         {
             printf("bad minute value: %d\n", minute);
             FAIL("Minute out of range");
         }
    }
};
//END: TestGroup

//START: InRange
TEST(RandomMinute, GetIsInRange)
{
    for (int i = 0; i < 100; i++)
    {
        minute = RandomMinute_Get();
        AssertMinuteIsInRange();
    }
}
//END: InRange

//START: AllValues
TEST(RandomMinute, AllValuesPossible)
{
    int hit[2*BOUND + 1];
    memset(hit, 0, sizeof(hit));
	int i;
    for (i = 0; i < 225; i++)
    {
        minute = RandomMinute_Get();
        AssertMinuteIsInRange();
        hit[minute + BOUND]++;
    }
    for (i = 0; i < 2* BOUND + 1; i++) {
        CHECK(hit[i] >= 0);
    }
}
//END: AllValues
