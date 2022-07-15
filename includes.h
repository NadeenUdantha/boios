// Copyright (c) 2015-2022 Nadeen Udantha <me@nadeen.lk>. All rights reserved.

typedef unsigned char uint8_t;
typedef unsigned short int uint16_t;
typedef unsigned int uint32_t;
typedef unsigned long int uint64_t;

struct regs
{
    uint32_t gs, fs, es, ds;
    uint32_t edi, esi, ebp, esp, ebx, edx, ecx, eax;
    uint32_t eip, cs, eflags, esp2, ss;
}; //sz=(4+8+5)*4=(17)*4

#define THREAD_STACK_SZ 4096

typedef uint32_t pid_t;
typedef struct process process_t;
typedef struct regs regs_t;
struct process
{
    regs_t *regs;
    pid_t tid;
    process_t *next;
    void *main;
    int argc;
    char **argv;
};

extern volatile process_t *current;
void processes_sync(void);
pid_t create_process(void *main, int argc, char **argv);

#define memcpy __builtin_memcpy
#define strcmp __builtin_strcmp
#define strlen __builtin_strlen

#define MEMORY_BARRIER asm __volatile__("" \
                                        :  \
                                        :  \
                                        : "memory")
#define sti()                    \
    {                            \
        asm __volatile__("sti"); \
    }
#define cli()                    \
    {                            \
        asm __volatile__("cli"); \
    }
#define hlt()                    \
    {                            \
        asm __volatile__("hlt"); \
    }

#define debug()                              \
    {                                        \
        asm __volatile__("xchg    %bx,%bx"); \
    }

#define inline __attribute__((always_inline))
#define noreturn __attribute__((noreturn))

extern volatile uint8_t stdout_x;
extern volatile uint8_t stdout_y;
extern volatile uint8_t stdout_color;

extern void set_irq_handler(uint8_t x, void *handler);
extern noreturn void shutdown(void);
extern noreturn void reboot(void);

void putchar(uint8_t c);

void sh(int argc, char **argv);

void timer_handler(void);
void kbd_handler(void);

uint8_t *malloc(uint32_t sz);
