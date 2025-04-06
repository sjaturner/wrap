#include "wrap_utils.h"

#include <stdio.h>
#include <string.h>

int main(int argc, char *argv[])
{
    if (argc < 2)
    {
        return 0;
    }

    --argc, ++argv;

    char cmd[0x10000] = { };

    while (argc--)
    {
        strcat(cmd, *argv++);
        strcat(cmd, " ");
    }

    char *av[10] = { };
    int ac = string_to_args(cmd, 10, av);

    for (int index = 0; index < ac; ++index)
    {
        printf("|%s|\n", av[index]);
    }
    return 0;
}

