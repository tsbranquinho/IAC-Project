; ******************************************************************************
; * IST-UL, 2022/2023
; * Introdução à Arquitetura de Computadores
; * Projeto do Jogo "Beyond Mars"
; *
; * IST 1106630 - Diogo Almada
; * IST 1106635 - Tiago Branquinho
; * IST 1107059 - Pedro Loureiro
; *
; * Descrição: Entrega final



; ******************************************************************************
; ******************************** CONSTANTES **********************************
; ******************************************************************************

DISPLAYS     EQU 0A000H  							; endereço dos displays de 7 segmentos (periférico POUT-1)
TEC_LIN      EQU 0C000H  							; endereço das linhas do teclado (periférico POUT-2)
TEC_COL      EQU 0E000H  							; endereço das colunas do teclado (periférico PIN)
ZERO         EQU 0
TECLA_ZERO   EQU 0
TECLA_UM     EQU 1
TECLA_DOIS   EQU 2
TECLA_QUATRO EQU 4
TECLA_CINCO  EQU 5
TECLA_SEIS   EQU 6
TECLA_SETE   EQU 7
COLISAO_NAVE EQU 23
ULTIMA_LINHA EQU 32
TECLA_C    	 EQU 0CH
TECLA_D      EQU 0DH
MASCARA      EQU 0FH     							; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
MASCARA_2    EQU 00FFH

COMANDOS				EQU	6000H				; endereço de base dos comandos do MediaCenter

DEFINE_LINHA    		EQU COMANDOS + 0AH		; endereço do comando para definir a linha
DEFINE_COLUNA   		EQU COMANDOS + 0CH		; endereço do comando para definir a coluna
DEFINE_PIXEL    		EQU COMANDOS + 12H		; endereço do comando para escrever um pixel
APAGA_AVISO     		EQU COMANDOS + 40H		; endereço do comando para apagar o aviso de nenhum cenário selecionado
APAGA_ECRÃ	 			EQU COMANDOS + 02H		; endereço do comando para apagar todos os pixels já desenhados
SELECIONA_CENARIO_FUNDO EQU COMANDOS + 42H		; endereço do comando para selecionar uma imagem de fundo
APAGA_CENARIO_FUNDO     EQU COMANDOS + 44H		; endereço do comando para apagar a imagem de fundo
COLOCA_CENARIO_FRONTAL  EQU COMANDOS + 46H		; endereço do comnando para colocar um cenário frontal
SELECIONA_VIDEO_FUNDO   EQU COMANDOS + 48H		; endereço do comando para selecionar um vídeo de fundo
SELECIONA_ESTADO_VID	EQU COMANDOS + 52H		; endereço do comando para selecionar o estado do vídeo
REPRODUZ		    	EQU COMANDOS + 5AH		; endereço do comando para tocar um som/vídeo
PAUSA                   EQU COMANDOS + 5EH      ; endereço do comando para pausar um som/vídeo
CONTINUA                EQU COMANDOS + 60H      ; endereço do comando para continuar um som/vídeo


LINHA_NAVE        	EQU 26      				; linha da nave (primeira linha)
COLUNA_NAVE			EQU 23       				; coluna da nave (primeira coluna)
LARGURA_NAVE		EQU	17						; largura da nave
ALTURA_NAVE			EQU 6						; altura da nave

LINHA_TIRO       	EQU 25        				; linha da sonda (primeira linha)
COLUNA_TIRO			EQU 31       				; coluna da sonda (primeira coluna)
LIMITE_SONDA        EQU LINHA_TIRO - 11			; limite da sonda
COLUNA_ESQUERDA     EQU COLUNA_TIRO - 5 		; coluna da sonda esquerda
COLUNA_DIREITA      EQU COLUNA_TIRO + 5			; coluna da sonda direita

LINHA_AST       	EQU 0       				; linha do asteroide (primeira linha)
COL_AST_ESQ			EQU 0       				; coluna do asteroide que aparece à esquerda (primeira coluna)
COL_AST_MEIO        EQU 29						; coluna do asteroide que aparece à meio (primeira coluna)
COL_AST_DIR         EQU 59						; coluna do asteroide que aparece à direita (primeira coluna)
LARGURA_AST			EQU	5						; largura do asteroide
ALTURA_AST			EQU 5						; altura do asteroide



MIN_COLUNA			EQU  0						; número da coluna mais à esquerda que o objeto pode ocupar
MAX_COLUNA			EQU  63     				; número da coluna mais à direita que o objeto pode ocupar
ATRASO				EQU	400H					; atraso para limitar a velocidade de movimento do boneco

				
COR_TIRO			EQU 0FFF0H					
BRANCO              EQU 0FFFFH
AZUL_ESCURO         EQU 0F00AH
AZUL_CLARO			EQU 0A07FH
VERDE_ESCURO        EQU 0F0A0H
VERDE_CLARO         EQU 0F2C0H
AMARELO             EQU 0FFF0H
VERMELHO		    EQU 0FF00H
LARANJA        	    EQU 0FF80H
ROSA				EQU 0FF9FH
ROXO			    EQU 0FB0FH
PRETO 				EQU 0F000H


; ******************************************************************************
; *********************************** DADOS ************************************
; ******************************************************************************
	PLACE       1000H

    STACK 100H            		      ; espaço reservado para o programa principal
SP_inicial_principal:                 

	STACK 100H						  ; espaço reservado para o processo de leitura do teclado
SP_inicial_teclado:

	STACK 100H						  ; espaço reservado para o processo de movimento do asteróide 1
SP_inicial_ast1:

	STACK 100H						  ; espaço reservado para o processo de movimento do asteróide 2
SP_inicial_ast2:

	STACK 100H						  ; espaço reservado para o processo de movimento do asteróide 3
SP_inicial_ast3:

	STACK 100H						  ; espaço reservado para o processo de movimento do asteróide 4
SP_inicial_ast4:

	STACK 100H                        ; espaço reservado para o processo de energia
SP_inicial_energia:

	STACK 100H						  ; espaço reservado para o processo de movimento da sonda central
SP_inicial_sonda_central:

	STACK 100H						  ; espaço reservado para o processo de movimento da sonda esquerda
SP_inicial_sonda_esquerda:

	STACK 100H						  ; espaço reservado para o processo de movimento da sonda direita
