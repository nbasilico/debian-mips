# Esempio di branch a più vie implementato con una Jump Address Table
	
	.data
	stringC0: .asciiz "CASO 0: \n"
	stringC1: .asciiz "CASO 1: \n"
	stringC2: .asciiz "CASO 2: \n"
	stringC3: .asciiz "CASO 3: \n"

	TABLE: .word LABEL_CASE_0, LABEL_CASE_1, LABEL_CASE_2, LABEL_CASE_3

	.text
	.globl main
main:

	# $s0, $s1, $s2, $s3, $s4, $s5 contengono f,g,h,i,j,k 
	# associo:
	# f -> $s0
	# g -> $s1
	# h -> $s2
	# i -> $s3
	# j -> $s4
	# k -> $s5

	# assumo: i=j=1, g=2, h=3
	li $s1, 2
	li $s2, 3
	li $s3, 1
	li $s4, 1

	# acquisisco k dall'utente
	li $v0, 5 # read int						
	syscall
	move $s5, $v0

	# controllo che k sia compreso tra 0 e 3 altrimenti default case
	slt  $t3, $s5, $zero
	bne  $t3, $zero, DEFAULT 			# if k<0, DEFAULT
	slti $t3, $s5, 4
	beq  $t3, $zero, DEFAULT			# if k>=4, DEFAULT

	# branch a più vie: destinazione determinata leggendo dalla jump address table

	la $t0, TABLE
	mulo   $t1, $s5, 4 # t1 = k*4 (offset)
	add    $t1, $t0, $t1 # t1 = indirizzo da cui leggere l'indirizzo di destinazione
	lw     $t0, 0($t1) # $t0 = indirizzo di destinazione 
	jr     $t0 # jump al case k

LABEL_CASE_0: 
	add $s0, $s3, $s4
	li $v0, 4 # print string
	la $a0, stringC0
	syscall
	j DEFAULT

LABEL_CASE_1: 
	add $s0, $s1, $s2
	li $v0, 4 # print string
	la $a0, stringC1
	syscall
	j DEFAULT

LABEL_CASE_2: 
	sub $s0, $s1, $s2
	li $v0, 4 # print string
	la $a0, stringC2
	syscall
	j DEFAULT

LABEL_CASE_3: 
	sub $s0, $s3, $s4
	li $v0, 4 # print string
	la $a0, stringC3
	syscall

DEFAULT:
	jr $ra
