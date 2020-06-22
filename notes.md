## Branch notes

### What I changed:
- dependencies: there's no need for `qemu-kvm` (since we don't use the host machine's ISA) or for `libvirt`. There is, although, for `qemu-system-mips`. Packages names are based on Debian 10 repositories. Also, while `apt-get` is backwards compatible, it is sort of obsolete. `wget` is also useful for the installing process.
- the `wget` URLs were obsolete, since the images got updated. I substituted them with a possibly universal command I came up with. It uses regexs and should work for every version. I tried to keep the other commands universal too.
- for some reason the `qemu-system-mips` command doesn't work with bash's `#` comments. I moved the notes below. Also, there were a couple of typos (missing `\`s): I fixed them.
- the `-redir` option is now deprecated and is not anymore in newer qemu versions. I replaced it with two options, which create a simple nic network card and map its 22 port to the host's 10022 (having the wanted effect)

### Suggestions
- It could be helpful to add something regarding the assembly developement, since we don't have the help the emulator gives. How do we assemble the code? What syscalls can we use?

### Various notes
- For some reason i couldn't get the memory or the CPU cores given to the guest higher. This considerably affects the performance and the experience.
- My main machine mounts Arch Linux. I've tested first on Arch and then on a lxc (linux container) with Debian 10 (hence the Debian 10 based notes). Just in case, here are the Arch dependencies: `qemu`, `qemu-arch-extra`, `wget`, `nbd`.