SP_inicial_sonda_direita:

	STACK 100H						  ; espaço reservado para o processo da nave
SP_inicial_nave:

tecla_carregada:
	LOCK 0							  ; forma do teclado comunicar com os outros processos

tecla_0_carregada:
	LOCK 0

tecla_1_carregada:
	LOCK 0

tecla_2_carregada:
	LOCK 0

evento_int:
	LOCK 0	
	LOCK 0
	LOCK 0
	LOCK 0						  ; forma da rotina de interrupção comunicar com o boneco


tab:
	WORD rot_ast					  ; rotina de atendimento da interrupção dos asteróides
	WORD rot_sonda				      ; rotina de atendimento da interrupção das sondas
	WORD rot_energia				  ; rotina de atendimento da interrupção da energia (display)
	WORD rot_nave				  	  ; rotina de atendimento da interrupção da nave

energia_total:
	WORD 0					  ; energia da nave

estado_jogo:
    WORD 0                    ; estado do jogo 
						      ;	0 - ecrã inicial, 
							  ; 1 - jogo a decorrer,
							  ; 2 - jogo pausado,
							  ; 3 - jogo terminado

nave_atual:
	WORD 0					  ; nave atual (0-7)

asteroide1:
	WORD 0					  ; sítio onde nasce asteróide 1 (0-5) (5 significa já andou 1 vez ou não existe)
	WORD 0                    ;	tipo de asteróide

asteroide2:
	WORD 0					  ; sítio onde nasce asteróide 2 (0-5) (5 significa já andou 1 vez ou não existe)
	WORD 0                    ;	tipo de asteróide

asteroide3:
	WORD 0					  ; sítio onde nasce asteróide 3 (0-5) (5 significa já andou 1 vez ou não existe)
	WORD 0                    ;	tipo de asteróide

asteroide4:
	WORD 0					  ; sítio onde nasce asteróide 4 (0-5) (5 significa já andou 1 vez )
	WORD 0                    ;	tipo de asteróide

DEF_NAVE_0:					  ; tabela que define o boneco (cor, largura, pixels)
	WORD		0, 0, 0, 0, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, 0, 0, 0, 0
	WORD 		0, 0, PRETO, PRETO, PRETO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, PRETO, PRETO, PRETO, 0, 0
	WORD 		0, 0, PRETO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, ROXO, AZUL_CLARO, PRETO, VERDE_CLARO, BRANCO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, PRETO, 0, 0
	WORD 		PRETO, PRETO, PRETO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, VERMELHO, AMARELO, PRETO, LARANJA, ROSA, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, PRETO, PRETO, PRETO
	WORD		PRETO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, PRETO
	WORD		PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO

DEF_NAVE_1:
	WORD 		0, 0, 0, 0, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, 0, 0, 0, 0
	WORD 		0, 0, PRETO, PRETO, PRETO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, PRETO, PRETO, PRETO, 0, 0
	WORD 		0, 0, PRETO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AMARELO, VERDE_CLARO, PRETO, BRANCO, ROXO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, PRETO, 0, 0
	WORD 		PRETO, PRETO, PRETO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, VERMELHO, LARANJA, PRETO, ROSA, AZUL_CLARO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, PRETO, PRETO, PRETO
	WORD 		PRETO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, PRETO
	WORD 		PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO

DEF_NAVE_2:
	WORD 		0, 0, 0, 0, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, 0, 0, 0, 0
	WORD 		0, 0, PRETO, PRETO, PRETO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, PRETO, PRETO, PRETO, 0, 0
	WORD 		0, 0, PRETO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, ROSA, BRANCO, PRETO, LARANJA, AZUL_CLARO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, PRETO, 0, 0
	WORD 		PRETO, PRETO, PRETO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, VERDE_CLARO, AMARELO, PRETO, VERMELHO, ROXO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, PRETO, PRETO, PRETO
	WORD 		PRETO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, PRETO
	WORD 		PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO

DEF_NAVE_3:
	WORD 		0, 0, 0, 0, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, 0, 0, 0, 0
	WORD 		0, 0, PRETO, PRETO, PRETO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, PRETO, PRETO, PRETO, 0, 0
	WORD 		0, 0, PRETO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, LARANJA, VERMELHO, PRETO, BRANCO, AZUL_CLARO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, PRETO, 0, 0
	WORD 		PRETO, PRETO, PRETO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AMARELO, VERDE_CLARO, PRETO, ROSA, ROXO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, PRETO, PRETO, PRETO
	WORD 		PRETO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, PRETO
	WORD 		PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO

DEF_NAVE_4:
	WORD 		0, 0, 0, 0, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, 0, 0, 0, 0
	WORD 		0, 0, PRETO, PRETO, PRETO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, PRETO, PRETO, PRETO, 0, 0
	WORD 		0, 0, PRETO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, VERDE_CLARO, AMARELO, PRETO, BRANCO, AZUL_CLARO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, PRETO, 0, 0
	WORD 		PRETO, PRETO, PRETO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, ROXO, AZUL_CLARO, PRETO, LARANJA, VERMELHO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, PRETO, PRETO, PRETO
	WORD 		PRETO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, PRETO
	WORD 		PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO

DEF_NAVE_5:
	WORD 		0, 0, 0, 0, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, 0, 0, 0, 0
	WORD 		0, 0, PRETO, PRETO, PRETO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, PRETO, PRETO, PRETO, 0, 0
	WORD 		0, 0, PRETO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AMARELO, LARANJA, PRETO, BRANCO, AZUL_CLARO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, PRETO, 0, 0
	WORD 		PRETO, PRETO, PRETO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, VERDE_CLARO, VERMELHO, PRETO, ROSA, ROXO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, PRETO, PRETO, PRETO
	WORD 		PRETO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, PRETO
	WORD 		PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO

DEF_NAVE_6:
	WORD 		0, 0, 0, 0, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, 0, 0, 0, 0
	WORD 		0, 0, PRETO, PRETO, PRETO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, PRETO, PRETO, PRETO, 0, 0
	WORD 		0, 0, PRETO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, BRANCO, VERMELHO, PRETO, LARANJA, AMARELO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, PRETO, 0, 0
	WORD 		PRETO, PRETO, PRETO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, VERDE_CLARO, AZUL_CLARO, PRETO, ROSA, ROXO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, PRETO, PRETO, PRETO
	WORD 		PRETO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, PRETO
	WORD 		PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO

