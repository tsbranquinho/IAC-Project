; ******************************************************************************
; * IST-UL, 2022/2023
; * Introdução à Arquitetura de Computadores
; * Projeto do Jogo "Beyond Mars"
; *
; * IST 1106630 - Diogo Almada
; * IST 1106635 - Tiago Branquinho
; * IST 1107059 - Pedro Loureiro
; *
; * Descrição: Entrega final do projeto



; ******************************************************************************
; ******************************** CONSTANTES **********************************
; ******************************************************************************

DISPLAYS     EQU 0A000H  						; endereço dos displays de 7 segmentos (periférico POUT-1)
TEC_LIN      EQU 0C000H  						; endereço das linhas do teclado (periférico POUT-2)
TEC_COL      EQU 0E000H  						; endereço das colunas do teclado (periférico PIN)
ZERO         EQU 0
TECLA_ZERO   EQU 0
TECLA_UM     EQU 1
TECLA_DOIS   EQU 2
TECLA_QUATRO EQU 4
TECLA_CINCO  EQU 5
TECLA_SEIS   EQU 6
TECLA_SETE   EQU 7
COLISAO_NAVE EQU 22
ULTIMA_LINHA EQU 32
TECLA_C    	 EQU 0CH
TECLA_D      EQU 0DH
TECLA_F      EQU 0FH
MASCARA      EQU 0FH     						; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
MASCARA_2    EQU 00FFH						    ; para isolar os 8 bits de menor peso, para a aleatoriedade
MASCARA_3    EQU 0003H                          ; para isolar os 2 bits de menor peso, para as colisões

COMANDOS				EQU	6000H				; endereço de base dos comandos do MediaCenter

SELECIONA_ECRA			EQU COMANDOS + 04H		; endereço do comando para selecionar o ecrã
DEFINE_LINHA    		EQU COMANDOS + 0AH		; endereço do comando para definir a linha
DEFINE_COLUNA   		EQU COMANDOS + 0CH		; endereço do comando para definir a coluna
DEFINE_PIXEL    		EQU COMANDOS + 12H		; endereço do comando para escrever um pixel
APAGA_AVISO     		EQU COMANDOS + 40H		; endereço do comando para apagar o aviso de nenhum cenário selecionado
APAGA_ECRÃ	 			EQU COMANDOS + 02H		; endereço do comando para apagar todos os pixels já desenhados
SELECIONA_CENARIO_FUNDO EQU COMANDOS + 42H		; endereço do comando para selecionar uma imagem de fundo
APAGA_CENARIO_FUNDO     EQU COMANDOS + 44H		; endereço do comando para apagar a imagem de fundo
COLOCA_CENARIO_FRONTAL  EQU COMANDOS + 46H		; endereço do comando para colocar um cenário frontal
SELECIONA_VIDEO_FUNDO   EQU COMANDOS + 48H		; endereço do comando para selecionar um vídeo de fundo
SELECIONA_ESTADO_VID	EQU COMANDOS + 52H		; endereço do comando para selecionar o estado do vídeo
METER_LOOP			    EQU COMANDOS + 58H	    ; endereço do comando para meter o vídeo em loop
REPRODUZ		    	EQU COMANDOS + 5AH		; endereço do comando para tocar um som/vídeo
PAUSA                   EQU COMANDOS + 5EH      ; endereço do comando para pausar um som/vídeo
CONTINUA                EQU COMANDOS + 60H      ; endereço do comando para continuar um som/vídeo
TERMINA                 EQU COMANDOS + 66H	    ; endereço do comando para terminar um som/vídeo


LINHA_NAVE        	EQU 26      				; linha da nave (primeira linha)
COLUNA_NAVE			EQU 23       				; coluna da nave (primeira coluna)
LARGURA_NAVE		EQU	17						; largura da nave
ALTURA_NAVE			EQU 6						; altura da nave

N_SONDAS			EQU 3
LINHA_SONDA       	EQU 25        				; linha da sonda (primeira linha)
COLUNA_sonda		EQU 31       				; coluna da sonda (primeira coluna)
LIMITE_SONDA        EQU LINHA_SONDA - 11		; limite da sonda
COLUNA_ESQUERDA     EQU COLUNA_sonda - 5 		; coluna da sonda esquerda
COLUNA_DIREITA      EQU COLUNA_sonda + 5		; coluna da sonda direita

N_ASTEROIDES		EQU 4
LINHA_AST       	EQU 0       				; linha do asteroide (primeira linha)
COL_AST_ESQ			EQU 0       				; coluna do asteroide que aparece à esquerda (primeira coluna)
COL_AST_MEIO        EQU 29						; coluna do asteroide que aparece à meio (primeira coluna)
COL_AST_DIR         EQU 59						; coluna do asteroide que aparece à direita (primeira coluna)
LARGURA_AST			EQU	5						; largura do asteroide
ALTURA_AST			EQU 5						; altura do asteroide

MIN_COLUNA			EQU  0						; número da coluna mais à esquerda que o objeto pode ocupar
MAX_COLUNA			EQU  63     				; número da coluna mais à direita que o objeto pode ocupar		   ***** TIRAR PROVAVELMENTE ESTAS 3 CONSTANTES ****
ATRASO				EQU	400H					; atraso para limitar a velocidade de movimento do boneco

				
COR_SONDA			EQU 0FFF0H					
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

	STACK 100H                        ; espaço reservado para o processo de energia
SP_inicial_energia:

	STACK 100H						  ; espaço reservado para o processo de movimento da sonda
SP_inicial_sonda:

	STACK 100H						  ; espaço reservado para o processo da nave
SP_inicial_nave:

	STACK 100H * 4					  ; espaço reservado para o processo dos asteroides
SP_inicial_asteroides:

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
	LOCK 0						  	  ; forma da rotina de interrupção comunicar com o boneco


tab:
	WORD rot_ast					  ; rotina de atendimento da interrupção dos asteróides
	WORD rot_sonda				      ; rotina de atendimento da interrupção das sondas
	WORD rot_energia				  ; rotina de atendimento da interrupção da energia (display)
	WORD rot_nave				  	  ; rotina de atendimento da interrupção da nave

energia_total:
	WORD 0					  		  ; energia da nave

estado_jogo:
    WORD 0                    		  ; estado do jogo 
						      		  ;	0 - ecrã inicial, 
							  		  ; 1 - jogo a decorrer,
							  		  ; 2 - jogo pausado,
							  		  ; 3 - jogo terminado
		  
nave_atual:		  
	WORD 0					  		  ; nave atual (0-7)


