	.data
prompt:	.asciiz "Inserisci un carattere ...\n"
outmsg: .asciiz "Tempo di risposta: %d secondi\n" 
	.align 2

buff0: 	.space 4
buff1: 	.space 4
buff2: 	.space 4

	.text
	.globl main 
main:
	# salvo $ra sullo stack
	subu   $sp, $sp, 4
       	sw     $ra, 0($sp)
	
	# acquisisco primo time
	li $v0, 4013 # syscall time
	la $a0, buff0
	syscall

	# stampo una richiesta di input
	la $a0, prompt
	jal printf

	# leggo un singolo carattere
	jal getchar

	# acquisisco secondo tempo
	li $v0, 4013 # syscall time
        la $a0, buff2
        syscall

	# calcolo differenza tra i tempi acquisiti
	sub $s2, $s1, $s0

	# stampo il tempo di risposta
	la $a0, outmsg
	move $a1, $s2
	jal printf	

        lw     $ra, 0($sp)
        addiu  $sp, $sp, 4
	jr $ra
