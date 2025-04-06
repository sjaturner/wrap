#include "wrap_utils.h"

#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char *argv[])
{
    char *dup = strdup("simon \\\\ \"pi\"eman\" \x30");

    char *av[10] = { };
    int ac = string_to_args(dup, 10, av);

    for (int index = 0; index < ac; ++index)
    {
        printf("|%s|\n", av[index]);
    }
    return 0;
}