DEF_NAVE_0:							  ; tabela que define uma das variações de cores do painel
	WORD		0, 0, 0, 0, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, 0, 0, 0, 0
	WORD 		0, 0, PRETO, PRETO, PRETO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, PRETO, PRETO, PRETO, 0, 0
	WORD 		0, 0, PRETO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, ROXO, AZUL_CLARO, PRETO, VERDE_CLARO, BRANCO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, PRETO, 0, 0
	WORD 		PRETO, PRETO, PRETO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, VERMELHO, AMARELO, PRETO, LARANJA, ROSA, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, PRETO, PRETO, PRETO
	WORD		PRETO, AMARELO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AMARELO, PRETO
	WORD		PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO

DEF_NAVE_1:							  ; tabela que define uma das variações de cores do painel
	WORD 		0, 0, 0, 0, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, 0, 0, 0, 0
	WORD 		0, 0, PRETO, PRETO, PRETO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, PRETO, PRETO, PRETO, 0, 0
	WORD 		0, 0, PRETO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AMARELO, VERDE_CLARO, PRETO, BRANCO, ROXO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, PRETO, 0, 0
	WORD 		PRETO, PRETO, PRETO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, VERMELHO, LARANJA, PRETO, ROSA, AZUL_CLARO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, PRETO, PRETO, PRETO
	WORD 		PRETO, BRANCO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, BRANCO, PRETO
	WORD 		PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO

DEF_NAVE_2:							  ; tabela que define uma das variações de cores do painel
	WORD 		0, 0, 0, 0, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, 0, 0, 0, 0
	WORD 		0, 0, PRETO, PRETO, PRETO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, PRETO, PRETO, PRETO, 0, 0
	WORD 		0, 0, PRETO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, ROSA, BRANCO, PRETO, LARANJA, AZUL_CLARO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, PRETO, 0, 0
	WORD 		PRETO, PRETO, PRETO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, VERDE_CLARO, AMARELO, PRETO, VERMELHO, ROXO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, PRETO, PRETO, PRETO
	WORD 		PRETO, AMARELO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AMARELO, PRETO
	WORD 		PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO

DEF_NAVE_3:							  ; tabela que define uma das variações de cores do painel
	WORD 		0, 0, 0, 0, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, 0, 0, 0, 0
	WORD 		0, 0, PRETO, PRETO, PRETO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, PRETO, PRETO, PRETO, 0, 0
	WORD 		0, 0, PRETO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, LARANJA, VERMELHO, PRETO, BRANCO, AZUL_CLARO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, PRETO, 0, 0
	WORD 		PRETO, PRETO, PRETO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AMARELO, VERDE_CLARO, PRETO, ROSA, ROXO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, PRETO, PRETO, PRETO
	WORD 		PRETO, BRANCO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, BRANCO, PRETO
	WORD 		PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO

DEF_NAVE_4:							  ; tabela que define uma das variações de cores do painel
	WORD 		0, 0, 0, 0, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, 0, 0, 0, 0
	WORD 		0, 0, PRETO, PRETO, PRETO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, PRETO, PRETO, PRETO, 0, 0
	WORD 		0, 0, PRETO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, VERDE_CLARO, AMARELO, PRETO, BRANCO, AZUL_CLARO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, PRETO, 0, 0
	WORD 		PRETO, PRETO, PRETO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, ROXO, AZUL_CLARO, PRETO, LARANJA, VERMELHO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, PRETO, PRETO, PRETO
	WORD 		PRETO, AMARELO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AMARELO, PRETO
	WORD 		PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO

DEF_NAVE_5:							  ; tabela que define uma das variações de cores do painel
	WORD 		0, 0, 0, 0, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, 0, 0, 0, 0
	WORD 		0, 0, PRETO, PRETO, PRETO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, PRETO, PRETO, PRETO, 0, 0
	WORD 		0, 0, PRETO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AMARELO, LARANJA, PRETO, BRANCO, AZUL_CLARO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, PRETO, 0, 0
	WORD 		PRETO, PRETO, PRETO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, VERDE_CLARO, VERMELHO, PRETO, ROSA, ROXO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, PRETO, PRETO, PRETO
	WORD 		PRETO, BRANCO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, BRANCO, PRETO
	WORD 		PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO

DEF_NAVE_6:							  ; tabela que define uma das variações de cores do painel
	WORD 		0, 0, 0, 0, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, 0, 0, 0, 0
	WORD 		0, 0, PRETO, PRETO, PRETO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, PRETO, PRETO, PRETO, 0, 0
	WORD 		0, 0, PRETO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, BRANCO, VERMELHO, PRETO, LARANJA, AMARELO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, PRETO, 0, 0
	WORD 		PRETO, PRETO, PRETO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, VERDE_CLARO, AZUL_CLARO, PRETO, ROSA, ROXO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, PRETO, PRETO, PRETO
	WORD 		PRETO, AMARELO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AMARELO, PRETO
	WORD 		PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO

DEF_NAVE_7:							 ; tabela que define uma das variações de cores do painel
	WORD 		0, 0, 0, 0, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, 0, 0, 0, 0
	WORD 		0, 0, PRETO, PRETO, PRETO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, PRETO, PRETO, PRETO, 0, 0
	WORD 		0, 0, PRETO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, ROXO, AMARELO, PRETO, LARANJA, VERMELHO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, PRETO, 0, 0
	WORD 		PRETO, PRETO, PRETO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, VERDE_CLARO, BRANCO, PRETO, AZUL_CLARO, ROSA, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, PRETO, PRETO, PRETO
	WORD 		PRETO, BRANCO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, AZUL_ESCURO, BRANCO, PRETO
	WORD 		PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO

	
DEF_AST:							  ; tabela que define o desenho do asteroide mineravel
	WORD		LARGURA_AST, ALTURA_AST
	WORD 		0, VERDE_ESCURO, VERDE_ESCURO, VERDE_ESCURO, 0
	WORD 		VERDE_ESCURO, VERDE_ESCURO, VERDE_CLARO, VERDE_ESCURO, VERDE_ESCURO
	WORD 		VERDE_ESCURO, VERDE_CLARO, VERDE_CLARO, VERDE_CLARO, VERDE_ESCURO         
	WORD 		VERDE_ESCURO, VERDE_ESCURO, VERDE_CLARO, VERDE_ESCURO, VERDE_ESCURO
	WORD 		0, VERDE_ESCURO , VERDE_ESCURO, VERDE_ESCURO, 0


