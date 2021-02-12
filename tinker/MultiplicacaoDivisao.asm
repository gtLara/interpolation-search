	.data
	
	div: .asciiz "\nA divisao 13 por 7 e: "
	mult:.asciiz "\nA multiplicacao de 2,1 por 4,7 e: "
	f0: .double 2.1
	f2: .double 4.7
	
	.text
main:
##############trecho para a divisão
	li $t0, 13		#carregando arbitrariamente t0
	li $t1, 7		#carregando arbitrariamente t1
	
#passando para o coprocessador1, de ponto flutuante
	mtc1.d $t0, $f0		#passando 13 para $f0 (usa $f0 + $f1)
	cvt.d.w $f0, $f0	#converte $f0 de inteiro para a representação de double
	mtc1.d $t1, $f2		#passando 7 para $f2
	cvt.d.w $f2, $f2	#converte para double
#conta de divisão
	div.d $f12, $f0, $f2	#$f12 = 1,85714 = 13 / 7
#escreve o resultado na tela
	li $v0, 4		#codigo imprime string
	la $a0, div		#armazena string a imprimir
	syscall 
	li $v0, 3 		#codigo para imprimir o double em $f12
	syscall

##############trecho para a multiplicação	
	l.d $f0, f0		#carregando f0 com double vindo de .data
	l.d $f2, f2 		#carregando f2 com double vindo de .data

#conta de multiplicacao
	mul.d $f12, $f0, $f2	#$f12 = 9,87 = 2.1 * 4.7
#escreve o resultado na tela
	li $v0, 4		#codigo imprime string
	la $a0, mult		#armazena string a imprimir
	syscall 
	li $v0, 3 		#codigo para imprimir o double em $f12
	syscall		