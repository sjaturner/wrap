#pragma once
#include <stdint.h>

int parse_uint64_t(uint64_t *val, char *str);
int parse_int64_t(int64_t *val, char *str);
int parse_int32_t(int32_t *val, char *str);
int parse_uint32_t(uint32_t *val, char *str);
int parse_int16_t(int16_t *val, char *str);
int parse_uint16_t(uint16_t *val, char *str);
int parse_int8_t(int8_t *val, char *str);
int parse_uint8_t(uint8_t *val, char *str);
int string_to_args(char *str, int limit, char *argv[]);
int wrap_argc_argv(int argc, char *argv[]);

typedef void wrap_printf_t(const char *fmt, ...) __attribute__ ((format (printf, 1, 2))); /* Ick for typedef but may be needed to get the format checks ... */
extern wrap_printf_t *wrap_printf;
extern void (*wrap_enter)(void);
extern void (*wrap_leave)(void);



#define WRAP_PRINTF printf
