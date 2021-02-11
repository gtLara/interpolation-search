.data
string1: .asciiz "Insira um Numero:"
string2: .asciiz "Insira um segundo Numero:"
string3: .asciiz "Soma:"
endLine: .asciiz "\n"

.text
main:

	li $v0 , 4		
	la $a0 , string1  
	syscall

	li $v0 , 5	 			
	syscall
	
	move $t0,$v0            
	
	li $v0 , 4
	la $a0 , endLine      
	syscall
	
	li $v0 , 4
	la $a0 , string2        
	syscall
	
	li $v0 , 5
	syscall
	
	move $t1,$v0            
	
	li $v0 , 4
	la $a0 , string3
	syscall
	
	add $t2,$t1,$t0	
	li $v0, 1	   
	move $a0, $t2
	syscall
	
		 
	li $v0, 10
	syscall
	