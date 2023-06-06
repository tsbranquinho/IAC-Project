; ******************************************************************************
; * IST-UL, 2022/2023
; * Introdução à Arquitetura de Computadores
; * Projeto do Jogo "Beyond Mars"
; *
; * IST 1106630 - Diogo Almada
; * IST 1106635 - Tiago Branquinho
; * IST 1107059 - Pedro Loureiro
; *
; * Descrição: Entrega intermédia.



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
TECLA_C    	 EQU 0CH
TECLA_D      EQU 0DH
MASCARA      EQU 0FH     							; para isolar os 4 bits de menor peso, ao ler as colunas do teclado

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


asteroide1:
	WORD 0					  ; asteróide 1 (0-5) (5 já andou 1 vez ou não nasceu)

asteroide2:
	WORD 0					  ; asteróide 2 (0-5) (5 já andou 1 vez ou não nasceu)

asteroide3:
	WORD 0					  ; asteróide 3 (0-5) (5 já andou 1 vez ou não nasceu)

asteroide4:
	WORD 0					  ; asteróide 4 (0-5) (5 já andou 1 vez ou não nasceu)


PLACE 0
inicio:

	MOV  SP, SP_inicial_principal	  ; inicializa SP para a palavra a seguir
									  ; à última da pilha



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
    MOV  R8, [asteroide1]
    MOV  R9, [asteroide2]
    MOV  R10, [asteroide3]
    MOV  R11, [asteroide4]
    MOV  R8, 2
    MOV  R9, 5
    MOV  R10, 1
    MOV  R11, 5
    MOV  [asteroide1], R8
    MOV  [asteroide2], R9
    MOV  [asteroide3], R10
    MOV  [asteroide4], R11
ciclo:
    CALL aleatorio
    JMP ciclo
; ******************************************************************************
; *************************** PSEUDO-ALEATÓRIO *********************************
; ******************************************************************************

aleatorio:
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
	;R10 vai guardar o tipo de asteróide
	;R11 vai guardar o número do asteróide
	MOV R0, [TEC_COL]                  ; ler do periférico do PIN
    MOV R9, 00FFH
    AND R0, R9
	SHR  R0, 4						    ; isolar os bits 7 a 4
	MOV  R1, R0						    ; copiar para R1
	SHR  R0, 2						    ; isolar os bits de menor peso
	MOV  R10, R0					    ; copiar para R10 (tipo de asteróide)
									    ; 0 - minerável
										; 1- não minerável
	CALL numero_de_asteroide
	POP  R9
	POP  R8
	POP  R7
	POP  R6
	POP  R5
	POP  R4
	POP  R3
	POP  R2
	POP  R1
	POP  R0
	RET

numero_de_asteroide:
    MOV  R9, 5
	MOD  R1, R9						    ; gerar um número entre 0 e 5
	MOV  R11, R1					    ; copiar para R11 (número do asteróide)
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
    MOV  R9, [asteroide1]
	CMP  R11, R9
	JZ   procura_linear
    MOV  R9, [asteroide2]
	CMP  R11, R9
	JZ   procura_linear
    MOV  R9, [asteroide3]
	CMP  R11, R9
	JZ   procura_linear
    MOV  R9, [asteroide4]
	CMP  R11, R9
	JZ   procura_linear
	RET