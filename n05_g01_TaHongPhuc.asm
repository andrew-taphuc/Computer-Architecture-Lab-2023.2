#----------------------------------------------------------------------------------------#
# 		    	Tạ Hồng Phúc - 20225906 - IT-E6 - K67	    	  		 #
#		Task 05 - Convert Infix to Postfix expression and calculate	  	 #
#----------------------------------------------------------------------------------------#

.data
infix:			.space 256
postfix: 		.space 256
postfix_:		.space 256 
stack: 			.space 256
msg_infix_insert: 	.asciiz "Please enter an infix expression: "
msg_infix_print: 	.asciiz "Infix expression: "
msg_postfix_print: 	.asciiz "Postfix expression: "
msg_result_print: 	.asciiz "Result of the expression: "
msg_newline: 		.asciiz "\n"
msg_err1:	 	.asciiz "You must enter a number from 0 to 99!"
msg_err2: 		.asciiz "ERROR: You enter a divisor that equal 0."
msg_err3: 		.asciiz "ERROR: You enter a bracket that has wrong position."
msg_err4: 		.asciiz "ERROR: Invalid character or expression."
msg_err5: 		.asciiz "ERROR: Operator in wrong position."

.text
#---------------------------------------------------------------------
# @brief      Read Infix Expr from user and print onto Run I/O
# @param[in]  $a0	argument
#	      $a1       argument
#             $a2       argument
#	      $v0	syscall service code 
#---------------------------------------------------------------------
infix_insert:	
	jal clear_buffer_infix
	li $v0, 54			# Request infix
	la $a0, msg_infix_insert	# address of string of message
	la $a1, infix 			# address of input buffer
	la $a2, 256			# maximum number of characters 
	syscall
	jal operator_check		# check if 2 operator stand together

convert_to_post_fix:
	jal clear_buffer_postfix
	li $s0, 0			# index j of infix
	li $s1, 0			# index i of postfix
	li $s2, -1			# index k of stack
	li $a3, 0			# left_par = 0
	li $s3, 0
	lb $t0, infix($s0)		# load first character to process
	jal check_invalid		# check if there are any invalid character
	beq $t0, '-', err_value		# check the first number is nagative
	beq $t0, '/', alert_1		# check if the first digit is invalid
	beq $t0, '%', alert_1		# check if the first digit is invalid
	beq $t0, '*', alert_1		# check if the first digit is invalid
	nop
	 
loop_infix:	
	lb $t0, infix($s0)		# $t0 = infix[j]
	beq $t0, $0, end_loop_infix	# if end of string (null character), end of loop
	nop						
	beq $t0, '\n', end_loop_infix 	# remove newline 
	nop	
	beq $t0, ' ', rmv_space_1	# remove space
	nop	
	
# If $t0 is an operator, go to appropriate function to check priority		
	beq $t0, '+', check_plus_minus		
	nop
	beq $t0, '-', check_plus_minus
	nop
	beq $t0, '*', check_mul_div
	nop
	beq $t0, '%', check_mul_div
	nop
	beq $t0, '/', check_mul_div
	nop
	beq $t0, '(', check_left_par	# check nagative number if get '('
	nop
	beq $t0, ')', check_right_par_1
	nop
	
# If $t0 is a number, push to postfix immediately
	sb $t0, postfix($s1)		# push $t0 value into postfix[i]
	addi $s1, $s1, 1		# i++
# Check kí tự tiếp theo trong 
loop_continue:	
	addi 	$s0, $s0, 1		# j++ 
	lb 	$t2, infix($s0)		# $t2 = infix[j]
	li 	$s4, '0'
	slt 	$s3, $t2, $s4
	beq 	$s3, 1, cont_1
	nop
	li 	$s4, '9'
	sgt 	$s3, $t2, $s4
	beq 	$s3, 1, cont_1
	nop
	beq 	$t2, ' ', loop_continue  # gap dau cach bo qua
	nop
	j 	continue
cont_1:	
	li 	$s3, ' ' 		# them dau cach vao post fix
	sb 	$s3, postfix($s1)	# postfix[i] = ' '
	addi 	$s1, $s1, 1		# i++
	j 	loop_infix		
	nop
