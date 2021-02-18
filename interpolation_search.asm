.data

	sizeprompt: .asciiz "\nInsira o tamanho do array:"
	keyprompt: .asciiz "\nInsira o elemento a ser buscado:"
	arrayprompt: .asciiz "\nPreencha vetor:"
	newline: .asciiz "\n"
	answer: .asciiz "\nEsta na posicao: "
	
.text
	j main
			###
			### funcao para criar e preencher array
			###
create_array:
	
			# passa argumentos
	
			# a0: contador
			# a1: tamanho do array
			# a2: endereço base

			# pede para usuario preencher vetor
	
create_array_loop:

	slt $t0, $a0, $a1 		# verifica se preenchimento de array terminou
	beqz $t0, create_array_return 	# se sim, retorna

	sll $t0, $a0, 2 		# cria o offset em n° de bytes
	add $t0, $t0, $a2 		# soma ao endereco base

			# le valor de entrada
	li $v0 , 5	 			
	syscall

	add $t1, $0, $v0		# recupera a saída da função
	sw $t1, 0($t0) 			# carrega elemento inserido em posição desejada

	addi $a0, $a0, 1 		# itera o contador

	j create_array_loop

create_array_return:

	jr $ra				#fim da função
			###
			### funcao principal de busca recursiva
			###
interpolation_search:
	
			# carrega argumentos
	
	add $t0, $0, $a0 		# elemento buscado
	add $t1, $0, $a1 		# endereco de ultimo elemento de subarray
	add $t2, $0, $a2 		# endereco de primeiro elemento de subarray
			# a3: base do array. nao sera carregado em temporario e sim acessado diretamente em a3
	
			# verificando 3 condições
	
			# exaustão de busca
			# 1: se endereco superior <= endereco inferior, escapar
	
	sle $t7, $t2, $t1
	beqz $t7, return_failure
	
			# as duas condicoes seguintes decorrem do fato do array estar ordenado
			# 2: se elemento buscado < primeiro elemento de subarray, escapar
	
	add $t7, $a3, $t2 		# cria endereco somando base de array a endereço desejado
	lw $t7, 0($t7) 			# carrega primeiro elemento de subarray
	sle $t7, $t7, $t0
	beqz $t7, return_failure
	
			# 3: se elemento buscado > ultimo elemento de subarray, escapar
	
	add $t7, $a3, $t1 		# cria endereco somando base de array a endereco desejado
	lw $t7, 0($t7) 			# carrega ultimo elemento de subarray
	sle $t7, $t0, $t7		# se elemento buscado for menor ou igual ao último elemento, $t7 = 1
	beqz $t7, return_failure
	
			# prepara para estimar nova posicao para elemento buscado assumindo distribuicao uniforme de array
			# carrega variaveis importantes (lo, hi, arr[lo], arr[hi])
	
	add $t7, $a3, $t1 		# cria endereco somando base de array a endereco desejado
	lw $t3, 0($t7)
	add $t7, $a3, $t2 		# cria endereco somando base de array a endereco desejado
	lw $t4, 0($t7)
	srl $t1, $t1, 2 		# carrega hi simplesmente convertendo offset em bytes para índice do array (4, 8, 12 -> 1, 2, 3)
	srl $t2, $t2, 2 		# carrega lo da mesma maneira
	
			# define nova posição		# pos = lo + (hi-lo)*(x-arr[lo])/(arr[hi]-arr[lo])
	
			# t0: x, elemento buscado
			# t1: hi
			# t2: lo
			# t3: arr[hi]
			# t4: arr[lo]
	
	sub $t5, $t1, $t2		# $t5 = hi - lo
	sub $t6, $t3, $t4		# $t6 = arr[hi]-arr[lo]
	sub $t7, $t0, $t4		# $t7 = x - arr[lo]
	
			#passa para o CoProcessador1 e converte somente as variáveis que precisam de operação em PF
	
	mtc1.d $t5, $f0			# $t5 vai para o Cop1 num espaço de double e fica em $f0~$f1
	cvt.d.w $f0, $f0		# Convertido para double: $f0 = hi - lo 
	mtc1.d $t6, $f2
	cvt.d.w $f2, $f2		# $f2 = arr[hi] - arr[lo]
	mtc1.d $t7, $f4
	cvt.d.w $f4, $f4		# $f4 = x - arr[lo]
	
			#faz as operações
	div.d $f2, $f4, $f2		# $f2 = (x-arr[lo])/(arr[hi]-arr[lo])
	mul.d $f0, $f0, $f2		# $f0 = (hi - lo) * $f2
	
			#converte e recupera o valor obtido
	cvt.w.d $f0, $f0		# converte $f0 de double para inteiro
	mfc1.d $t6, $f0			# move para $t6
	
			#nova posição
	add $t3, $t6, $t2		# $t3 = pos = ($t2 = lo) + ( $t6 = (hi-lo)*(x-arr[lo])/(arr[hi]-arr[lo]) )
	
			# nesse ponto $t3 deve segurar enderecamento nominal (índice) de posicao
	
	sll $t3, $t3, 2 		# converte pos para offset em bytes
	sll $t2, $t2, 2 		# converte lo para offset em bytes
	sll $t1, $t1, 2 		# converte hi para offset em bytes
	
			# verifica se o elemento buscado foi encontrado
	
	add $t7, $a3, $t3 		# cria endereco somando base de array a offset desejado
	lw $t7, 0($t7) 			# carrega valor de posicao estimada
	sub $t6, $t0, $t7		# se elem. buscado (em $t0) for igual ao elemento estimado (em $t7), sucesso 
	beqz $t6, return_success
	
			# chama funcao recursivamente
			# observe que $t7 = array[posicao estimada]
			# decisão se vai buscar no subarray superior ou no inferior
	
	slt $t6, $t0, $t7		# se elem. buscado ($t0) NÃO for menor do que o elem. estimado ($t7)
	beqz $t6, upper_subarray	# busca no subarray superior
	
			# se elemento buscado < elemento em posicao estimada, busca em subarray inferior,
			# no qual a nova posição superior passa a ser a antiga posição estimada menos 1
			# e a posição inferior se mantém
			# carrega argumentos para proxima chamada de interpolation_search
	
	add $a0, $0, $t0 		# elemento buscado se mantem
	subi $a1, $t3, 4 		# endereco superior assume pos - 1
	add $a2, $0, $t2  		# endereco inferior se mantem 
	
			# nao ha necessidade de salvar PC em $ra por meio de jal porque o programa nunca voltará
			# para este ponto, e sim para o ponto em que a $ra registra neste momento quando alguma das condicoes
			# acima forem atendidas. o pulo eh portanto incondicional
	j interpolation_search
	
			# se elemento buscado > elemento em posicao estimada, busca em subarray superior,
			# no qual a nova posição inferior passa a ser a antiga posição estimada mais 1
			# e a posição superior se mantém
