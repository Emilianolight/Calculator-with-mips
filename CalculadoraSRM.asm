	
					.data
resultado: .space 51
msg1: .asciiz "\nIngresa un primer número: "
msg2: .asciiz "\nIngresa un segundo número: "
number2: .space 50
msg3: .asciiz "\n El resultado es: "
msg4: 	.asciiz "Estoy pasando por aqui\n"
number1: .space 50
opciones: .asciiz "\nEscoja la operación que desea realizar: \n1)Suma. \n2)Resta. \n3)Multiplicación.\n"
mas:		.asciiz "+"
menos:		.asciiz "-"
msg5: .asciiz "num1: \n"
msg6: .asciiz "num2: \n"
msg7: .asciiz "resultado: \n"
salto: .asciiz "\n"
posi:		.asciiz "El resultado mostrado es positivo"
espacio2:	.space 1
nega:		.asciiz "El resultado mostrado es negativo"
respuesta: 	.space 51

							.text
.eqv index1, $t7	#index del space 1
.eqv index2, $t8	#index del space 2
.eqv indexResultado, $t9	#Index del space 3
.eqv num1, $s0		#num en el que estoy parado del vector 1
.eqv num2, $s1	#num en el que estoy parado del vector 2
.eqv carrier, $s2		#Carry cuando llevo algo
.eqv num10, $s3
.eqv num0, $s4 
.eqv index_decremento, $s7       #usado para ir sumando el resultado de la multiplicación
.eqv Kikiriwiki, $t0		#los resultados que vamos obteniendo

li index_decremento,1		#el valor inicial de index_decremento debe de ser 1
li  $t7, 0
li $s5, 10

# MACROS GENERALES
.macro ultima_pos %vector
li $t1, 0
loop:  
	lb $t2, %vector($t1)
	addi $t1, $t1, 1
	bnez $t2, loop	
	subi $t1,$t1,3
.end_macro

.macro ultima_pos_resultado %vector
li $t1, 0
loop:  
	lb $t2, %vector($t1)
	addi $t1, $t1, 1
	bnez $t2, loop	
	subi $t1, $t1, 2
.end_macro

.macro asciiadecimal %ascii
subi $t1, %ascii, 0x30
.end_macro

.macro finalizar
li	$v0,10
syscall
.end_macro

.macro imprimir_string %mensaje
la	$a0, %mensaje
li 	$v0,4
syscall 
.end_macro


# MACROS SUMA
.macro carry %numero
 blt %numero,10, sincarry
 div  %numero, $s5
 mfhi $t1
 mflo carrier
 
.end_macro

.macro carrito %numero
 blt %numero,10, sin_carrito
 div  %numero, $s5
 mfhi $t1
 mflo carrier
 
.end_macro

.macro carritoindex2 %numero
 blt %numero,10, sin_carritoindex2
 div  %numero, $s5
 mfhi $t1
 mflo carrier 
.end_macro

.macro  impresion_sin_0 %vector
ultima_pos_resultado(%vector)
li $t3,0
li $t4, 48
li $t5, 96
li $t6, 0
con_0: lb $t2, %vector($t3)
	beq $t2, 48,con_0
	addi $t2, $t2, 0x30
	addi $t3, $t3,1
	beqz $t2, con_0	
	
	subi $t3, $t3, 1	
sin_0:	lb $t2, %vector($t3)
	move $a0, $t2
	addi $a0, $a0, 0x30
	li $v0 ,1 
	syscall	
	addi $t3, $t3,1
	ble $t3, $t1,sin_0			
 li $v0, 10
syscall	
.end_macro

# MACROS RESTA

.macro resta_inversa %number1, %number2
	ultima_pos(%number1)      # doy valor al index1
	move index1, $t1

	ultima_pos(%number2)      #doy valor al index2
	move index2, $t1

restaInversa: 						#Resta en caso de que el sustraendo sea mayor al minuendo  
		
		li	num10,10			#Se coloca el 10 para la resta con acarreo
		lb 	num1, %number1(index1)		#Cargo el caracter
		asciiadecimal(num1)			#Lo convierto a decimal
		move 	num1, $t1				#lo coloco en num1
		
		lb 	num2, %number2(index2)		#Cargo el caracter
		beq	num2,43,loop2
		beq	num2,45,loop2
		asciiadecimal(num2)			#Lo convierto a decimal
		move 	num2,$t1			#lo coloco en num2
		add	num2, num2, carrier
		li	carrier, 0			#Se coloca el carry en 0
		
		sub  	$t1, num1, num2			#Se realiza la resta
		bltz	$t1, acarreo			#Se realiza la resta con acarreo
		b	siga				#Sigue si no es necesaria la resta con acarreo
