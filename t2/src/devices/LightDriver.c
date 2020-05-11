/***
 * Excerpted from "Test-Driven Development for Embedded C",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material, 
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose. 
 * Visit http://www.pragmaticprogrammer.com/titles/jgade for more book information.
***/
/*- ------------------------------------------------------------------ -*/
/*-    Copyright (c) James W. Grenning -- All Rights Reserved          -*/
/*-    For use by owners of Test-Driven Development for Embedded C,    -*/
/*-    and attendees of Renaissance Software Consulting, Co. training  -*/
/*-    classes.                                                        -*/
/*-                                                                    -*/
/*-    Available at http://pragprog.com/titles/jgade/                  -*/
/*-        ISBN 1-934356-62-X, ISBN13 978-1-934356-62-3                -*/
/*-                                                                    -*/
/*-    Authorized users may use this source code in your own           -*/
/*-    projects, however the source code may not be used to            -*/
/*-    create training material, courses, books, articles, and         -*/
/*-    the like. We make no guarantees that this source code is        -*/
/*-    fit for any purpose.                                            -*/
/*-                                                                    -*/
/*-    www.renaissancesoftware.net james@renaissancesoftware.net       -*/
/*- ------------------------------------------------------------------ -*/

#include "LightDriver.h"
#include "common.h"

static LightDriverInterface interface = NULL;

void LightDriver_SetInterface(LightDriverInterface i)
{
    interface = i;
}

static BOOL isValid(LightDriver self)
{
    return interface && self;
}

void LightDriver_TurnOn(LightDriver self)
{
    if (isValid(self))
        interface->TurnOn(self);
}

void LightDriver_TurnOff(LightDriver self)
{
    if (isValid(self))
        interface->TurnOff(self);
}

void LightDriver_Destroy(LightDriver self)
{
    if (isValid(self))
        interface->Destroy(self);
}

const char * LightDriver_GetType(LightDriver driver)
{
    return driver->type;
}

int LightDriver_GetId(LightDriver driver)
{
    return driver->id;
}

#if 0 
void LightDriver_TurnOn(LightDriver self)
{
    interface->TurnOn(self);
}
#endif 

#if 0 
void LightDriver_SetBrightness(LightDriver self, int level)
{
    if(isValid(self) && interface->setBrightness)
        interface->setBrightness(self, level);
}
#endif 


