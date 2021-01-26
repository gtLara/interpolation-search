.data   
	######################################
	##trecho com declaracao de variaveis##
	######################################
	
	#variaveis da main#
	arr: .word 3 5 6 12 19 20 42 49 60 120 250 # 11 elementos   #
	n: .word 11                               		    #tamanho do array
	x: .word 5                                                  # numero a ser encontrado
	hi: .word 0						    #limites do
	lo: .word 0						    #sub-array
	
	#variaveis da funcao#
	pos: .word 0                                                # posicao em uso no array
	error_signal: .word -1					    #

.text 
	##############################################
	##trecho com as instrucoes, o programa mesmo##
	##############################################
	
	#buscando os valores na memoria#
main:	
	lw $a0, n                          #n = 11
	lw $a1, x			   #x = 5
	lw $a2, lo                         #lo = 0
	lw $a3, hi                         #hi = 0
	
	addi $a3 $a0 -1                    #hi = n - 1
	
	jal interpolation		   #Entra na funcao interpolation, argumentos x = 5, hi = n - 1, lo = 0
					   
	# imprime indice de chave se estiver no vetor e sinal de erro (-1) se nao#
	li $v0, 1			    #escreve no registrador do sistema o tipo de chamada
	move $a0, $s7                       #coloca o valor a ser escrito no argumento
	syscall		

	
interpolation:
	
	# t0: variavel de testes
	# t1: a[i]
	# t2: endereco de a[i] ( i * 4 )
	# t3: i
	
	#######################
	##condicoes de parada##
	#######################
	
	#sao os dois primeiros if's da funcao#
	
	slt $t0, $s0, $s1                   # se chegou ao fim do array:
	beqz $t0, done                      # se (i < tamanho) == 0 (falso) , escapar
	
	                                    # se key == a[i], escapar#	
	sub $t0, $s2, $t1                   # t0 = key - a[i]
	beqz $t0, return_index              # escapa se t0 == 0
	
	######################
	##iteracao por vetor##
	######################
	
	#e o ultimo if then else do while#
	
	sll $t2, $s0, 2                     # cria endereço
	lw $t1, array($t2)                  # t1 = a[i]
	
	addi $s0, $s0, 1                    # i ++
	
	j interpolation                     # retorna para label "interpolation"	 	 	    
	
return_index:
	
	subi $t3, $s0, 1                    # decrementa i para retornar indice correto
	add $s7, $0, $t3                    # escreve sobre sinal de retorno
	 
	j done