acarreo:
		add	$t1, num10, $t1			
		addi	carrier, carrier, 1			#Se coloca el carry en 1

siga:		
		subi 	$t1, $t1, 0x30			#Convierto en ascii
		sb   	$t1, resultado(index1)		#Se guarda el resultado
		subi 	index1, index1, 1			#Resto 1 a index1
		subi 	index2, index2, 1			#Resto2 a index2
		bgez 	index2, restaInversa		#Si index1 es >=0 seguir sumando
		bgez 	index1, loop2			#Si index1 es >=0 pero index2 no lo es, agrega 0 a num2 y sigue restando
		b	Imprimirresultado2_resta
		
loop2:		
		li 	num0, 0
		li	num10,10			#Se coloca el 10 para la resta con acarreo
		lb 	num1, %number1(index1)		#Cargo el caracter
		asciiadecimal(num1)			#Lo convierto a decimal
		move 	num1, $t1				#lo coloco en num1
		
		add	num0, num0, carrier		#sumamos el acarreo
		li	carrier, 0			#Se coloca el carry en 0
				
								
		sub  	$t1, num1, num0		#Se realiza la resta
	
		subi 	$t1, $t1, 0x30			#Convierto en ascii
		sb   	$t1, resultado(index1)		#Se guarda el resultado
		subi 	index1, index1, 1			#Resto 1 a index1
		bgez 	index1, loop2		#Si index1 es >=0 seguir restando

Imprimirresultado2_resta:
imprimir_string(msg3)
	
	ultima_pos(number1)	#obtenemos el tamaño del número1
	move $t4, $t1

	ultima_pos(number2)	#obtenemos el tamaño del número2
	move $t5, $t1
	

	bgt	$t4, $t5, num1_mayor		#si el número1 es más grande que el número2, se usa el signo del número1

	bgt	$t5, $t4, num2_mayor		#si el número2 es más grande que el número1, se usa el signo del número2
	b	loop_compar2
	
num1_mayor:
	li	$t1, 0
	lb	$t2, number1($t1)		#obtenemos el signo del número1 para colocarlo en el resultado
	beq	$t2,43,positivo			#si el signo es positivo, imprimimos +
	beq	$t2,45,negativo			#si el signo es negativo, imprimimos -
	b	imprimir

num2_mayor:
	li	$t1, 0
	lb 	$t3, number2($t1)		#obtenemos el signo del número1 para colocarlo en el resultado
	beq	$t3,43,positivo			#si el signo es positivo, imprimimos +
	beq	$t3,45,negativo			#si el signo es negativo, imprimimos -
	b	imprimir
	
loop_compar2:  
	lb $t2, number1($t1)		#obtenemos el primer dígito del número1
	lb $t3, number2($t1)		#obtenemos el primer dígito del número2
	addi $t1, $t1, 1
	beq	$t3, $t2, loop_compar2		#si son iguales vamos al loop para comparar el segundo dígito de cada uno
	bgt $t3, $t2, num2_mayor		#si el dígito del número2 es mayor significa que el número2 es mayor, y cambiamos el orden de la resta
	b	num1_mayor			#si llega hasta acá significa que el número1 es el mayor y se puede restar normal

positivo:
imprimir_string(menos)				#imprimimos el signo -
b	imprimir

negativo:
imprimir_string(mas)				#imprimimos el signo +
b	imprimir

imprimir:
ultima_pos_resultado(resultado)
move $t4, $t1
li $t1, 1

loo:   lb $a0,resultado($t1)
	addi $a0, $a0, 0x30
	li $v0, 1
	syscall
	add $t1, $t1, 1
	ble $t1, $t4, loo
		
.end_macro



						#EMPIEZA EL PROGRAMA
la $a0, msg1  #pido el  primer numero
li $v0, 4
syscall

la $a0, number1  #leo el numero
li $a1, 50
li $v0, 8
syscall

la $a0, msg2  #pido el  segundo numero
li $v0, 4
syscall

la $a0, number2  #leo el numero
li $a1, 50
li $v0, 8
syscall


