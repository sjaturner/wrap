# wrap

## Introduction

A minimal and constrained wrapper generator for C functions.  It allows
C functions with simple parameter types to be wrapped so they can be
called using an `argc`, `argv` interface.

## Intended use

Imagine that you have an embedded Linux system with long running
processes. You might have functions which could be called for adjusting
state or printing out debug information. It's straightforward to poll
a UDP port for a command string and pass that to the generated wrapper
code in order to execute the named function. UDP is simple and attractive
and if you look at the code provided you will see a means of defining a
printf-like function and a hook mechanism to emit the debug at the end
of the call. See the following functions in `wrap_utils.c`:

    static void buffer_wrap_enter(void)
    int buffer_wrap_printf(const char *restrict fmt, ...)
    static void buffer_wrap_leave(void)

In order to keep things simple, the wrapper generator can only cope
with a fixed format header file which contains the debug functions
and optionally enumerations. This restricted format header is still
available for inclusion elsewhere in the project - it's well formed C,
albeit with simple content.

## Header file format

I'll paste an example wrapper header file here. At the time of writing
this is called wrap.h, the contents might change but it serves to
illustrate what drives the wrapper generator.

    #pragma once
    #include <stdint.h>

    /* This is a comment written by an old person. */

    // This is a comment written by somebody else.

    int first_function(int64_t foo, uint64_t bar);
    int next_function(int64_t foo, uint64_t bar);
    int stringy_bob(int64_t foo, uint64_t bar, char *str);
    typedef enum {
        fish = 123,
        chips = 321,
    }an_enum;
    int another_function(uint64_t self, char *blah, an_enum an_enum);
    int pass_through(uint64_t self, int argc, char *argv[]);

All of the functions will be wrapped; the enumerations will be usable
directly as parameters, when they are referenced in the prototypes.

You will see that I have been reduced to using a typedef. It made the
parser easier and I'm being pragmatic.

The examples have `uint64_t` and while I've added parsers for other
stdint types I have not tested those. TBH If you are writing wrappers
as additional code why not have the biggest type?

## Building and running the example code

To build and test the wrapper, run:

    :; make clean test
    rm -f lex.yy.c wrap.tab.h wrap.tab.c parser wrap.c test
    done
    flex wrap.l
    bison -d wrap.y
    gcc -Wall -g lex.yy.c wrap.tab.c -o parser
    ./parser < wrap.h > wrap.c
    gcc -Wall -g wrap_utils.c test.c wrap.c -o test

The test program's main function reconstructs the `argv` input into
a single string and passes it to the parser, which then calls the
appropriate wrapped C function.

    :; ./test first_function 1 2
    first_function 1 2
    :; ./test stringy_bob 3 4 '"this works for a while"'
    stringy_bob 3 4 "this works for a while"
    :;