rmv_space_1:	
	addi 	$s0, $s0, 1		# i++
	j 	loop_infix
	nop
# check the next character 
continue: 	
	addi 	$t3, $s0, 1		# $t3 = j++
	lb 	$t4, infix($t3)		# infix[$t3] = $t4
	
# if greater than 99 -> branch to error alert
check_value:	
	li 	$s4, '0'
	slt 	$s3, $t4, $s4
	beq 	$s3, 1, cont_2
	nop
	li 	$s4, '9'
	sgt 	$s3, $t4, $s4
	beq 	$s3, 1, cont_2
	nop
	j 	err_value

cont_2:	sb 	$t2, postfix($s1)  	# else postfix[i] = $t2
	addi 	$s1, $s1, 1		# i++
	li 	$s3, ' '		
	sb 	$s3, postfix($s1)	# postfix[i] = ' '
	addi 	$s1, $s1, 1		# i++
	addi 	$s0, $s0, 1		# j++
	j 	loop_infix		
	nop
	
err_value:	
	li 	$v0, 55
	la 	$a0, msg_err1		# address of error message
	syscall
	j 	infix_insert		
	nop
	
#--------------------------------------------------------------------------------------
# @brief      Deal with plus and minus
#
#--------------------------------------------------------------------------------------
check_plus_minus:	

	beq $s2, -1, push_op		# if stack is null, push this operator to stack 
	nop
	lb $t9, stack($s2)		
	beq $t9, '(', push_op		# if peek of stack is '(', push this operator to stack
	nop
	lb $t1, stack($s2)		# else pop all operators out of stack then push this operator to stack
	sb $t1, postfix($s1)	
	addi $s2, $s2, -1		# k--
	addi $s1, $s1, 1		# i++
	li $s3, ' ' 		
	sb $s3, postfix($s1)		# postfix[i] = ' '
	addi $s1, $s1, 1		# i++
	j check_plus_minus	
	nop	
	
#--------------------------------------------------------------------------------------
# @brief      Deal with multiply, divide and modulo
#
#--------------------------------------------------------------------------------------
check_mul_div:

	beq $s2, -1, push_op		# if stack is null, push this operator to stack
	nop				
	lb $t9, stack($s2)			
	beq $t9, '+', push_op		# if peek of stack is '+', '-', '(', push this operator to stack
	nop
	beq $t9, '-', push_op
	nop
	beq $t9, '(', push_op
	nop
	lb $t1, stack($s2)        	# else pop all operators out of stack then push this operator to stack
	sb $t1, postfix($s1)
	addi $s2, $s2, -1	       	# k--
	addi $s1, $s1, 1			# i++
	li $s3, ' ' 		
	sb $s3, postfix($s1)		# postfix[i] = ' '
	addi $s1, $s1, 1			# i++
	j check_mul_div
	nop

#--------------------------------------------------------------------------------------
# @brief      Deal with opening and closing pars
#
#--------------------------------------------------------------------------------------
check_left_par:
	addi $a3, $a3, 1		# lparcount++
	addi $t3, $s0, 1		# $t3 = j++
	lb $t4, infix($t3)		# $t4 = infix[j]
	beq $t4, '-', err_value		# if infix[j] == '-' -> negative value -> branch to error alert
	nop
	j 	push_op			# else push to stack
	nop			
	
check_right_par_1:
	addi $a3, $a3, -1		# lparcount--
	j 	check_right_par
	nop			
	
check_right_par:
	beq $s2, -1, push_op		# if stack is null, push right parentheses to stack
	nop
	lb $t1, stack($s2)  		# else pop operator out of stack
	sb $t1, postfix($s1)		# postfix[i] = $t1
	addi $s2, $s2, -1		# k-- 
	addi $s1, $s1, 1		# i++
	beq $t1, '(', push_op		# until get '(' then push to stack
	j check_right_par
	nop			

