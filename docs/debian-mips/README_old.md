# IMMAGINE QEMU


ld -o hello -dynamic-linker /lib/ld-linux.so.2 /usr/lib/crt1.o /usr/lib/crti.o -lc hello.o /usr/lib/crtn.o



# Installazione Qemu

https://en.wikibooks.org/wiki/QEMU/Installing_QEMU

# lanciare immagine:
qemu-system-mips -M malta -kernel vmlinux-3.2.0-4-4kc-malta -m 512 -hda debian_wheezy_mips_standard.qcow2 -append "root=/dev/sda1 console=tty0"

# lanciare immagine con forward ssh su host (porta 22 guest su 2222 host)
qemu-system-mips -M malta -kernel vmlinux-3.2.0-4-4kc-malta -m 512 -hda debian_wheezy_mips_standard.qcow2 -net nic -net user,hostfwd=tcp::2222-:22 -append "root=/dev/sda1 console=tty0"

# versione upgraded : debian 8, nuovo kernel (con ssh)
qemu-system-mips -M malta -kernel vmlinux-3.16.0-4-4kc-malta -m 512 -hda debian_wheezy_mips_standard.qcow2 -net nic -net user,hostfwd=tcp::2222-:22 -append "root=/dev/sda1 console=tty0"

# ssh con:
ssh user@localhost -p 2222

# debian 7 --> problema con apt-get update... (forse è da cancellare il repo security da sources.list, in
# quanto non più supportato)

# user: user
# pass: user
# root: root

# keyboard it
# sudo installato
# build-essential installati

# per cambiare layout: 
sudo dpkg-reconfigure keyboard-configuration
# configurare keyboard
sudo service keyboard-setup restart

# Assemblare file assembly
as inputfile.asm -o objectfile.o

# Linking file oggetto
ld objectfile.o -o binary_file

# Esecuzione
./binary_file

# syscall unix su MIPS:
https://www.linux-mips.org/wiki/Syscall#Calling_conventions
https://github.com/spotify/linux/blob/master/arch/mips/include/asm/unistd.h

######### manca qualcosa nel sistema, non si trova get_random ???? ########
https://github.com/torvalds/linux/blob/master/arch/mips/include/uapi/asm/unistd.h
######################################

# o all'interno del sistema guardare includes...
# es.
/usr/include/mips-linux-gnu/asm/unistd.h