DEF_NAVE_7:
	WORD 		0, 0, 0, 0, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, 0, 0, 0, 0
	WORD 		0, 0, PRETO, PRETO, PRETO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, PRETO, PRETO, PRETO, 0, 0
	WORD 		0, 0, PRETO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, ROXO, AMARELO, PRETO, LARANJA, VERMELHO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, PRETO, 0, 0
	WORD 		PRETO, PRETO, PRETO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, VERDE_CLARO, BRANCO, PRETO, AZUL_CLARO, ROSA, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, PRETO, PRETO, PRETO
	WORD 		PRETO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, PRETO
	WORD 		PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO

	
DEF_AST:
	WORD		LARGURA_AST, ALTURA_AST
	WORD 		0, VERDE_ESCURO, VERDE_ESCURO, VERDE_ESCURO, 0
	WORD 		VERDE_ESCURO, VERDE_ESCURO, VERDE_CLARO, VERDE_ESCURO, VERDE_ESCURO
	WORD 		VERDE_ESCURO, VERDE_CLARO, VERDE_CLARO, VERDE_CLARO, VERDE_ESCURO         
	WORD 		VERDE_ESCURO, VERDE_ESCURO, VERDE_CLARO, VERDE_ESCURO, VERDE_ESCURO
	WORD 		0, VERDE_ESCURO , VERDE_ESCURO, VERDE_ESCURO, 0

	
DEF_ASTE:
	WORD		LARGURA_AST, ALTURA_AST
	WORD 		0, VERMELHO, VERMELHO, VERMELHO, 0
	WORD 		VERMELHO, 0, VERMELHO, 0, VERMELHO
	WORD 		VERMELHO, VERMELHO, 0, VERMELHO, VERMELHO       
	WORD 		VERMELHO, 0, VERMELHO, 0, VERMELHO
	WORD 		0, VERMELHO, VERMELHO, VERMELHO, 0
	
DEF_ASTE_EXPLOSAO:
	WORD		LARGURA_AST, ALTURA_AST
	WORD 		VERMELHO, 0, 0, 0, VERMELHO
	WORD 		0, VERMELHO, 0, VERMELHO, 0
	WORD 		0, 0, VERMELHO, 0, 0       
	WORD 		0, VERMELHO, 0, VERMELHO, 0
	WORD 		VERMELHO, 0, 0, 0, VERMELHO


DEF_TIRO:
	WORD 		LINHA_TIRO, COLUNA_TIRO
	WORD		COR_TIRO
						
; ******************************************************************************
; ********************************** CÓDIGO ************************************
; ******************************************************************************
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
	MOV  R9, COL_AST_ESQ 			  ; registo com a coluna do pixel de referencia asteroide
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
	EI3							      ; ativa interrupção da nave
	EI								  ; ativa interrupções (geral)

	CALL teclado
	CALL energia
	CALL asteroide_um
	CALL asteroide_dois
	CALL asteroide_tres
	CALL asteroide_quatro
	CALL sonda_central
	CALL sonda_esquerda
	CALL sonda_direita
	CALL nave

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
    
	MOV R7, DEF_NAVE_0				  ; endereço do boneco
	MOV R11, 0						  ; valor da nave atual
	MOV [nave_atual], R11			  ; guarda o valor da nave atual
	MOV R11, 5                        ; não há asteroides
	MOV [asteroide1], R11			  ; guarda o valor do asteroide 1
	MOV [asteroide2], R11			  ; guarda o valor do asteroide 2
	MOV [asteroide3], R11			  ; guarda o valor do asteroide 3
	MOV [asteroide4], R11			  ; guarda o valor do asteroide 4
	CALL desenha_nave				  ; desenha a nave

ciclo:
	MOV R1, 1
    ;MOV [R4], R11      				  ; escreve linha e coluna a zero nos displays

obtem_tecla:
	MOV R0, [tecla_carregada]
	MOV R11, [estado_jogo]
	CMP R11, 1
	JZ  call_verifica_tecla
	CMP R11, 2
	JZ  call_estado_pausa
	JMP ciclo

call_verifica_tecla:
	CALL verifica_tecla
	JMP ciclo

call_estado_pausa:
	CALL verifica_tecla_pausa
	JMP ciclo

verifica_tecla:	

	MOV R6, TECLA_ZERO
	CMP R6, R0
	JZ  ativa_tecla_0

	MOV R6, TECLA_UM
	CMP R6, R0
	JZ  ativa_tecla_1

	MOV R6, TECLA_DOIS
	CMP R6, R0
	JZ  ativa_tecla_2

	MOV R6, TECLA_D
	CMP R6, R0
	JZ  pausa_jogo
	  
	RET  

verifica_tecla_pausa:

	MOV R6, TECLA_D
	CMP R6, R0
	JZ  retoma_jogo

	RET

ativa_tecla_0:
	PUSH R1
	MOV  [tecla_0_carregada], R1
	POP  R1
	RET

ativa_tecla_1:
	PUSH R1
	MOV  [tecla_1_carregada], R1
	POP  R1
	RET

ativa_tecla_2:
	PUSH R1
	MOV  [tecla_2_carregada], R1
	POP  R1
	RET

pausa_jogo:
	MOV  R11, 2
	MOV  [estado_jogo], R11
	MOV  [APAGA_AVISO], R1			   ; apaga o aviso de nenhum cenário selecionado (o valor de R1 não é relevante)
	MOV  R1, 0                         ; vídeo número 0
	MOV  [PAUSA], R1				   ; reproduz o vídeo número 0
	MOV  R1, 1						   ; imagem número 1
	MOV  [COLOCA_CENARIO_FRONTAL], R1 ; reproduz a imagem número 1
	JMP  ciclo

retoma_jogo:
	MOV  R11, 1
	MOV  [estado_jogo], R11
	MOV  [APAGA_AVISO], R1			   ; apaga o aviso de nenhum cenário selecionado (o valor de R1 não é relevante)
	MOV  R1, 1						   ; imagem número 1
	MOV  [APAGA_CENARIO_FUNDO], R1     ; apaga a imagem número 1
	MOV  R1, 0                         ; vídeo número 0
	MOV  [CONTINUA], R1				   ; continua a reproduzir o vídeo número 0
	JMP  ciclo