upper_subarray:
	
			# carrega argumentos para proxima chamada de interpolation_search
	
	add $a0, $0, $t0 		# elemento buscado se mantem
	add $a1, $0, $t1 		# endereco superior se mantem
	addi $a2, $t3, 4  		# endereco inferior assume pos + 1 
	
	j interpolation_search
	
return_failure:
	
	addi $v0, $0, -1 		# retorna sinal indicador que elemento nao foi encontrado
	jr $ra				#sai da função
	
return_success:
	srl $t3, $t3, 2			#passa de offset em bytes para índice
	add $v0, $0, $t3 		# retorna endereço nominal (indice) de elemento
	jr $ra
	
main:
			###
			### interação com o usuário para criar array	
			###
			
			# demanda tamanho de array	
			
			#imprime
	li $v0 , 4		#chamada de escrever string		
	la $a0 , sizeprompt 	#pede o tamanho do array
	syscall
	
			#leitura
	li $v0 , 5	 	#chamada de ler inteiro		
	syscall
	add $t0, $0, $v0	#recebe o tamanho do array
	
			# demanda elemento de busca
			
			#imprime
	li $v0 , 4		#chamada de escrever string
	la $a0 , keyprompt 	#pede o elemento a ser buscado
	syscall
	
			#leitura
	li $v0 , 5		#chamada de ler inteiro	 			
	syscall
	add $t1, $0, $v0	#recebe o valor do elemento a ser buscado
	
			# demanda preenchimento de array
	
	li $v0 , 4		#chamada de escrever string		
	la $a0 , arrayprompt	#pede para preencher o array 
	syscall
	
			# carrega informacoes inseridas e variaveis necessarias

	addi $s0, $s0, 0 	# $s0 = contador
	add $s1, $0, $t0	# $s1 = tamanho do array
	add $s2, $0, $t1	# $s2 = elemento a ser buscado

	lui $s4, 0x1000
	ori $s4, $s4, 0x0128 	# define endereço inicial para array, mas nunca faça isso. Deixe para o compilador.

			# carrega argumentos para funcao create_array
	add $a0, $0, $s0 	# contador
	add $a1, $0 ,$s1	# tamanho
	add $a2, $0, $s4	# endereço base

	jal create_array	#chama o criador de array
	
	add, $s0, $0, $s2 	# s0 = elemento buscado
	subi $s1, $s1, 1 	# s1 = tamanho de array - 1
	
			# cria offset em bytes da ultima posicao de array
	
	sll $s2, $s1, 2 	# $s2 = offset da ultima posicao
	
			# carrega argumentos para interpolation_search
	
	add $a0, $0, $s0 	# elemento buscado
	add $a1, $0, $s2 	# offset da posição do ultimo elemento
	add $a2, $0, $0  	# offset da posição do primeiro elemento (inicialmente = 0)
	add $a3, $0, $s4 	# endereço base do array
	
	jal interpolation_search
	
	add $s3, $0, $v0 	# recupera retorno da interpolation
	
			# imprime sinal de retorno
	li $v0, 4		# chamada de escrever string
	la $a0, answer		# texto da resposta
	syscall
	
	li $v0, 1		# chamada de escrever inteiro
	add $a0, $0, $s3	# o inteiro é o elemento encontrado
	syscall
	
