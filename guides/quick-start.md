:arrow_left: [back to README.md](../README.md)


# Linux MIPS assembly quick-start
After [installing](install.md), you are probably wondering where to start to compile and run an assembly program. Since you've installed an entire Linux distribution, you can potentially do whatever you like with it, including using an assembler and a linker of your choice. However, we'll use `as` and `ld`. Here are the steps to assemble, link and run an assembly program.



## Table of contents
- [A general approach](#A-general-approach)
	- [Code](#Code)
	- [Assemble](#Assemble)
	- [Link](#Link)
	- [Run](#Run)
- [Not obvious concepts](#Not-obvious-concepts)
	- [Entry points](#Entry-points)
		- [With C initializers](#Entry-points-with-C-initializers)
	- [Command line arguments](#Command-line-arguments)
		- [With C initializers](#Arguments-with-C-initializers)
- [Makefiles](#Makefiles)
	- [A somewhat universal assembly makefile](#A-somewhat-universal-assembly-makefile)



## A general approach
In the following example we see what you generally need to do from coding your program to run it.


### Code
The first step is obviously writing your program. You can use whatever editor you like, but it's probably faster to use one accessible via terminal, since our VM lacks in performance and in a GUI (although, you could technically use a GUI with ssh X11 forwarding or VNC). Vim, emacs or the simpler nano, pico, ne, etc. are good examples. Alternatively you can edit on your host and transfer the code in any way, including [directory sharing](install.md#Create-a-shared-directory) which works with ease.

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

Something you may not recognize from using an emulator like MARS or SPIM is the label `__start`. This label is required at linking time by `ld` and sets the starting point of the program.

We used `1` as the first argument for the `write` syscall as it is the conventional file descriptor for the `stdout` stream (see `stdin(3)`).


### Assemble
To assemble your code, that is, to make it an object file `hello.o`, you can use `as` as follows:
```sh
as hello.asm -o hello.o
```


### Link
To link your code, that is, to make it an executable file `hello` where each call is linked with its related address, you can use `ld` as follows:
```sh
ld hello.o -o hello
```

If your program includes multiple object files (assembled by multiple `.asm`s), link them all by passing them as arguments to `ld`. If you need to link other libraries, for example the C library, see `ld --help` (or `man ld`) for a list of flags. More information of using the C library in assembly is included in [this guide](libc.md).


### Run
As you would do with any executable file, just use:
```
./hello
```



## Not obvious concepts
In this section we cover some system/assembler/linker specific concepts which you might not learn by simply reading manual pages, and which are different from emulators like SPIM and MARS. We assume using `as` as assembler and `ld` as linker.

Some of these features differ if you link the C library initializers `/usr/lib/mips-linux-gnu/crt*.o`. These cases will be specified in the specific subsections. You can dynamically link the initializers with:
```
ld -o <target> <object files> /usr/lib/mips-linux-gnu/crt*.o -dynamic-linker /lib/ld.so.1
```
More information on using the C library in assembly in [this guide](libc.md).


### Entry points
As shown in the example, linking an object file with `ld` will look for an entry point labeled `__start`. Your program must start at the global (`.globl`) tag `__start` and it must end with an `exit` syscall as this segment will be the root of the call stack. Technically, omitting `__start` will let `ld` start at a default address, although it will show a warning and should be avoided.

#### Entry points with C initializers
The C library initializers contain a `__start` tag which contains initialization features, including jumping at the tag `main`. If you want to make use of said features link the object files and start your program at the `main` tag. Since your main is not the root of the call stack (it is in fact a callee), remember to terminate it with `jr $ra` and not by using the `exit` syscall.


### Command line arguments
The Linux loader will put command line arguments on the top of the stack as follows:
- the top of the stack (initial `$sp`) will contain the number of arguments the program was executed with, including the command itself (similarly to C's `argc`);
- the second word to the top of the stack (initial `$sp`+ 4) will contain the address of the first command line token, which is the command the program was executed with (saved as ASCII string);
- the third element of the stack (initial `$sp`+ 8) will contain the first argument in the same format;
- the fourth element of the stack (initial `$sp`+ 12) will contain the second argument;
- ...and so on;

Obviously you will need to check the number of arguments before popping elements from the stack. Don't forget to update `$sp` or your program will suffer from a (small) memory leak.

#### Arguments with C initializers
The C initialization procedure provides `argc` and `argv`, which have the same meaning and work exactly like they would in C (and in SPIM), `argc` being the number of command line tokens (including the program name) and `argv` being the (pointer to an) array of said tokens. In your `main`, `argc` will be loaded in register `$a0` and `argv` in `$a1`. Do not use the stack method if you link the C initializers and vice versa.



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


### A somewhat universal assembly makefile
The following makefile automatically builds the target `TARGET` by assembling each `.asm` in the `SRC` directory and putting the object files in the (existing) `OBJ` directory, then linking them together in the (existing) `BIN` directory.
```make
# target (executable name)
TARGET   = foo

# assembler and its flags
AS	 = as
ASFLAGS  =

# linker and its flags
LINKER   = ld
LFLAGS   =

# build directories (use . for current)
SRCDIR   = src
OBJDIR   = obj
BINDIR   = .

# automatically generated list of sources and object files
# this will select all .asm files in SRCDIR; explicitly list SOURCES if you want to manually select
SOURCES := $(wildcard $(SRCDIR)/*.asm)
OBJECTS := $(SOURCES:$(SRCDIR)/%.asm=$(OBJDIR)/%.o)


# target rule
$(BINDIR)/$(TARGET): $(OBJECTS)
	@$(LINKER) $(OBJECTS) $(LFLAGS) -o $@
	@echo "Linking complete!"

# object files rule
$(OBJECTS): $(OBJDIR)/%.o : $(SRCDIR)/%.asm
	@$(AS) $(ASFLAGS) $< -o $@
	@echo "Assembled "$<" successfully!"

# clean rule (removes build files) (use "make clean" to run)
.PHONY: clean
clean:
	@$(rm) $(OBJECTS)
	@echo "Cleanup complete!"

# remove rule (removes executable too)
.PHONY: remove
remove: clean
	@$(rm) $(BINDIR)/$(TARGET)
	@echo "Executable removed!"
```


:top: [get back to top](#Linux-MIPS-assembly-quick-start)