; ******************************************************************************
; ******************************** DISPLAY *************************************
; ******************************************************************************

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

converte_decimal:
	MOD R7, R2 						  ;passo 1
	DIV R2, R5 						  ;passo 2
	MOV R6, R2
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


; ******************************************************************************
; ********************************* TECLADO ************************************
; ******************************************************************************

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


; ******************************************************************************
; *********************************** NAVE *************************************
; ******************************************************************************

PROCESS SP_inicial_nave

nave:
	MOV R1, [evento_int + 6]
	MOV R11, [estado_jogo]
	CMP R11, 1
	JNZ nave
	MOV R10, [nave_atual]
	CMP R10, 7
	JZ  mudar_nave_7
	ADD R10, 1
	MOV [nave_atual], R10
	JMP lidar_casos_nave
	
mudar_nave_7:
	MOV R10, 0                         ; volta a nave 0
	MOV [nave_atual], R10
	JMP lidar_casos_nave

lidar_casos_nave:
	CMP R10, 0
	JZ  caso_nave_0
	CMP R10, 1
	JZ  caso_nave_1
	CMP R10, 2
	JZ  caso_nave_2
	CMP R10, 3
	JZ  caso_nave_3
	CMP R10, 4
	JZ  caso_nave_4
	CMP R10, 5
	JZ  caso_nave_5
	CMP R10, 6
	JZ  caso_nave_6
	CMP R10, 7
	JZ  caso_nave_7

caso_nave_0:
	MOV R7, DEF_NAVE_0
	CALL desenha_nave
	JMP nave

caso_nave_1:
	MOV R7, DEF_NAVE_1
	CALL desenha_nave
	JMP nave

caso_nave_2:
	MOV R7, DEF_NAVE_2
	CALL desenha_nave
	JMP nave

caso_nave_3:
	MOV R7, DEF_NAVE_3
	CALL desenha_nave
	JMP nave

caso_nave_4:
	MOV R7, DEF_NAVE_4
	CALL desenha_nave
	JMP nave

caso_nave_5:
	MOV R7, DEF_NAVE_5
	CALL desenha_nave
	JMP nave

caso_nave_6:
	MOV R7, DEF_NAVE_6
	CALL desenha_nave
	JMP nave

caso_nave_7:
	MOV R7, DEF_NAVE_7
	CALL desenha_nave
	JMP nave

desenha_nave:
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4
	PUSH R5
	PUSH R6
	MOV R1, LINHA_NAVE				  ; primeira linha da nave
	MOV R2, COLUNA_NAVE		  		  ; primeira coluna da nave
	MOV R4, R7				  		  ; tabela que define as naves
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

; ******************************************************************************
; ********************************* PIXELS *************************************
; ******************************************************************************
escreve_pixel:
	MOV  [DEFINE_LINHA], R1			  ; seleciona a linha
	MOV  [DEFINE_COLUNA], R2		  ; seleciona a coluna
	MOV  [DEFINE_PIXEL], R3			  ; altera a cor do pixel na linha e coluna já selecionadas
	RET

desenha_pixels:       				  ; desenha os pixels do boneco a partir da tabela
	MOV	 R3, [R4]					  ; obtém a cor do próximo pixel do boneco
	CALL escreve_pixel			      ; escreve cada pixel do boneco
	ADD	 R4, 2						  ; endereço da cor do próximo pixel (2 porque cada cor de pixel é uma word)
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


; ******************************************************************************
; ********************************** ENERGIA ***********************************
; ******************************************************************************

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

; ******************************************************************************
; *************************** PSEUDO-ALEATÓRIO *********************************
; ******************************************************************************

aleatorio:
	PUSH R0
	PUSH R1
	PUSH R9
	;R10 vai guardar o tipo de asteróide
	;R11 vai guardar o número/posição inicial do asteróide
	MOV  R0, [TEC_COL]                  ; ler do periférico do PIN
	MOV  R9, MASCARA_2            
	AND  R0, R9				    		; isolar os 8 bits de menor peso
	SHR  R0, 4						    ; isolar os bits 7 a 4
	MOV  R1, R0						    ; copiar para R1
	SHR  R0, 2						    ; isolar os bits de menor peso
	MOV  R10, R0					    ; copiar para R10 (tipo de asteróide)
									    ; 0 - minerável
										; 1, 2, 3 - não minerável
	CALL numero_de_asteroide
	POP  R9
	POP  R1
	POP  R0
	RET

numero_de_asteroide:
	MOV  R9, 5							; 5 possibilidades de posição
	MOD  R1, R9						    ; gerar um número entre 0 e 5
	MOV  R11, R1					    ; copiar para R11 (número/posição inicial do asteróide)
	CALL verifica_asteroide
	RET

procura_linear:
	CMP  R11, 4
	JZ   caso_4
	ADD  R11, 1
	JMP verifica_asteroide

caso_4:
	MOV  R11, 0

verifica_asteroide:
	MOV  R9,  [asteroide1]
	CMP  R11, R9
	JZ   procura_linear

	MOV  R9,  [asteroide2]
	CMP  R11, R9
	JZ   procura_linear

	MOV  R9,  [asteroide3]
	CMP  R11, R9
	JZ   procura_linear

	MOV  R9,  [asteroide4]
	CMP  R11, R9
	JZ   procura_linear
	RET

; ******************************************************************************
; ****************************** ASTERÓIDES ************************************
; ******************************************************************************


;reinicia_ast:
;	CALL apaga_ast					  ; se não move o asteróide mais uma linha
;	MOV R8, COL_AST_ESQ				  ; reinicia a coluna inicial em que o asteróide será desenhado
;	MOV R9, LINHA_AST				  ; reinicia a linha incial em que o asteróide será desenhado
;	JMP asteroide_um				  ; volta ao ciclo para reiniciar o movimento do asteróide


;	MOV R0, 23						  ; move o valor da linha em que o asteróide colide com a nave
;	CMP R9, R0						  ; ver se o asteróide colidiu com a nave
;   JZ reinicia_ast				      ; se colidiu reinicia o asteróide
;
;	PROCESSO PARA REINICIAR ASTEROIDES 1 e 3