imprimir_string(opciones)		# Mostramos las opciones
li	$v0,5
syscall
move	$t1, $v0
li	$t2, 1
li	$t3, 2
li	$t4, 3
beq	$t2,$t1,sumatoria
beq	$t3,$t1,sustraccion
beq	$t4,$t1,multiplicacion
					#Aqui empieza la suma 
			
sumatoria:

	li	$t1, 0
	lb	$t2, number1($t1)		#obtenemos el signo del número1
	lb 	$t3, number2($t1)		#obtenemos el signo del número2
	beq	$t2,$t3, suma			#si los signos son iguales, se resta normal
	b	resta			#si los signos son distintos hay que hacer una suma
	
suma:

li carrier, 0

ultima_pos(number1)      # doy valor al index1
move index1, $t1

ultima_pos(number2)      #doy valor al index2
move index2, $t1

		

						#Aquí va si son diferentes
beq index1, index2, PreludioSumasIguales
b PreludioSumasDiferentes

#############################################Preludiosumasiguales
PreludioSumasIguales:
move indexResultado, index1
add indexResultado, indexResultado, 1
sumatoriaIguales:   	
		lb num1, number1(index1)		#Cargo el caracter
		beq num1, 43, transformar_a_0
		beq num1, 45, transformar_a_0
		b	no_transformar
		
no_transformar:		
		asciiadecimal(num1)			#Lo convierto a decimal
		move num1, $t1				#lo coloco en num1
		
		lb num2, number2(index2)		#Cargo el caracter
		asciiadecimal(num2)			#Lo convierto a decimal
		move num2,$t1				#lo coloco en num2
		
		add  $t1, num1, num2			#Se realiza la suma
		add $t1, $t1, carrier			#Sumo el carrier
		
		li carrier, 0
		carry($t1)
		b	sincarry

transformar_a_0:
		move	num1, num0
		move 	num2, num0
		add  $t1, num1, num2			#Se realiza la suma
		add $t1, $t1, carrier			#Sumo el carrier
		
		li carrier, 0
		carry($t1)

sincarry:		
		subi $t1, $t1, 0x30			#Convierto en ascii

		sb   $t1, resultado(indexResultado)	#Se guarda el resultado         
		subi index1, index1, 1			#Resto 1 a index1
		subi index2, index2, 1			#Resto 1 a index2
		subi indexResultado, indexResultado, 1	#Resto 1 a indexResultado         
		bgez index1, sumatoriaIguales	#Si index1 es >= 0 seguir sumando
		
		
ImprimirresultadoIguales: 
li $t2, 0
siguiendo:	move $t1, carrier
		subi $t1, $t1, 0x30
		sb $t1, resultado($t2)

ultima_pos_resultado(resultado)
move $t4, $t1
li $t1, 0

la $a0, msg3 

li $v0, 4
syscall

	lb	$t2, number1($t1)		#obtenemos el signo del número1 para colocarlo en el resultado
	beq	$t2,43,positivo_suma			#si el signo es positivo, imprimimos +
	beq	$t2,45,negativo_suma			#si el signo es negativo, imprimimos -
	b	loo

positivo_suma:
imprimir_string(mas)
b 	loo

negativo_suma:
imprimir_string(menos)
b	loo

loo:   impresion_sin_0(resultado)
			
	li $v0, 10			#Terminar programa
	syscall
	#Sumasiguales
#####################################################################################################################

PreludioSumasDiferentes:
bgt index1,index2,index1Mayor
bgt index2, index1, index2Mayor
################################################index1Mayor##############################################
index1Mayor:
move indexResultado, index1								
loop:		
		lb num1, number1(index1)       #Cargo el  valor
		asciiadecimal(num1)
		move num1, $t1
		
		lb num2, number2(index2)        #Cargo el  valor
		beq	num2, 43, loop2
		beq	num2, 45, loop2
		asciiadecimal(num2)
		move num2, $t1
		
		add $t1, num1, num2		# hago la suma
		add $t1, $t1, carrier
		li carrier, 0
		carrito($t1)
	
sin_carrito: 	
		subi $t1, $t1, 0x30	
		sb $t1, resultado(indexResultado)
		subi index1, index1, 1
		subi index2, index2, 1
		subi indexResultado, indexResultado, 1
		beq index2, -1, loop2
		b loop

