#include "wrap_utils.h"

#include <ctype.h>
#include <limits.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* Provided as an example, in case you want to save up all the output and then emit it at the end of the wrapped function call. */
enum
{
    WRAP_BUFFER_SIZE = 0x400,
    WRAP_BUFFER_USE = WRAP_BUFFER_SIZE - 1,
};
static char buffer[WRAP_BUFFER_SIZE];
static uint32_t position;
static int stop;

static void buffer_wrap_enter(void)
{
    position = 0;
    stop = 0;
}

int buffer_wrap_printf(const char *restrict fmt, ...)
{
    va_list ap = { };

    if (stop)
    {
        return 0;
    }

    va_start(ap, fmt);
    int n = vsnprintf(buffer + position, WRAP_BUFFER_USE - position, fmt, ap);
    va_end(ap);

    if (n < 0)
    {
        stop = 1;
        return n;
    }

    position += n;

    return n;
}

static void buffer_wrap_leave(void)
{
    buffer[WRAP_BUFFER_USE] = 0;
    printf("%s", buffer);
}

void wrap_init_buffer(void)
{
    wrap_enter = buffer_wrap_enter;
    wrap_leave = buffer_wrap_leave;
    wrap_printf = buffer_wrap_printf;
}

/* The default is to use printf. */
static void base_wrap_enter(void)
{
}

wrap_printf_t *wrap_printf = printf;

static void base_wrap_leave(void)
{
}

void (*wrap_enter)(void) = base_wrap_enter;
void (*wrap_leave)(void) = base_wrap_leave;

int parse_uint64_t(uint64_t *val, char *str)
{
    if (!str)
    {
        return 0;
    }
    else
    {
        char *pos = str;

        *val = strtoull(str, &pos, 0);
        if (pos == str + strlen(str))
        {
            return 1;
        }
        else
        {
            return *val = 0;
        }
    }
}

int parse_int64_t(int64_t *val, char *str)
{
    if (!str)
    {
        return 0;
    }
    else
    {
        char *pos = str;

        *val = strtoll(str, &pos, 0);
        if (pos == str + strlen(str))
        {
            return 1;
        }
        else
        {
            return *val = 0;
        }
    }
}

#define PARSE_TYPE(TYPE, WIDE, MIN, MAX) \
int parse_ ## TYPE(TYPE *val, char *str) \
{ \
    WIDE wide = 0; \
 \
    if (!parse_ ## WIDE(&wide, str)) \
    { \
        return *val = 0; \
    } \
    else if(wide < MIN || wide > MAX) \
    { \
        return *val = 0; \
    } \
 \
    *val = wide; \
    return 1; \
}

PARSE_TYPE(int32_t,   int64_t,   INT32_MIN,  INT32_MAX)
PARSE_TYPE(uint32_t,  uint64_t,  0,          UINT32_MAX)
PARSE_TYPE(int16_t,   int64_t,   INT16_MIN,  INT16_MAX)
PARSE_TYPE(uint16_t,  uint64_t,  0,          UINT16_MAX)
PARSE_TYPE(int8_t,    int64_t,   INT8_MIN,   INT8_MAX)
PARSE_TYPE(uint8_t,   uint64_t,  0,          UINT8_MAX)

int hex_digit(char c)
{
    if ('0' <= c && c <= '9')
        return c - '0';
    if ('a' <= c && c <= 'f')
        return 10 + (c - 'a');
    if ('A' <= c && c <= 'F')
        return 10 + (c - 'A');
    return -1;
}

int oct_digit(char c)
{
    if ('0' <= c && c <= '7')
        return c - '0';
    return -1;
}

void expand_c_escapes(char *out, const char *in)
{
    while (*in)
    {
        if (*in == '\\')
        {
            in++;
            switch (*in)
            {
                case 'a':
                    *out++ = '\a';
                    in++;
                    break;
                case 'b':
                    *out++ = '\b';
                    in++;
                    break;
                case 'f':
                    *out++ = '\f';
                    in++;
                    break;
                case 'n':
                    *out++ = '\n';
                    in++;
                    break;
                case 'r':
                    *out++ = '\r';
                    in++;
                    break;
                case 't':
                    *out++ = '\t';
                    in++;
                    break;
                case 'v':
                    *out++ = '\v';
                    in++;
                    break;
                case '\\':
                    *out++ = '\\';
                    in++;
                    break;
                case '\'':
                    *out++ = '\'';
                    in++;
                    break;
                case '\"':
                    *out++ = '\"';
                    in++;
                    break;
                case '?':
                    *out++ = '\?';
                    in++;
                    break;

                case 'x':
                    {
                        in++;
                        int val = 0, count = 0;
                        while (hex_digit(*in) >= 0 && count < 2)
                        {
                            val = val * 16 + hex_digit(*in++);
                            count++;
                        }
                        *out++ = (char)val;
                        break;
                    }

                default:
                    if (oct_digit(*in) >= 0)
                    {           // Octal
                        int val = 0, count = 0;
                        while (oct_digit(*in) >= 0 && count < 3)
                        {
                            val = val * 8 + oct_digit(*in++);
                            count++;
                        }
                        *out++ = (char)val;
                    }
                    else
                    {
                        *out++ = '\\';
                        if (*in)
                            *out++ = *in++;
                    }
                    break;
            }
        }
        else
        {
            *out++ = *in++;
        }
    }
    *out = '\0';
}

int string_to_args(char *str, int limit, char *argv[])
{
    if (strchr(str, '%'))
    {
        return -1;
    }

    int len = strlen(str) + 1;
    char *buf = memset(valloc(len), 0, len);
    memcpy(buf, str, strlen(str));
    expand_c_escapes(str, buf);

    printf("%s\n", str);
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
            in_quote = *scan == '"';
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
