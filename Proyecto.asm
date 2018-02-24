start		EQU P0.2
					EOC 		EQU P0.1
					ALE			EQU	P0.0
					CLK			EQU	P0.3
					MIN   	EQU 66H
					ACT			EQU 67H
					MAX 		EQU	68H
					MINMAX	EQU	P3.0
					MUX			EQU	P3.1

					ORG 0000H
					JMP INICIO

					ORG 0003H
INTEX0:		ACALL SETMAX				;Llama a Configurar Temperatura Maxima
					SETB TR1
					SETB MUX						;Activa el ADC
					RETI

					ORG 0013H
INTEX1:				CPL MINMAX						;Complementa el 3.0 (Minimo o Maximo)
					RETI


					ORG 000Bh
INTTI0:			CPL CLK
					RETI



					ORG 0040H
INICIO:				;MOV SCON, #00100001B		;Temporizadores
					MOV IE, #10000111B			;Interrupciones
					;MOV IP, #00000010B			;Prioridad de Interrupciones
					MOV TMOD, #00100010B  				;Modo 1 del temporizador 1
					MOV TH1, #0CDH					;Timer 1 con recarga de (-50)
					MOV TL1, #0CDH					;Timer 1 con recarga de (-50)
					MOV TH0, #0A0H					;Timer 1 con recarga de (-50)
					MOV TL0, #0A0H					;Timer 1 con recarga de (-50)
					SETB IT0								;Interrupcion externa 0 por flanco
					SETB IT1								;Interrupcion externa 1 por flanco
					SETB MINMAX							;Prende la bandera de Maximo
					SETB MUX								;Activa el ADC

					SETB P3.5
					SETB P3.4

					MOV 60H, #1d			;MINIMA
					MOV 61H, #7d

					MOV 62H, #2d			;ACTUAL
					MOV 63H, #5d

					MOV 64H, #2d			;MAXIMA
					MOV 65H, #5d

					MOV R7, #00H			;Bandera de digitos

					MOV MIN, #17H				;Temp minima
					MOV ACT, #26H			;Temp actual
					MOV MAX,#25H			;Temp maxima

					CALL ESP15					;Espera
					MOV A, #38H					;Inicializacion de la pantalla
					ACALL SENDC
					ACALL SENDC
					ACALL SENDC
					MOV A, #01H
					ACALL SENDC
					MOV A, #00001100b
					ACALL SENDC
					MOV A, #'T'
					ACALL SENDTEX
					MOV A, #'e'
					ACALL SENDTEX
					MOV A, #'m'
					ACALL SENDTEX
					MOV A, #'p'
					ACALL SENDTEX
					MOV A, #'e'
					ACALL SENDTEX
					MOV A, #'r'
					ACALL SENDTEX
					MOV A, #'a'
					ACALL SENDTEX
					MOV A, #'t'
					ACALL SENDTEX
					MOV A, #'u'
					ACALL SENDTEX
					MOV A, #'r'
					ACALL SENDTEX
					MOV A, #'a'
					ACALL SENDTEX
					MOV A, #':'
					ACALL SENDTEX
					MOV R0, #62H						;Manda la direccion de memoria donde se almacena 'tempereatura actual'
					ACALL IMPTEMP						;Lama a la subrutina
					MOV A, #0DFH						;Simbolo de grados en ASCII
					ACALL SENDTEX
					MOV A, #'C'
					ACALL SENDTEX
					MOV A, #0C0H						;Salto de linea en el LCD
					ACALL SENDC

					;SEGUNDA PARTE
					MOV A, #'M'
					ACALL SENDTEX
					MOV A, #'i'
					ACALL SENDTEX
					MOV A, #'n'
					ACALL SENDTEX
					MOV A, #':'
					ACALL SENDTEX

					MOV R0, #60H					;Direccion de temperatura minima
					ACALL IMPTEMP

					MOV A, #0DFH
					ACALL SENDTEX
					MOV A, #' '
					ACALL SENDTEX

					MOV A, #'M'
					ACALL SENDTEX
					MOV A, #'a'
					ACALL SENDTEX
					MOV A, #'x'
					ACALL SENDTEX
					MOV A, #':'
					ACALL SENDTEX
					MOV R0, #64H			;Direccion de temperatura maxima
					ACALL IMPTEMP
					MOV A, #0DFH
					ACALL SENDTEX

					SETB TR1					;Activa el timer 1 para empezar a muestrear la temperatura
					SETB TR0
CICLO:		JB TF1, ACTU							;Espera a un interrupcion
					;JB INTT, SETMAX
					JMP CICLO

ACTU:			;CLR EX1
					CLR EX0						;Deshabilita temporalmente la interrupcion externa 0
					;CLR ET1
					ACALL MAINLOOP		;Manda a llamar a MAINLOOP que opera al ADC
					ACALL SETACT			;Llama a configurar temeratura ACTUAL
					MOV A, ACT				;Mueve al acumulador A la temperatura actual
