#Este é um programa que cria uma função recursiva
#A função recursiva mostra qantas vezes ela foi chamada

	.data
	 contagem: .asciiz "\nEssa e a chamada de numero: "
	 pergunta: .asciiz "\nQuantas vezes chamar a funcao(?): "
	
	.text
main:
	#pergunta quantas vezes quer chamar a função
	la $a0, pergunta	#coloca a string no argumento da syscall
	li $v0, 4		#codigo imprime string
	syscall 
	li $v0, 5		#codigo ler inteiro
	syscall			#número lido agora está em $v0
	
	#prepara para chamar a função
	move $a0, $v0		#coloca no argumento da função o valor lido
	li $a1, 1		#a função deve receber também o número de vezes que ela foi chamada até agora
				#ela é chamada pelo menos uma vez
	#chama a função
	jal funcao

	#aqui a função já terminou e basta sair
	li $v0, 10			#codigo de saída syscall
	syscall				#acabou o programa

funcao:
	#esta funcao sai se foi chamada o numero de vezes suficiente. Senão, ela se chama mais uma vez.
	#$a0: número dado pelo usuário
	#$a1: número de vezes que a função foi chamada
	
	#imprime a vez que foi chamada
	move $t0, $a0			#preservar $a0 (num de chamadas pedido) porque vai ser usado depois
	la $a0, contagem		#string a imprimir no argumento
	li $v0, 4			#codigo imprime string
	syscall
	move $a0, $a1			#argumento ($a0) agora com o número de chamadas ($a1)
	li $v0, 1			#código imprime inteiro
	syscall
	move $a0, $t0			#recupera o valor antigo de $a0
	
	
	#se o número já feito for igual ao que pediu, vai para o fim
	beq $a0, $a1, fim
	
	#se não chamou o suficiente:
	addi $a1, $a1, 1		#marca que vai chamar mais uma vez	

	
	#chama a função mais uma vez
	#como $a0 não muda e $a1 já foi incrementado, os argumentos estão prontos
	addi $sp, $sp, -4		#libera espaço na pilha
	sw $ra, 0($sp)			#guarda o endereço de retorno na pilha
	jal funcao			#chama de novo a função
	j fim				#depois que chamou, resta ir para o fim
	
	
	######### trecho do fim #########		
	fim:
		#recupera o endereço de retorno e libera a pilha
		lw $ra, 0($sp)		#carrega o endereço de retorno
		addi $sp, $sp, 4	#libera a pilha
		jr $ra			#volta para onde estava
		