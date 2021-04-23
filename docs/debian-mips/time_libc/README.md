# Utilizzo di libc

Nei sistemi UNIX l'uso diretto delle syscall non è l'unico modo per utilizzare le funzioni del kernel. La libreria standard del C `libc` fornisce una serie di funzioni per svolgere task comuni come la gestione della memoria e l'input/output. Costituiscono un livello di astrazione sopra le syscall del kernel.

## Hello world con printf

Scriviamo un programma assembly che stampi "Hello world" usando `printf` (fornita da `libc`). Come primo step dobbiamo installare la documentazione di `libc` per avere a disposizione le man pages delle varie funzioni.

```bash
sudo apt-get install -y manpages-dev manpages-posix-dev
```

Dal manuale di `man` vediamo che le man pages delle funzioni di libreria stanno nella sezione 3:

```bash
man man
# [...]
# 1   Executable programs or shell commands
# 2   System calls (functions provided by the kernel)
# 3   Library calls (functions within program libraries)
# [...]
```
Visualizziamo la man page di `printf`:
```bash
man 3 printf
```
da cui vediamo che la signature della funzione è:
```c
int printf(const char *format, ...);
```
Il primo parametro, che verrà passato in `$a0`, è la stringa di formato seguita dalla lista degli argomenti da passare nei registri `a1`, `a2`, etc. (come specificato dalla convezione di passaggio parametri in MIPS).

```mips
# helloworld.asm
	.data
hello:	.asciiz "Hello world with printf!\n"
	.text
	.globl main
main:
	subu   $sp, $sp, 4
	sw     $ra, 0($sp)
	la     $a0, hello # primo parametro: stringa di controllo
	jal    printf
	lw     $ra, 0($sp)
	addiu  $sp, $sp, 4
	jr     $ra
```

Nel codice asssembly riportato sopra notiamo i seguenti aspetti:

- utilizziamo la label `main` anzichè `__start`; quindi in fase di linking dovremo ricordarci di includere le librerie `crt*.o` che si occuperanno di assemblare, insieme al nostro programma, le procedure di init che invocheranno `main`;

- per lo stesso motivo del punto precedente, il programma termina con `jr $ra` anzichè con una syscall `exit`; il `main` è quindi un callee non foglia (per via di `jal printf`), deve quindi salvare il registro `$ra` sullo stack per preservarlo attraverso la chiamata a funzione;

- la label `printf` non è definita in questo sorgente; in fase di linking specificheremo di includere `libc`, il linker andrà quindi a risolvere la label con l'indirizzo a cui sta `printf`.

Assemblaggio:

```bash
as time.asm -o time.o
```
Linking:

```bash
ld time.o 
	-o time
	-dynamic-linker /lib/ld.so.1 /usr/lib/mips-linux-gnu/crt*.o
	-lc
```
Esecuzione:

```bash
./time # Hello world with printf!
```

## Esercizio

Si scriva un programma che chieda all'utente di inserire un carattere e stampi il tempo di risposta in secondi (definito come il tempo che intercorre tra il momento in cui viene fatta la richiesta all'utente e il momento in cui il carattere è inserito). Si faccia uso della syscall `time` e delle funzioni `printf` e `getchar` dalla libreria standard del C.
