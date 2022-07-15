// Copyright (c) 2015-2022 Nadeen Udantha <me@nadeen.lk>. All rights reserved.

#include "includes.h"

void panic(char *x)
{
    cli();
    stdout_color = 0x0c;
    printf("\n\nWTF: %s\n\n", x);
    for (;;)
        hlt();
}

uint8_t in_byte(uint16_t _port)
{
    uint8_t rv;
    asm __volatile__("inb %1, %0"
                     : "=a"(rv)
                     : "dN"(_port));
    return rv;
}

void out_byte(uint16_t _port, uint8_t _data)
{
    asm __volatile__("outb %1, %0"
                     :
                     : "dN"(_port), "a"(_data));
}