; *************************** PROCESSOS ASTEROIDES ************************************


; R0 guarda o valor adicionado á coluna
; asteroide 0 --------> 1
; asteroides 1, 2 e 3 -> 0
; asteroide 4 --------> -1

; R8 FICA COM A LINHA DO PIXEL DE REFERENCIA INICIAL DO ASTEROIDE 
; sempre 0 porque começa sempre na primeira linha

; R9 FICA COM A COLUNA DO PIXEL DE REFERENCIA INICIAL DO ASTEROIDE
; asteroide 0 --------> 0
; asteroides 1, 2 e 3 -> 29
; asteroide 4 --------> 59

; R10 - minerável ou não (0, 1, 2 ou 3)
; R11 - sítio onde nasce (0, 1, 2, 3 ou 4)


PROCESS SP_inicial_ast1         	  ; indicação do início do processo do asteroide 1

asteroide_um:
	MOV R7, [evento_int]		  	  ; espera a interrupção ativar
	MOV R10, [estado_jogo]			  ; copia o estado de jogo para o R10
	CMP R10, 1						  ; verifica se está a jogar
	JNZ asteroide_um				  ; se não estiver volta ao asteróide
	CALL escolhe_asteroide
	CALL escolhe_col_ast
	CALL escolhe_tipo_ast
	MOV [asteroide1], R11			  ; guarda o sítio onde nasce o asteroide
	MOV [asteroide1+2], R10		      ; guarda o tipo de asteroide
	MOV R8, LINHA_AST				  ; guarda NO R8 a linha que vai começar (linha 0 sempre)
	CALL desenha_ast1
	JMP ciclo_asteroide1

desenha_ast1:
	MOV R1, R8						  ; copia a linha do pixel de referência do asteroide
	MOV R2, R9						  ; copia a coluna do pixel de referência do asteroide
	PUSH R1
	PUSH R2
	PUSH R4
	PUSH R6
	MOV R5, [R4]					  ; guarda em R5 a largura do asteróide
	ADD R4, 2						  ; altera o R4 para guardar o endereço da altura do asteróide
	MOV R6, [R4]				      ; guarda no R6 a altura do asteróide
	ADD R4, 2						  ; altera o R4 para guardar o endereço das cores do asteróide
	
ciclo_desenha_ast1:					  ; altera os valores para desenhar a próxima linha do asteroide
	CALL desenha_pixels
	MOV R2, R9					  	  ; copia a coluna do pixel de referência do asteroide
	MOV R5, LARGURA_AST				  ; repõe a largura do asteroide
	ADD R1, 1						  ;	troca a linha em que se está a desenhar
	SUB R6, 1						  ; decrementa o número de linhas que faltam desenhar
	JNZ ciclo_desenha_ast1			  ; repete o ciclo até desenhar todas as linhas do asteroide
	POP R6
	POP R4
	POP R2
	POP R1
	RET								  ; volta quando terminou de desenhar o asteroide

ciclo_asteroide1:
    MOV R11, [evento_int]             ; espera a interrupção ativar
    MOV R10, [estado_jogo]            ; copia o estado de jogo para o R10
    CMP R10, 1                        ; verifica se está a jogar
	MOV R10, [asteroide1]             ; copia o sítio onde nasce o asteroide
	MOV R10, 5						  ; definir que o asteroide está em andamento
	MOV [asteroide1], R10			  ; guarda na memória o estado do asteroide
    JNZ ciclo_asteroide1              ; se não estiver volta ao ciclo
    CALL move_ast1					  ; se estiver move o asteróide uma linha
	CALL verifica_fundo				  ; verifica se chegou ao fundo da tela
	CALL verifica_colisoes
	CMP R10, 1						  ; chegar ao fundo (valor 1)
	JZ  asteroide_um				  ; se chegou ao fundo
	JMP ciclo_asteroide1			  ; se não chegou fim volta para o ciclo para continuar a descer o asteróide

move_ast1:							  ; rotina responsável por mover o asteroide
	CALL push_function1		
	ADD R8, 1						  ; modifica a linha de referencia para o desenho do asteroide
	ADD R9, R0						  ; modifica a coluna de referencia para o desenho do asteroide
	CALL desenha_ast1
	RET
	
push_function1:
	PUSH R1
	PUSH R2
	PUSH R5
	PUSH R6
	PUSH R8
	MOV  R1, R8						  ; copia a linha do pixel de referência do asteroide
	MOV R6, ALTURA_AST
apaga_ast1:
	MOV R2, R9						  ; copia a coluna do pixel de referência do asteroide
	MOV R5, LARGURA_AST				  ; largura do asteroide
	CALL apaga_pixels
	ADD R1, 1						  ;	troca a linha em que se está a desenhar
	SUB R6, 1						  ; decrementa o número de linhas que faltam desenhar
	JNZ apaga_ast1				  	  ; repete até apagar todo o asteroide
	POP R8
	POP R6
	POP R5
	POP R2
	POP R1
	RET								  ; volta quando terminou de desenhar o asteróide




PROCESS SP_inicial_ast2         	  ; indicação do início do processo do asteroide 1

asteroide_dois:
	MOV R7, [evento_int]		  	  ; espera a interrupção ativar
	MOV R10, [estado_jogo]			  ; copia o estado de jogo para o R10
	CMP R10, 1						  ; verifica se está a jogar
	JNZ asteroide_dois				  ; se não estiver volta ao asteróide
	CALL escolhe_asteroide
	CALL escolhe_col_ast
	CALL escolhe_tipo_ast
	MOV [asteroide2], R11			  ; guarda o sítio onde nasce o asteroide
	MOV [asteroide2+2], R10		      ; guarda o tipo de asteroide
	MOV R8, LINHA_AST				  ; guarda NO R8 a linha que vai começar (linha 0 sempre)
	CALL desenha_ast2
	JMP ciclo_asteroide2

desenha_ast2:
	MOV R1, R8						  ; copia a linha do pixel de referência do asteroide
	MOV R2, R9						  ; copia a coluna do pixel de referência do asteroide
	PUSH R1
	PUSH R2
	PUSH R4
	PUSH R6
	MOV R5, [R4]					  ; guarda em R5 a largura do asteróide
	ADD R4, 2						  ; altera o R4 para guardar o endereço da altura do asteróide
	MOV R6, [R4]				      ; guarda no R6 a altura do asteróide
	ADD R4, 2						  ; altera o R4 para guardar o endereço das cores do asteróide
	
