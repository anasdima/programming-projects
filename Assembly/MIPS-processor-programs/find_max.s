.data
.align 2
.globl Test
Test: 	
	.word 1
	.word 3
	.word 5
	.word 7
	.word 90
	.word 8
	.word 6
	.word 4
	.word 2
	.word 100
TextA: .asciiz "Lab 3, Home Assignment 1\n"
TextB: .asciiz "The max is \n"
TextC: .asciiz "\nDone\n"

.text
.align 2

.globl FindMax
.ent FindMax
FindMax:
	subu $sp, $sp, 24 # Reserve a new 24 byte stack frame
	sw $s0, 0($sp) # Save value of s0 on the stack
	sw $s1, 4($sp) # Save value of s1 on the stack
	sw $a0, 8($sp) # Save the address of the vector
	sw $a1, 12($sp) # Save the number n
	sw $s2, 16($sp)
	sw $s3, 20($sp)
	
	#	-----Missing Code-----
	
	#The loop counter is $s0
	#The "array" indexer is $s1
	#The MAX value is $s2
	#Current word (inside the Loop) is $s3
	
	add $s0, $zero, $zero #Initialize the counter
	add $s1, $zero, $zero #Initialize the array indexer
	
	#Store the first value as max
	add $t0, $s1, $a0 #Store the address of the first word to $t0 (Could use addi aswell)
	lw $s2, 0($t0) #Store the first word as a max
	addi $s1, $s1, 4 #Point to the next word
Loop:
	slt $t1, $s0, $a1 #Check if the loop counter is equal to the total number
	beq $t1, $zero, Outside #If it is exit the loop
	
	add $t2, $s1, $a0 #Store the address of the current "array element"
	lw  $s3, 0($t2) #Load the current word in $s3
	
	slt $t3, $s2, $s3 #Check if the stored max is smaller than the current word
	beq $t3, $zero, EndLoop #If it is not, jump to the end of the Loop
	
	add $s2, $zero, $s3 #We have a new max, so we replace the old one
	j EndLoop
	
EndLoop:	
	addi $s1, $s1, 4 #Increase indexer by 4 since we are parsing words
	addi $s0, $s0 ,1 #Increase the counter
	j Loop #Rinse and repeat
	
	
	
Outside:
	add $v0, $zero, $s2 #Save the max to the value register so we can return it
	
	#	-----End of Missing Code-----
	
	lw $s1, 4($sp) # Restore old value of s1
	lw $s0, 0($sp) # Restore old value of s0
	lw $s2, 16($sp) # Restore s2
	lw $s3, 20($sp) # Restore s3
	addu $sp, $sp, 24 # Pop the stack frame
	jr $ra # Jump back to calling routine

.end FindMax

.text
.align 2
.globl main
.ent main

main: 	subu $sp, $sp, 32 # Reserve a new 32 byte stack frame
	sw $ra, 20($sp) # Save old value of return address
	sw $fp, 16($sp) # Save old value of frame pointer
	addu $fp, $sp, 28 # Set up new frame pointer
	
	la $a0, TextA # Load address to welcome text
	li $v0, 4     
      syscall
      
	la $a0, Test # Load address to vector
	li $a1, 9 #Number n
	jal FindMax # Call FindMax subroutine
	move $t0, $v0	

	la $a0, TextB # Load address to result text
	li $v0, 4
	syscall 
	
	li $v0, 1
      	move $a0, $t0
      syscall

	la $a0, TextC # Load address to goodbye text
	li $v0, 4
	syscall

	lw $fp, 16($sp) # Restore old frame pointer
	lw $ra, 20($sp) # Restore old return address
	addu $sp, $sp, 32 # Pop stack frame
	jr $ra
.end main
