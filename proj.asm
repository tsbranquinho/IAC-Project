; *********************************************************************
; * IST-UL, 2022/2023
; * Introdução à Arquitetura de Computadores
; * Projeto do Jogo "Beyond Mars"
; *
; * IST 1106630 - Diogo Almada
; * IST 1106635 - Tiago Branquinho
; * IST 1107059 - Pedro Loureiro
; *
; * Descrição: Entrega intermédia.

; **********************************************************************
; ************************** CONSTANTES ********************************
; **********************************************************************
DISPLAYS     EQU 0A000H  							; endereço dos displays de 7 segmentos (periférico POUT-1)
TEC_LIN      EQU 0C000H  							; endereço das linhas do teclado (periférico POUT-2)
TEC_COL      EQU 0E000H  							; endereço das colunas do teclado (periférico PIN)
ZERO         EQU 0
TECLA_UM     EQU 1
TECLA_QUATRO EQU 4
TECLA_CINCO  EQU 5
TECLA_SEIS   EQU 6
TECLA_SETE   EQU 7
TECLA_C    	 EQU 0CH
MASCARA      EQU 0FH     							; para isolar os 4 bits de menor peso, ao ler as colunas do teclado

COMANDOS				EQU	6000H				; endereço de base dos comandos do MediaCenter

DEFINE_LINHA    		EQU COMANDOS + 0AH		; endereço do comando para definir a linha
DEFINE_COLUNA   		EQU COMANDOS + 0CH		; endereço do comando para definir a coluna
DEFINE_PIXEL    		EQU COMANDOS + 12H		; endereço do comando para escrever um pixel
APAGA_AVISO     		EQU COMANDOS + 40H		; endereço do comando para apagar o aviso de nenhum cenário selecionado
APAGA_ECRÃ	 			EQU COMANDOS + 02H		; endereço do comando para apagar todos os pixels já desenhados
SELECIONA_CENARIO_FUNDO EQU COMANDOS + 42H		; endereço do comando para selecionar uma imagem de fundo
SELECIONA_VIDEO_FUNDO   EQU COMANDOS + 48H		; endereço do comando para selecionar um vídeo de fundo
SELECIONA_ESTADO_VID	EQU COMANDOS + 52H		; endereço do comando para selecionar o estado do vídeo
REPRODUZ		    	EQU COMANDOS + 5AH		; endereço do comando para tocar um som


LINHA_NAVE        	EQU 26      				; linha da nave (primeira linha)
COLUNA_NAVE			EQU 23       				; coluna da nave (primeira coluna)
LARGURA_NAVE		EQU	17						; largura da nave
ALTURA_NAVE			EQU 6						; altura da nave

LINHA_TIRO       	EQU 25        				; linha da sonda (primeira linha)
COLUNA_TIRO			EQU 31       				; coluna da sonda (primeira coluna)
LIMITE_SONDA        EQU 12

LINHA_AST        	EQU 0       				; linha do asteroide (primeira linha)
COLUNA_AST			EQU 0       				; coluna do asteroide (primeira coluna)
LARGURA_AST			EQU	5						; largura do asteroide
ALTURA_AST			EQU 5						; altura do asteroide



MIN_COLUNA			EQU  0						; número da coluna mais à esquerda que o objeto pode ocupar
MAX_COLUNA			EQU  63     				; número da coluna mais à direita que o objeto pode ocupar
ATRASO				EQU	400H					; atraso para limitar a velocidade de movimento do boneco

				
COR_TIRO			EQU 0FF00H					
BRANCO              EQU 0FFFFH
AZUL_ESCURO         EQU 0F00AH
AZUL_CLARO			EQU 0A07FH
VERDE_ESCURO        EQU 0F0A0H
VERDE_CLARO         EQU 0F2C0H
AMARELO             EQU 0FFF0H
PRETO 				EQU 0F000H


; **********************************************************************
; ******************************* DADOS ********************************
; **********************************************************************
	PLACE       1000H

    STACK 100H            		      ; espaço reservado para o programa principal
SP_inicial_principal:                 

	STACK 100H						  ; espaço reservado para o processo de leitura do teclado
SP_inicial_teclado:

	STACK 100H						  ; espaço reservado para o processo de movimento do asteróide
SP_inicial_ast:

	STACK 100H                        ; espaço reservado para o processo de energia
SP_inicial_energia:

	STACK 100H						  ; espaço reservado para o processo de movimento da sonda
SP_inicial_sonda:

tecla_carregada:
	LOCK 0							  ; forma do teclado comunicar com os outros processos

evento_int:
	LOCK 0	
	LOCK 0
	LOCK 0
	LOCK 0						  ; forma da rotina de interrupção comunicar com o boneco