#--------------------------------------------------------------------------------------
# @brief      Push number and operator into postfix
#
#--------------------------------------------------------------------------------------			
push_op:	
	addi $s2, $s2, 1		# k++ 
	sb $t0, stack($s2)		# stack[k] = $t0 
	addi $s0, $s0, 1		# j++
	j loop_infix
	nop

#--------------------------------------------------------------------------------------
# @brief      Push remain operators to postfix
#
#--------------------------------------------------------------------------------------	
end_loop_infix:	
	beq $s2, -1, remove_par
	nop
	lb $t0, stack($s2)		# $t0 = stack[k]
	sb $t0, postfix($s1)		# postfix[i] = $t0
	addi $s2, $s2, -1		# k--
	addi $s1, $s1, 1		# i++
	li $s3, ' ' 		
	sb $s3, postfix($s1)		# postfix[i] = ' '
	addi $s1, $s1, 1		# i++
	j end_loop_infix
	nop
	
#--------------------------------------------------------------------------------------
# @brief      Remove pars from postfix
#
#--------------------------------------------------------------------------------------	
	li $s6, 0			# index of postfix
	li $s7, 0			# index of postfix_
remove_par:	
	lb $t5, postfix($s6)		# $t5 = postfix[i]
	addi $s6, $s6, 1		# i++
	beq $t5, '(', remove_par
	nop
	beq $t5, ')', remove_par
	nop
	beq $t5, 0, important_check 	# if get a null character -> branch to print postfix expression
	nop
	sb $t5, postfix_($s7)		# postfix_[j] = $t5
	addi $s7, $s7, 1		# j++
	j remove_par
	nop
	
important_check:
	#jal big_num_check
	#jal operator_check
	j print_postfix

#######################################################################################
#--------------------------------------------------------------------------------------
# @brief      PRINTING INFIX & POSTFIX EXPRESSION
#             
#--------------------------------------------------------------------------------------
#######################################################################################
print_postfix:	
	bne $a3, 0, error1		# if lparcount != 0 -> branch to error alert
	nop
	li $v0, 4
	la $a0, msg_infix_print		# address of string to print
	syscall
	li $v0, 4
	la $a0, infix			# address of string to print
	syscall
	li $v0, 4
	la $a0, msg_postfix_print	# address of message
	syscall
	li $v0, 4
	la $a0, postfix_		# address of final result
	syscall
	li $v0, 4
	la $a0, msg_newline
	syscall
	nop
	j calculate_postfix
			
error1:			
	li $v0, 55
	la $a0, msg_err3
	syscall
	nop
	j infix_insert	
	
#######################################################################################
#--------------------------------------------------------------------------------------
# @brief      Calculate the expression
#             $sp       Stack pointer
#--------------------------------------------------------------------------------------
#######################################################################################

calculate_postfix:	
	li $s1, 0 			# i = 0
loop_postfix: 	
	lb $t0, postfix_($s1)		# $t0 = postfix[i]
	beq $t0, $0, print_result	# if $t0 = '\0' -> branch to print result 
	nop
	beq $t0, ' ', remove_space	# skip space
	nop
# if character is number -> check the next character
	li 	$s4, '0'
	slt 	$s3, $t0, $s4
	beq 	$s3, 1, operator
	nop
	li 	$s4, '9'
	sgt 	$s3, $t0, $s4
	beq 	$s3, 1, operator
	nop
	j 	next
operator:	
	lw $t6, -8($sp)			# load the first value (a) from stack pointer
	lw $t7, -4($sp)			# load the second value (b) from stack pointer 
	addi $sp, $sp, -8
	beq $t0, '+', add_func		# if $t0 = '+' -> branch to add function
	nop
	beq $t0, '-', sub_func		# if $t0 = '-' -> branch to sub function
	nop
	beq $t0, '*', mul_func		# if $t0 = '*' -> branch to mul function
	nop
	beq $t0, '%', mod_func		# if $t0 = '%' -> branch to mod function
	nop
	beq $t0, '/', div_func		# if $t0 = '/' -> branch to div function
	nop
	addi $s1, $s1, 1		# i++
	j loop_postfix
# if get a space then remove it
remove_space:	
	addi $s1, $s1, 1		# i++
	j loop_postfix
	nop
