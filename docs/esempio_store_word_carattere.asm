# Esempio: lettura di due singoli caratteri e loro scrittura in memoria con store word

	.data
	arr: .space 8

	.text
	.globl main
	
main:
	# leggo il primo carattere (system call 12, read_character)
	li $v0, 12
	syscall
	move $s1, $v0
	
	# scrivo il carattere in memoria
	la $t0, arr
	sw $s1 0($t0)
	
	# leggo il secondo carattere
	li $v0, 12
	syscall
	move $s1, $v0
	
	# scrivo il carattere in memoria
	la $t0, arr
	sw $s1 4($t0)
	
	# exit
	li $v0, 10
	syscall