tab:
	WORD rot_ast					  ; rotina de atendimento da interrupção dos asteróides
	WORD rot_sonda				      ; rotina de atendimento da interrupção das sondas
	WORD rot_energia				  ; rotina de atendimento da interrupção da energia (display)
	WORD 0				  ; rotina de atendimento da interrupção da nave

energia_total:
	WORD 0					  ; energia da nave

estado_jogo:
    WORD 0                    ; estado do jogo 
						      ;	0 - ecrã inicial, 
							  ; 1 - jogo a decorrer,
							  ; 2 - jogo pausado,
							  ; 3 - jogo terminado

DEF_NAVE:							  ; tabela que define o boneco (cor, largura, pixels)
	WORD		0, 0, 0, 0, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, 0, 0, 0, 0
	WORD 		0, 0, PRETO, PRETO, PRETO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, PRETO, PRETO, PRETO, 0, 0
	WORD 		0, 0, PRETO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, VERDE_ESCURO, VERDE_ESCURO, VERDE_ESCURO, VERDE_ESCURO, VERDE_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, PRETO, 0, 0
	WORD 		PRETO, PRETO, PRETO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, VERDE_ESCURO, VERDE_ESCURO, VERDE_ESCURO, VERDE_ESCURO, VERDE_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, PRETO, PRETO, PRETO
	WORD		PRETO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, PRETO
	WORD		PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO
	
DEF_AST:
	WORD		LARGURA_AST, ALTURA_AST
	WORD 		0, VERDE_ESCURO, VERDE_ESCURO, VERDE_ESCURO, 0
	WORD 		VERDE_ESCURO, VERDE_CLARO, VERDE_CLARO, VERDE_CLARO, VERDE_ESCURO
	WORD 		VERDE_ESCURO, VERDE_CLARO, VERDE_CLARO, VERDE_CLARO, VERDE_ESCURO         
	WORD 		VERDE_ESCURO, VERDE_CLARO, VERDE_CLARO, VERDE_CLARO, VERDE_ESCURO
	WORD 		0, VERDE_ESCURO , VERDE_ESCURO, VERDE_ESCURO, 0
	
DEF_TIRO:
	WORD 		LINHA_TIRO, COLUNA_TIRO
	WORD		COR_TIRO
						
; **********************************************************************
; ***************************** CÓDIGO *********************************
; **********************************************************************
	PLACE 0
inicio:


	MOV  SP, SP_inicial_principal	  ; inicializa SP para a palavra a seguir
									  ; à última da pilha
	MOV  BTE, tab					  ; inicializa BTE


; inicializações

    MOV  R2, TEC_LIN   				  ; endereço do periférico das linhas
    MOV  R3, TEC_COL   				  ; endereço do periférico das colunas
    MOV  R4, DISPLAYS  				  ; endereço do periférico dos displays
    MOV  R5, MASCARA   				  ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
	MOV  R7, ZERO					  ; iniciar o R7 a zero
	MOV  R8, LINHA_AST				  ; registo com a linha do pixel de referencia asteroide
	MOV  R9, COLUNA_AST 			  ; registo com a coluna do pixel de referencia asteroide
	MOV  R10, LINHA_TIRO			  ; registo com a linha do tiro
	MOV  [R4], R7					  ; reseta os displays
	MOV  [estado_jogo], R7			  ; estado do jogo - ecrã inicial
                            

; corpo principal do programa

cenario_inicial: 
	MOV  [APAGA_AVISO], R1			  ; apaga o aviso de nenhum cenário selecionado (o valor de R1 não é relevante)
    MOV  [APAGA_ECRÃ], R1			  ; apaga todos os pixels já desenhados (o valor de R1 não é relevante)
	MOV  R1, 0                        ; cenário de fundo número 0
	MOV  [SELECIONA_CENARIO_FUNDO], R1; reproduz o vídeo número 0
	MOV  R11, 0						  ; registo com o valor inicial do display (depois estou a pensar mudar para -100)
	MOV  R1, 1   					  ; para guardar a linha que está a ser testada

	EI0								  ; ativa interrupção dos asteróides
	EI1							      ; ativa interrupção das sondas
	EI2								  ; ativa interrupção da energia (display)
								      ; ativa interrupção da nave
	EI								  ; ativa interrupções (geral)

	CALL teclado
	CALL energia
	CALL asteroide
	CALL sonda

espera_inicio:
	MOV R0, [tecla_carregada]
	MOV R1, TECLA_C
	CMP R0, R1
	JNZ espera_inicio
	MOV R0, [estado_jogo]
	ADD R0, 1
	MOV [estado_jogo], R0