DEF_AST_EXPLOSAO:					  ; tabela que define o desenho do asteroide mineravel apos a explosao
	WORD		LARGURA_AST, ALTURA_AST
	WORD 		0, 0, 0, 0, 0
	WORD 		0, 0, VERDE_ESCURO, 0, 0
	WORD 		0, VERDE_ESCURO, VERDE_ESCURO, VERDE_ESCURO, 0         
	WORD 		0, 0, VERDE_ESCURO, 0, 0
	WORD 		0, 0 , 0, 0, 0
	WORD		LARGURA_AST, ALTURA_AST
	WORD 		0, 0, 0, 0, 0
	WORD 		0, 0, VERDE_ESCURO, 0, 0
	WORD 		0, VERDE_ESCURO, VERDE_ESCURO, VERDE_ESCURO, 0         
	WORD 		0, 0, VERDE_ESCURO, 0, 0
	WORD 		0, 0 , 0, 0, 0


DEF_ASTE:							  ; tabela que define o desenho do asteroide nao mineravel
	WORD		LARGURA_AST, ALTURA_AST
	WORD 		0, VERMELHO, VERMELHO, VERMELHO, 0
	WORD 		VERMELHO, 0, VERMELHO, 0, VERMELHO
	WORD 		VERMELHO, VERMELHO, 0, VERMELHO, VERMELHO       
	WORD 		VERMELHO, 0, VERMELHO, 0, VERMELHO
	WORD 		0, VERMELHO, VERMELHO, VERMELHO, 0


DEF_ASTE_EXPLOSAO:					  ; tabela que define o desenho do asteroide nao mineravel após a explosão
	WORD		LARGURA_AST, ALTURA_AST
	WORD 		VERMELHO, 0, 0, 0, VERMELHO
	WORD 		0, VERMELHO, 0, VERMELHO, 0
	WORD 		0, 0, VERMELHO, 0, 0       
	WORD 		0, VERMELHO, 0, VERMELHO, 0
	WORD 		VERMELHO, 0, 0, 0, VERMELHO


dados_asteroides:                     ; dados dos asteroides
	WORD 0, 5, 0, 0, 0, 0 			  ; tipo de asteroide (0-3) 0 - Minerável, 1-3 Não minerável
	WORD 0, 5, 0, 0, 0, 0			  ; posição inicial (0-5) 5 - ainda não nasceu ou já pode ser criado na mesma posição
	WORD 0, 5, 0, 0, 0, 0			  ; posição inicial imutável (0-4)
	WORD 0, 5, 0, 0, 0, 0			  ; linha/coluna do asteróide
									  ; colisão com sonda (0-1) 0 -> não colidiu, 1 -> colidiu
  
dados_sondas:  
	WORD 0, 0, -1					  ; linha/coluna da sonda e incremento da coluna
	WORD 0, 0, 0					  ; linha/coluna da sonda e incremento da coluna
	WORD 0, 0, 1					  ; linha/coluna da sonda e incremento da coluna

DEF_sonda:
	WORD 		LINHA_SONDA, COLUNA_sonda
	WORD		COR_SONDA
						
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
	MOV  R10, LINHA_SONDA			  ; registo com a linha da sonda
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
	

; ******************************************************************************
; ********************** INICIALIZAÇÃO DOS PROCESSOS ***************************
; ******************************************************************************

CALL nave							  ; inicializa o processo nave
CALL teclado						  ; inicializa o processo teclado
CALL energia						  ; inicializa o processo energia
  
MOV	R7, N_ASTEROIDES				  ; número de asteróides (4 asteróides)
loop_asteroides:					  ; inicializa todas as instâncias do processo asteróide
	SUB	R7, 1			        	  ; próximo asteróide
	CALL	asteroide_inicio    	  ; cria uma nova instância do processo asteroide (o valor de R7 distingue-as)
						        	  ; cada processo fica com uma cópia independente dos registos
	CMP  R7, 0			        	  ; verifica se já criou todas as instâncias
    JNZ	loop_asteroides		    	  ; se ainda não criou volta para o loop
  
MOV	R7, N_SONDAS					  ; número de sondas (4 sondas)
loop_sondas:						  ; inicializa todas as instâncias do processa sonda
	SUB	R7, 1			        	  ; próxima sonda
	CALL	sonda_inicio	    	  ; cria uma nova instância do processa sonda (o valor de R7 distingue-as)
						        	  ; cada processo fica com uma cópia independente dos registos
	CMP  R7, 0			        	  ; verifica se já criou todas as instâncias
    JNZ	loop_sondas		   			  ; se ainda não criou volta para o loop
	JMP controlo


; ******************************************************************************
; ******TROCAR NOME DO TITULO**************** TROCAR NOME DO TITULO *********TROCAR NOME DO TITULO**************TROCAR NOME DO TITULO*********
; ******************************************************************************

espera_inicio:
	MOV R1, TECLA_C					  ; a tecla para começar é a "C"
	CMP R0, R1						  ; verifica se a tecla carregada é a certa
	JNZ controlo					  ; se nao for a tecla esperada espera por outra
	MOV R0, 1						  ; muda o estado do jogo
	MOV [estado_jogo], R0			  ; guarda o estado do jogo na memoria

setup:

	MOV  [APAGA_AVISO], R1			  ; apaga o aviso de nenhum cenário selecionado (o valor de R1 não é relevante)
    MOV  [APAGA_ECRÃ], R1			  ; apaga todos os pixels já desenhados (o valor de R1 não é relevante)
	MOV  R1, 1						  ; imagem número 1
	MOV  [APAGA_CENARIO_FUNDO], R1    ; apaga a imagem número 1 (caso esteja desenhada)
	MOV  R1, 0                        ; vídeo número 0
	MOV  [REPRODUZ], R1				  ; reproduz o vídeo número 0
	MOV  [METER_LOOP], R1			  ; mete o vídeo em loop
	MOV  R11, 100					  ; valor do display inicial do jogo
	MOV [energia_total], R11		  ; valor da energia total
	CALL mostra_display				  ; mostra o valor da energia total no display
    
	MOV R8, DEF_NAVE_0				  ; endereço da nave
	MOV R11, 0						  ; valor da nave atual
	MOV [nave_atual], R11			  ; guarda o valor da nave atual
	;MOV R11, 5                       ; não há asteroides
	CALL desenha_nave				  ; desenha a nave

controlo:
	MOV R0, [tecla_carregada]		  ; guarda a tecla carregada em R0
	MOV R11, [estado_jogo]			  ; guarda o estado do jogo
	CMP R11, 0						  ; verifica o estado do jogo
	JZ  espera_inicio				  ; se ainda nao tiver começado espera pela tecla de começar
	CMP R11, 3						  ; se o jogo estiver terminado
	JZ  espera_inicio				  ; espera pela tecla de inicio
	MOV R1, 1						  ; se nenhum se verificar entao o jogo está a decorrer

obtem_tecla:
	CMP R11, 1						  ; se o jogo estiver a correr espera por teclas/instruções
	JZ  call_verifica_tecla			  ; espera a tecla carregada
	CMP R11, 2						  ; verifica se o jogo está pausado
	JZ  call_estado_pausa			  ; pausa o jogo
	JMP controlo					   

