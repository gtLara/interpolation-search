.data

	sizeprompt: .asciiz "\nInsira o tamanho do array:"
	keyprompt: .asciiz "\nInsira o elemento a ser buscado:"
	arrayprompt: .asciiz "\nPreencha vetor:"
	newline: .asciiz "\n"
	
.text
	j main
	
	# funcao para criar e preencher array
	
	create_array:
	
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
	
	# le valor de entrada
	li $v0 , 5	 			
	syscall
	add $t1, $0, $v0

	sw $t1, 0($t0) # carrega elemento inserido em posicao desejada
	#sll $t7, $a0, 1
	#sw $t7, 0($t0) # carrega elemento inserido em posicao desejada

	addi $a0, $a0, 1 # itera i
	
	j create_array_loop
	
	create_array_return:
	
	jr $ra
	
	# funcao principal de busca recursiva
	
	interpolation_search:
	
	# carrega argumentos
	
	add $t0, $0, $a0 # elemento buscado
	add $t1, $0, $a1 # endereco de ultimo elemento de subarray
	add $t2, $0, $a2 # endereco de primeiro elemento de subarray
	# a3: base do array. nao sera carregado em temporario e sim acessado diretamente em a3
	
	# t5, t7 e t6: variaveis factualmente temporarias
	
	# verificando 3 condicoes
	
	# exaustao de busca
	# 1: se endereco superior <= endereco inferior, escapar
	
	sle $t7, $t2, $t1
	beqz $t7, return_failure
	
	# as duas condicoes seguintes decorrem do fato do array estar ordenado
	# 2: se elemento buscado < primeiro elemento de subarray, escapar
	
	add $t7, $a3, $t2 # cria endereco somando base de array a endereco desejado
	lw $t7, 0($t7) # carrega primeiro elemento de subarray
	sle $t7, $t7, $t0
	beqz $t7, return_failure
	
	# 3: se elemento buscado > ultimo elemento de subarray, escapar
	
	add $t7, $a3, $t1 # cria endereco somando base de array a endereco desejado
	lw $t7, 0($t7) # carrega ultimo elemento de subarray
	sle $t7, $t0, $t7
	beqz $t7, return_failure
	
	# prepara para estimar nova posicao para elemento buscado assumindo distribuicao uniforme de array
	# carrega variaveis importantes (lo, hi, arr[lo], arr[hi])
	
	add $t7, $a3, $t1 # cria endereco somando base de array a endereco desejado
	lw $t3, 0($t7)
	add $t7, $a3, $t2 # cria endereco somando base de array a endereco desejado
	lw $t4, 0($t7)
	srl $t1, $t1, 2 # carrega hi simplesmente convertendo enderecamento por palavra em enderecamento nominal (4, 8, 12 -> 1, 2, 3)
	srl $t2, $t2, 2 # carrega lo da mesma maneira
	
	# define nova posicao		# pos = lo + (hi-lo)*(x-arr[lo])/(arr[hi]-arr[lo])
	
	# t0: key
	# t1: hi
	# t2: lo
	# t3: arr[hi]
	# t4: arr[lo]
	
	#######################
	
	# $t0 = key
	# $t1 = arr[hi]
	# $t2 = arr[lo]
	# $t3 = hi 
	# $t4 = lo
	
	sub $t5, $t1, $t2		# hi - lo
	sub $t6, $t3, $t4		# arr[hi]-arr[lo]
	sub $t7, $t0, $t4		# x - arr[lo]
	
	#passa para o CoProcessador1 e converte somente as variáveis que precisam de operação em PF
	
	mtc1.d $t5, $f0			# t5 em Cop1 no espaço para double
	cvt.d.w $f0, $f0		# Convertido para double
	mtc1.d $t6, $f2			# idem
	cvt.d.w $f2, $f2		#
	mtc1.d $t7, $f4			#
	cvt.d.w $f4, $f4		#
	
	#faz as operações
	div.d $f2, $f4, $f2		# f2 = (x-arr[lo])/(arr[hi]-arr[lo])
	mul.d $f0, $f0, $f2		# f0 = (hi - lo)*$f2
	
	#converte e recupera o valor obtido
	cvt.w.d $f0, $f0		# converte de double para inteiro
	mfc1.d $t6, $f0			# move a parte inteira para $t6
	
	#nova posição
	add $t3, $t6, $t2		# t5 = pos = lo($t4) + [...]($t6)
	
	# nesse ponto $t3 deve segurar enderecamento nominal de posicao
	
	sll $t3, $t3, 2 # converte pos para enderecamento por palavra
	sll $t2, $t2, 2 # converte lo para enderecamento de palavra
	sll $t1, $t1, 2 # converte hi para enderecamento de palavra
	
	# verifica se o elemento buscado foi encontrado
	
	add $t7, $a3, $t3 # cria endereco somando base de array a endereco desejado
	lw $t7, 0($t7) # carrega valor de posicao estimada
	sub $t6, $t0, $t7
	beqz $t6, return_success
	
	# chama funcao recursivamente
	
	# observe que $t7 = array[posicao estimada]
	# se elemento buscado < valor em posicao estimada, busca em subarray inferior
	slt $t6, $t0, $t7
	beqz $t6, upper_subarray
	
	# carrega argumentos para proxima chamada de interpolation_search
	
	add $a0, $0, $t0 # elemento buscado se mantem
	subi $a1, $t3, 4 # endereco superior assume pos - 1
	add $a2, $0, $t2  # endereco inferior se mantem 
	
	# nao ha necessidade de salvar registrar PC em $ra por meio de jal porque o programa nunca voltara
	# para esse ponto, e sim para o ponto em que a $ra registra nesse momento quando alguma das condicoes
	# acima forem atendidas. o pulo eh portanto incondicional
	j interpolation_search
	
	# se elemento buscado > elemento em posicao estimada, busca em subarray superior  
	upper_subarray:
	
	# carrega argumentos para proxima chamada de interpolation_search
	
	add $a0, $0, $t0 # elemento buscado se mantem
	add $a1, $0, $t1 # endereco superior se mantem
	addi $a2, $t3, 4  # endereco inferior assume pos + 1 
	
	j interpolation_search
	
	return_failure:
	
	addi $v0, $0, -1 # retorna sinal indicador que elemento nao foi encontrado
	jr $ra
	
	return_success:
	srl $t3, $t3, 2
	add $v0, $0, $t3 # retorna endereço nominal (numero decimal relativo a base) de elemento
	jr $ra
	
	main:
	
	# interage com o usuario para criar array
	
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

	lui $s4, 0x1000
	ori $s4, $s4, 0x0128 # define endereço inicial para array

	add $a0, $0, $s0 # carrega argumentos para funcao create_array
	add $a1, $0 ,$s1
	add $a2, $0, $s4

	jal create_array
	
	add, $s0, $0, $s2 # s0 = elemento buscado
	subi $s1, $s1, 1 # s1 = tamanho de array - 1
	
	# cria endereco da ultima posicao de array
	
	sll $s2, $s1, 2 # s2 = endereco de ultima posicao
	
	# carrega argumentos para interpolation_search
	
	add $a0, $0, $s0 # elemento buscado
	add $a1, $0, $s2 # ultimo endereco
	add $a2, $0, $0  # primeiro endereco (inicialmente = 0)
	add $a3, $0, $s4 # base de array
	
	jal interpolation_search
	
	add $s3, $0, $v0 # recupera retorno
	
	# imprime sinal de retorno
	
	li $v0, 1
	add $a0, $0, $s3
	syscall
	
	# TODO: comentar melhor, testar casos extremos