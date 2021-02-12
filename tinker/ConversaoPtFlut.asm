#Código para ver como o processador converte os números, para ver o que entra no
#coprocessador1 e o que sai se quiser recuperar

	.data
	num: .double 7.77
	antesdocop1: .asciiz "\nNumero 8 antes de ser passado para cop1: "
	sconv: .asciiz "\nNumero 8 sem converter: "
	cconv: .asciiz "\nNumero 8 com conversao: "
	dtoint0: .asciiz "\nNumero 7.77 antes de converter para inteiro: "
	dtoint1: .asciiz "\nNumero 7.77 convertido para inteiro: "
	dtoint2: .asciiz "\nNumero 7.77 convertido agora no processador principal: "
	
	.text
main:
#$f12 é um registrador do cop1 usado para imprimir na syscall.
# Todas as operações foram feitas em cima dele
###########trecho para colocar no coprocessador1
	li $t0 8		#número arbitrário em $t0
#imprime antes de ir para o cop1
	li $v0, 4		#codigo imprime string
	la $a0, antesdocop1	#armazena string a imprimir
	syscall
	move $a0, $t0		#$a0 = 8 como argumento para a syscall
	li $v0, 1		#codigo imprime inteiro em $a0
	syscall
#imprimir o numero sem converter
	mtc1.d $t0, $f12	#passou para o cop1 em $f12, mas sem converter
	li $v0, 4		#codigo imprime string
	la $a0, sconv		#armazena string a imprimir
	syscall 
	li $v0, 3 		#codigo para imprimir o double em $f12
	syscall
#imprimir o numero depois de converter
	cvt.d.w $f12, $f12	#converter de inteiro para double
	li $v0, 4		#codigo imprime string
	la $a0, cconv		#armazena string a imprimir
	syscall 
	li $v0, 3 		#codigo para imprimir o double em $f12
	syscall
##########trecho para recuperar do coprocessador1
	l.d $f12, num		# $f12 = num = 7.77
#imprimir o número do jeito que ele chegou
	li $v0, 4		#codigo imprime string
	la $a0, dtoint0		#armazena string a imprimir
	syscall
	li $v0, 3		#codigo imprime double $f12
	syscall	
#imprimir depois da conversão, ainda no cop1
	cvt.w.d $f12, $f12	#converter de double para word/inteiro
	li $v0, 4		#codigo imprime string
	la $a0, dtoint1		#armazena string a imprimir
	syscall
	li $v0, 3 		#codigo para imprimir o double em $f12
	syscall
#imprimir depois de voltar pro processador principal
	mfc1.d $t0, $f12	#move $f12 para $t0, tirando do cop1
				#atencao que este comando enche $t1 de lixo, não só seta $t0
	li $v0, 4		#codigo imprime string
	la $a0, dtoint2		#armazena string a imprimir
	syscall
	move $a0, $t0		#coloca o numero em $t0 como 
	li $v0, 1		#codigo imprime inteiro
	syscall 
#finalizando
      li   $v0, 10          # código de finalização
      syscall               # fechou o programa
