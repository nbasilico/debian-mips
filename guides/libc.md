:arrow_left: [back to README.md](../README.md)

# WIP
This guide is a Work In Progress.

#### TODO
- [ ] how structs work
- [ ] C compiling steps (`gcc -S`)

# libc in assembly
This guide will teach you how to call C library functions from assembly.



## Table of contents
- [Link the C library](#Link-the-C-library)
- [Calling a function from the standard library](#Calling-a-function-from-the-standard-library)
- [Calling a written C function](#Calling-a-written-C-function)
- [Extra: compile C step by step](#Extra:-compile-C-step-by-step)



## Link the C library
To dynamically link the C library and its initializers, use:
```sh
ld  <object files> -o <target> -dynamic-linker /lib/ld.so.1 /usr/lib/mips-linux-gnu/crt*.o -lc
```
- `-dynamic-linker /lib/ld.so.1`: use the runtime dynamic linker `/lib/ld.so.1` (see `ld.so(8)`)
- `/usr/lib/mips-linux-gnu/crt*.o`: link the initializers
- `-lc`: link the C library
Keep in mind that the order of the arguments is relevant when using `ld`.

If you are willing link the C library with your program remember to use `main` as starting label and to `jr $ra` at the end.

You may need to link non other C libraries, e.g. `-lm` for the math library and `-lrt` for the realtime library.



## Calling a function from the standard library
Look for the desired function in the manual. Library functions reside in section 3. For example, from `man 3 printf` we get the function signature `int printf(const char *restrict format, ...)`.

The function signature shows what arguments have to be put in input to the function. These arguments correspond to the registers `$a0`, `$a1`, etc. as specified by MIPS assembly conventions (some of which described in `syscall(2)`). This works exactly like the syscalls in manual section 2: in fact, section 2 actually shows the C wrapping functions of the respective syscalls.

In your code you'll have to:
- Put the arguments in the right registers
- call the function as a normal assembly procedure (`jal printf`)

and that's it! The linker will do the rest.



## Calling a written C function
If the function you want to call is in a C source file `func.c`, compile it to an object file. With `gcc` you can do it with the flag `-c`. Then, just add it to the list of object files to link in the link command (if you aren't using standard library functions, you don't need to link libc too).

The same considerations of using standard library functions about the arguments and the function call apply to this case.



## Extra: compile C step by step
...
