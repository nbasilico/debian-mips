# Emulazione di una macchina Debian MIPS

## Installazione dell'emulatore
Installazione di [Qemu](https://www.qemu.org/) tramite `apt-get`:
```bash
sudo apt-get install -y qemu qemu-kvm libvirt-bin
```
Informazioni più dettagliate, incluse le istruzioni per più sistemi operativi, sono disponibili a [questo link](https://en.wikibooks.org/wiki/QEMU/Installing_QEMU).

## Configurazione e avvio
Scaricare l'archivio zip a [questo link](https://gvm.aislab.di.unimi.it/index.php/s/4Z1nPWMJBQgId0K) e scompattarlo in una directory locale. L'archivio contiene:

- un'immagine del kernel `vmlinux-3.2.0-4-4kc-malta`;
- un'immagine per il disco virtuale `debian_wheezy_mips_standard.qcow2`.

Avviare la macchina virtuale:
```bash
qemu-system-mips 
	-M malta 
	-kernel vmlinux-3.16.0-4-4kc-malta
	-m 512 
	-hda debian_wheezy_mips_standard.qcow2
	-net nic 
	-net user,hostfwd=tcp::20011-:22 
	-append "root=/dev/sda1 console=tty0"
```
Tramite il comando riportato sopra andremo ad utilizzare il PC System Emulator di Qemu per MIPS (`qemu-system-mips`) per ottenere l'emulazione di una macchina con queste caratteristiche:

- processore con ISA MIPS32 (tra le più recenti), nello specifico il processore è il MIPS32 4Kc; si veda la [lista completa processori MIPS](https://en.wikipedia.org/wiki/List_of_MIPS_architecture_processors), mentre con il comando `qemu-system-mips -cpu '?'` si veda la lista di tutti i processori MIPS emulabili; sul sistema emulato possiamo inoltre ottenere dettagli sulla CPU con il comando `cat /proc/cpuinfo`;

- scheda madre [MIPS Malta](https://www.linux-mips.org/wiki/MIPS_Malta);

- 512 megabyte di RAM;

- sistema operativo [Debian 8 Jessie](https://www.debian.org/releases/jessie/index.en.html) (Linux `debian-mips`, versione del kernel `3.16.51-2`, release `3.16.0-4-4kc-malta`);

- porta 22 della macchina emulata mappata sulla porta 20011 della macchina host, accesso `ssh` con nome utente e password "user". 

Una volta avviata la macchina virtuale, possiamo aprire una shell via `ssh`:

```bash
ssh user@localhost -p 20011 # password: user
```
