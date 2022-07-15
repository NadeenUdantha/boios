// Copyright (c) 2015-2022 Nadeen Udantha <me@nadeen.lk>. All rights reserved.

#include "includes.h"

volatile process_t *current;
volatile pid_t next_tid = 1;

extern regs_t *irq_stack;

void processes_sync(void)
{
    memcpy(current->regs, irq_stack, sizeof(regs_t));
    current = current->next;
    memcpy(irq_stack, current->regs, sizeof(regs_t));
}

void processes_init(void)
{
    current = malloc(sizeof(process_t));
    current->regs = malloc(sizeof(regs_t));
    current->next = current;
    current->tid = next_tid++;
}

regs_t *new_regs()
{
    regs_t *r = malloc(sizeof(regs_t));
    r->gs = 0x10;
    r->fs = 0x10;
    r->es = 0x10;
    r->ds = 0x10;
    r->edi = 0;
    r->esi = 0;
    r->ebp = 0;
    uint32_t *stack = (uint32_t *)malloc(THREAD_STACK_SZ);
    //stack[sizeof(process_t)] = (uint32_t)args;
    r->esp = (uint32_t)(stack + THREAD_STACK_SZ / 2);
    r->ebx = 0;
    r->edx = 0;
    r->ecx = 0;
    r->eax = 0;
    r->cs = 0x08;
    r->eflags = 0x0202;
    r->esp2 = 0;
    r->ss = 0x10;
    return r;
}

pid_t create_process(void *main, int argc, char **argv)
{
    process_t *t = malloc(sizeof(process_t));
    t->tid = next_tid++;
    regs_t *r = new_regs();
    r->eip = (uint32_t)main;
    //r->esp->
    memcpy(r->esp, r, sizeof(regs_t));
    t->regs = r;
    cli();
    t->next = current->next;
    current->next = t;
    sti();
    return t->tid;
}

void process_dump(process_t *t)
{
    printf("process_dump id=%d next.id=%d\n", t->tid, t->next->tid);
    regs_t *r = t->regs;
    printf("cs=%x ds=%x ss=%x es=%x fs=%x gs=%x\n"
           "eip=%x eflags=%x esp=%x ebp=%x esp2=%x\n"
           "eax=%x ebx=%x ecx=%x edx=%x esi=%x edi=%x\n",
           r->cs, r->ds, r->ss, r->es, r->fs, r->gs,
           r->eip, r->eflags, r->esp, r->ebp, r->esp2,
           r->eax, r->ebx, r->ecx, r->edx, r->esi, r->edi);
}