setup:

	MOV  [APAGA_AVISO], R1			  ; apaga o aviso de nenhum cenário selecionado (o valor de R1 não é relevante)
    MOV  [APAGA_ECRÃ], R1			  ; apaga todos os pixels já desenhados (o valor de R1 não é relevante)
	MOV  R1, 0                        ; vídeo número 0
	MOV  [REPRODUZ], R1				  ; reproduz o vídeo número 0
	MOV	 R7, 1						  ; valor a somar à coluna do boneco, para o movimentar
	MOV  R11, 100					  ; valor do display inicial do jogo
	MOV [energia_total], R11		  ; valor da energia total
	CALL mostra_display				  ; mostra o valor da energia total no display
      
	CALL desenha_nave
	CALL desenha_ast

ciclo:
	MOV R1, 1
    ;MOV [R4], R11      				  ; escreve linha e coluna a zero nos displays

obtem_tecla:
	MOV R0, [tecla_carregada]
	CALL verifica_tecla
	JMP ciclo

mostra_display: 
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R5
	PUSH R6
	PUSH R7
	MOV R1, 0
	MOV R11, [energia_total]
	MOV R7, R11
	MOV R2, 1000
	MOV R5, 10
	JMP converte_decimal

verifica_tecla:		
	MOV R6, TECLA_QUATRO
	CMP R6, R0					  	  ; testa se a tecla premida é a 4
	JZ aumenta_display			  	  ; incrementa o valor do display
  
	MOV R6, TECLA_CINCO
	CMP R6, R0					  	  ; testa se a tecla premida é a 5				
	JZ diminui_display			  	  ; decrementa o valor do display
	  
	RET  	

aumenta_display:
	MOV R11, [energia_total]
	ADD R11, 1	
	MOV [energia_total], R11
	RET  
	 			  
diminui_display:
	MOV R11, [energia_total]			  
	SUB R11, 1						  ; decrementa o valor do display
	MOV [energia_total], R11					  ; escreve no periférico do display
	RET

converte_decimal:
	MOD R7, R2 						  ;passo 1
	DIV R2, R5 						  ;passo 2
	MOV R6, R2
	;SUB R6, 5
	;SUB R6, 5
	CMP R6, 1
	JLT escreve_display 			  ;passo 3
	MOV R3, R7
	DIV R3, R2 						  ;passo 4
	SHL R1, 4 						  ;passo 5
	OR R1, R3 						  ;passo 6
	JMP converte_decimal

escreve_display:
	MOV [R4], R1					  ; escreve no periférico do display
	POP R7
	POP R6
	POP R5
	POP R3
	POP R2
	POP R1
	RET	

; *****************************************************************
; ***************************** NAVE ******************************
; *****************************************************************
desenha_nave:
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4
	PUSH R5
	PUSH R6
	MOV R1, LINHA_NAVE				  ; primeira linha da nave
	MOV R2, COLUNA_NAVE		  		  ; primeira coluna da nave
	MOV R4, DEF_NAVE				  ; tabela que define a nave
	MOV R5, LARGURA_NAVE			  ; copia a largura da nave
	MOV R6, ALTURA_NAVE				  ; copia a altura da nave
	JMP linha_seguinte				  ; começa a desenhar a nave
	
ciclo_nave:							  ; altera os valores para desenhar a próxima linha da nave
	MOV R2, COLUNA_NAVE				  ; primeira coluna da nave
	MOV R5, LARGURA_NAVE			  ; repor a largura da nave
	ADD R1, 1						  ;	troca a linha em que se está a desenhar 
	SUB R6, 1						  ; decrementa o número de linhas que faltam desenhar
	JNZ linha_seguinte				  ; se ainda não desenhou todas as linhas, continua a desenhar
	POP R6							  ; repõe todos os valores nos seus registos
	POP R5
	POP R4
	POP R3
	POP R2
	POP R1
	RET								  ; volta quando terminou de desenhar a nave

linha_seguinte:						  ; passa para a próxima linha
	CALL desenha_pixels
	JMP ciclo_nave
	

PROCESS SP_inicial_teclado            ; indicação do início do processo do teclado

teclado:
	MOV  R1, 1   					  ; para guardar a linha que está a ser testada
    MOV  R2, TEC_LIN   				  ; endereço do periférico das linhas
    MOV  R3, TEC_COL   				  ; endereço do periférico das colunas~