REVMIN:		MOV B, MIN				;Mueve al acumulador B la temeratura minima
					DIV AB						;Divide Actual/Minima
					JNZ REVMAX				;Si A != 0 (Minima > Actual)
					CLR P3.5					;Activa el generador de calor
					LJMP REGR

REVMAX:		SETB P3.5					;Apaga el generador de calor
					MOV A, MAX				;Mueve al acuumulador A la temperatura MAXIMA
					MOV B, ACT				;Mueve al acumunlador B la temeratura actual
					DIV AB						;Divide maxima/actual
					JNZ REGR					;Si A != 0 (Actual < Maxima)
					CLR P3.4					;Prende el ventilador
					SETB EX0
					LJMP CICLO

REGR:			SETB EX0
					SETB P3.4									;Apaga el ventilador
					LJMP CICLO

SENDC:		CLR P3.7
					CLR P3.6
					MOV P2, A
					SETB P3.6
					CLR P3.6
					ACALL ESP15
					RET

SENDTEX:	MOV P2, A
					SETB P3.7
					CLR P3.6
					ACALL ESP15
					SETB P3.6
					ACALL ESP15
					CLR P3.6
					CLR P3.7
					ACALL ESP15
					INC R6
					RET

SETMAX:		CLR MUX
					;ACALL ESP15
					CLR TR1
					JNB MINMAX, SETMIN			;Si P3.0 es 0 salta a configurar minimo
					MOV R1, #MAX					;Manda a R1 la direccion de la temperatura maxima
					MOV R0, #64H					;Manda a R0 la direccion de los caracteres de la temeratura MAXIMA
					MOV A, #0C4H					;Manda a la pantalla la direccion del LCD donde se imprime Max
					ACALL SENDC
					ACALL RECCAR					;Llama a recibir caracter
					RET

SETMIN:		MOV R1, #MIN					;Mueve a R1 la direccion de la temeratura MINIMA
					MOV R0, #60H					;Mueve a R0 la direccion de los caracteres de la temperatura MINIMA
					MOV A, #0CCH					;Manda a la pantalla la direccion del LCD donde se imprime Min
					ACALL SENDC
					ACALL RECCAR					;Llama a recibir caracter
					RET

SETACT: 	ADD A, #0BEH
					//MOV 67H, A						;Mueve la temepratura ACTUAL en A
					MOV B, #0AH
					DIV AB
					MOV 62H, A						;Guarda Mueve al primer digito lo obtenido al primer digito de acutal
					MOV 63H, B
					SWAP A
					ADD A, B
					MOV 67H, A;Guarda Mueve al segundo digito lo obtenido al segundo digito de acutal
					MOV A, #8CH						;Mueve el puntero del LCD a donde se imorime actual
					ACALL SENDC						;Llama a mandar comando
					MOV R0, #62H
					ACALL IMPTEMP
					RET


RECCAR:				MOV A, P1								;Mueve al acumulador lo que entra del 922
					ANL A, #0FH
					CJNE R7, #01H, PRMDIG		;Si la banera de primer digito (R7) es 0 salta
					INC R0									;Si,no: Incrementa la direccion de R0 (para segundo caracter)
					MOV @R0, A							;Mueve el segundo digito recibido a la segunda direccion
					ADD A, R6								;Suma los acumuladores para obtener el numero total
					MOV @R1, A							;Mueve al apuntador de temepratura (R1) ese numero total
					MOV R7, #00H						;Borra bandera de primer digito
					DEC R0									;Decrementa el apuntador de caracter (R0) para imprimir los dos
					ACALL IMPTEMP						;Llama a imprimir temeratura
					CLR TR1
					CLR TF1
					ACALL ESP15
					ACALL ESP15
					SETB TR1
					RET

PRMDIG:		MOV @R0, A							;Mueve al apuntdor de caracter (R0) lo recibido
					SWAP A									;Cambia los nibbles para poder sumarlos posteriormente
					MOV R6, A								;Guarda ese numero en B temporalmente
					MOV R7, #01H						;Activa la bandera que indica que se recibio el primer caracter (R7)
					RET


IMPTEMP:			MOV A, @R0							;Mueve al acumulador el primer caracter guardado
					ADD A, #30H							;Añade 30 para cumplir con el codigo ASCII
					ACALL SENDTEX						;Lo imprime en pantalla
					INC R0									;Incrementa el apuntador para seleccionar el segundo caracter
					MOV A, @R0							;Mueve a A el segundo caracter
					ADD A, #30H							;Añade 30 para cumplir con el codigo ASCII
					ACALL SENDTEX						;Lo imprime en pantalla
					RET

MAINLOOP:			;Latch channel select
					SETB ALE
					;Start conversion
					SETB start
					ACALL ESP15
					CLR ALE
					CLR start

					;Wait for end of conversion
					JB EOC, $ ; $ means jump to same location
					JNB EOC, $
					; Read DataS
					MOV A, P1
					RET


ESP15:   	 		MOV R2, #25
C1:   		 		MOV R3, #255
C2:   		 		DJNZ R3, C2
						DJNZ R2, C1
						RET

FIN:				NOP
						END
