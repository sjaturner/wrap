#pragma once
#include <stdint.h>

/* This is a comment written by an old person. */

// This is a comment written by somebody else.

int first_function(int64_t foo, uint64_t bar);
int next_function(int64_t foo, uint64_t bar[]);
int stringy_bob(int64_t foo, uint64_t bar, char *str);
//int may_the_lord_have_mercy_on_stringy_bob(int64_t foo, uint64_t bar char *str[]);

enum {
    fish = 123,
    chips = 321,
}an_enum;
int another_function(uint64_t self, char *blah, an_enum an_enum);