next:		
	addi $s1, $s1, 1		# i++
	lb $t2, postfix_($s1)		# $t2 = postfix_[i]
	
	li 	$s4, '0'
	slt 	$s3, $t2, $s4
	beq 	$s3, 1, cont_6
	nop
	li 	$s4, '9'
	sgt 	$s3, $t2, $s4
	beq 	$s3, 1, cont_6
	nop
	j 	push_num
	
cont_6:	addi $t0, $t0, -48		# if number < 10 then convert character from char to number 
	sw $t0, 0($sp)			
	addi $sp, $sp, 4
	j loop_postfix
	nop	
push_num:	
	addi $t0, $t0, -48		# convert character from char to number
	addi $t2, $t2, -48		# convert character from char to number
	mul $t3, $t0, 10
	add $t3, $t3, $t2 		# $t3 = 10 * $t0 + $t2
	sw $t3, 0($sp)			# $sp = $t3
	addi $sp, $sp, 4
	addi $s1, $s1, 1		# i++ 
	j loop_postfix		
#--------------------------------------------------------------------------------------
# @brief      Plus function
#
#--------------------------------------------------------------------------------------
add_func:	
	add $t6, $t6, $t7		# $t6 = $t6 + $t7
	sw $t6, 0($sp)			# $sp = $t6
	addi $sp, $sp, 4		
	addi $s1, $s1, 1		# i++
	j loop_postfix
	nop
#--------------------------------------------------------------------------------------
# @brief      Minus function
#
#--------------------------------------------------------------------------------------
sub_func:	
	sub $t6, $t6, $t7		# $t6 = $t6 - $t7
	sw $t6, 0($sp)			# $sp = $t6
	addi $sp, $sp, 4
	addi $s1, $s1, 1		# i++
	j loop_postfix
	nop
#--------------------------------------------------------------------------------------
# @brief      Multiply function
#
#--------------------------------------------------------------------------------------
mul_func:	
	mul $t6, $t6, $t7		# $t6 = $t6 * $t7
	sw $t6, 0($sp)			# $sp = $t6
	addi $sp, $sp, 4
	addi $s1, $s1, 1		# i++
	j loop_postfix
#--------------------------------------------------------------------------------------
# @brief      Modulo function
#
#--------------------------------------------------------------------------------------	
mod_func:	
	beq $t7, 0, invalid_divisor	# if divisor == 0, alert and exit
	nop
	div $t6, $t7 			# $t9 = $t6 % $t7
	mfhi $t9
	sw $t9, 0($sp)			# $sp = $t6
	addi $sp, $sp, 4
	addi $s1, $s1, 1		# i++
	j loop_postfix
#--------------------------------------------------------------------------------------
# @brief      Divide function
#
#--------------------------------------------------------------------------------------
div_func:	
	beq $t7, 0, invalid_divisor	# if divisor == 0, alert and exit
	nop
	div $t6, $t6, $t7		# $t6 = $t6 / $t7
	sw $t6, 0($sp)			# $sp = $t6
	addi $sp, $sp, 4
	addi $s1, $s1, 1		# i++
	j loop_postfix
	nop

# If detect a divisor = 0
invalid_divisor:
	li $v0, 55
	la $a0, msg_err2
	syscall
	j end			# exit
	

#--------------------------------------------------------------------------------------
# @brief      Print the result of the expression
# @param[in]  $t6	Dividend / Result of division
#	      $t7       Divisor
#             $sp       Stack pointer
#--------------------------------------------------------------------------------------
print_result:		
	li $v0, 4
	la $a0, msg_result_print
	syscall
	li $v0, 1
	lw $t4, -4($sp)
	la $a0, ($t4)
	syscall
	li $v0, 4
	la $a0, msg_newline
	syscall
end:	li $v0, 10
	syscall

#--------------------------------------------------------------------------------------
# @brief      Check if there is any invalid character in infix expression
# @param[in]  $t0	character to check
#	      $t1       temporary char to check
#             $t2       temporary char to check
#--------------------------------------------------------------------------------------
check_invalid:
    lb $t0, infix($s0)		# Load byte from buffer
    beq $t0, $0, check_valid    # If end of string (null character), go to check_valid
    nop
    beq $t0, '\n', check_valid  # If newline character, go to check_valid

