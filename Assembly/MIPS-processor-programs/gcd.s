.data
.align 2
.globl Numbers
Numbers:
		 .byte 40,1
		 
Warning: .asciiz "Warning: The input you gave was (0,0)\n"	
Res:  	 .asciiz "The result of GCD(a,b) is: "	 


.text
.align 2
.globl main
.ent main

main:

	subu $sp, $sp, 32
	sw $ra, 20($sp)
	sw $fp, 16($sp)
	addu $fp, $sp, 28

	la $a0 , Numbers # Store the address of "Numbers" to a0
	jal GCD
	move $t0, $v0

	beq $t0, $zero, PrintWarning # So... did we have zeros?

	# Print the Res text
	la $a0, Res 
	li $v0, 4
	syscall

	# Print t0, which is a
	li $v0, 1
	move $a0, $t0
	syscall

	j Exit # Override PrintWarning

PrintWarning:

	la $a0, Warning # Load the warning message & print it since numbers are both 0
	li $v0, 4
	syscall

Exit:

	lw $fp, 16($sp) 
	lw $ra, 20($sp) 
	addu $sp, $sp, 32
	jr $ra

.end main

.text
.align 2
.globl GCD
.ent GCD

GCD:

	subu $sp, $sp, 12
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $a0, 8($sp) # a0 holds "Numbers" address

	add $t0, $zero, $a0 # Load the address and then the bytes with the number to t0 and s0,s1 respectively
	lbu $s0, 0($t0)
	lbu $s1, 1($t0)
 
 	# Now :
	# s0 = a
	# s1 = b

	beq $s0, $s1, Equals	# Case 1: GCD(a,a) (This includes GCD(0,0))

	beq $s0, $zero, One_Zero_a	# Case 3: GCD(0,b)
	beq $s1, $zero, One_Zero_b	# Case 4: GCD(a,0)

	addi $t5, 1

	beq $s0, $t5, One_Zero_b	# Case 5: GCD(1,a)
	beq $s1, $t5, One_Zero_a	# Case 6: GCD(b,1)

Recursion:

	beq $s0, $s1, Normal # If a==b (while a!=b)

	slt $t3, $s0, $s1 # if (a<b)
	bne $t3, $zero, Swap 

	subu $s0, $s0, $s1 # a -= b
	j Recursion

Swap:

	# Swap the numbers
	move $t4, $s0  # t4 is temp
	move $s0, $s1
	move $s1, $t4

	subu $s0, $s0, $s1 # a -= b	
	j Recursion

Normal:

	move $v0, $s0
	j Quit

Equals:

	move $v0, $s0
	j Quit

One_Zero_a:

	move $v0, $s1
	j Quit

One_Zero_b:

	move $v0, $s0
	j Quit


Quit:

	lw $a0, 8($sp)
	lw $s1, 4($sp)
	lw $s0, 0($sp)
	addu $sp, $sp, 12
	jr $ra

.end GCD




