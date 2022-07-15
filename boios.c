// Copyright (c) 2015-2022 Nadeen Udantha <me@nadeen.lk>. All rights reserved.

#include "includes.h"

void boios_main(void)
{
    cls();
    stdout_color = 0x0e;
    puts("Welcome to boiOS");
    stdout_color = 0x0a;
    set_irq_handler(0, timer_handler);
    set_irq_handler(1, kbd_handler);
    processes_init();
    create_process(sh, 0, 0);
    sti();
    for (;;)
        hlt();
}

void isr_dump(uint8_t *ptr)
{
    putchar('\n');
    puthex32(ptr);
    putchar('\n');
    uint32_t *x = (uint32_t *)ptr;
    for (int z = -5; z <= 5; z++)
    {
        puthex32(x[z]);
        putchar('\n');
    }
}