# Check if character is valid (0-9, +, -, *, /, %)
    li $t1, '0'
    li $t2, '9'
    bgt $t0, $t2, invalid	# If character > '9', it's invalid
    blt $t0, $t1, check_other	# If character < '0', check other valid characters
    
    j next_char

check_other:
    li $t1, '+'
    beq $t0, $t1, next_char
    li $t1, '-'
    beq $t0, $t1, next_char
    li $t1, '*'
    beq $t0, $t1, next_char
    li $t1, '/'
    beq $t0, $t1, next_char
    li $t1, '%'
    beq $t0, $t1, next_char
    li $t1, '('
    beq $t0, $t1, next_char
    li $t1, ')'
    beq $t0, $t1, next_char
    li $t1, ' '
    beq $t0, $t1, next_char
    j invalid			# If none of the valid characters, go to invalid

next_char:
    addi $s0, $s0, 1        	# Move to the next character
    j check_invalid

invalid:
    li $v0, 55            	# System call for print string
    la $a0, msg_err4    	# Load address of the error message
    syscall
    j infix_insert    		# Restart insert infix process

check_valid:
    li $s0, 0               	# Reset $s0
    lb $t0, infix($s0)
    jr $ra               	# Return from function
	
#--------------------------------------------------------------------------------------
# @brief      Check if there are 2 operators stand together
# @param[in]  $t0	character to check
#	      $t1       temporary char to check
#             $t2       temporary char to check
#--------------------------------------------------------------------------------------
	
operator_check:
    la $t0, infix    		 # Load address of the postfix array
    li $t1, 0         		 # Index to iterate through the array
    li $t2, 0         		 # Counter for consecutive numbers

check_next_char_1:
    lb $t3, 0($t0)    		 # Load the current character
    beq $t3, ' ', cont_3
    beqz $t3, end_check_1  	 # If null character, end of the array

# Check if the character is an operator
    beq $t3, '*', counter	
    beq $t3, '/', counter
    beq $t3, '%', counter
    beq $t3, '+', counter
    beq $t3, '-', counter  
    j reset_counter_1
counter:
    addi $t2, $t2, 1
    beq $t2, 2, alert_1		# If counter reaches 3, trigger alert

# Move to the next character
cont_3: 
    addi $t0, $t0, 1
    j check_next_char_1

reset_counter_1:
    li $t2, 0         	 	# Reset the counter for consecutive numbers
    addi $t0, $t0, 1   		# Move to the next character
    j check_next_char_1

alert_1:
    li $v0, 55          	# System call for print string
    la $a0, msg_err5  		# Load address of alert message
    syscall
    j infix_insert      	# Exit after alert
    
end_check_1:
	jr $ra
	
#--------------------------------------------------------------------------------------
# @brief      Clear buffer infix
#
#--------------------------------------------------------------------------------------
clear_buffer_infix:
    la $s0, infix                     # Load address of infix buffer into $s0
    li $t0, 256                       # Set $t0 to 256 for loop count
clear_buffer_loop_1:
    sb $zero, 0($s0)                  # Set byte at $s0 to null (0)
    addi $s0, $s0, 1                  # Move to next byte
    subi $t0, $t0, 1                  # Decrement loop counter
    bnez $t0, clear_buffer_loop_1
    jr $ra
    
#--------------------------------------------------------------------------------------
# @brief      Clear buffer postfix
#
#--------------------------------------------------------------------------------------
clear_buffer_postfix:
    la $s0, postfix                   # Load address of infix buffer into $s0
    li $t0, 256                       # Set $t0 to 256 for loop count
clear_buffer_loop_2:
    sb $zero, 0($s0)                  # Set byte at $s0 to null (0)
    addi $s0, $s0, 1                  # Move to next byte
    subi $t0, $t0, 1                  # Decrement loop counter
    bnez $t0, clear_buffer_loop_2
    jr $ra
    

	




	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
