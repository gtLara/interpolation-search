.data

	sizeprompt: .asciiz "\nInsira o tamanho do array:"
	keyprompt: .asciiz "\nInsira o elemento a ser buscado:"
	arrayprompt: .asciiz "\nPreencha vetor:"
	newline: .asciiz "\n"

.text

	j main
	
	create_array: # inicia preenchimento de array
	
	# passa argumentos
	
	# a0: contador
	# a1: tamanho do array
	# a2: base

	# pede para usuario preencher vetor
	
	create_array_loop:
	
	slt $t0, $a0, $a1 # verifica se preenchimento de array terminou
	beqz $t0, create_array_return # se sim, retorna

	sll $t0, $a0, 2 # cria endereço
	add, $t0, $t0, $a2 # soma endereco a base
	
	#le valor de entrada
	li $v0 , 5	 			
	syscall
	add $t1, $0, $v0

	sw $t1, 0($t0) # carrega elemento inserido em posicao desejada

	addi $a0, $a0, 1 # itera i
	
	j create_array_loop
	
	create_array_return:
	
	jr $ra
	
	search:

	add $t0, $0, $0 # passa argumentos
	add $t1, $0 ,$a1
	add $t2, $0, $a2
	add $t3, $0, $a3
	add $t7, $0, $a0

	for:

	# t0: iterador
	# t1: size
	# t2: key
	# t3: sinal de operacao, diz se busca foi bem sucedida (indice de chave) ou nao (-1)
	# t4: variavel de testes
	# t5: a[i]
	# t6: endereco de a[i] ( i * 4 )
	# t7: endereco base de array

	# condicoes de parada

	# se key == a[i], escapar

	sub $t4, $t2, $t5 # t4 = key - a[i]
	beqz $t4, return_index # escapa se t4 == 0

	slt $t4, $t0, $t1 # se chegou ao fim do array:
	beqz $t4, done # se (i < tamanho) == 0 (falso) , escapar

	# itera por array

	sll $t6, $t0, 2 # cria endereço
	add $t6, $t6, $t7 # desloca base no valor de endereco criado
	lw $t5, 0($t6) # t5 = a[i]

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
	
	# demanda tamanho de array
	
	#imprime
	li $v0 , 4		
	la $a0 , sizeprompt 
	syscall
	#le
	li $v0 , 5	 			
	syscall
	add $t0, $0, $v0
	
	# demanda elemento de busca
	
	li $v0 , 4		
	la $a0 , keyprompt 
	syscall
	li $v0 , 5	 			
	syscall
	add $t1, $0, $v0
	
	# demanda preenchimento de array
	
	li $v0 , 4		
	la $a0 , arrayprompt 
	syscall
	
	# carrega informacoes inseridas e variaveis necessarias

	addi $s0, $s0, 0 	# iterator
	add $s1, $0, $t0	# size
	add $s2, $0, $t1	# key
	addi $s3, $s0, -1	# error signal

	lui $s4, 0x1000
	ori $s4, $s4, 0x0128 # define endereço inicial para array

	add $a0, $0, $s0 # carrega argumentos para funcao create_array
	add $a1, $0 ,$s1
	add $a2, $0, $s4

	jal create_array

	add $a0, $0, $s4 # carrega argumentos para funcao search
	add $a1, $0 ,$s1
	add $a2, $0, $s2
	add $a3, $0, $s3

	jal search # entra em funcao e armazena proxima instrucao em registrador $ra
	
	add $s3, $0, $v0 # recupera retorno de linsearch

	li $v0, 4		
	la $a0, newline 
	syscall

	li $v0, 1
	add $a0, $0, $s3 # imprime indice de chave se estiver no vetor e sinal de erro (-1) se nao.
	syscall