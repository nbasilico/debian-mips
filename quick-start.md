:arrow_left: [back to README.md](README.md)

# Linux MIPS assembly quick-start
After [installing](install.md), you are probably wondering where to start to compile and run an assembly program. Since you've installed an entire Linux distribution, you can potentially do whatever you like with it, including using an assembler and a linker of your choice. However, we'll use `as` and `ld`. Here are the steps to assemble, link and run an assembly program.



## Table of contents
- [A general approach](#A-general-approach)
	- [Code](#Code)
	- [Assemble](#Assemble)
	- [Link](#Link)
	- [Run](#Run)
- [Makefiles](#Makefiles)



## A general approach
In the following example we see what you generally need to do from coding your program to run it.


### Code
The first step is obviously writing your program. You can use whatever editor you like, but it's probably faster to use one accessible via terminal, since our VM lacks in performance and in a GUI (although, you could tecnically use a GUI with ssh X11 forwarding or VNC), for example vim, emacs or the simpler nano, pico, ne, etc. Alternatively you can edit on your host and transfer the code in any way, including [directory sharing](install.md#Create-a-shared-directory) which works with ease.

While programming you'll probably use syscalls or the C library. In [this guide](manual.md) we teach you where to find what you're looking for in the manual.

Let's say you wrote this hello world program, saved as `hello.asm`:
```asm
.data
	hello: .asciiz "Hello, World!\n"

.text

.globl __start
__start:
	li $v0, 4004
	li $a0, 1
	la $a1, hello
	li $a2, 14
	syscall
	
	li $v0, 4001
	li $a0, 0
	syscall
```

Something you may not recognise from using an emulator like MARS or SPIM is the label `__start`. This label is required at linking time by `ld` and sets the starting point of the program.

We used `1` as the first argument for the `write` syscall as it is the conventional file descriptor for the `stdout` stream (see `stdin(3)`).


### Assemble
To assemble your code, that is, to make it an object file `hello.o`, you can use `as` as follows:
```sh
as hello.asm -o hello.o
```


### Link
To link your code, that is, to make it an executable file `hello` where each call is linked with its related address, you can use `ld` as follows:
```sh
ld hello.o
```

If your program includes multiple object files (assembled by multiple `.asm`s), link them all by passing them as arguments to `ld`. If you need to link other libraries, for example the C library, see `ld --help` (or `man ld`) for a list of flags. More information of using the C library in assembly is included in [this guide](clib.md).


### Run
As you would do with any executable file, just use:
```
./hello
```


## Makefiles
[GNU make](https://www.gnu.org/software/make/manual/make.html#Introduction) is a software that helps you automate compiling (or even installing and testing) your programs.

A makefile is a file, very similar to a shell script, that contains everything `make` needs to know to build your program. A simple makefile that automates what seen in the previous example is the following:
```make
hello: hello.o
	ld hello.o -o hello

hello.o: hello.asm
	as hello.asm -o hello.o
```

Save this file as `Makefile`. From now on, once made your improvements to `hello.asm` (or any of the files included in the makefile), you only need to run:
```sh
make
```

Make will automatically assemble and link your program, making the `hello` executable. If you didn't make changes, or if you changed only some of the source code files, make will know what to rebuild and only do that.

Make is a complex software that can automate many parts of your workflow. For example, you often see `clean` or `install` rules in makefiles. While in some environments and with some languages Make may be considered obsolete or not fitting, it is the perfect tool for assembling and linking assembly projects like these. However, it is not the purpose of this guide to teach you how to use Make extensively; we highly suggest to consult the manual (`man make`) and look in the internet for useful examples.


:top: [get_back_to_top](#Linux-MIPS-assembly-quick-start)
