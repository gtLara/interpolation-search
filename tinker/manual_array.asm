.data
	array: .word 3 5 6 12 19 20 42 49 60 120 250 # 11 elements

.text

	j main

	search:
	
	add $t0, $0, $a0 # passa argumentos
	add $t1, $0 ,$a1
	add $t2, $0, $a2
	add $t3, $0, $a3
	
	for:

	# t0: iterador
	# t1: size
	# t2: key
	# t3: sinal de operacao, diz se busca foi bem sucedida (indice de chave) ou nao (-1)
	# t4: variavel de testes
	# t5: a[i]
	# t6: endereco de a[i] ( i * 4 )

	# condicoes de parada
	
	slt $t4, $t0, $t1 # se chegou ao fim do array:
	beqz $t4, done # se (i < tamanho) == 0 (falso) , escapar

	# se key == a[i], escapar
	
	sub $t4, $t2, $t5 # t4 = key - a[i]
	beqz $t4, return_index # escapa se t4 == 0
	
	# iteracao por vetor
	
	sll $t6, $t0, 2 # cria endereço
	lw $t5, array($t6) # t5 = a[i]
	
	addi $t0, $t0, 1 # i ++
	
	j for # retorna para label "for"
	
	return_index:
	
	subi $t4, $t0, 1 # decrementa i para retornar indice correto
	add $t3, $0, $t4 # escreve sobre sinal de retorno
	 
	j done
	
	done:
	
	add $v0, $0, $t3 
	jr $ra

	main:

	li $s0, 0 	# iterator
	li $s1, 11	# size
	li $s2, 41	# key
	li $s3, -1	# error signal
	
	lui $s4, 0x0001
	ori $s4, $s4, 0x0128 # define endereço inicial para array
	
	open: # inicia preenchimento de array
	
	slt $t0, $s0, $s1 # verifica se deve sair do loop
	beqz $t0, close
	
	sll $t0, $s0, 2 # cria endereço
	add, $t0, $t0, $s4
	
	lw $s0, 0($t0) # carrega i em array
	
	# TODO: entender como escolher endereço base
	
	addi $s0, $s0, 1 # itera i
	j open
	
	close:
	
	add $a0, $0, $s0 # carrega argumentos
	add $a1, $0 ,$s1
	add $a2, $0, $s2
	add $a3, $0, $s3
	
	
	jal search # entra em funcao e armazena proxima instrucao em registrador $ra
	
	add $s3, $0, $v0 # recupera retorno de linsearch
	li $v0, 1
	move $a0, $s3 # imprime indice de chave se estiver no vetor e sinal de erro (-1) se nao.
	syscall