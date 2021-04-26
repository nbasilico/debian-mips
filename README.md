# MIPS assembly in Debian
*The following tutorial is an advanced annex to the laboratory course of Computer Architecture II, given in the Computer Science B. Sc. program at the University of Milan. The work is the result of a joint idea and work with dr. Jacopo Essenziale who helped me in bringing this tutorial from a coffee-break discussion to an actual playground for students to enjoy. We are constantly searching for new ideas and suggestions. If you have any comments or would like to contribute feel free to contact us.*

Nicola Basilico nicola.basilico@unimi.it, Jacopo Essenziale jacopo.essenziale@unimi.it 




## Motivation and scope
A great number of Computer Architecture courses adopt the MIPS architecture as a subject of study due to its simplicity and pragmatism. Such courses often include lab sessions where students are trained to develop Assembly programs. So do we in the course of Computer Architecture II at the University of Milan. Just like many of these lab courses around the world, we run our Assembly programs in a simulated environment using great tools like [Spim](http://spimsimulator.sourceforge.net/) or [Mars](http://courses.missouristate.edu/KenVollmar/MARS/). From one side, this approach tremendously simplifies the task of teaching Assembly to first-year students and is, undoubtedly, a lot of fun. On the other side, a simulator is not the real thing. The objective of this tutorial is to provide a step-by-step guide to setup a MIPS virtual machine and install Linux Debian on it. By doing so, we will enable the possibility to run Assembly sources without any fancy abstraction on the machine and by exploiting the development tools and library of a real operative system.

The tutorial assumes to work on a Debian-based Linux distribution (though it's really easy do adapt to others) and requires basic shell skills.




## Install and configure Debian
1. Install [Qemu](https://www.qemu.org/) and the other dependencies with `apt`:
   ```sh
   sudo apt install -y qemu qemu-system-mips wget
   ```
   See the [wiki page](https://en.wikibooks.org/wiki/QEMU/Installing_QEMU) for more info on installing Qemu.

2. Create our working directory an `cd` to it.
   ```sh
   mkdir debian-mips # you might choose any name you like ...
   cd debian-mips
   ```

3. We shall perform a netboot of installation, so we need to get the initrd file and the kernel image. The initrd (initial RAM disk) will be used by the kernel as a root file system and, basically, contains our Debian installer. The kernel image is the one provided for the MIPS Malta board.
   ```sh
   # download initrd and kernel image
   wget -r -np -nd -A 'initrd.gz' -A 'vmlinux-*-malta' http://ftp.debian.org/debian/dists/stable/main/installer-mips/current/images/malta/netboot/
   ```

4. Create a virtual disk image to use for the installation. For the installation we must ensure a minimum size of about 1GB, but a bit more for our work won't hurt.
   ```sh
   # creates a virtual disk of 4GB in qcow2 format
   qemu-img create -f qcow2 hda.img 4G
   ```

5. Boot the machine and make the installer being launched
   ```sh
   qemu-system-mips \
      -M malta \
      -m 512 \
      -hda hda.img \
      -kernel vmlinux-*-malta \
      -initrd initrd.gz \
      -nographic \
      -append "console=ttyS0 nokaslr"
   ```
   - `-M malta`: board: Malta
   - `-m 512`: main memory (RAM): 512MB
   - `-hda hda.img`: disk: the disk image we just created
   - `-kernel vmlinux-*-malta`: kernel: the image of the kernel we just downloaded
   - `-initrd initrd.gz`: initrd: the initrd we just downloaded
   - `-nographic` we don't need guis
   - `-append "console=ttys0 nokaslr"`: additional kernel parameters: we'll need a console, address space layout randomization will not be necessary   

6. Proceed with the installation. At this point the debian installer should start and the installation of debian should proceed on the virtual machine. A number of prompts will be presented:
   - don't install a desktop environment, but make sure to install the ssh server (we'll need it for remote access to the machine)
   - choose a root password and create a user. Let us assume that we created a user named `mips1`

7. Once the installation is completed and we turn off the machine, we need to change the initrd before restarting everything otherwise the installer will be run again upon boot. The initrd we need is the one that the installation procedure created within the boot partition of our virtual disk image. We need to fetch that and use it in our launching script. To access the virtual disk image we shall use the nbd protocol, supported by Qemu. the steps are as follows:
   ```sh
   sudo modprobe nbd max_part=63         # enable the ndb kernel module on the host, set max partitions number to 63
   sudo qemu-nbd -c /dev/nbd0 hda.img    # export the virtual disk to a nbd device in our local file system
   sudo mount /dev/nbd0p1 /mnt           # mount the disk's boot partition under /mnt so we can access it
   cp -r /mnt/boot/initrd.img-*-malta .  # copy the initrd from the boot partition into the working directory
   sudo umount /mnt                      # unmount the partition
   sudo qemu-nbd -d /dev/nbd0            # detatch the nbd device
   ```

8. We are ready to prepare a script for starting the virtual machine, let's save it in a file called `start.sh` that we shall place in our working directory:
   ```sh
   #!/bin/sh

   qemu-system-mips \
      -M malta \
      -m 512 \
      -hda hda.img \
      -kernel vmlinux-*-malta \
      -initrd initrd.img-*-malta \
      -nographic \
      -append "root=/dev/sda1 console=ttyS0 nokaslr" \
      -net user,hostfwd=tcp::10022-:22 \
      -net nic
   ```
- the `-initrd` option we now have the new fetched initrd
- the `-append` option now includes the main disk
- the last two options create a virtual network card to connect between host and guest and to the internet. It has the port 22, the ssh server default, mapped to the host's port 10022.

9. By running the above script, Debian OS should boot and we should see the command prompt. Thanks to the port mapping we applied in the script, we can ssh to the machine from a new local terminal:
   ```bash
   ssh -p 10022 mips1@localhost
   ```


## Post installation
Upon login we will be presented with our freshly installed Debian, let's take care of some basic tools that will come handy:

```sh
su                      # become root
apt install sudo        # install sudo    
usermod -aG sudo mips1  # add user mips1 to the sudoers group
```

After logging out and back in, we can use sudo to run commands with superuser rights:
```sh
sudo echo "I am (g)root"         # test if sudo works
sudo apt install vim             # let's install our favorite text editor
sudo apt install build-essential # installs various compiling tools including gcc
```