espera_tecla:          			  	  ; neste ciclo espera-se até uma tecla ser premida

	YIELD                             ; ciclo potencialmente bloqueante
	
    ROL R1, 1				  
    MOVB [R2], R1      				  ; escrever no periférico de saída (linhas)
    MOVB R0, [R3]      				  ; ler do periférico de entrada (colunas)
    AND  R0, R5        				  ; elimina bits para além dos bits 0-3
    CMP  R0, ZERO       			  ; há tecla premida?
    JZ   espera_tecla  				  ; se nenhuma tecla premida, repete
									  ; vai mostrar a linha e a coluna da tecla
				  
	CALL converte_valor				  ; converte o valor da linha e guarda no R7
    SHL R7, 4         				  ; coloca linha no nibble high
	MOV R6, R7		   				  ; copia o novo valor da linha para o R6
	MOV R1, R0		   				  ; copia a coluna para o R1
	CALL converte_valor				  ; reseta o contador (R7)
	MOV R0, R7						  ; copia o novo valor da coluna para o R0
	CALL conv_hexa					  ; converte a tecla premida para um valor hexadecimal
	MOV [tecla_carregada], R6		  ; guarda o valor da tecla premida
	  
ha_tecla:              			  	  ; neste ciclo espera-se até NENHUMA tecla estar premida

	YIELD							  ; ciclo potencialmente bloqueante
    MOVB R0, [R3]      			  	  ; ler do periférico de entrada (colunas)
    AND  R0, R5        			  	  ; elimina bits para além dos bits 0-3
    CMP  R0, ZERO         			  ; há tecla premida?
    JNZ  ha_tecla      			  	  ; se ainda houver uma tecla premida, espera até não haver
    JMP  teclado         		      ; volta a testar se alguma tecla foi premida
  
converte_valor:					  	  ; transforma o valor das linhas e colunas para 0,1,2,3
	MOV R7, ZERO	   			  	  ; reseta o contador a zero

valor_ciclo:		  	  
	ADD R7, 1					  	  ; soma um ao contador
	SHR R1, 1           		  	  ; diminui o valor da linha
	JNZ valor_ciclo  			  	  ; continua enquanto a linha não for zero
	SUB R7, 1					  	  ; subtrai 1 ao valor do contador para o valor ficar certo
	RET		  	  
  
conv_hexa:		  	  
	SHR R6, 2           		  	  ; divide o valor da linha por 4
	ADD R6, R0          		  	  ; adiciona o valor da coluna e guarda no R6
	RET		  	  


; ****************************************************************
; *************************** PIXELS *****************************
; ****************************************************************
escreve_pixel:
	MOV  [DEFINE_LINHA], R1			  ; seleciona a linha
	MOV  [DEFINE_COLUNA], R2		  ; seleciona a coluna
	MOV  [DEFINE_PIXEL], R3			  ; altera a cor do pixel na linha e coluna já selecionadas
	RET

desenha_pixels:       				  ; desenha os pixels do boneco a partir da tabela
	MOV	R3, [R4]					  ; obtém a cor do próximo pixel do boneco
	CALL	escreve_pixel			  ; escreve cada pixel do boneco
	ADD	R4, 2						  ; endereço da cor do próximo pixel (2 porque cada cor de pixel é uma word)
    ADD  R2, 1               		  ; próxima coluna
    SUB  R5, 1						  ; menos uma coluna para tratar
    JNZ  desenha_pixels      		  ; continua até percorrer toda a largura do objeto
	RET
	
apaga_pixels:       				  ; desenha os pixels do boneco a partir da tabela
	MOV	 R3, 0						  ; cor para apagar o próximo pixel do boneco
	CALL escreve_pixel			      ; escreve cada pixel do boneco
    ADD  R2, 1               		  ; próxima coluna
    SUB  R5, 1						  ; menos uma coluna para tratar
    JNZ  apaga_pixels      		  	  ; continua até percorrer toda a largura do objeto
	RET

PROCESS SP_inicial_energia

energia:
	MOV R1, [evento_int + 4]
	MOV R10, [estado_jogo]
	CMP R10, 1
	JNZ energia
	MOV R11, [energia_total]
	SUB R11, 3
	MOV [energia_total], R11
	CALL mostra_display               ; atualiza valor do display
	JMP energia


PROCESS SP_inicial_ast         		  ; indicação do início do processo do ast

asteroide:
	MOV R1, [evento_int]			  ; espera a interrupção ativar
	MOV R10, [estado_jogo]			  ; copia o estado de jogo para o R10
	CMP R10, 1						  ; verifica se está a jogar
	JNZ asteroide					  ; se não estiver volta ao asteróide
	CALL desenha_ast

ciclo_asteroide:
	MOV R1, [evento_int]
	CALL move_ast
	JMP ciclo_asteroide