ciclo_desenha_ast2:					  ; altera os valores para desenhar a próxima linha do asteroide
	CALL desenha_pixels
	MOV R2, R9					  	  ; copia a coluna do pixel de referência do asteroide
	MOV R5, LARGURA_AST				  ; repõe a largura do asteroide
	ADD R1, 1						  ;	troca a linha em que se está a desenhar
	SUB R6, 1						  ; decrementa o número de linhas que faltam desenhar
	JNZ ciclo_desenha_ast2			  ; repete o ciclo até desenhar todas as linhas do asteroide
	POP R6
	POP R4
	POP R2
	POP R1
	RET								  ; volta quando terminou de desenhar o asteroide

ciclo_asteroide2:
    MOV R11, [evento_int]             ; espera a interrupção ativar
    MOV R10, [estado_jogo]            ; copia o estado de jogo para o R10
    CMP R10, 1                        ; verifica se está a jogar
	MOV R10, [asteroide2]             ; copia o sítio onde nasce o asteroide
	MOV R10, 5						  ; definir que o asteroide está em andamento
	MOV [asteroide2], R10			  ; guarda na memória o estado do asteroide
    JNZ ciclo_asteroide2              ; se não estiver volta ao ciclo
    CALL move_ast2					  ; se estiver move o asteróide uma linha
	CALL verifica_fundo			      ; verifica se o asteroide chegou ao fim do ecrã
	CMP R10, 1					      ; 
	JZ  asteroide_dois
	JMP ciclo_asteroide2			  ; se não colidiu volta para o ciclo para continuar a descer o asteróide

move_ast2:							  ; rotina responsável por mover o asteroide
	CALL push_function2		
	ADD R8, 1						  ; modifica a linha de referencia para o desenho do asteroide
	ADD R9, R0						  ; modifica a coluna de referencia para o desenho do asteroide
	CALL desenha_ast2
	RET
	
push_function2:
	PUSH R1
	PUSH R2
	PUSH R5
	PUSH R6
	PUSH R8
	MOV  R1, R8						  ; copia a linha do pixel de referência do asteroide
	MOV R6, ALTURA_AST
apaga_ast2:
	MOV R2, R9						  ; copia a coluna do pixel de referência do asteroide
	MOV R5, LARGURA_AST				  ; largura do asteroide
	CALL apaga_pixels
	ADD R1, 1						  ;	troca a linha em que se está a desenhar
	SUB R6, 1						  ; decrementa o número de linhas que faltam desenhar
	JNZ apaga_ast2				  	  ; repete até apagar todo o asteroide
	POP R8
	POP R6
	POP R5
	POP R2
	POP R1
	RET								  ; volta quando terminou de desenhar o asteróide



PROCESS SP_inicial_ast3     	  ; indicação do início do processo do asteroide 3
asteroide_tres:
	MOV R7, [evento_int]		  	  ; espera a interrupção ativar
	MOV R10, [estado_jogo]			  ; copia o estado de jogo para o R10
	CMP R10, 1						  ; verifica se está a jogar
	JNZ asteroide_tres				  ; se não estiver volta ao asteróide
	CALL escolhe_asteroide
	CALL escolhe_col_ast
	CALL escolhe_tipo_ast
	MOV [asteroide3], R11			  ; guarda o sítio onde nasce o asteroide
	MOV [asteroide3+2], R10		      ; guarda o tipo de asteroide
	MOV R8, LINHA_AST				  ; guarda NO R8 a linha que vai começar (linha 0 sempre)
	CALL desenha_ast3
	JMP ciclo_asteroide3

desenha_ast3:
	MOV R1, R8						  ; copia a linha do pixel de referência do asteroide
	MOV R2, R9						  ; copia a coluna do pixel de referência do asteroide
	PUSH R1
	PUSH R2
	PUSH R4
	PUSH R6
	MOV R5, [R4]					  ; guarda em R5 a largura do asteróide
	ADD R4, 2						  ; altera o R4 para guardar o endereço da altura do asteróide
	MOV R6, [R4]				      ; guarda no R6 a altura do asteróide
	ADD R4, 2						  ; altera o R4 para guardar o endereço das cores do asteróide
	

ciclo_desenha_ast3:					  ; altera os valores para desenhar a próxima linha do asteroide
	CALL desenha_pixels
	MOV R2, R9					  	  ; copia a coluna do pixel de referência do asteroide
	MOV R5, LARGURA_AST				  ; repõe a largura do asteroide
	ADD R1, 1						  ;	troca a linha em que se está a desenhar
	SUB R6, 1						  ; decrementa o número de linhas que faltam desenhar
	JNZ ciclo_desenha_ast3			  ; repete o ciclo até desenhar todas as linhas do asteroide
	POP R6
	POP R4
	POP R2
	POP R1
	RET								  ; volta quando terminou de desenhar o asteroide

ciclo_asteroide3:
    MOV R11, [evento_int]             ; espera a interrupção ativar
    MOV R10, [estado_jogo]            ; copia o estado de jogo para o R10
    CMP R10, 1                        ; verifica se está a jogar
	MOV R10, [asteroide3]             ; copia o sítio onde nasce o asteroide
	MOV R10, 5						  ; definir que o asteroide está em andamento
	MOV [asteroide3], R10			  ; guarda na memória o estado do asteroide
    JNZ ciclo_asteroide3              ; se não estiver volta ao ciclo
    CALL move_ast3					  ; se estiver move o asteróide uma linha
	CALL verifica_fundo			      ; verifica se o asteroide chegou ao fim do ecrã
	CMP R10, 1					      
	JZ  asteroide_tres
	JMP ciclo_asteroide3			  ; se não colidiu volta para o ciclo para continuar a descer o asteróide

move_ast3:							  ; rotina responsável por mover o asteroide
	CALL push_function3	
	ADD R8, 1						  ; modifica a linha de referencia para o desenho do asteroide
	ADD R9, R0						  ; modifica a coluna de referencia para o desenho do asteroide
	CALL desenha_ast3
	RET
	
