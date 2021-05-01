:arrow_left: [back to README.md](../README.md)


# Install Debian on a Qemu MIPS VM
In this guide we see how to install Debian on a Qemu MIPS virtual machine. The tutorial assumes to work on a Debian-based Linux distribution (though it's really easy do adapt to others) and requires basic shell skills.

## Table of contents
- [Dependencies and preparation](#Dependencies-and-preparation)
- [Debian installation](#Debian-installation)
- [Update the initrd](#Update-the-initrd)
- [Create the startup script](#Create-the-startup-script)
- [Post installation](#Post-installation)
- [Create a shared directory](#Create-a-shared-directory)


## Dependencies and preparation
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

## Debian installation
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

## Update the initrd
7. Once the installation is completed and we turn off the machine, we need to change the initrd before restarting everything otherwise the installer will be run again upon boot. The initrd we need is the one that the installation procedure created within the boot partition of our virtual disk image. We need to fetch that and use it in our launching script. To access the virtual disk image we shall use the nbd protocol, supported by Qemu. the steps are as follows:
   ```sh
   sudo modprobe nbd max_part=63         # enable the ndb kernel module on the host, set max partitions number to 63
   sudo qemu-nbd -c /dev/nbd0 hda.img    # export the virtual disk to a nbd device in our local file system
   sudo mount /dev/nbd0p1 /mnt           # mount the disk's boot partition under /mnt so we can access it
   cp -r /mnt/boot/initrd.img-*-malta .  # copy the initrd from the boot partition into the working directory
   sudo umount /mnt                      # unmount the partition
   sudo qemu-nbd -d /dev/nbd0            # detatch the nbd device
   ```

## Create the startup script
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

## Create a shared directory
This section is completely optional and lets you set up a shared directory between your host and the MIPS VM by mounting a [9p filesystem](http://9p.cat-v.org/) using the [9p network protocol](https://en.wikipedia.org/wiki/Plan_9_from_Bell_Labs#9P_protocol). Doing this is actually surprisingly simple and can be done with only a couple of tweaks. Among other benefits, a shared directory allows to code using your preferred editor and configuration (including GUI applications which are hard to use on a VM of this kind) and to do so while having bare-metal performance and still being able to access the edited files from within the VM. Obviously, you'll have to run your final product on the VM since you're programming in MIPS assembly (unless you're using a phisical MIPS machine, in which case this guide is completely pointless to you). In theory, you could also compile and link your code from the host machine, but doing so would require setting up assembler and linker to build something for a MIPS architecture and it's easier generally to just do it in the VM.

An in-depth guide to virtual filesystems using 9p on Qemu is available in the [official documentation page](https://wiki.qemu.org/Documentation/9psetup).

You can setup a 9p directory sharing between host and guest by simply appending this option to the `start.sh` script Qemu command:
```sh
-virtfs local,path=<path/to/directory>,mount_tag=<tag>,security_model=mapped-xattr
```
Where `<path/to/directory>` the relative or absolute path to the shared directory on the host and `<tag>` is a tag of your choice.

Once booted the VM, you can mount the shared directory similarly to what you would do with a normal volume:
```sh
mount -t 9p -o trans=virtio,version=9p2000.L,msize=50000    <tag> <mountpoint>
```

Or by adding the following entry to `/etc/fstab`, which will automatically mount the drive at boot time.
```fstab
<tag>   <mountpoint>   9p   trans=virtio,version=9p2000.L,_netdev,msize=50000   0 0
```

Note that `msize` should be set depending on the phisical drive on which the shared directory resides, as described in [the documentation](https://wiki.qemu.org/Documentation/9psetup#msize).


### Notes
- The `version` parameter specifies, as you might have guessed, the version of the protocol (if omitted, the version is `9P2000.u`). More information on the version can be found in the [documentation](https://github.com/chaos/diod/blob/master/protocol.md) of the implementation Diod and its bibliography.
- In the fstab entry, the `_netdev` option specifies that the guest must wait for the network libraries to load before attempting to mount the drive. This is necessary since the 9p libraries aren't loaded right away. While this is by far the easiest solution, you could also compile the initrd so that these libraries are instantly loaded, as described in [this Superuser answer](https://superuser.com/a/536352), and then replace the old initrd with the new one in `start.sh`.



:top: [get back to top](#Install-Debian-on-a-Qemu-MIPS-VM)
