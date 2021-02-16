.data
	array: .word 2 3 5 12 17 20 28 42
	key: .word 5
.text
	j main
	
	# funcao principal de busca recursiva
	
	interpolation_search:
	
	# carrega argumentos
	
	add $t0, $0, $a0 # elemento buscado
	add $t1, $0, $a1 # ultimo elemento de subarray
	add $t2, $0, $a2 # primeiro elemento de subarray
	
	# t7 e t6: variaveis factualmente temporarias
	
	# verificando condicoes
	
	# exaustao de busca
	# 1: se endereco superior <= endereco inferior, escapar
	sle $t7, $t2, $t1
	beqz $t7, return_failure
	# as duas condicoes seguintes decorrem do fato do array estar ordenado
	# 2: se elemento buscado < primeiro elemento de subarray, escapar
	lw $t7, array($t2) # carrega primeiro elemento de subarray
	slt $t7, $t7, $t0
	beqz $t7, return_failure
	# 3: se elemento buscado > ultimo elemento de subarray, escapar
	lw $t7, array($t1) # carrega ultimo elemento de subarray
	slt $t7, $t0, $t7
	beqz $t7, return_failure
	
	# estima nova posicao para elemento buscado assumindo distribuicao uniforme de array
	
	# converte enderecos por palavras para enderecamento nominal (4, 8, 12 -> 1, 2, 3)
	srl $t7, $t1, 2 # recupera endereco nominal de limite superior
	srl $t6, $t2, 2 # recupera endereco nominal de limite inferior
	
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
	addi $s1, $0, 7 # s1 = tamanho de array - 1
	
	# cria endereco da ultima posicao de array
	
	sll $s2, $s1, 2 # s2 = endereco de ultima posicao
	
	# carrega argumentos para interpolation_search
	
	add $a0, $0, $s0 # elemento buscado
	add $a1, $0, $s2 # ultimo endereco
	add $a2, $0, $0  # primeiro endereco (inicialmente = 0)
	
	jal interpolation_search
	
	add $s3, $0, $v0 # recupera retorno
	
	# imprime sinal de retorno
	
	li $v0, 1
	add $a0, $0, $s3
	syscall 
	
	# TODO: implementar calculo de posicao