; ****************************************************************
; ************************* ASTERÓIDE ****************************
; ****************************************************************

valores_ast:
	MOV R1, R8						  ; copia a linha do pixel de referência do asteroide
	MOV R2, R9						  ; copia a coluna do pixel de referência do asteroide
	MOV R4, DEF_AST					  ; guarda em R4 o design da nave
	MOV R5, [R4]					  ; guarda em R5 a largura da nave
	ADD R4, 2
	MOV R6, [R4]				      
	ADD R4, 2						  ; guarda em R6 a altura da nave
	RET
	
desenha_ast:
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4
	PUSH R5
	PUSH R6
	PUSH R9
	CALL valores_ast
	
ciclo_desenha_ast:					  ; altera os valores para desenhar a próxima linha do asteroide
	CALL desenha_pixels
	MOV R2, R9					  	  ; copia a coluna do pixel de referência do asteroide
	MOV R5, LARGURA_AST				  ; repõe a largura do asteroide
	ADD R1, 1						  ;	troca a linha em que se está a desenhar
	SUB R6, 1						  ; decrementa o número de linhas que faltam desenhar
	JNZ ciclo_desenha_ast			  ; repete o ciclo até desenhar todas as linhas do asteroide
	POP R9							  ; repõe todos os valores nos seus registos
	POP R6							  
	POP R5
	POP R4
	POP R3
	POP R2
	POP R1
	RET								  ; volta quando terminou de desenhar o asteroide

move_ast:							  ; rotina responsável por mover o asteroide
	CALL apaga_ast			
	ADD R8, 1						  ; modifica a coluna de referencia para o desenho do asteroide
	ADD R9, 1						  ; modifica a linha de referencia para o desenho do asteroide
	CALL desenha_ast
	MOV    R7, 1            		  ; som com número 0
    MOV [REPRODUZ], R7       		  ; comando para tocar o som
	RET
	
	
apaga_ast:
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4
	PUSH R5
	PUSH R6
	PUSH R9
	CALL valores_ast
	
ciclo_apaga_ast:
	CALL apaga_pixels
	MOV R2, R9						  ; copia a coluna do pixel de referência do asteroide
	MOV R5, LARGURA_AST				  ; largura do asteroide
	ADD R1, 1						  ;	troca a linha em que se está a desenhar
	SUB R6, 1						  ; decrementa o número de linhas que faltam desenhar
	JNZ ciclo_apaga_ast				  ; repete até apagar todo o asteroide
	POP R9							  ; repõe todos os valores nos seus registos
	POP R6						
	POP R5
	POP R4
	POP R3
	POP R2
	POP R1
	RET								  ; volta quando terminou de desenhar o asteróide

	


PROCESS SP_inicial_sonda              ; indicação do início do processo do ast

sonda:
	MOV R0, [tecla_carregada]
	CMP R0, TECLA_UM
	JNZ sonda
	MOV R4, 1
	MOV R9, LINHA_TIRO 
	CALL desenha_tiro

ciclo_sonda:
	MOV R1, [evento_int + 2]
	MOV R10, [estado_jogo]
	CMP R10, 1
	JNZ sonda
	CALL verifica_limite
	CMP R4, 0
	JZ sonda
	CALL move_tiro
	JMP ciclo_sonda

verifica_limite:
	MOV R8, LIMITE_SONDA
	CMP R8, 0
	JZ limite_maximo
	RET
	
limite_maximo:
	MOV R4, 0
	CALL apaga_tiro
	RET
; *****************************************************************
; **************************** TIRO *******************************
; *****************************************************************

desenha_tiro:
	MOV R1, R9    			          ; guardar em R1 o valor associado a linha onde está o tiro
	MOV R2, COLUNA_TIRO     		  ; guardar em R2 o valor associado a coluna onde está o tiro
	MOV R3, COR_TIRO				  ; guardar em R3 o valor associado a cor da sonda
	CALL escreve_pixel
	RET

move_tiro:							  ; faz com o que o tiro suba no ecrã
	CALL apaga_tiro
	SUB R9, 1     			  		  ; decrementa o valor da linha do tiro
	CALL desenha_tiro
	RET
	
apaga_tiro:
	MOV R3, ZERO					  ; guarda o valor 0 em R3
	CALL escreve_pixel
	RET

;***************************************************************************************************
rot_ast:
	PUSH R1
	MOV [evento_int], R1
	POP R1
	RFE

rot_sonda:
	PUSH R1
	MOV [evento_int + 2], R1
	POP R1
	RFE

rot_energia:
	PUSH R1
	MOV [evento_int + 4], R1
	POP R1
	RFE

rot_nave:
	RFE