call_verifica_tecla:
	CALL verifica_tecla
	JMP controlo

call_estado_pausa:
	CALL verifica_tecla_pausa
	JMP controlo

verifica_tecla:	

	MOV R6, TECLA_D					  ; guarda a tecla D
	CMP R6, R0
	JZ  pausa_jogo					  ; se tiveres carregado a tecla D põe o jogo em pausa

	MOV R6, TECLA_F					  ; guarda a tecla F
	CMP R6, R0
	JZ  termina_jogo				  ; se tiveres carregado a tecla F termina o jogo
	  
	RET  

verifica_tecla_pausa:

	MOV R6, TECLA_D					  ; guarda a tecla D
	CMP R6, R0						  ; verifica a tecla carregada
	JZ  retoma_jogo					  ; se estivermos em pausa e a tecla carregada for D retoma o jogo

	MOV R6, TECLA_F					  ; guarda a tecla F
	CMP R6, R0						  ; verifica a tecla carregada
	JZ  termina_jogo				  ; se estivermos em pausa e a tecla carregada for F termina o jogo
	  
	RET


pausa_jogo:
	MOV  R11, 2						  ; põe o jogo em pausa
	MOV  [estado_jogo], R11			  ; guarda o estado do jogo
	DI3								  ; desativa a interrupção 3
	DI2								  ; desativa a interrupção 2
	DI1								  ; desativa a interrupção 1
	DI0								  ; desativa a interrupção 0
	DI								  ; desativa as interrupções (no geral)
	MOV  [APAGA_AVISO], R1			  ; apaga o aviso de nenhum cenário selecionado (o valor de R1 não é relevante)
	MOV  R1, 0                        ; vídeo número 0
	MOV  [PAUSA], R1				  ; reproduz o vídeo número 0
	MOV  R1, 1						  ; imagem número 1
	MOV  [COLOCA_CENARIO_FRONTAL], R1 ; reproduz a imagem número 1
	JMP  controlo

retoma_jogo:
	MOV  R11, 1						  ; põe o estado do jogo em normal
	MOV  [estado_jogo], R11			  ; guarda o estado do jogo
	EI3								  ; ativa a interrupção 3
	EI2								  ; ativa a interrupção 2
	EI1								  ; ativa a interrupção 1
	EI0								  ; ativa a interrupção 0
	EI								  ; ativa as interrupções (no geral)
	MOV  [APAGA_AVISO], R1			  ; apaga o aviso de nenhum cenário selecionado (o valor de R1 não é relevante)
	MOV  R1, 1						  ; imagem número 1
	MOV  [APAGA_CENARIO_FUNDO], R1    ; apaga a imagem número 1
	MOV  R1, 0                        ; vídeo número 0
	MOV  [CONTINUA], R1				  ; continua a reproduzir o vídeo número 0
	MOV  [METER_LOOP], R1			  ; mete o vídeo em loop
	JMP  controlo

termina_jogo:

	MOV  R11, 3						  ; poe o estado do jogo como terminado
	MOV  [estado_jogo], R11			  ; guarda o estado do jogo
	MOV  [APAGA_AVISO], R1			  ; apaga o aviso de nenhum cenário selecionado (o valor de R1 não é relevante)
	MOV  R1, 0                        ; vídeo número 0
	MOV  [TERMINA], R1				  ; reproduz o vídeo número 0
	MOV  [APAGA_ECRÃ], R1			  ; apaga o ecrã
	MOV  R1, 4						  ; imagem número 4
	MOV  [SELECIONA_CENARIO_FUNDO], R1; reproduz a imagem número 4
	JMP  espera_inicio				  ; reseta as variáveis do jogo (exceto memória)


; ******************************************************************************
; ******************************** DISPLAY *************************************
; ******************************************************************************

mostra_display: 
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4
	PUSH R5
	PUSH R6
	PUSH R7
	PUSH R11
	MOV R4, DISPLAYS				  ; endereço do display
	MOV R1, 0
	MOV R11, [energia_total]
	CMP R11, 0
	JLE menor_zero
	MOV R7, R11
	MOV R2, 1000
	MOV R5, 10
	JMP converte_decimal

converte_decimal:
	MOD R7, R2 						  ; passo 1
	DIV R2, R5 						  ; passo 2
	MOV R6, R2
	CMP R6, 1
	JLT escreve_display 			  ; passo 3
	MOV R3, R7
	DIV R3, R2 						  ; passo 4
	SHL R1, 4 						  ; passo 5
	OR R1, R3 						  ; passo 6
	JMP converte_decimal

menor_zero:
	MOV R1, 0
	JMP escreve_display

escreve_display:
	MOV [R4], R1					  ; escreve no periférico do display
	POP R11
	POP R7
	POP R6
	POP R5
	POP R4
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

reseta_r1:							  ; reseta o valor da linha a testar
	MOV R1, 1						  ; primeira linha
	JMP espera_tecla				  ; salta para esperar pela tecla

rol_r1:
	ROL R1, 1
	MOV R11, 10H
	CMP R1, R11
	JZ  reseta_r1

espera_tecla:          			  	  ; neste ciclo espera-se até uma tecla ser premida

	WAIT                              ; ciclo potencialmente bloqueante
				  
    MOVB [R2], R1      				  ; escrever no periférico de saída (linhas)
    MOVB R0, [R3]      				  ; ler do periférico de entrada (colunas)
    AND  R0, R5        				  ; elimina bits para além dos bits 0-3
    CMP  R0, ZERO       			  ; há tecla premida?
    JZ   rol_r1  				      ; se nenhuma tecla premida, repete
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
	MOV R8, DEF_NAVE_0
	CALL desenha_nave
	JMP nave

caso_nave_1:
	MOV R8, DEF_NAVE_1
	CALL desenha_nave
	JMP nave

caso_nave_2:
	MOV R8, DEF_NAVE_2
	CALL desenha_nave
	JMP nave

caso_nave_3:
	MOV R8, DEF_NAVE_3
	CALL desenha_nave
	JMP nave

caso_nave_4:
	MOV R8, DEF_NAVE_4
	CALL desenha_nave
	JMP nave

caso_nave_5:
	MOV R8, DEF_NAVE_5
	CALL desenha_nave
	JMP nave

caso_nave_6:
	MOV R8, DEF_NAVE_6
	CALL desenha_nave
	JMP nave

caso_nave_7:
	MOV R8, DEF_NAVE_7
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
	MOV R4, R8				  		  ; tabela que define as naves
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
	CALL verifica_fim_jogo
	MOV [energia_total], R11
	CALL mostra_display               ; atualiza valor do display
	JMP energia

verifica_fim_jogo:
	CMP R11, 0
	JLE fim_jogo
	RET

