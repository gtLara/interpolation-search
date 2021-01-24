.data

	key: .word 20
	i: .word 0
	
.text 

	lw $s0, i # s0 = i = 0
	lw $s1, key # s1 = key = 20
	
	for:
	
	slt $t0, $s0, $s1 # t0 = i < 10
	beq $t0, $0, done# se i < 10, sai de laco
	
	addi $s0, $s0, 1 # i ++
	
	j for # retorna para label "for"
	
	done:
	
	li $v0, 1
	move $a0, $s0 # imprime conteudo de i
	syscall