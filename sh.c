// Copyright (c) 2015-2022 Nadeen Udantha <me@nadeen.lk>. All rights reserved.

#include "includes.h"

int cmd_help(int argc, char **argv)
{
    puts("boiOS shell\n"
         " echo\n"
         " shutdown\n"
         " reboot\n"
         " help\n");
    return 0;
}

int cmd_echo(int argc, char **argv)
{
    for (int z = 1; z < argc; z++)
    {
        printf("%s", argv[z]);
        if (z < argc - 1)
            putchar(' ');
    }
    putchar('\n');
    return 0;
}

int cmd_shutdown(int argc, char **argv)
{
    shutdown();
}

int cmd_reboot(int argc, char **argv)
{
    reboot();
}

void sh(int argc, char **argv)
{
    puts("boiOS shell");
    char *buf = malloc(1024);
    char **xargv = malloc(4 * 16);
    int xargc;
    while (1)
    {
        putchar('>');
        int len = gets(buf, 1024);
        if (!len)
            continue;
        xargc = 0;
        char *s = buf;
        while (len)
        {
            while (len && *s == ' ')
                len--, s++;
            char *e = s + 1;
            while (len && *e != ' ')
                len--, e++;
            *e = 0;
            if (xargc == 16)
                panic("argc > 16");
            xargv[xargc++] = s;
            s = e + 1;
        }
        if (!xargc)
            continue;
        char *cmd = xargv[0];
        if (!cmd[0])
            continue;
        if (!strcmp(cmd, "echo"))
            cmd_echo(xargc, xargv);
        else if (!strcmp(cmd, "shutdown"))
            cmd_shutdown(xargc, xargv);
        else if (!strcmp(cmd, "reboot"))
            cmd_reboot(xargc, xargv);
        else if (!strcmp(cmd, "help"))
            cmd_help(xargc, xargv);
        else
            printf("wtf is '%s'?\n", cmd);
    }
}
