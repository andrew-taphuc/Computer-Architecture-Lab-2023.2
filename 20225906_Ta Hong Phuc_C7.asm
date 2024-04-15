.data
prompt: .asciiz "Nhap xau ky tu: "
string: .space 256

.text

    # print promt
	li $v0, 4
	la $a0, prompt
	syscall
    
    # Insert
	li $v0, 8
	la $a0, string
	li $a1, 256
	syscall
	
	la $a0, string
	li $s1, 96	# 'a' - 1
	li $s2, 64	# 'A' - 1
	li $s3, 122	# 'z'
	li $s4, 90	# 'Z'
	li $s7, 10	
    
check: 
	lb $t1, ($a0)
	beq $t1, $s7, print 
	bgt $t1, $s1, check_low	# compare ascii code
	bgt $t1, $s2, check_up	# compare ascii code
	
	j continue
	
check_low:	
	bgt $t1, $s3, continue	# compare ascii code
	addi $t1, $t1, -32	# convert to upper
	sb $t1, ($a0)		# store new char
	j continue
	
check_up:
	bgt $t1, $s4, continue	# compare ascii code
	addi $t1, $t1, 32	#convert to lower
	sb $t1, ($a0)		# store new char
	j continue
	

continue:
	addi $a0, $a0, 1	# move to next char
	j check
	
print:
    li $v0, 4	# print
    la $a0, string
    syscall
    
    li $v0, 10	# end
    syscall