loop2: 		
	  	li num2, 0

		lb num1, number1(index1)       #Cargo el  valor
		asciiadecimal(num1)
		beq	num1, 43, transformar1_a_0
		beq	num1, 45, transformar1_a_0
		move num1, $t1
	
		add $t1, num1, num2		# hago la suma
		add $t1, $t1, carrier
		li carrier, 0
		subi $t1, $t1, 0x30
		sb $t1, resultado(indexResultado)
		subi index1, index1, 1
		subi indexResultado, indexResultado, 1
		bgez index1, loop2
		
		b Imprimirresultadodiferentes

transformar1_a_0:	
		li	num1,0
		add $t1, num1, num2		# hago la suma
		add $t1, $t1, carrier
		li carrier, 0
		subi $t1, $t1, 0x30
		sb $t1, resultado(indexResultado)
		subi index1, index1, 1
		subi indexResultado, indexResultado, 1
		bgez index1, loop2
		
		b Imprimirresultadodiferentes		

Imprimirresultadodiferentes: 
li $t2, 0


ultima_pos_resultado(resultado)
move $t4, $t1
li $t1, 0

la $a0, msg3  #pido el  primer numero
li $v0, 4
syscall

lb	$t2, number1($t1)		#obtenemos el signo del número1 para colocarlo en el resultado
	beq	$t2,43,positivo_suma1			#si el signo es positivo, imprimimos +
	beq	$t2,45,negativo_suma1			#si el signo es negativo, imprimimos -
	b	loopo

positivo_suma1:
imprimir_string(mas)
b 	loopo

negativo_suma1:
imprimir_string(menos)
b	loopo

loopo:  impresion_sin_0(resultado)
	li $v0, 10
	syscall
##########################################3index2Mayor###########################################
index2Mayor:
move indexResultado, index2								
loopindex2:		
		lb num1, number2(index2)       #Cargo el  valor
		asciiadecimal(num1)
		move num1, $t1
		
		lb num2, number1(index1)        #Cargo el  valor
		beq	num2, 43, loop2index2
		beq	num2, 45, loop2index2
		asciiadecimal(num2)
		move num2, $t1
		
		add $t1, num1, num2		# hago la suma
		add $t1, $t1, carrier
		li carrier, 0
		carritoindex2($t1)
	
sin_carritoindex2: 	
		subi $t1, $t1, 0x30	
		sb $t1, resultado(indexResultado)
		subi index1, index1, 1
		subi index2, index2, 1
		subi indexResultado, indexResultado, 1
		beq index1, -1, loop2index2
		b loopindex2

loop2index2: 		
	  	li num2, 0

		lb num1, number2(index2)       #Cargo el  valor
		asciiadecimal(num1)
		beq	num1, 43, transformar2_a_0
		beq	num1, 45, transformar2_a_0
		move num1, $t1
	
		add $t1, num1, num2		# hago la suma
		add $t1, $t1, carrier
		li carrier, 0
		subi $t1, $t1, 0x30
		sb $t1, resultado(indexResultado)
		subi index2, index2, 1
		subi indexResultado, indexResultado, 1
		bgez index2, loop2index2
		
		b Imprimirresultadodiferentesindex2

transformar2_a_0:	
		li	num1,0
		add $t1, num1, num2		# hago la suma
		add $t1, $t1, carrier
		li carrier, 0
		subi $t1, $t1, 0x30
		sb $t1, resultado(indexResultado)
		subi index2, index2, 1
		subi indexResultado, indexResultado, 1
		bgez index2, loop2index2
		
		b Imprimirresultadodiferentesindex2			

Imprimirresultadodiferentesindex2: 
li $t2, 0


ultima_pos_resultado(resultado)
move $t4, $t1
li $t1, 0

la $a0, msg3  #pido el  primer numero
li $v0, 4
syscall

	lb	$t2, number1($t1)		#obtenemos el signo del número1 para colocarlo en el resultado
	beq	$t2,43,positivo_suma2			#si el signo es positivo, imprimimos +
	beq	$t2,45,negativo_suma2			#si el signo es negativo, imprimimos -
	b	loopoindex2

positivo_suma2:
imprimir_string(mas)
b 	loopoindex2

negativo_suma2:
imprimir_string(menos)
b	loopoindex2

loopoindex2:   impresion_sin_0(resultado)
	li $v0, 10
	syscall

							#RESTA
sustraccion:

	li	$t1, 0
	lb	$t2, number1($t1)		#obtenemos el signo del número1
	lb 	$t3, number2($t1)		#obtenemos el signo del número2
	beq	$t2,$t3, resta			#si los signos son iguales, se resta normal
	b	suma			#si los signos son distintos hay que hacer una suma
	
