.data
	array: .word 2 3 5 12 17 20 28 42
	key: .word 5
.text
	j main
	
	# funcao principal de busca recursiva
	
	interpolation_search:
	
	# carrega argumentos
	
	lw $t1, ($a1) 	#ultimo elemento de subarray
	lw $t2, ($a2)	#primeiro elemento de subarray
	
	# t7 e t6: variaveis factualmente temporarias
	
	# verificando 3 condicoes
	
	# exaustao de busca
	# 1: se endereco superior <= endereco inferior, escapar
	sle $t7, $a2, $a1
	beqz $t7, return_failure
	# as duas condicoes seguintes decorrem do fato do array estar ordenado
	# 2: se elemento buscado < primeiro elemento de subarray, escapar
	slt $t7, $t2, $a0
	beqz $t7, return_failure
	# 3: se elemento buscado > ultimo elemento de subarray, escapar
	slt $t7, $a0, $t1
	beqz $t7, return_failure
	
	# estima nova posicao para elemento buscado assumindo distribuicao uniforme de array
	
	# converte enderecos por palavras para enderecamento nominal (4, 8, 12 -> 1, 2, 3)
	sub $t6, $s1, $a2
	srl $t3, $t6, 2  # recupera endereco nominal de limite superior
	sub $t6, $s2, $a2
	srl $t4, $t6, 2 # recupera endereco nominal de limite inferior !done
	
	# define nova posicao
	
	sub $t7, $t7, $t6 # 
	addi $t6, $0, 2
	div $t7, $t6
	mflo $t3 # carrega endereco nominal de posicao
	sll $t3, $t3, 2 # converte endereco de posicao para enderecamento de palavra
	
	# verifica se o elemento buscado foi encontrado
	lw $t7, array($t3) # carrega valor de posicao estimada
	sub $t6, $t0, $t7
	beqz $t6, return_success
	
	# chama funcao recursivamente
	
	# observe que $t7 = array[posicao estimada]
	# se elemento buscado < valor em posicao estimada, busca em subarray inferior
	slt $t6, $t0, $t7
	beqz $t6, upper_subarray
	
	# carrega argumentos para proxima chamada de interpolation_search
	
	add $a0, $0, $t0 # elemento buscado se mantem
	add $a1, $0, $t3 # endereco superior assume posicao
	add $a2, $0, $t2  # endereco inferior se mantem 
	
	# nao ha necessidade de salvar registrar PC em $ra por meio de jal porque o programa nunca voltara
	# para esse ponto, e sim para o ponto em que a $ra registra nesse momento quando alguma das condicoes
	# acima forem atendidas. o pulo eh portanto incondicional
	j interpolation_search
	
	# se elemento buscado > posicao estimada, busca em subarray superior  
	upper_subarray:
	
	# carrega argumentos para proxima chamada de interpolation_search
	
	add $a0, $0, $t0 # elemento buscado se mantem
	add $a1, $0, $t1 # endereco inferior se torna posicao
	add $a2, $0, $t3  # endereco inferior assume posicao
	
	j interpolation_search
	
	return_failure:
	
	addi $v0, $0, -1 # retorna sinal indicador que elemento nao foi encontrado
	jr $ra
	
	return_success:
	srl $t3, $t3, 2
	add $v0, $0, $t3 # retorna endereço nominal (numero decimal relativo a base) de elemento
	jr $ra
	
	main:
	
	#addi, $s0, $0, 1 # s0 = elemento buscado
	lw $s0, key
	addi $s3, $0, 7 # s1 = tamanho de array - 1
	
	# cria enderecos das posicoes de array
	la $s2, array # s2 = endereço da primeira posicao
	sll $t2, $s3, 2
	add $s1, $s2, $t2 # s1 = endereco de ultima posicao 
	
	
	# carrega argumentos para interpolation_search
	add $a0, $0, $s0 # elemento buscado
	add $a1, $0, $s1 # ultimo endereco
	add $a2, $0, $s2  # primeiro endereco (inicialmente = 0)
	
	jal interpolation_search
	
	add $s3, $0, $v0 # recupera retorno
	
	# imprime sinal de retorno
	
	li $v0, 1
	add $a0, $0, $s3
	syscall 
	
	# TODO: implementar calculo de posicao