fim_jogo:
	MOV R10, 3						  ; estado de jogo = 3 (fim de jogo)
	MOV [estado_jogo], R10			  ; guarda o estado de jogo na memória
	CALL mostra_display				  ; mostra o display
	MOV R1, 0						  ; video numero zero
	MOV [TERMINA], R1				  ; pausa o vídeo
	MOV [APAGA_ECRÃ], R1			  ; apaga o ecrã
	MOV R1, 2						  ; imagem numero dois
	MOV [SELECIONA_CENARIO_FUNDO], R1 ; colocar imagem 2 no ecrã
	RET
	
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
	PUSH R10
									  ;R10 vai guardar o tipo de asteróide
									  ;R11 vai guardar o número/posição inicial do asteróide
	MOV  R0, [TEC_COL]                ; ler do periférico do PIN
	MOV  R8, MASCARA_2            
	AND  R0, R8				    	  ; isolar os 8 bits de menor peso
	SHR  R0, 4						  ; isolar os bits 7 a 4
	MOV  R1, R0						  ; copiar para R1
	SHR  R0, 2						  ; isolar os bits de menor peso
	MOV  R9, R0					      ; copiar para R10 (tipo de asteróide)
									  ; 0 - minerável
									  ; 1, 2, 3 - não minerável
	CALL numero_de_asteroide
	MOV  [R11], R9					  ; guardar o tipo de asteróide
	MOV  [R11 + 2], R10				  ; guardar o número/posição inicial do asteróide
	MOV  [R11 + 4], R10				  ; guardar a posição para verificação
	POP  R10
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
	MOV  R8, 5						  ; 5 possibilidades de posição
	MOD  R1, R8						  ; gerar um número entre 0 e 4
	MOV  R10, R1					  ; copiar para R11 (número/posição inicial do asteróide)
	CALL verifica_asteroide
	RET

procura_linear:
	CMP  R10, 4
	JZ   caso_4
	ADD  R10, 1
	JMP verifica_asteroide

caso_4:
	MOV  R10, 0

verifica_asteroide:
	MOV  R8,  [dados_asteroides + 2]  ; endereço da posição do asteroide 1
	CMP  R10, R8
	JZ   procura_linear

	MOV  R6,  dados_asteroides	
	MOV  R7,  14
	MOV  R8,  [R6 + R7]				  ; endereço da posição do asteroide 2
	CMP  R10, R8
	JZ   procura_linear

	MOV  R6,  dados_asteroides
	MOV  R7,  26
	MOV  R8,  [R6 + R7]               ; endereço da posição do asteroide 3
	CMP  R10, R8
	JZ   procura_linear

	MOV  R6,  dados_asteroides
	MOV  R7,  38
	MOV  R8,  [R6 + R7]			      ; endereço da posição do asteroide 4
	CMP  R10, R8
	JZ   procura_linear
	RET


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


PROCESS SP_inicial_asteroides         ; indicação do início do processo do asteroide 1

asteroide_inicio:
	MOV R1, 100H
	MUL R1, R7
	SUB SP, R1
	MOV R11, R7

	MOV R2,  12						  ; multiplicador para o endereço
	MUL R11, R2					  	  ; garante a soma para o endereço base desta instância do asteróide
	MOV R3, dados_asteroides		  ; endereço base dos dados do asteróide
	ADD R3, R11						  ; endereço base desta instância do asteróide
	MOV R11, R3						  ; guarda o endereço base desta instância do asteróide


asteroide_geral:
	MOV R10, [evento_int]		  	  ; espera a interrupção ativar
	MOV R10, [estado_jogo]			  ; copia o estado de jogo para o R10
	CMP R10, 1						  ; verifica se está a jogar
	JNZ asteroide_geral				  ; se não estiver volta ao asteróide

	CALL escolhe_asteroide
	CALL escolhe_col_ast
	CALL escolhe_tipo_ast
	CALL reseta_colisao

	MOV R8, LINHA_AST				  ; guarda NO R8 a linha que vai começar (linha 0 sempre)
	CALL desenha_ast
	JMP ciclo_asteroide1

ciclo_asteroide1:
    MOV R10, [evento_int]             ; espera a interrupção ativar
    MOV R10, [estado_jogo]            ; copia o estado de jogo para o R10
	CMP R10, 3						  ; verifica se acabou o jogo
	JZ  asteroide_geral               ; se acabou o jogo volta ao asteróide geral
    CMP R10, 1                        ; verifica se está a jogar
	JNZ ciclo_asteroide1			  ; se não estiver volta ao ciclo
	CALL verifica_se_pode_desenhar_na_posicao
    CALL move_ast					  ; se estiver move o asteróide uma linha
	CALL verifica_fundo				  ; verifica se chegou ao fundo da tela
	CMP  R10, 1						  ; verifica se chegou ao fundo (valor 1)
	JZ   detetou_colisao		      ; se chegou ao fundo volta a asteróide geral
	CALL verifica_colisoes_nave
	CMP R10, 1						  ; verifica se houve colisão com a nave
	JZ 	detetou_colisao  	          ; se houver colisão volta a asteroide_geral
	CALL verifica_colisao_sonda	  	  ; verifica se há sinal de colisão com a sonda
	CMP R10, 1						  ; verifica se houve colisão com a sonda
	JZ 	detetou_colisao  	          ; se houver colisão volta a desenhar o asteroide
	JZ  asteroide_geral				  ; se chegou ao fundo
	JMP ciclo_asteroide1			  ; se não chegou fim volta para o ciclo para continuar a descer o asteróide

detetou_colisao:
	CALL apaga_ast			  	  	  ; apaga o asteróide
	JMP asteroide_geral				  ; volta a desenhar o asteróide


desenha_ast:
	MOV R1, R8						  ; copia a linha do pixel de referência do asteroide
	MOV R2, R9						  ; copia a coluna do pixel de referência do asteroide
	PUSH R1
	PUSH R2
	PUSH R4
	PUSH R6
	PUSH R7
	MOV R5, [R4]					  ; guarda em R5 a largura do asteróide
	ADD R4, 2						  ; altera o R4 para guardar o endereço da altura do asteróide
	MOV R6, [R4]				      ; guarda no R6 a altura do asteróide
	ADD R4, 2						  ; altera o R4 para guardar o endereço das cores do asteróide
	
ciclo_desenha_ast:					  ; altera os valores para desenhar a próxima linha do asteroide
	CALL desenha_pixels
	MOV R2, R9					  	  ; copia a coluna do pixel de referência do asteroide
	MOV R5, LARGURA_AST				  ; repõe a largura do asteroide
	ADD R1, 1						  ;	troca a linha em que se está a desenhar
	SUB R6, 1						  ; decrementa o número de linhas que faltam desenhar
	JNZ ciclo_desenha_ast			  ; repete o ciclo até desenhar todas as linhas do asteroide
	POP R7
	POP R6
	POP R4
	POP R2
	POP R1
	RET								  ; volta quando terminou de desenhar o asteroide

