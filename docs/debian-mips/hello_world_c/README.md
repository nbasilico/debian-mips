# Da C ad Assembly

Si consideri il programma C riportato nel file *helloworld.c*. 
```c
// helloworld.c
#include <stdio.h>
int main()
{
    printf("Hello World!\n");
    return 0;
}
```
Compiliamo il file usando `gcc` per ottenere un eseguibile:
```bash
gcc helloworld.c -o helloworld
```
Lanciamo l'eseguibile:
```bash
./helloworld # Hello World!
```

Per produrre l'eseguibile, il compilatore ha svolto (in ordine):

1) pre-processing: rimozione commenti, espansione di header e macro;
2) compilazione vera e propria: produce linguaggio assembly;
3) assemblaggio: produce linguaggio macchina;
4) linking: risoluzione dipendenze, produce un file eseguibile.

Possiamo richiedere a `gcc` di fermarsi dopo lo step di compilazione (2) e di produrre un file con il codice assembly ottenuto (che possiamo ispezionare):
 
```bash
gcc -S helloworld.c -o helloworld.s
```

Svolgiamo manualmente l'assemblaggio (3) usando `as`, l'assembler GNU:

```bash
as helloworld.s -o helloworld.o
```

Il file oggetto ottenuto (`helloworld.o`) contiene le istruzioni in linguaggio macchina, ma non è ancora eseguibile:

```bash
chmod +x helloworld.o
./helloworld # cannot execute binary file: Exec format error
```


Dobbiamo fare il linking usando `ld`, il linker GNU:
 
```bash
ld hello.o
	-o hello 
	-dynamic-linker /lib/ld.so.1 /usr/lib/mips-linux-gnu/crt*.o
	-lc
```

* con l'opzione `-dynamic-linker` richiediamo a `ld` di utilizzare la libreria `ld.so.1` per eseguire il linking delle librerie a run-time (linking dinamico);
* le librerie `/usr/lib/mips-linux-gnu/crt*.o` contengono le routine di startup per il programma (e in particolare le definizioni per le label `__start` e `__init`) che chiameranno il `main` del nostro programma e a cui restituiremo il controllo al termine;
* l'opzione `-lc` richiede il linking di `libc`, la libreria standard del C.

Il file `helloworld` è ora un *eseguibile*:
```bash
./helloworld # Hello World!
```
