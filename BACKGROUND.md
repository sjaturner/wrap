## Background

It's often useful to add a command processor to interact with a long
running program. Sometimes these turn into large boilerplate "if / else
if" trees. In a large project, these can get messy and tend to connect
to all parts of the system.

An alternative approach is to generate wrappers for functions and include
a language interpreter, like Lua or Tcl. I've used this approach in the
past and it has its advantages: a fully featured interpreter offers a
lot of possibilities. I used a wrapper generator called SWIG to integrate
C functions into the Tcl interpreter and it was straightforward to do.

The VxWorks RTOS which I used in the 1990's took a different approach
which proved to be very flexible. It had access to the symbol table
and provided a minimal C interpreter - capable of calling functions,
reading globals and executing C-style maths expressions. This was a good
compromise and avoided any intermediate steps. It did rely on simple stack
layouts, pointers and integers were assumed to be the same size, etc.

Anyway, it's fun to write wrapper generators so I thought I'd try a
slightly different tack - a bit like a watered-down version of SWIG.

The premise here is to drive the wrapper generator from a valid - but 
restricted C header file. Functions which can be wrapped have simple 
types, the parameters can be stdint types or strings but there's a 
special exception where the last parameters are an argc, argv pair.

There's a wrapper generator - using flex and bison and after that the
underlying C functions can be called by passing a string with the function
names and arguments as strings.

I wouldn't be surprised if something like this already exists, if you 
know of anything similar then let me know :-)

As it stands, this is just a proof of concept - thrown together - so 
do not rely on it for anything. I plan to try it out in a project and 
see how it performs. As usual, I will get distracted by something else 
fairly soon.