move_ast:							  ; rotina responsável por mover o asteroide
	CALL apaga_ast		
	ADD R8, 1						  ; modifica a linha de referencia para o desenho do asteroide
	MOV R10, 6						  ; valor a somar para obter endereço da linha guardada na memória
	MOV [R11 + R10], R8				  ; guarda a nova linha de referência para o desenho do asteroide	
	ADD R9, R0						  ; modifica a coluna de referencia para o desenho do asteroide
	MOV R10, 8						  ; valor a somar para obter endereço da coluna guardada na memória
	MOV [R11 + R10], R9				  ; guarda a nova coluna de referência para o desenho do asteroide
	CALL desenha_ast
	RET

apaga_ast:
	PUSH R1
	PUSH R2
	PUSH R5
	PUSH R6
	PUSH R8
	MOV  R1, R8						  ; copia a linha do pixel de referência do asteróide
	MOV  R6, ALTURA_AST

ciclo_apaga_ast:
	MOV R2, R9						  ; copia a coluna do pixel de referência do asteroide
	MOV R5, LARGURA_AST				  ; largura do asteroide
	CALL apaga_pixels
	ADD R1, 1						  ;	troca a linha em que se está a desenhar
	SUB R6, 1						  ; decrementa o número de linhas que faltam desenhar
	JNZ ciclo_apaga_ast		  		  ; repete até apagar todo o asteróide
	POP R8
	POP R6
	POP R5
	POP R2
	POP R1
	RET								  ; volta quando terminou de desenhar o asteróide


verifica_se_pode_desenhar_na_posicao:
	PUSH R8
	PUSH R9
	PUSH R10
	MOV R8, [R11 + 6]				  ; linha onde está o asteroide
	MOV R9, LINHA_NAVE
	CMP R8, R9				          ; verifica se o asteroide já chegou ao limite em que se pode desenhar outro
	JNZ dar_retorno					  ;	retornar
	MOV R10, 5						  ; definir que o asteroide está em andamento e passou o limite
	MOV [R11 + 2], R10			      ; guarda que já se pode
	JMP dar_retorno					  ; retornar 

dar_retorno:
	POP R10
	POP R9
	POP R8
	RET

escolhe_asteroide:	
	CALL aleatorio					  ; gera um asteróide aleatoriamente
	RET

escolhe_col_ast:
	PUSH R1							  ; para a comparação
	MOV R1, [R11 + 2]
	CMP R1, 0						  ; verifica se o asteroide vai nascer na esquerda (anda para a direita)
	JZ valores_ast_0
	CMP R1, 1						  ; verifica se o asteroide vai nascer no meio (anda para a esquerda)
	JZ valores_ast_1
	CMP R1, 2						  ; verifica se o asteroide vai nascer no meio (anda para baixo só)
	JZ valores_ast_2
	CMP R1, 3						  ; verifica se o asteroide vai nascer no meio (anda para a direita)
	JZ valores_ast_3			    
	CMP R1, 4						  ; verifica se o asteroide vai nascer na direita (anda para a esquerda)
	JZ valores_ast_4			  

valores_ast_0:
	MOV R9, COL_AST_ESQ				  ; guarda a coluna inicial do asteroide da esquerda
	MOV R0, 1						  ; o quanto a coluna vai variar em cada ciclo
	POP R1
	RET

valores_ast_1:
	MOV R9, COL_AST_MEIO			  ; guarda a coluna inicial do asteroide do meio
	MOV R0, -1						  ; o quanto a coluna vai variar em cada ciclo
	POP R1
	RET

valores_ast_2:
	MOV R9, COL_AST_MEIO			  ; guarda a coluna inicial do asteroide do meio
	MOV R0, 0						  ; o quanto a coluna vai variar em cada ciclo
	POP R1
	RET

valores_ast_3:
	MOV R9, COL_AST_MEIO			  ; guarda a coluna inicial do asteroide do meio
	MOV R0, 1						  ; o quanto a coluna vai variar em cada ciclo
	POP R1
	RET

valores_ast_4:
	MOV R9, COL_AST_DIR				  ; guarda a coluna inicial do asteroide da direita
	MOV R0, -1						  ; o quanto a coluna vai variar em cada ciclo
	POP R1
	RET


escolhe_tipo_ast:
	PUSH R1							  ; para a comparação
	MOV R1, [R11]
	CMP R1, 0
	JZ ast_mineravel
	MOV R4, DEF_ASTE				  ; guarda o design do asteroide não minerável
	POP R1
	RET

reseta_colisao:
	PUSH R1
	PUSH R2
	MOV  R1, 10						  ; valor a somar para obter o endereço da colisão
	MOV  R2, 0						  ; valor a guardar na memória
	MOV  [R11 + R1], R2				  ; guarda o valor 0 na memória
	POP  R2
	POP  R1
	RET

ast_mineravel:
	MOV R4, DEF_AST					  ; guarda o design do asteroide minerável
	POP R1
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
; R11 guarda a posição do asteroide
; R8 guarda a linha do asteroide

verifica_colisoes_nave:
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

escolhe_colisoes:
	MOV R0, [R11 + 4]		    	  ; vai buscar o sítio onde nasceu o asteroide
	MOV R2, 2						  ; constante pra fazer o mod por 2
	MOD R0, R2						  ; mod por 2				
	CMP R0, 0						  ; se for zero (ast 0, 2 ou 4 --> podem bater na nave)
	JNZ sem_hipotese				  ; não pode bater na nave
	CALL verifica_colisao_nave	  

fim_verificacao:
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
	RET

sem_hipotese:
	MOV R10, 0
	JMP fim_verificacao

verifica_colisao_nave:
	MOV R2, COLISAO_NAVE
	CMP R8, R2
	JZ houve_colisao_nave
	MOV R10, 0
	RET
	
houve_colisao_nave:
	MOV R10, 1
	MOV R3, [estado_jogo]
	MOV R3, 3
	MOV [estado_jogo], R3
	MOV R1, 0						  ; vídeo número zero
	MOV  [TERMINA], R1				  ; pausa o vídeo
	MOV [APAGA_ECRÃ], R1			  ; apaga o ecrã
	MOV R1, 3						  ; imagem número três
	MOV [SELECIONA_CENARIO_FUNDO], R1 ; seleciona a imagem três
	RET

