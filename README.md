# MIPS assembly in Debian

*The following tutorial is an advanced annex to the laboratory course of Computer Architecture II, given in the Computer Science B. Sc. program at the University of Milan. The work is the result of a joint idea and work with dr. Jacopo Essenziale who helped me in bringing this tutorial from a coffee-break discussion to an actual playground for students to enjoy. We are constantly searching for new ideas and suggestions. If you have any comments or would like to contribute feel free to contact us.*

Nicola Basilico nicola.basilico@unimi.it, Jacopo Essenziale jacopo.essenziale@unimi.it 

## Motivation and scope

A great number of Computer Architecture courses adopt the MIPS architecture as a subject of study due to its simplicity and pragmatism. Such courses often include lab sessions where students are trained to develop Assembly programs. So do we in the course of Computer Architecture II at the University of Milan. Just like many of these lab courses around the world, we run our Assembly programs in a simulated environment using great tools like [Spim](http://spimsimulator.sourceforge.net/) or [Mars](http://courses.missouristate.edu/KenVollmar/MARS/). From one side, this approach tremendously simplifies the task of teaching Assembly to first-year students and is, undoubtedly, a lot of fun. On the other side, a simulator is not the real thing. The objective of this tutorial is to provide a step-by-step guide to setup a MIPS virtual machine and install Linux Debian on it. By doing so, we will enable the possibility to run Assembly sources without any fancy abstraction on the machine and by exploiting the development tools and library of a real operative systems.

The tutorial assumes to work on a Debian-based Linux distribution and requires basic bash skills.

## Install and configure Debian

1. install [Qemu](https://www.qemu.org/) with `apt-get`:

```bash
sudo apt-get install -y qemu qemu-kvm libvirt-bin
```
More detailed information, also including a guide for other operating systems, are available at [this link](https://en.wikibooks.org/wiki/QEMU/Installing_QEMU).

2. Create our working directory an cd to it.

```bash
mkdir debian-mips # you might choose any name you like ...
cd debian-mips
```

3. We shall perform a netboot of installation, so we need to get the initrd file and the kernel image. The initrd (initial RAM disk) will be used by the kernel as a root file system and, basically, contains out Debian installer. The kernel image is the one provided for the MIPS Malta board.

```bash
# get the initrd
wget http://ftp.debian.org/debian/dists/stable/main/installer-mips/current/images/malta/netboot/initrd.gz

# get the kernel image
wget http://ftp.debian.org/debian/dists/stable/main/installer-mips/current/images/malta/netboot/vmlinux-4.19.0-8-4kc-malta
```

4. Create a virtual disk image to use for the installation. On this virtual disk we must ensure a minimum size of 1GB.

````bash
# creates a virtual disk of 4GB in qcow2 format
qemu-img create -f qcow2 hda.img 4G
````

5. Boot the machine and make the installer being launched

```sh
qemu-system-mips 
	-M malta \ # we are going to emulate a Malta MIPS board
	-m 512 \ # our machine will have 512MB of RAM
	-hda hda.img \ # the disk image we just created
	-kernel vmlinux-4.19.0-8-4kc-malta \ # the image of the kernel we just downloaded
	-initrd initrd.gz \ # the initrd we just downloaded
	-nographic # we don't need GUIs
	-append "console=ttyS0 nokaslr" \ # we'll need a console, address space layout randomization will not be necessary	
```

At this point the Debian installer should start and the installation on Debian should proceed on the virtual machine. A number of prompts will be presented:

- don't install a desktop environment, but make sure to install the SSH server (we'll need it for remote access to the machine)
- choose a root password and we create a user. Let us assume that we created a user named `mips1`

6. Once the installation is completed and we turn off the machine, we need to change the initrd before restarting everything otherwise the installer will be run again upon boot. The initrd we need is the one that the installation procedure created within the boot partition of our virtual disk image. We need to fetch that and use it in our launching script. To access the virtual disk image we shall use the NBD protocol, supported by qemu. The steps are as follows:

```bash
sudo modprobe nbd max_part=63 # enable the ndb module, set max partitions number to 63
sudo qemu-nbd -c /dev/nbd0 hda.img # export the virtual disk to a nbd device in our local file system
sudo mount /dev/nbd0p1 /mnt # mount the boot partition under /mnt so we can access it
cp -r /mnt/boot/initrd.img-4.9.0-6-4kc-malta .  # copy the initrd from the boot partition to the working directory (check version!)
sudo umount /mnt # unmount the partition
sudo qemu-nbd -d /dev/nbd0 # detatch the nbd device
```

7. We are ready to prepare a script for starting the virtual machine, let's save it in a file called `start.sh` that we shall place in our working directory:

```bash
qemu-system-mips 
	-M malta \
	-m 512 \
	-hda hda.img \
	-kernel vmlinux-4.19.0-8-4kc-malta \
	-initrd initrd.img-4.19.0-8-4kc-malta \ # this is the new fetched initrd!
	-nographic \
	-append "root=/dev/sda1 console=ttyS0 nokaslr" \ # appending also the main disk now
  	-redir tcp:10022::22 # local port 10022 will map to port 22 on the virtual machine
```

8. Debian OS should boot and we should see the command prompt. Thanks to the port mapping we applied in the start sript, we can ssh to the machine:

```bash
ssh mips1@localhost -p 10022
```

Upon login we will be presented with our freshly installed Debian, let's take care of some basic tools that will come handy:

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
sudo echo "I am (g)root" # test if sudo work
sudo apt install vim # let's install our favorite text editor
sudo apt install build-essential # installs gcc
```