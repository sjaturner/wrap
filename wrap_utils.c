#include "wrap_utils.h"
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int string_to_args(char *str, int limit, char *argv[])
{
    if (strchr(str, '%'))
    {
        return -1;
    }

    int len = strlen(str) + 1;
    char *buf = memset(valloc(len), 0, len);
    snprintf(buf, len, str);
    memcpy(str, buf, len);

    char *scan = str;
    int in_quote = *scan == '"';
    int last_space = 1;
    int argc = 0;

    for (; *scan; ++scan)
    {
        int this_space = isspace(*scan);
        if (in_quote)
        {
            if (*scan == '"')
            {
                in_quote = 0;
            }
        } 
        else
        {
            if (last_space)
            {
                if (!this_space)
                {
                    if (argc >= limit)
                    {
                        return -1;
                    }
                    else
                    {
                        argv[argc++] = scan;
                    }
                }
            }
            *scan = this_space ? 0 : *scan;
        }

        last_space = this_space;
    }

    for (int index = 0; index < argc; ++index)
    {
        if (argv[index][0] == '"')
        {
            argv[index][0] = 0;
            ++argv[index];
        }
        int length = strlen(argv[index]);
        if (length && argv[index][length - 1] == '"')
        {
            argv[index][length - 1] = 0;
        }
    }

    return argc;
}

