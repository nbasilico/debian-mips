:arrow_left: [back to README.md](../README.md)


# Crossbuild for Linux MIPS
Since the VM's performance isn't the best, you might have wondered if it's possible to assemble and link Linux MIPS programs on your bare metal host, to then run them in the MIPS VM. The process of building (compiling, assembling, linking, etc.) software for an architecture different from the one you're building from is known as [cross building](https://en.wikipedia.org/wiki/Cross_compiler) (or cross compiling).

This process is not always straightforward since the building software contained in the distribution repository is typically compiled to build for the target architecture it runs on. However, the following methods let you succeed in having a full-featured building set with relative ease. They are presented in order of ease. A more comprehensive list of methods and existing toolchains is available [here](https://www.linux-mips.org/wiki/Toolchains).

## Distribution repository
Some distributions, including Debian, have packages in their repositories specific for this purpose. If you're using Debian, install the `crossbuild-essential-mips` package:
```sh
sudo apt install -y crossbuild-essential-mips
```
This package provides the same utilities of `build-essential` (recall from the [VM installation](install.md)), except they are compiled to work for MIPS targets. The programs work exactly like they would in the VM, except they are named `mips-linux-gnu-<program_name>`, for example:
```sh
mips-linux-gnu-as hello_world.asm -o hello_world.o
mips-linux-gnu-ld hello_world.o -o hello_world
```

If you are not on Debian, check your distribution's repositories for packages similar to this, as this is the easier and more canonical (no pun intended) method.


## Pre-compiled binaries
The official MIPS website offers downloads for [pre-compiled GNU toolchains](https://codescape.mips.com/components/toolchain/latest/index.html) (see download page) for MIPS bare metal and Linux systems. Of course, in our case we need the Linux ones. These pre-compiled binaries are available for x86 and x64 systems.


## Compile your own toolchain
You might want to compile your own GNU toolchain for one of the following reasons:
- your distribution does not provide an appropriate package
- the pre-compiled toolchain is too outdated for your needs (or you need a specific version)
- you want the most possibly optimized toolchain for your system

While being harder than the previous methods, compiling your own toolchain is not as hard as you might think. The procedure is well described [here](https://www.linux-mips.org/wiki/Toolchains#Roll-your-own).



:top: [get back to top](#Crossbuild-for-Linux-MIPS)
