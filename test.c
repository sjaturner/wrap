#include "wrap_utils.h"
#include "wrap.h"

#include <stdio.h>
#include <string.h>
#include <inttypes.h>


int first_function(int64_t foo, uint64_t bar)
{
    printf("%s %" PRId64 " %" PRIu64 "\n", __func__, foo, bar);
    return 0;
}

int next_function(int64_t foo, uint64_t bar)
{
    printf("%s %" PRId64 " %" PRIu64 "\n", __func__, foo, bar);
    return 0;
}

int stringy_bob(int64_t foo, uint64_t bar, char *str)
{
    printf("%s %" PRId64 " %" PRIu64 " \"%s\"\n", __func__, foo, bar, str);
    return 0;
}

int another_function(uint64_t self, char *blah, an_enum an_enum)
{
    printf("%s %" PRIu64 " \"%s\" %d\n", __func__, self, blah, an_enum);
    return 0;
}

int pass_through(uint64_t self, int argc, char *argv[])
{
    printf("%s %" PRIu64 " ", __func__, self);
    while (argc--)
    {
        printf("%s ", *argv++);
    }
    printf("\n");
    return 0;
}

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

    wrap_init_buffer();

    char *av[10] = { };
    int ac = string_to_args(cmd, 10, av);

    if (0)
    {
        for (int index = 0; index < ac; ++index)
        {
            printf("|%s|\n", av[index]);
        }
    }
    wrap_argc_argv(ac, av);
    return 0;
}
