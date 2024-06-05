.data
string:      	.space   50
Message1:	.asciiz "Nhap xau: "
Message2:	.asciiz "Do dai xau la: "
.text
main:	
get_string:	li $v0, 54
		la $a0, Message1
		la $a1, string
		la $a2, 50
		syscall

get_length: 	la   $a0,string
		add  $t0,$zero,$zero
		
check_char:   	add  $t1,$a0,$t0
		lb $t2, 0($t1) # $t2 = string[i]
		beq $t2, $zero, end_of_str # is null char?
		addi $t0, $t0, 1 # $t0 = $t0 + 1 -> i = i + 1
		j check_char
end_of_str:
end_of_get_length:
print_length: 	li $v0, 56
		la $a0, Message2
		move $a1, $t0
		syscall