verifica_colisao_sonda:
	PUSH R0
	PUSH R1
	PUSH R2
	PUSH R3
	MOV R0, 10    					 ; valor a somar ao endereço
	MOV R10, [R11 + R0]				 ; ler se há colisao (1)
	MOV R1, [R11]				     ; tipo de asteroide
	CMP R10, 1						 ; se for 1, há colisão
	JZ houve_colisao_sonda
	POP R3
	POP R2
	POP R1
	POP R0
	RET		

houve_colisao_sonda:
	CMP R1, 0						 ; se for 0, é minerável
	JNZ colisao_nao_mineravel
	MOV R1, 0						 ; resetar colisão
	MOV [R11 + R0], R1				 ; escrever 0 no endereço
	MOV R2, 2						 ; executar som 2
	MOV [REPRODUZ], R2				 ; reproduzir som
	MOV R3, [evento_int]
	CALL apaga_ast
	MOV R4, DEF_AST_EXPLOSAO
	CALL desenha_ast
	MOV R3, [evento_int]
	CALL apaga_ast
	POP R3
	POP R2
	POP R1
	POP R0
	RET

colisao_nao_mineravel:
	MOV R2, 3						 ; executar som 3
	MOV [REPRODUZ], R2				 ; reproduzir som da colisão com o asteróide não minerável
	MOV R1, 0						 ; resetar colisão
	MOV [R11 + R0], R1				 ; escrever 0 no endereço
	MOV R3, [evento_int]
	CALL apaga_ast
	MOV R4, DEF_ASTE_EXPLOSAO
	CALL desenha_ast
	MOV R3, [evento_int]
	CALL apaga_ast
	POP R3
	POP R2
	POP R1
	POP R0
	RET

; ******************************************************************************
; ********************************* SONDAS *************************************
; ******************************************************************************

PROCESS SP_inicial_sonda

sonda_inicio:
	MOV R1, 100H
	MUL R1, R7
	SUB SP, R1
	MOV R11, R7

	MOV R2,  6						  ; multiplicador para o endereço
	MUL R11, R2					  	  ; garante a soma para o endereço base desta instância da sonda
	MOV R3, dados_sondas		      ; endereço base dos dados da sonda
	ADD R3, R11						  ; endereço base desta instância da sonda
	MOV R11, R3						  ; guarda o endereço base desta instância da sonda

sonda:
	MOV  R2, [tecla_carregada]	      ; ir buscar a tecla carregada
	CMP  R2, R7						  ; desbloquear a instância consoante a tecla carregada
	JNZ  sonda
	MOV  R0, [estado_jogo]			  ; ir buscar o estado do jogo
	CMP  R0, 1						  ; 1 indica jogo a correr
	JNZ  sonda						  ; se não for 1 não desenha a sonda
	CALL coord_iniciais_sonda		  ; ir buscar a coluna inicial da sonda
	MOV  R9, LINHA_SONDA              ; linha inicial da sonda
	MOV  R4, DISPLAYS
	MOV  R6, 1						  ; indica que a sonda ainda não chegou ao limite
	MOV  R10, [R11 + 4]				  ; incremento da coluna
	MOV  [R11], R9			 		  ; guarda a linha da sonda
	MOV  [R11 + 2], R2		          ; guarda a coluna da sonda
	MOV  R0, [energia_total]		  ; vai buscar a energia total atual	
	SUB  R0, 5
	MOV  [energia_total], R0		  ; atualiza a energia total
	CALL mostra_display
	CALL desenha_sonda
	MOV R0, 1
	MOV [REPRODUZ], R0				  ; reproduzir o áudio 1
	JMP ciclo_sonda

coord_iniciais_sonda:
	CMP R7, 0
	JZ esquerda
	CMP R7, 2
	JZ direita
	MOV R2, COLUNA_sonda
	RET

esquerda:
	MOV R2, COLUNA_ESQUERDA
	RET

direita:
	MOV R2, COLUNA_DIREITA
	RET
	
ciclo_sonda:
	MOV R0, [evento_int + 2]
	MOV R0, [estado_jogo]
	CMP R0, 3
	JZ sonda
	CMP R0, 1
	JNZ ciclo_sonda
	CALL verifica_limite			  ; verifica se a sonda chegou ao limite
	CMP R6, 0						  ; 0 indica que chegou ao limite
	JZ sonda
	CALL verifica_colisao_asteroide
	CMP R6, 1						  ; há colisão?								   
	JZ sonda						  ; se sim, volta ao inicio
	CALL move_sonda
	MOV [R11], R9			          ; atualiza a linha da sonda
	MOV [R11 + 2], R2	              ; atualiza a coluna da sonda
	JMP ciclo_sonda

verifica_limite:
	MOV R8, LIMITE_SONDA
	MOV R9, [R11]                     ; linha da sonda
	CMP R8, R9
	JZ limite_maximo
	MOV R6, 1
	RET
	
limite_maximo:
	MOV R6, 0
	CALL apaga_sonda
	MOV [R11], R6					  ; resetar na memória a linha da sonda
	MOV [R11+ 2], R6				  ; resetar na memória a coluna da sonda
	RET

verifica_colisao_asteroide:
	PUSH R0
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4
	PUSH R5
	PUSH R8
	PUSH R9
	PUSH R10
	MOV  R0, 4					      ; número de asteróides
	CALL ciclo_verificar_asteroides	  ; verificar se houve colisão com algum asteroide
	JMP pop_function

ciclo_verificar_asteroides:
	SUB  R0, 1

	MOV  R1, 12			 			  ; multiplicador para o valor a somar ao endereço
	MOV  R2, R0						  ; cópia do número do asteroide
	MUL  R2, R1						  ; valor a somar ao endereço
	MOV  R1, dados_asteroides		  ; endereço base dos dados dos asteroides
	ADD  R1, R2						  ; endereço base do asteroide

	MOV  R2, [R1]					  ; tipo de asteróide	
	MOV  R3, [R1 + 6]                 ; linha do asteróide
	MOV  R10, 8                   	  ; valor a somar para obter a coluna
	MOV  R4, [R1 + R10]               ; coluna do asteróide
	MOV  R10, 10					  ; valor a somar para o dado de colisão do asteróide
	MOV  R5, R1                  	  ; parte 1 - endereço da colisão do asteróide
	ADD  R5, R10					  ; parte 2 - endereço da colisão do asteróide
	CALL verifica_asteroide_especifico; verificar se houve colisão com o asteroide
	CMP  R10, 1						  ; se não puder colidir
	JNZ  verifica_proximo_asteroide	  ; verificar próximo asteróide
	CALL verifica_se_colidiu
	CMP  R6, 1						  ; se colidir, apagar a sonda e sair do ciclo
	JZ   apagar_sonda			      ; se sim, apagar a sonda
	MOV  R6, 0						  ; se não colidir, verificar próximo asteróide
	CMP  R0, 0						  ; se já verificou todos os asteroides
	JNZ  ciclo_verificar_asteroides	  ; próximo asteróide
	RET

