# Esempio di allocazione dinamica di memoria: alloco memoria per un elemento struct definito a piacere.

	.data
	buffer: .space 1024

	# elemento struct:
	# campo nome: stringa di 1024 bytes
	# campo age: intero su 32 bit

	.text
	.globl main
main:

	li $v0, 9 # sbrk
	li $a0, 1056 # alloco 1056 bytes (1024 + 32, quanti ne servonp per ogni elemento struct)
	syscall
	move $s0, $v0 # ottengo riferimento all'elemento creato

	# acquisizione di un stringa
	li $v0, 8 # read string
	la $a0, buffer
	li $a1, 1024
	syscall

	la $t1, buffer
	li $t2, 0 # contatore
	move $t3, $s0 # base address che verrà aggiornato
loop1:	
	lbu $t0, 0($t1) 		# leggo carattere
	sb $t0, 0($t3) 			# copio carattere nella struct	
	beqz $t0, loop1_exit 		# termine stringa: esco
	bge $t2, 1024, loop1_exit 	# max dim raggiunta: esco

	addi $t1, $t1, 1 
	addi $t3, $t3, 1
	addi $t2, $t2, 1
	
	j loop1

loop1_exit:
	# acquisizione di un intero
	li $v0, 5 # read int
	syscall
	# scrivo intero nella struct
	sw $v0, 1024($s0)

	# stampo la stringa acquisita
	li $v0, 4 # print string
	move $a0, $s0
	syscall

	# e anche l'intero
	li $v0, 1 # print int
	lw $a0, 1024($s0)
	syscall
jr $ra
