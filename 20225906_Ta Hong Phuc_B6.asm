.data

A: .space 256
B: .space 256
mes1: .asciiz "Insert N (N < 64): "
mes2: .asciiz "Insert elements (one element each line): "
nl: .asciiz "\n"
odd:.asciiz "Sum of odd numbers is: "
negative: .asciiz "Sum of negative numbers is: "

.text
	li $v0, 4	
    	la $a0, mes1	# Print promt
    	syscall
    	
    	li $v0, 5	# insert N
    	syscall
    	move $t0, $v0	# Store N into $t0
    	
    	li $t1, 0	# i = 0
    	la $t2, A	# Load address A into $t2

    	
    	
insert: beq $t1, $t0, continue
	
	add $t4, $t1, $t1	# $t4 = 2 * i
	add $t4, $t4, $t4	# $t4 = 4 * i
	add $t4, $t4, $t2	# $t4 = 4i + A[0]
	
	li $v0, 4	
    	la $a0, mes2	# Print promt
    	syscall
    	
    	li $v0, 5	# insert N
    	syscall
    	sw $v0, ($t4)	# Store N into $t4 A[i]
	
    	addi $t1, $t1, 1
    	j insert
	
continue:
	li $t1, 0	# Set i = 0
	li $t5, 0	# Sum odd == 0
	li $t6, 0	# Sum negative == 0
	li $t7, 2
	

check:
	beq $t1, $t0, print
	
	add $t4, $t1, $t1	# $t4 = 2 * i
	add $t4, $t4, $t4	# $t4 = 4 * i
	add $t4, $t4, $t2	# $t4 = 4i + A[0]
	lw  $t4, 0($t4)
	addi $t1, $t1, 1
	
	bltz $t4, negative_sum
	
	div $t4, $t7	# Divide with remainder
	mfhi $t8	# Store remainder in $t2
	bnez $t8, odd_sum
	j check
	
odd_sum:
	add $t5, $t5, $t4
	j check

negative_sum:
	add $t6, $t6, $t4
	
	div $t4, $t7	# Divide with remainder
	mfhi $t8	# Store remainder in $t2
	bnez $t8, odd_sum
	
	j check

print:
	li $v0, 4	
    	la $a0, odd		# Print promt
    	syscall
    	
    	li $v0, 1	
    	move $a0, $t5		# Print odd sum
    	syscall
    	
	li $v0, 4	
    	la $a0, nl		# Print newline
    	syscall	

	li $v0, 4	
    	la $a0, negative	# Print promt
    	syscall
    	
    	li $v0, 1	
    	move $a0, $t6		# Print negative sum
    	syscall
    	
    	
    	
    	
    	
    	
    	
    	
    	
    	
    	
    	
    	