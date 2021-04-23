# Da Assembly all'eseguibile

Scriviamo un programma assembly che stampi la stringa "Hello world!" e generiamo un file eseguibile da lanciare sulla macchina virtuale. Dobbiamo considerare due aspetti:

- `ld` richiede una entry label di default con nome `__start`, quindi usiamo questa label al posto di `main` oppure, se usiamo `main`, dobbiamo ricordarci di linkare `ld.so.1`;
- le syscall non saranno quelle simulate da SPIM ma, ovviamente, le reali syscall esposte dal kernel Linux, dobbiamo capire come usarle.

## Utilizzo delle syscall

Supponiamo di avere una stringa da stampare sullo standard output, necessitiamo quindi di una syscall simile a quella che in SPIM/MARS è `print_string`. Per capire come utilizzare *direttamente* le syscall del kernel Linux dobbiamo incrociare diverse informazioni.

Per prima cosa ispezioniamo la lista di tutte le syscall offerte dal sistema operativo. Lo facciamo lanciando questo comando sul sistema emulato:
```bash
man syscalls
```
Dalla lunga lista ci accorgiamo che esiste una syscall `write` che, nelle man pages ha 2 sezioni come indicato dal "(2)" dopo il nome della funzione. Esistono due `write`. Una è un comando della bash che implementa una utility per spedire messaggi ad altri utenti (si può invocare da terminale). La seconda è invece una syscall del sistema operativo. Dal manuale di `man` vediamo che le descrizioni inerenti alle syscall stanno nella sezione 2 della man page:
```bash
man man
#NAME
#       man - an interface to the on-line reference manuals
# [...]
# 1   Executable programs or shell commands
# 2   System calls (functions provided by the kernel)
# [...]
```
Per ottenere quindi la man page della *syscall* `write` (e non dell'*utility* `write`) dobbiamo richiamare la seconda sezione:

```bash
man write # manuale dell'utility write, non ci interessa
#NAME
#     write — send a message to another user
# [...]
```
```bash
man 2 write # manuale della syscall write, è quello che ci serve
#NAME
#       write - write to a file descriptor
```

Dalla man page ci accorgiamo che la signature della syscall è:
```c
ssize_t write(int fd, const void *buf, size_t count);
```
Con la signature ricaviamo il tipo e l'ordine dei parametri che, nel codice assembly, tratteremo seguendo le convenzioni di chiamata a procedura del MIPS. Nello specifico:

- il primo parametro, da passare in `$a0`, è un intero che rappresenta il file descriptor; nei sistemi UNIX lo standard output è indicato con il valore `1`;
 
- il secondo parametro, da passare in `$a1`, è un puntatore al buffer che contiene i bytes da stampare; sarà quindi il base address della stringa che vogliamo stampare;

- il terzo parametro, da passare in `$a2`, è il numero di byte da stampare e cioè il numero di caratteri della nostra stringa (in C, `size_t` è un intero unsigned su non meno di 16 bit).


Per risalire al codice della syscall ispezioniamo (sempre sul sistema emulato) il file `/usr/include/mips-linux-gnu/asm/unistd.h`: la `write` ha codice 4004, valore che dovremo quindi caricare nel registro `$v0`.

```mips
	.data
hello:	.asciiz "\nHello, World!\n"
	.text
	.globl __start
__start:
	li $v0, 4004 # codice syscall write
	li $a0, 1 # standard output
	la $a1, hello # base address stringa
	li $a2, 15 # lunghezza stringa in bytes
	syscall	
	li $v0, 4001 # exit
	syscall
```

## Assemblaggio e linking

Una volta scritto il sorgente assembly (si veda il file `helloworld.asm`), lo assembliamo e lo linkiamo. In questo caso non stiamo usando nessuna libreria esterna e quindi non abbiamo dipendenze da segnalare al linker. Il linker non ha dipendenze esterne da risolvere, ma comunque ristruttura il file oggetto in un formato che il sistema operativo riconosce come eseguibile.
```bash
as helloworld.asm -o helloworld.o
ld helloworld.o -o helloworld
./helloworld # Hello World!
```