resta:
	
	
	ultima_pos(number1)	#obtenemos el tamaño del número1
	move $t4, $t1

	ultima_pos(number2)	#obtenemos el tamaño del número2
	move $t5, $t1

	bgt	$t4, $t5, start		#si el número1 es más grande que el número2, empieza el programa

	bgt	$t5, $t4, cambio	#si el número2 es más grande que el número1, cambia el orden de la resta

	li $t1, 1
loop_compar:  
	lb $t2, number1($t1)		#obtenemos el primer dígito del número1
	lb $t3, number2($t1)		#obtenemos el primer dígito del número2
	addi $t1, $t1, 1
	beq	$t3, $t2, loop_compar		#si son iguales vamos al loop para comparar el segundo dígito de cada uno
	bgt $t3, $t2, cambio		#si el dígito del número2 es mayor significa que el número2 es mayor, y cambiamos el orden de la resta
	b	start			#si llega hasta acá significa que el número1 es el mayor y se puede restar normal
cambio:
		resta_inversa(number2,number1)
		finalizar

start:
ultima_pos(number1)      # doy valor al index1
move index1, $t1

ultima_pos(number2)      #doy valor al index2
move index2, $t1

restaIguales:   

		li num0, 0
		li	num10,10			#Se coloca el 10 para la resta con acarreo
		lb 	num1, number1(index1)		#Cargo el caracter
		asciiadecimal(num1)			#Lo convierto a decimal
		move 	num1, $t1				#lo coloco en num1
		
		lb 	num2, number2(index2)		#Cargo el caracter
		beq	num2,43,loop2_resta
		beq	num2,45,loop2_resta
		asciiadecimal(num2)			#Lo convierto a decimal
		move 	num2,$t1				#lo coloco en num2
		
		add	num2, num2, carrier
		li	carrier, 0			#Se coloca el carry en 0
		
		sub  	$t1, num1, num2			#Se realiza la resta
		bltz	$t1, acarreo			#Se realiza la resta con acarreo
		b	siga				#Sigue si no es necesaria la resta con acarreo
acarreo:
		add	$t1, num10, $t1			
		addi	carrier, carrier, 1			#Se coloca el carry en 1

siga:
		subi 	$t1, $t1, 0x30			#Convierto en ascii
		sb   	$t1, resultado(index1)		#Se guarda el resultado
		subi 	index1, index1, 1			#Resto 1 a index1
		subi 	index2, index2, 1			#Resto2 a index2
		bgez 	index2, restaIguales		#Si index1 es >=0 seguir sumando
		bgez 	index1, loop2_resta			#Si index1 es >=0 pero index2 no lo es, agrega 0 a num2 y sigue restando
		b	Imprimirresultado_resta
		
loop2_resta:		
		li 	num0, 0
		li	num10,10			#Se coloca el 10 para la resta con acarreo
		lb 	num1, number1(index1)		#Cargo el caracter
		asciiadecimal(num1)			#Lo convierto a decimal
		move 	num1, $t1				#lo coloco en num1
		
		add	num0, num0, carrier		#sumamos el acarreo
		li	carrier, 0			#Se coloca el carry en 0
				
		sub  	$t1, num1, num0		#Se realiza la resta
	
		subi 	$t1, $t1, 0x30			#Convierto en ascii
		sb   	$t1, resultado(index1)		#Se guarda el resultado
		subi 	index1, index1, 1			#Resto 1 a index1
		bgez 	index1, loop2_resta			#Si index1 es >=0 pero index2 no lo es, agrega 0 a num2 y sigue restando
		b	Imprimirresultado_resta
		

		
#Imprimir resultado Numeros iguales
Imprimirresultado_resta: 
imprimir_string(msg3)
	
	ultima_pos(number1)	#obtenemos el tamaño del número1
	move $t4, $t1

	ultima_pos(number2)	#obtenemos el tamaño del número2
	move $t5, $t1
	

	bgt	$t4, $t5, num1_mayor		#si el número1 es más grande que el número2, se usa el signo del número1

	bgt	$t5, $t4, num2_mayor		#si el número2 es más grande que el número1, se usa el signo del número2
	b	loop_compar2
	
num1_mayor:
	li	$t1, 0
	lb	$t2, number1($t1)		#obtenemos el signo del número1 para colocarlo en el resultado
	beq	$t2,43,positivo			#si el signo es positivo, imprimimos +
	beq	$t2,45,negativo			#si el signo es negativo, imprimimos -
	b	imprimir

