:arrow_left: [back to README.md](../README.md)


# The manual and syscalls
After [installing Debian MIPS] you're probably wondering where to look for while researching syscalls and Linux assembly programming in general. Here's what you need to know.

Be sure of consulting the manual from the emulated system, since the pages may differ from your host OS/architecture. We assume you are using a Debian MIPS installation like the one obtained by following our [installation guide], however, most of the guide is easily adaptable to any architecture.

[installation guide]: install.md
[installing Debian MIPS]: install.md



## Table of contents
- [Table of useful man pages](#Table-of-useful-man-pages)
- [Syscalls](#Syscalls)
- [Library functions](#Library-functions)


## Table of useful man pages
Use:
```
man <section> <name>
```
Page `name` of section `section` is referred to as `name(section)`. See `man man` for an in-depth explanation.

|   Name   | Section |               Description                 |
|:--------:|:-------:|:-----------------------------------------:|
|   man    |    1    |             Manual of manual              |
| intro    |    2    |       Introduction to Linux syscalls      |
| syscalls |    2    |           List of Linux syscalls          |
| syscall  |    2    | Architecture specific syscall information |

Note that the description matches our use-case. Some of the listed pages may contain not related information.



## Syscalls
Section `2` of the manual contains information about system calls. `intro(2)` is an introduction to Linux syscalls. `syscalls(2)` lists all existing Linux syscalls. While with high level languages you typically use wrapper functions (C wrapper functions in particular), more or less directly, in assembly you can just use the syscall itself.

A syscall's arguments are documented in its C wrapper function's man page. For example, `write(2)` contains information about the `write` syscall in the form of a C function signature:

```c
#include <unistd.h>
ssize_t write(int fd, const void *buf, size_t count);
```

Once found your syscall, you may look for its number in the header file `/usr/include/mips-linux-gnu/asm/unistd.h`, for example, the number of `write` is 4004:
```c
#define __NR_Linux                      4000
...
#define __NR_write                      (__NR_Linux +   4)
```


## Library functions
Section `3` of the manual contains information about library functions: for example, `printf(3)` contains information about the C library function `printf`.

In section `3` you can also find an overview of the features included in a header file, for example `stdio(3)`, or info about special symbols, such as `stdin(3)`.



:top: [get back to top](#Guide-to-the-manual)
