.data
mes1: .asciiz "Insert N (N > 0): "
mes2: .asciiz "Min digit is: "
mes3: .asciiz "You didn't enter positive number!"
.text
main:	li $s0, 9	# Min digit = 9
	li $v0, 4	
    	la $a0, mes1	# Print promt
    	syscall
    	
    	li $v0, 5
    	syscall
    	move $t0, $v0	# Store number into $t0
    	bltz $t0, negative
    	beqz  $t0, negative
    	
find_min:
	beqz $t0, print	# Quit if N == 0
	li $t1, 10	# Set 10 to divide
	div $t0, $t1	# Divide with remainder
	mfhi $t2	# Store remainder in $t2
	sub $t0, $t0, $t2	# Remove the last digit
	div $t0, $t1
	mflo $t0	# Update new number
	blt $t2, $s0, update	# Check if remainder > min_digit
	j find_min
    
update:
	move $s0, $t2	# Update min number
	j find_min
    
print:	li $v0, 4
	la $a0, mes2
	syscall
	
	li $v0, 1	# Print
	move $a0, $s0
	syscall
    	j quit
    	
negative: 
	li $v0, 4
	la $a0, mes3
	syscall
quit:	li $v0, 10	# exit
    	syscall