push_function3:
	PUSH R1
	PUSH R2
	PUSH R5
	PUSH R6
	PUSH R8
	MOV  R1, R8						  ; copia a linha do pixel de referência do asteroide
	MOV R6, ALTURA_AST
apaga_ast3:
	MOV R2, R9						  ; copia a coluna do pixel de referência do asteroide
	MOV R5, LARGURA_AST				  ; largura do asteroide
	CALL apaga_pixels
	ADD R1, 1						  ;	troca a linha em que se está a desenhar
	SUB R6, 1						  ; decrementa o número de linhas que faltam desenhar
	JNZ apaga_ast3				  	  ; repete até apagar todo o asteroide
	POP R8
	POP R6
	POP R5
	POP R2
	POP R1
	RET								  ; volta quando terminou de desenhar o asteróide

PROCESS SP_inicial_ast4         	  ; indicação do início do processo do asteroide 4

asteroide_quatro:
	MOV R7, [evento_int]		  	  ; espera a interrupção ativar
	MOV R10, [estado_jogo]			  ; copia o estado de jogo para o R10
	CMP R10, 1						  ; verifica se está a jogar
	JNZ asteroide_quatro				  ; se não estiver volta ao asteróide
	CALL escolhe_asteroide
	CALL escolhe_col_ast
	CALL escolhe_tipo_ast
	MOV [asteroide4], R11			  ; guarda o sítio onde nasce o asteroide
	MOV [asteroide4+2], R10		      ; guarda o tipo de asteroide
	MOV R8, LINHA_AST				  ; guarda NO R8 a linha que vai começar (linha 0 sempre)
	CALL desenha_ast4
	JMP ciclo_asteroide4

desenha_ast4:
	MOV R1, R8						  ; copia a linha do pixel de referência do asteroide
	MOV R2, R9						  ; copia a coluna do pixel de referência do asteroide
	PUSH R1
	PUSH R2
	PUSH R4
	PUSH R6
	MOV R5, [R4]					  ; guarda em R5 a largura do asteróide
	ADD R4, 2						  ; altera o R4 para guardar o endereço da altura do asteróide
	MOV R6, [R4]				      ; guarda no R6 a altura do asteróide
	ADD R4, 2						  ; altera o R4 para guardar o endereço das cores do asteróide
	
ciclo_desenha_ast4:					  ; altera os valores para desenhar a próxima linha do asteroide
	CALL desenha_pixels
	MOV R2, R9					  	  ; copia a coluna do pixel de referência do asteroide
	MOV R5, LARGURA_AST				  ; repõe a largura do asteroide
	ADD R1, 1						  ;	troca a linha em que se está a desenhar
	SUB R6, 1						  ; decrementa o número de linhas que faltam desenhar
	JNZ ciclo_desenha_ast4			  ; repete o ciclo até desenhar todas as linhas do asteroide
	POP R6
	POP R4
	POP R2
	POP R1
	RET								  ; volta quando terminou de desenhar o asteroide

ciclo_asteroide4:
    MOV R11, [evento_int]             ; espera a interrupção ativar
    MOV R10, [estado_jogo]            ; copia o estado de jogo para o R10
    CMP R10, 1                        ; verifica se está a jogar
	MOV R10, [asteroide4]             ; copia o sítio onde nasce o asteroide
	MOV R10, 5						  ; definir que o asteroide está em andamento
	MOV [asteroide4], R10			  ; guarda na memória o estado do asteroide
    JNZ ciclo_asteroide4              ; se não estiver volta ao ciclo
    CALL move_ast4					  ; se estiver move o asteróide uma linha
	CALL verifica_fundo			      ; verifica se o asteroide chegou ao fim do ecrã
	CMP R10, 1
	JZ  asteroide_quatro
	JMP ciclo_asteroide4			  ; se não colidiu volta para o ciclo para continuar a descer o asteróide

move_ast4:							  ; rotina responsável por mover o asteroide
	CALL push_function4		
	ADD R8, 1						  ; modifica a linha de referencia para o desenho do asteroide
	ADD R9, R0						  ; modifica a coluna de referencia para o desenho do asteroide
	CALL desenha_ast4
	RET
	
push_function4:
	PUSH R1
	PUSH R2
	PUSH R5
	PUSH R6
	PUSH R8
	MOV  R1, R8						  ; copia a linha do pixel de referência do asteroide
	MOV R6, ALTURA_AST
apaga_ast4:
	MOV R2, R9						  ; copia a coluna do pixel de referência do asteroide
	MOV R5, LARGURA_AST				  ; largura do asteroide
	CALL apaga_pixels
	ADD R1, 1						  ;	troca a linha em que se está a desenhar
	SUB R6, 1						  ; decrementa o número de linhas que faltam desenhar
	JNZ apaga_ast4				  	  ; repete até apagar todo o asteroide
	POP R8
	POP R6
	POP R5
	POP R2
	POP R1
	RET								  ; volta quando terminou de desenhar o asteróide




escolhe_asteroide:	
	CALL aleatorio					  ; gera um asteroide aleatoriamente
	; FALTA MOVER PARA A MEMORIA OS VALORES DE R10 e R11
	; TALVEZ TENHA DE IR PARA DENTRO DOS PROCESSOS
	RET

escolhe_col_ast:
	CMP R11, 0						  ; verifica se o asteroide vai nascer na esquerda (anda para a direita)
	JZ valores_ast_0
	CMP R11, 1						  ; verifica se o asteroide vai nascer no meio (anda para a esquerda)
	JZ valores_ast_1
	CMP R11, 2						  ; verifica se o asteroide vai nascer no meio (anda para baixo só)
	JZ valores_ast_2
	CMP R11, 3						  ; verifica se o asteroide vai nascer no meio (anda para a direita)
	JZ valores_ast_3			    
	CMP R11, 4						  ; verifica se o asteroide vai nascer na direita (anda para a esquerda)
	JZ valores_ast_4					  

valores_ast_0:
	MOV R9, COL_AST_ESQ
	MOV R0, 1
	RET

valores_ast_4:
	MOV R9, COL_AST_DIR
	MOV R0, -1
	RET

valores_ast_2:
	MOV R9, COL_AST_MEIO
	MOV R0, 0 
	RET

