#Este � um programa que cria uma fun��o recursiva
#A fun��o recursiva mostra qantas vezes ela foi chamada

	.data
	 contagem: .asciiz "\nEssa e a chamada de numero: "
	 pergunta: .asciiz "\nQuantas vezes chamar a funcao(?): "
	
	.text
main:
	#pergunta quantas vezes quer chamar a fun��o
	la $a0, pergunta	#coloca a string no argumento da syscall
	li $v0, 4		#codigo imprime string
	syscall 
	li $v0, 5		#codigo ler inteiro
	syscall			#n�mero lido agora est� em $v0
	
	#prepara para chamar a fun��o
	move $a0, $v0		#coloca no argumento da fun��o o valor lido
	li $a1, 1		#a fun��o deve receber tamb�m o n�mero de vezes que ela foi chamada at� agora
				#ela � chamada pelo menos uma vez
	#chama a fun��o
	jal funcao

	#aqui a fun��o j� terminou e basta sair
	li $v0, 10			#codigo de sa�da syscall
	syscall				#acabou o programa

funcao:
	#esta funcao sai se foi chamada o numero de vezes suficiente. Sen�o, ela se chama mais uma vez.
	#$a0: n�mero dado pelo usu�rio
	#$a1: n�mero de vezes que a fun��o foi chamada
	
	#imprime a vez que foi chamada
	move $t0, $a0			#preservar $a0 (num de chamadas pedido) porque vai ser usado depois
	la $a0, contagem		#string a imprimir no argumento
	li $v0, 4			#codigo imprime string
	syscall
	move $a0, $a1			#argumento ($a0) agora com o n�mero de chamadas ($a1)
	li $v0, 1			#c�digo imprime inteiro
	syscall
	move $a0, $t0			#recupera o valor antigo de $a0
	
	
	#se o n�mero j� feito for igual ao que pediu, vai para o fim
	beq $a0, $a1, fim
	
	#se n�o chamou o suficiente:
	addi $a1, $a1, 1		#marca que vai chamar mais uma vez	

	
	#chama a fun��o mais uma vez
	#como $a0 n�o muda e $a1 j� foi incrementado, os argumentos est�o prontos
	addi $sp, $sp, -4		#libera espa�o na pilha
	sw $ra, 0($sp)			#guarda o endere�o de retorno na pilha
	jal funcao			#chama de novo a fun��o
	j fim				#depois que chamou, resta ir para o fim
	
	
	######### trecho do fim #########		
	fim:
		#recupera o endere�o de retorno e libera a pilha
		lw $ra, 0($sp)		#carrega o endere�o de retorno
		addi $sp, $sp, 4	#libera a pilha
		jr $ra			#volta para onde estava
		