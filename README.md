# wrap

## Introduction

This is a very simplistic and constrained wrapper generator for C functions. 
It allows C functions with simply typed parameters to be wrapped so that they 
can be called in an argc, argv fashion. If you are prepared to add handlers 
for more complex types I think that those would be simply accommodated, too.

## Intended use

Imagine that you have an embedded Linux system with long running processes. 
You may have functions which could be usefully called for adjusting state 
or printing out debug information. It's straightforward to poll a UDP port 
for a command string and pass that to the generated wrapper code in order 
to execute the named function. UDP is simple and attractive and if you look 
at the code provided you will see a means of defining a printf like function 
and a hook mechanism to emit the debug at the end of the call.

In order to keep things straightforward, the wrapper generator can only
cope with a fixed format header file which contains the debug functions
and optionally enumerations. This restricted format header is still
available for inclusion elsewhere in the project - it's well formed C,
albeit with simple content.

## Header file format

I'll paste an example wrapper header file here. At the time of writing this 
is called wrap.h, the contents might change but it serves to illustrate 
what drives the wrapper generator.


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

All of the functions will be wrapped; the enumerations will be useable
directly as parameters, when they are referenced in the prototypes.

You will see that I have been reduced to using a typedef. It made the 
parser easier and I'm being pragmatic.

The examples have uint64\_t and while I've added parsers for other stdint 
types I have not tested those. TBH If you are writing wrappers as additional 
code why not have the biggest type?


