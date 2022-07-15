// Copyright (c) 2015-2022 Nadeen Udantha <me@nadeen.lk>. All rights reserved.

#include "includes.h"

#define DEFMEMPTR uint16_t *stdout_ptr = (uint16_t *)0xB8000;
volatile uint8_t stdout_color = 0x0a;
volatile uint8_t stdout_x = 0;
volatile uint8_t stdout_y = 5;

void cls(void)
{
    DEFMEMPTR
    uint16_t x = 0;
    while (x < 80 * 25)
        stdout_ptr[x++] = 0;
    stdout_x = 0;
    stdout_y = 0;
}

void putchar(uint8_t c)
{
    DEFMEMPTR
    if (c == '\r')
        stdout_x = 0;
    else if (c == '\n')
    {
        stdout_x = 0;
        stdout_y++;
    }
    else if (c == '\b')
    {
        stdout_ptr[stdout_y * 80 + --stdout_x] = 0;
    }
    else
        stdout_ptr[stdout_y * 80 + stdout_x++] = c | (stdout_color << 8);
    if (stdout_x >= 80)
    {
        stdout_x = 0;
        stdout_y++;
    }
    if (stdout_y >= 25)
        stdout_y = 0;
}

void puthex4(uint8_t x)
{
    putchar(x + (x < 10 ? '0' : 'A' - 10));
}

void puthex8(uint8_t x)
{
    puthex4((x >> 4) & 0x0f);
    puthex4(x & 0x0f);
}

void puthex16(uint16_t x)
{
    puthex8((x >> 8) & 0xff);
    puthex8(x & 0xff);
}

void puthex32(uint32_t x)
{
    puthex16((x >> 16) & 0xffff);
    puthex16(x & 0xffff);
}

void putdec32(uint32_t x)
{
    uint32_t z = x / 10;
    if (z)
        putdec32(z);
    putchar('0' + (x % 10));
}

void puts(char *s)
{
    while (*s)
        putchar(*s++);
    putchar('\n');
}

#undef DEFMEMPTR