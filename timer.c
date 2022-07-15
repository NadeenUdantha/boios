// Copyright (c) 2015-2022 Nadeen Udantha <me@nadeen.lk>. All rights reserved.

#include "includes.h"

volatile uint32_t time_ms = 0;

void sleep_ms(uint32_t ms)
{
    ms += time_ms;
    while (time_ms < ms)
        hlt();
}

void timer_handler(void)
{
    time_ms++;
    int x = stdout_x, y = stdout_y;
    stdout_x = 80 - 10;
    stdout_y = 24;
    printf("%d", time_ms);
    stdout_x = x;
    stdout_y = y;
    processes_sync();
}