verifica_proximo_asteroide:
	MOV  R6, 0						  ; indicar que não colidiu
	CMP  R0, 0						  ; se já verificou todos os asteroides
	JNZ  ciclo_verificar_asteroides	  ; se não, próximo asteróide
	RET

verifica_asteroide_especifico:
	MOV  R9, [R1 + 4]				  ; copia o valor da posição do asteróide
	CMP  R7, 0						  ; se a sonda estiver na parte esquerda
	JZ  parte_esquerda
	CMP  R7, 1						  ; se a sonda estiver na parte central
	JZ  parte_central
	MOV  R10, 3						  ; asteróides com quais pode colidir: 3 ou 4
	CMP  R9, R10					  ; ver se o asteróide está em alguma dessas posições
	JGE  pode_colidir				  ; se sim, pode colidir
	MOV  R10, 0						  ; se não, não pode colidir
	RET

parte_esquerda:
	MOV  R10, 1						  ; asteróides com quais pode colidir: 0 ou 1
	CMP  R9, R10					  ; ver se o asteróide está em alguma dessas posições
	JLE  pode_colidir				  ; se sim, pode colidir
	MOV  R10, 0						  ; se não, não pode colidir
	RET

parte_central:
	MOV  R10, 2						  ; asteróides com quais pode colidir: 2
	CMP  R9, R10					  ; ver se o asteróide está em alguma dessas posições
	JZ   pode_colidir				  ; se sim, pode colidir
	MOV  R10, 0						  ; se não, não pode colidir
	RET

pode_colidir:
	MOV  R10, 1
	RET

verifica_se_colidiu:
	MOV  R8, [R11]					  ; linha da sonda
	MOV  R9, [R11 + 2]				  ; coluna da sonda
	CMP  R8, R3						  ; comparação da linha da sonda com a linha de referência do asteroide
	JGE  verifica_parte_inferior	  ; se a linha da sonda for maior que a linha de referência do asteroide
	MOV  R6, 0						  ; não houve colisão
	RET								  ; não há colisão

verifica_parte_inferior:
	MOV  R10, ALTURA_AST			  ; altura do asteróide
	ADD  R3, R10					  ; obtem o valor da linha de referência inferior do asteróide
	CMP  R8, R3						  ; comparação da linha da sonda com a linha de referência do asteroide
	JLE  verifica_largura			  ; se a linha da sonda for menor que a linha de referência do asteroide
	MOV  R6, 0						  ; não houve colisão
	RET								  ; não há colisão	

verifica_largura:
	CMP  R9, R4						  ; comparação da coluna da sonda com a coluna de referência do asteroide
	JGE  verifica_na_direita		  ; se a coluna da sonda for maior que a coluna de referência do asteroide
	MOV  R6, 0						  ; não houve colisão
	RET								  ; não há colisão

verifica_na_direita:
	MOV  R10, LARGURA_AST			  ; largura do asteróide
	ADD  R4, R10					  ; obtem o valor da coluna de referência da direita do asteróide
	CMP  R9, R4						  ; comparação da coluna da sonda com a coluna de referência do asteróide
	JLE  ha_colisao					  ; se a coluna da sonda for menor que a coluna de referência do asteróide
	MOV  R6, 0						  ; indica que não houve colisão	
	RET								  ; retorna

ha_colisao:
	MOV  R6, 1						  ; indica que houve colisão
	RET

apagar_sonda:
	CMP  R2, 0						  ; se o tipo de asteroide for 0
	JZ   muda_energia				  ; se sim, aumenta energia
	MOV  R10,  1					  ; valor 1 para indicar que houve colisão
	MOV  [R5], R10					  ; colisão do asteróide
	CALL apaga_sonda
	MOV  R1, 0						  ; valor 0 para resetar na memória a linha
	MOV  R2, 0						  ; valor 0 para resetar na memória a coluna
	MOV  [R11], R1					  ; resetar na memória a linha da sonda
	MOV  [R11 + 2], R2				  ; resetar na memória a coluna da sonda
	RET

muda_energia:
	MOV  R10, [energia_total]		  ; obter energia total
	MOV  R2, 25						  ; valor a somar à energia total
	ADD  R10, R2					  ; somar à energia total
	MOV  [energia_total], R10		  ; guardar na memória a energia total
	CALL mostra_display
	JMP apagar_sonda				  ; não entra em loop infinito porque R2 foi alterado


pop_function:
	POP R10
	POP R9
	POP R8
	POP R5
	POP R4
	POP R3
	POP R2
	POP R1
	POP R0
	RET
	
; ******************************************************************************
; *********************************** sonda *************************************
; ******************************************************************************

desenha_sonda:
	MOV R1, [R11]    			      ; guardar em R1 o valor associado a linha onde está a sonda
	MOV R2, [R11 + 2]    		  	  ; guardar em R2 o valor associado a coluna onde está a sonda
	MOV R3, COR_SONDA				  ; guardar em R3 o valor associado a cor da sonda
	CALL escreve_pixel
	RET

move_sonda:							  ; faz com o que a sonda suba no ecrã
	CALL apaga_sonda
	MOV R9, [R11]					  ; guarda o valor da linha da sonda
	SUB R9, 1						  ; muda o valor da linha da sonda
	MOV [R11], R9					  ; guarda o valor da linha da sonda
	MOV R5, [R11 + 2]				  ; guarda o valor da coluna da sonda
	MOV R10, [R11 + 4]
	ADD R5, R10					  	  ; muda o valor da coluna da sonda
	MOV [R11 + 2], R5                 ; guarda o valor da coluna da sonda
	CALL desenha_sonda
	RET

apaga_sonda:
	MOV R1, [R11]
	MOV R2, [R11 + 2]
	MOV R3, ZERO					  ; guarda o valor 0 em R3
	CALL escreve_pixel
	RET
	
; ******************************************************************************
; ******************************* INTERRUPÇÕES *********************************
; ******************************************************************************

rot_ast:						      ; interrupção dos asteroides
	PUSH R1
	MOV [evento_int], R1			  ; dá unlock dos processos dos asteróides
	POP R1
	RFE

rot_sonda:							  ; interrupção das sondas
	PUSH R1
	MOV [evento_int + 2], R1		  ; dá unlock dos processos das sondas
	POP R1
	RFE

rot_energia:						  ; interrupção da energia 
	PUSH R1
	MOV [evento_int + 4], R1		  ; dá unlock do processo da energia
	POP R1
	RFE

rot_nave:							  ; interrupção da nave
	PUSH R1
	MOV [evento_int + 6], R1		  ; dá unlock do processo da nave
	POP R1
	RFE