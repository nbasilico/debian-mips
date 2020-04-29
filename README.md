# Playing with MIPS assembly on Debian

*The following tutorial is an advanced annex to the laboratory course of Computer Architecture II, given in the Computer Science B.Sc. program at the University of Milan. The work is the result of a joint idea and work with Jacopo Essenziale who helped me in bringing this tutorial from a nerdy "coffee-break" discussion to an actual playground for students to enjoy. We are constantly searching for new ideas and suggestions. If you have any comments or would like to contribute feel free to contact us.*

Nicola Basilico nicola.basilico@unimi.it, Jacopo Essenziale jacopo.essenziale@unimi.it 

## Scope of this tutorial

A great number of Computer Architecture courses adopt MIPS architecture as a subject of study due to its simplicity. Many of such courses have lab sessions that involve Assembly programming. So do we at the University of Milan.

Just like many of these lab courses around the world, we run our Assembly programs in a simulated environment using great tools like Spim or Mars. From one side, this approach tremendously simplifies the task of teaching Assembly to first-year students. On the other side, a simulator **is not the real thing**.

## Install and configure Debian

Creating a work directory

```bash
mkdir debian-mips
cd debian-mips
```

Get the inird and the kernel image

```bash
# initial ram disk, can be used by the kernel as a root fs, contains the installer
wget http://ftp.debian.org/debian/dists/stable/main/installer-mips/current/images/malta/netboot/initrd.gz

# kernel image for the MIPS Malta board
wget http://ftp.debian.org/debian/dists/stable/main/installer-mips/current/images/malta/netboot/vmlinux-4.19.0-8-4kc-malta
```

Creating a virtual disk image to use. Please consider a minimum size of 1GB.

````bash
qemu-img create -f qcow2 hda.img 4G
````

Launch the installer

```sh
qemu-system-mips 
	-M malta \ # we are going to emulate a Malta MIPS board
	-m 512 \ # our machine will have 512MB of RAM
	-hda hda.img \ # the hd image we just created
	-kernel vmlinux-4.19.0-8-4kc-malta \ # the image of the kernel
	-initrd initrd.gz \ # the initial ram disk, contains the debian installer
	-append "console=ttyS0 nokaslr" \ # we'll need a console, we don't need address space layout randomization
	-nographic # we don't need GUIs
```

The Debian installer should start and should download various packages.

There will be a number of prompts.

Don't install a desktop environment, but make sure to install the SSH server

During the installation we must choose a root password and we must create a user. Let us assume that we created the user `mips1`

To start the machine we need to change the initrd we used. If we still use the previous one, the installer will be run at every boot. We need to get the initrd that the installation process created within the boot partition of our virtual hard disk. To do that we are going to use the NBD protocol, supported by qemu

```bash
sudo modprobe nbd max_part=63 # enable the ndb module, set max partitions number to 63
sudo qemu-nbd -c /dev/nbd0 hda.img # export the virtual disk to a nbd device in our local fs
sudo mount /dev/nbd0p1 /mnt # mount the boot partition under /mnt so we can access it
cp -r /mnt/boot/initrd.img-4.9.0-6-4kc-malta .  # the inird from the boot partition to the working directory (check version!)
# #cp -r /mnt/boot .                               # copy the entire boot folder this can also be done check!
sudo umount /mnt # unmount the partition
sudo qemu-nbd -d /dev/nbd0 # detactch the nbd device

```

At this point we are ready to start our virtual machine. This is the command we should use. We suggest to save this command inside a `start.sh` bash script:

```bash
qemu-system-mips 
	-M malta \
	-m 512 \
	-hda hda.img \
	-kernel vmlinux-4.19.0-8-4kc-malta \
	-initrd initrd.img-4.19.0-8-4kc-malta \ # this is the new initrd!
	-append "root=/dev/sda1 console=ttyS0 nokaslr" \ # appending also the main disk now
  	-nographic \
  	-redir tcp:5555::22 # local port 5555 will map to port 22 on the virtual machine
```

Debian should boot and we should see the command prompt. Let's open another shell and ssh to the machine:

```bash
ssh mips1@localhost -p 5555
```

Upon login we will be presented with our freshly instaled Debian! Let's take care of some basic stuff that will come handy:

```bash
su # become root
apt install sudo # install sudo 	
/sbin/usermod/usermod -aG sudo mips1 # add user mips1 to the sudoers group
```
At this point a reboot is probably needed

```bash
/sbin/shutdown now
```
Let's restart the machine and ssh to it just like we did before. 

```bash
# you might want to activate some aliases in your .bashrc
sudo apt install vim # let's install our favorite text editor
sudo apt install build-essential # installs gcc
```