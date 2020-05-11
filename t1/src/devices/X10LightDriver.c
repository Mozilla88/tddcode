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


#include "X10LightDriver.h"
#include <stdlib.h>
#include <memory.h>
#include "common.h"

#define MAX_X10_MESSAGE_LENGTH 100

typedef struct X10LightDriverStruct * X10LightDriver;
typedef struct X10LightDriverStruct
{
    LightDriverStruct base;
    X10_HouseCode house;
    int unit;
    char message[MAX_X10_MESSAGE_LENGTH];
} X10LightDriverStruct;

LightDriver X10LightDriver_Create(int id, X10_HouseCode house, int unit)
{
     X10LightDriver self = calloc(1, sizeof(X10LightDriverStruct));
     self->base.type = X10;
     self->base.id = id;
     self->house = house;
     self->unit = unit;
     return (LightDriver)self;
}

void X10LightDriver_Destroy(LightDriver self)
{
    free(self);
}

static void formatTurnOnMessage(X10LightDriver self)
{
    explodesInTestEnvironment(self);
}

static void formatTurnOffMessage(X10LightDriver self)
{
    explodesInTestEnvironment(self);
}

static void sendMessage(X10LightDriver self)
{
    explodesInTestEnvironment(self);
}

void X10LightDriver_TurnOn(LightDriver base)
{
    X10LightDriver self = (X10LightDriver)base;
    formatTurnOnMessage(self);
    sendMessage(self);
}

void X10LightDriver_TurnOff(LightDriver base)
{
    X10LightDriver self = (X10LightDriver)base;
    formatTurnOffMessage(self);
    sendMessage(self);
}

