# 9pfs error "Socket operation on non socket"
We copy here a question originally asked in [Superuser](https://superuser.com/q/1664049/1025605.md) regarding an error while using 9pfs on a QEMU MIPS VM. Unfortunately, the question had no answers and our current belief is that this problem is due to a QEMU bug.

## Context
On my Arch Linux x86_64 host, I'm running a Debian MIPS VM on Qemu with a [9pfs shared filesystem](https://wiki.qemu.org/Documentation/9psetup) using the following script:
```
qemu-system-mips \
	-M malta \
	-m 512 \
	-hda hda.img \
	-kernel vmlinux-*-malta \
	-initrd initrd.img-*-malta \
	-nographic \
	-append "root=/dev/sda1 console=ttyS0 nokaslr" \
	-net user,hostfwd=tcp::10022-:22 \
	-net nic \
	-virtfs local,path=code,mount_tag=host0,security_model=mapped-xattr,id=host0
```

Inside the guest, I mount the shared filesystem with the following fstab entry
```fstab
host0       /host        9p        trans=virtio,version=9p2000.L,_netdev,msize=52428800         0 0
```
or, equivalently, with the following command:
```sh
mount -t 9p -o trans=virtio,version=9p2000.L,msize=52428800    host0 /host
```

## The problem
Whenever I try to run on the guest any executable which resides on the shared filesystem, I get the following error:
```bash
-bash: <executable_file>: Socket operation on non-socket
```
For example:
```sh
sgorblex@debian-mips:/host$ cp /bin/ls ./
sgorblex@debian-mips:/host$ ./ls
-bash: ./ls: Socket operation on non-socket
sgorblex@debian-mips:/host$
```

I get the same error if I run `ls -l` in a directory on the 9pfs which contains executables.


## The question
What is causing this error? How do I get rid of it? I've tried a similar script with x86 VMs and they work fine. Is this a bug of QEMU's 9pfs implementation on MIPS?
