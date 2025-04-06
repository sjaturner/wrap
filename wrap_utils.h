#pragma once
#include <stdint.h>

int string_to_args(char *str, int limit, char *argv[]);
int parse_uint64_t(uint64_t *val, char *str);
int parse_int64_t(int64_t *val, char *str);
#define PRINT printf
