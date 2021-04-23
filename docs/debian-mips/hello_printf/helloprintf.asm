	.data
hello:  .asciiz "Hello world with printf!\n"

	.text
	.globl main
main:
       subu   $sp, $sp, 4
       sw     $ra, 0($sp)
       la     $a0, hello
       jal    printf
       lw     $ra, 0($sp)
       addiu  $sp, $sp, 4

       jr     $ra
