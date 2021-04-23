	.data
hello: 	.asciiz "\nHello, World!\n"

	.text
	.globl __start

__start:
	li $v0, 4004 		# codice syscall write
	li $a0, 1		# standard output
	la $a1, hello		# base address stringa
	li $a2, 15		# lunghezza stringa in bytes
	syscall
	
	li $v0, 4001		# exit
	syscall