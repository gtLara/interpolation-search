.text
	j main
	
	main:
	
	#define inteiros
	
	
	addi $s0, $0, 42 
	addi $s1, $0, 15
	
	# multiplicacao: resultado é registrado em registradores HI e LO
	
	mult $s0, $s1
	mfhi $t0 # carrega 32 bits menos signfificantes da multiplicacao em t0
	mflo $t1 # carrega 32 bits mais significantes da multiplicacao em t1
	
	# divisao: quociente é armazenado em LO e resto em HI
	 
	div $s0, $s1 # 42/15
	mfhi $t0 # carrega resto em t0
	mflo $t1 # carrega quociente em t1	