.data
	array: .word 2 3 5 12 17 20 28 42
	key: .word 5
.text
	j main
	
	# funcao principal de busca recursiva
	
	interpolation_search:
	
	# carrega argumentos
	##
	#(GPG)fale por favor quem sao os argumentos (o que cada registrador representa) $a0, $a1 e $a2
	##
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
	##
	#(GPG)$s1 e $s2 têm guardado o quê?
	##
	sub $t6, $s1, $a2
	srl $t3, $t6, 2  # recupera endereco nominal de limite superior
	sub $t6, $s2, $a2
	srl $t4, $t6, 2 # recupera endereco nominal de limite inferior 
	
	##
	#(GPG) essa parte que transformei em comentário deve ser retirada 
	##
	# converte variaveis para double
	#cvt.d.w $t0, $a0		#key
	#cvt.d.w $t1, $t1		#valor final
	#cvt.d.w $t2, $t2		#valor inicial
	#cvt.d.w $t3, $t3		#indice final 
	#cvt.d.w $t4, $t4		#indice inicial
	
	# define nova posicao		# pos = lo + (hi-lo)*(x-arr[lo])/(arr[hi]-arr[lo])
	
	#sub.d $t5, $t3, $t4		# hi - lo 		
	#sub.d $t6, $t1, $t2		# arr[hi]-arr[lo] 
	#sub.d $t7, $t0, $t2		# x - arr[lo]
	#mul.d $t5, $t5, $t7		
	#div.d $t6, $t5, $t6		# $t6 = (hi-lo)*(x-arr[lo])/(arr[hi]-arr[lo])
	#add.d $t5, $t6, $t4		# $t5 = pos	
	#cvt.w.d $t5, $t5
	
	#//////////////////Vim até aqui(ass. Bahia)/////////////////////////////////#
	###########################
	#(GPG) mudança PFlut inicio
	###########################
	
	# define nova posicao		# pos = lo + (hi-lo)*(x-arr[lo])/(arr[hi]-arr[lo])
	#$a0 = key
	#$t1 = arr[hi]
	#$t2 = arr[lo]
	#$t3 = hi 
	#$t4 = lo	
	sub $t5, $t3, $t4		#hi - lo
	sub $t6, $t1, $t2		#arr[hi]-arr[lo]
	sub $t7, $a0, $t2		# x - arr[lo]
	
	#passa para o CoProcessador1 e converte somente as variáveis que precisam de operação em PF
	mtc1.d $t5, $f0			#$t5 em Cop1 no espaço para double
	cvt.d.w $f0, $f0		#Convertido para double
	mtc1.d $t6, $f2			#idem
	cvt.d.w $f2, $f2		#
	mtc1.d $t7, $f4			#
	cvt.d.w $f4, $f4		#
	
	#faz as operações
	div.d $f2, $f4, $f2		#$f2 = (x-arr[lo])/(arr[hi]-arr[lo]
	mul.d $f0, $f0, $f2		#$f0 = (hi - lo)*$f2
	
	#converte e recupera o valor obtido
	cvt.w.d $f0, $f0		#converte de double para inteiro
	mfc1.d $t6, $f0			#move a parte inteira para $t6
	
	#nova posição
	add $t5, $t6, $t4		#$t5 = pos = lo($t4) + [...]($t6)
	
	
	########################
	#(GPG) mudança PFlut Fim
	########################
	
	
	
	
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
