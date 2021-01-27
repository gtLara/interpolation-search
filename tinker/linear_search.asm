.data   
	######################################
	##trecho com declaracao de variaveis##
	######################################
	
	#GABRIEL P: sugiro separar as variaveis por trecho de codigo, 
	#tipo: essas vao na funcao, e essas outras vao na main
	
	array: .word 3 5 6 12 19 20 42 49 60 120 250 # 11 elementos
	size: .word 11                               
	key: .word 5                                 # numero a ser encontrado
	i: .word 0                                   # posicao em uso no array
	error_signal: .word -1
	
.text 
	##############################################
	##trecho com as instrucoes, o programa mesmo##
	##############################################
	
	#buscando os valores na memoria#
	
	lw $s0, i
	lw $s1, size                  
	lw $s2, key
	lw $s7, error_signal
	
for:
	
	# t0: variavel de testes
	# t1: a[i]
	# t2: endereco de a[i] ( i * 4 )
	
	#######################
	##condicoes de parada##
	#######################
	
	
	slt $t0, $s0, $s1                   # se chegou ao fim do array:
	beqz $t0, done                      # se (i < tamanho) == 0 (falso) , escapar
	
	                                    # se key == a[i], escapar#	
	sub $t0, $s2, $t1                   # t0 = key - a[i]
	beqz $t0, return_index              # escapa se t0 == 0
	
	######################
	##iteracao por vetor##
	######################
	
	
	sll $t2, $s0, 2                     # cria endereço
	lw $t1, array($t2)                  # t1 = a[i]
	
	addi $s0, $s0, 1                    # i ++
	
	j for                               # retorna para label "for"
	
return_index:
	
	subi $t3, $s0, 1                    # decrementa i para retornar indice correto
	add $s7, $0, $t3                    # escreve sobre sinal de retorno
	 
	j done
	
done:
					    # imprime indice de chave se estiver no vetor
					    #e sinal de erro (-1) se nao.#
	li $v0, 1			    #escreve no registrador do sistema o tipo de chamada
	move $a0, $s7                       #coloca o valor a ser escrito no argumento
	syscall		 	 	    
	
	
