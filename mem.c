
#include "includes.h"

uint8_t *mem_start = (uint8_t *)0x00100000;
uint8_t *malloc(uint32_t sz)
{
    while (sz % 4)
        sz++;
    uint8_t *z = mem_start;
    mem_start += sz;
    return z;
}