valores_ast_3:
	MOV R9, COL_AST_MEIO
	MOV R0, 1
	RET

valores_ast_1:
	MOV R9, COL_AST_MEIO
	MOV R0, -1
	RET


escolhe_tipo_ast:
	CMP R10, 0
	JZ ast_mineravel
	MOV R4, DEF_ASTE
	RET

ast_mineravel:
	MOV R4, DEF_AST
	RET
	
verifica_fundo:
	MOV R7, ULTIMA_LINHA			  ; fundo da tela
	CMP R8, R7						  ; verifica se chegou ao fim da tela
	JZ chegou_ao_fundo				  ; se chegou ao fim volta a criar um asteroide aleatoriamente
	MOV R10, 0
	RET

chegou_ao_fundo:
	MOV R10, 1
	RET



; R0 guarda a posição do asteroide (1, 2, 3, 4 ou 5)
; R1 guarda o tipo do asteroide (1, 2, 3 ou 4)
; R11 guarda o endereço do inicio do projeto

verifica_colisoes:
	PUSH R0
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4
	PUSH R5
	PUSH R6
	PUSH R7
	PUSH R8
	PUSH R9
	PUSH R10
	PUSH R11

escolhe_colisoes:
	MOV R2, 2					; constante pra fazer o mod por 2
	MOD R0, R2					; mod por 2				
	CMP R0, 0					; se for zero (ast 0, 2 ou 4 --> podem bater na nave)
	CALL verifica_colisao_nave

fim_verificacao:
	POP R11
	POP R10
	POP R9
	POP R8
	POP R7
	POP R6
	POP R5
	POP R4
	POP R3
	POP R2
	POP R1
	POP R0
	; 		PODE POR-SE O VERIFICA FUNDO AQUI EM VEZ DA FUNÇÃO PRINCIPAL
	RET


verifica_colisao_nave:
	MOV R2, COLISAO_NAVE
	CMP R8, R2
	RET
	


; ******************************************************************************
; ********************************* SONDAS *************************************
; ******************************************************************************

PROCESS SP_inicial_sonda_central              ; indicação do início do processo da sonda central

sonda_central:
	MOV R0, [tecla_1_carregada]
	MOV R2, COLUNA_TIRO
	MOV R4, DISPLAYS
	MOV R5, R2
	MOV R6, 1								  ; indica que a sonda ainda não chegou ao limite
	MOV R9, LINHA_TIRO 
	MOV R10, 0                                ; indica o quanto a coluna varia
	MOV R11, [energia_total]
	SUB R11, 5
	MOV [energia_total], R11
	CALL mostra_display
	CALL desenha_tiro
	MOV R0, 1
	MOV [REPRODUZ], R0

ciclo_sonda:
	MOV R1, [evento_int + 2]
	MOV R11, [estado_jogo]
	CMP R11, 1
	JNZ ciclo_sonda
	CALL verifica_limite
	CMP R6, 0
	JZ sonda_central
	CALL move_tiro
	JMP ciclo_sonda

PROCESS SP_inicial_sonda_esquerda

sonda_esquerda:
	MOV R0, [tecla_0_carregada]
	MOV R4, DISPLAYS
	MOV R6, 1                                   ; indica que a sonda ainda não chegou ao limite
	MOV R9, LINHA_TIRO
	MOV R2, COLUNA_ESQUERDA
	MOV R5, R2
	MOV R10, -1                                 ; indica o quanto a coluna varia
	MOV R11, [energia_total]
	SUB R11, 5
	MOV [energia_total], R11
	CALL mostra_display
	CALL desenha_tiro
	MOV R0, 1
	MOV [REPRODUZ], R0

ciclo_sonda_esquerda:
	MOV R1, [evento_int + 2]
	MOV R11, [estado_jogo]
	CMP R11, 1
	JNZ ciclo_sonda_esquerda
	CALL verifica_limite
	CMP R6, 0
	JZ sonda_esquerda
	CALL move_tiro
	JMP ciclo_sonda_esquerda

PROCESS SP_inicial_sonda_direita

sonda_direita:
	MOV R0, [tecla_2_carregada]
	MOV R4, DISPLAYS
	MOV R6, 1									 ; indica que a sonda ainda não chegou ao limite
	MOV R9, LINHA_TIRO
	MOV R2, COLUNA_DIREITA
	MOV R5, R2
	MOV R10, 1									 ; indica o quanto a coluna varia 
	MOV R11, [energia_total]
	SUB R11, 5
	MOV [energia_total], R11
	CALL mostra_display
	CALL desenha_tiro
	MOV R0, 1
	MOV [REPRODUZ], R0
	
ciclo_sonda_direita:
	MOV R0, [evento_int + 2]
	MOV R11, [estado_jogo]
	CMP R11, 1
	JNZ ciclo_sonda_direita
	CALL verifica_limite
	CMP R6, 0
	JZ sonda_direita
	CALL move_tiro
	JMP ciclo_sonda_direita
	
verifica_limite:
	MOV R8, LIMITE_SONDA
	CMP R8, R9
	JZ limite_maximo
	RET
	
limite_maximo:
	MOV R6, 0
	CALL apaga_tiro
	RET

; ******************************************************************************
; *********************************** TIRO *************************************
; ******************************************************************************

desenha_tiro:
	MOV R1, R9    			          ; guardar em R1 o valor associado a linha onde está o tiro
	MOV R2, R5    		  			  ; guardar em R2 o valor associado a coluna onde está o tiro
	MOV R3, COR_TIRO				  ; guardar em R3 o valor associado a cor da sonda
	CALL escreve_pixel
	RET

move_tiro:							  ; faz com o que o tiro suba no ecrã
	CALL apaga_tiro
	SUB R9, 1     			  		  ; muda o valor da linha do tiro
	ADD R5, R10						  ; muda o valor da coluna do tiro
	CALL desenha_tiro
	RET

apaga_tiro:
	MOV R1, R9
	MOV R2, R5
	MOV R3, ZERO					  ; guarda o valor 0 em R3
	CALL escreve_pixel
	RET

; ******************************************************************************
; ******************************* INTERRUPÇÕES *********************************
; ******************************************************************************

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
	PUSH R1
	MOV [evento_int + 6], R1
	POP R1
	RFE