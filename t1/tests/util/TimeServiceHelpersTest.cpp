//- ------------------------------------------------------------------
//-    Copyright (c) James W. Grenning -- All Rights Reserved         
//-    For use by owners of Test-Driven Development for Embedded C,   
//-    and attendees of Renaissance Software Consulting, Co. training 
//-    classes.                                                       
//-                                                                   
//-    Available at http://pragprog.com/titles/jgade/                 
//-        ISBN 1-934356-62-X, ISBN13 978-1-934356-62-3               
//-                                                                   
//-    Authorized users may use this source code in your own          
//-    projects, however the source code may not be used to           
//-    create training material, courses, books, articles, and        
//-    the like. We make no guarantees that this source code is       
//-    fit for any purpose.                                           
//-                                                                   
//-    www.renaissancesoftware.net james@renaissancesoftware.net      
//- ------------------------------------------------------------------


extern "C"
{
#include <memory.h>
#include "FakeTimeService.h"
}

#include "CppUTest/TestHarness.h"

//START: TimeServiceHelpers
TEST_GROUP(TimeServiceHelpers)
{
    Time time;
     void setup()
    {
      TimeService_Create();
    }

    void givenThatItIs(Day day)
    {
        FakeTimeService_SetDay(day);
        TimeService_GetTime(&time);
    }
};

TEST(TimeServiceHelpers, ExactMatch)
{
    givenThatItIs(MONDAY);
    CHECK(TimeService_MatchesDayOfWeek(&time, MONDAY));
}

TEST(TimeServiceHelpers, WeekendDays)
{
    givenThatItIs(SATURDAY);
    CHECK(TimeService_MatchesDayOfWeek(&time, WEEKEND));
    givenThatItIs(SUNDAY);
    CHECK(TimeService_MatchesDayOfWeek(&time, WEEKEND));
}
//END: TimeServiceHelpers