num2_mayor:
	li	$t1, 0
	lb 	$t3, number2($t1)		#obtenemos el signo del número1 para colocarlo en el resultado
	beq	$t3,43,positivo			#si el signo es positivo, imprimimos +
	beq	$t3,45,negativo			#si el signo es negativo, imprimimos -
	b	imprimir
	
loop_compar2:  
	lb $t2, number1($t1)		#obtenemos el primer dígito del número1
	lb $t3, number2($t1)		#obtenemos el primer dígito del número2
	addi $t1, $t1, 1
	beq	$t3, $t2, loop_compar2		#si son iguales vamos al loop para comparar el siguiente dígito de cada uno
	bgt $t3, $t2, num2_mayor		#si el dígito del número2 es mayor significa que el número2 es mayor
	b	num1_mayor			#si llega hasta acá significa que el número1 es el mayor 
	
	
positivo:
imprimir_string(mas)				#se imprime el signo +
b	imprimir

negativo:
imprimir_string(menos)				#se imprime el signo -
b	imprimir

imprimir:
ultima_pos_resultado(resultado)
move $t4, $t1
li $t1, 1

loo_resta:   lb $a0,resultado($t1)
	addi $a0, $a0, 0x30
	li $v0, 1
	syscall
	add $t1, $t1, 1
	ble $t1, $t4, loo_resta
	
finalizar

						# MULTIPLICACION
						
multiplicacion:
#----------------------------------> llenamos de ceros a respuesta
		li $t1,0
		li $t0,0
		li $t2,50
		addi $t0,$t0,0x30
loop20:		
		sb $t0,respuesta($t1)
		addi $t1,$t1,1
		ble $t1,$t2,loop20
#----------------------------------> llenamos de ceros a respuesta

		ultima_pos(number2)      
		move index2, $t1	#index1 contiene inicialmente la última pos de numero1, para ir recorriendo numero1 iremos restando 1
		
		ultima_pos(number1)      
		move index1, $t1
		
		ultima_pos_resultado(respuesta)      
		move indexResultado, $t1
		
		#empieza la multiplicación
loop100:
		lb num2,number2(index2)		#cargamos a num2 el elemento apuntado en number2
		asciiadecimal(num2)
		move num2,$t1
loop200:
		lb num1,number1(index1)		#cargamos a num2 el elemento apuntado en number2
		asciiadecimal(num1)
		move num1,$t1
		mul Kikiriwiki,num1,num2
		
		
carrier_multi:
		add Kikiriwiki,Kikiriwiki,carrier
		li carrier,0
		lb $s5,respuesta(indexResultado)		
		subi $s5,$s5,0x30				
		add Kikiriwiki,Kikiriwiki,$s5
		li $t1,10
		div Kikiriwiki,$t1
		mflo carrier					
		mfhi Kikiriwiki
		addi Kikiriwiki,Kikiriwiki,0x30
		sb Kikiriwiki,respuesta(indexResultado)
		subi indexResultado,indexResultado,1		
		subi index1,index1,1
		lb $t1,number1(index1)
		beq $t1,43,signo_multiplicando
		beq $t1,45,signo_multiplicando
		b loop200
		
signo_multiplicando:
		move $s4,$t1			#movemos a $s4 el signo que guarde $t1
		addi carrier,carrier,0x30
		sb carrier,respuesta(indexResultado)
		li carrier,0
		ultima_pos(number1)      				
		move index1, $t1
		ultima_pos_resultado(respuesta)					
		move indexResultado, $t1
		sub indexResultado,indexResultado,index_decremento
		addi index_decremento,index_decremento,1
		subi index2,index2,1
		lb $t1,number2(index2)
		beq $t1,43,signo_multiplicador			 
		beq $t1,45,signo_multiplicador
		b loop100
		
signo_multiplicador:
		move $s3,$t1					#movemos a $s3 el signo que guarde $t1
		beq $s3,$s4,signos_iguales
		bne $s3,$s4,signos_distintos
signos_iguales:
		la $a0,posi
		li $v0,4
		syscall
		b fin
signos_distintos:
		la $a0,nega
		li $v0,4
		syscall
fin:		
		la $a0,salto
		li $v0,4
		syscall
		
		la $a0,respuesta
		li $v0,4
		syscall
		
		li $v0,10
		syscall