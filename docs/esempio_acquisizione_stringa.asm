# Esempio di acquisizione e stampa di una stringa

	.data
	str_1: .asciiz "Inserire una stringa: "
    	str_2: .asciiz "La stringa inserita è: "
    	# alloco spazio per una stringa di max 100 caratteri (100 bytes)
	str_read: .space 100

	.text
	.globl main
main:
	# stampa str_1
        la $a0,str_1
        li $v0,4
        syscall
		
	# leggo una stringa
	la $a0, str_read	# carico in $a0 l'indirizzo a cui memorizzerò la stringa
	li $a1, 100			# uno 100 come lunghezza massima (coincide con lo spazio che ho allocato nella sezione data)
	li $v0, 8			# carico codice syscall 8 (read_string)
	syscall

	# stampa str_2
        la $a0,str_2
        li $v0,4
        syscall
		
	# stampa stringa che ho appena letto
        la $a0,str_read
        li $v0,4
        syscall
		
	# exit
	li $v0, 10
	syscall
