; *********************************************************************
; * IST-UL
; * Modulo:    lab3.asm
; * Descrição: Exemplifica o acesso a um teclado.
; *            Lê uma linha do teclado, verificando se há alguma tecla
; *            premida nessa linha.
; *
; * Nota: Observe a forma como se acede aos periféricos de 8 bits
; *       através da instrução MOVB
; *********************************************************************

; **********************************************************************
; * Constantes
; **********************************************************************
; ATENÇÃO: constantes hexadecimais que comecem por uma letra devem ter 0 antes.
;          Isto não altera o valor de 16 bits e permite distinguir números de identificadores
DISPLAYS   EQU 0A000H  ; endereço dos displays de 7 segmentos (periférico POUT-1)
TEC_LIN    EQU 0C000H  ; endereço das linhas do teclado (periférico POUT-2)
TEC_COL    EQU 0E000H  ; endereço das colunas do teclado (periférico PIN)
ZERO       EQU 0
MASCARA    EQU 0FH     ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
TECLA_ESQUERDA			EQU 1		; tecla na primeira coluna do teclado (tecla C)
TECLA_DIREITA			EQU 2		; tecla na segunda coluna do teclado (tecla D)

COMANDOS				EQU	6000H			; endereço de base dos comandos do MediaCenter

DEFINE_LINHA    		EQU COMANDOS + 0AH		; endereço do comando para definir a linha
DEFINE_COLUNA   		EQU COMANDOS + 0CH		; endereço do comando para definir a coluna
DEFINE_PIXEL    		EQU COMANDOS + 12H		; endereço do comando para escrever um pixel
APAGA_AVISO     		EQU COMANDOS + 40H		; endereço do comando para apagar o aviso de nenhum cenário selecionado
APAGA_ECRÃ	 		EQU COMANDOS + 02H		; endereço do comando para apagar todos os pixels já desenhados
SELECIONA_CENARIO_FUNDO  EQU COMANDOS + 42H		; endereço do comando para selecionar uma imagem de fundo
TOCA_SOM				EQU COMANDOS + 5AH		; endereço do comando para tocar um som


LINHA_NAVE        	EQU  24        ; linha da nave (primeira linha)
COLUNA_NAVE			EQU  25       ; coluna da nave (primeira coluna)
LARGURA_NAVE		EQU	 15		; largura da nave
ALTURA_NAVE			EQU  8		; altura da nave

LINHA_TIRO       	EQU  23        ; linha da sonda (primeira linha)
COLUNA_TIRO			EQU  32       ; coluna da sonda (primeira coluna)

LINHA_AST        	EQU  0        ; linha do asteroide (primeira linha)
COLUNA_AST			EQU  0        ; coluna do asteroide (primeira coluna)
LARGURA_AST			EQU	5		; largura do asteroide
ALTURA_AST			EQU  5		; altura do asteroide



MIN_COLUNA		EQU  0		; número da coluna mais à esquerda que o objeto pode ocupar
MAX_COLUNA		EQU  63        ; número da coluna mais à direita que o objeto pode ocupar
ATRASO			EQU	400H		; atraso para limitar a velocidade de movimento do boneco

COR_PIXEL			EQU	0B566H	; cor do pixel: vermelho em ARGB (opaco e vermelho no máximo, verde e azul a 0)
COR_2				EQU 02200H	;
COR_TIRO			EQU 0FF00H


; **********************************************************************
; * Dados
; **********************************************************************
	PLACE       1000H
pilha:
    STACK 100H            ; espaço reservado para a pilha 
                        ; (200H bytes, pois são 100H words)
SP_inicial:                ; este é o endereço (1200H) com que o SP deve ser 
                        ; inicializado. O 1.º end. de retorno será 
                        ; armazenado em 11FEH (1200H-2)
						
DEF_NAVE:					; tabela que define o boneco (cor, largura, pixels)
	WORD		COR_2, COR_2, COR_2, COR_2, COR_2, COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_2, COR_2, COR_2, COR_2, COR_2	; # # #   as cores podem ser diferentes de pixel para pixel
	WORD		COR_2, COR_2, COR_2, COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_2, COR_2, COR_2
	WORD 		COR_2, COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_2
	WORD 		COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_PIXEL
	WORD 		COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_PIXEL
	WORD 		COR_2, COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_2
	WORD		COR_2, COR_2, COR_2, COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_2, COR_2, COR_2
	WORD		COR_2, COR_2, COR_2, COR_2, COR_2, COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_2, COR_2, COR_2, COR_2, COR_2
	
DEF_AST:
	WORD 		COR_2, COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_2
	WORD 		COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_PIXEL
	WORD 		COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_PIXEL
	WORD 		COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_PIXEL
	WORD 		COR_2, COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_2
	
DEF_TIRO:
	WORD		COR_TIRO
						
; **********************************************************************
; * Código
; **********************************************************************
	PLACE 0
inicio:


MOV  SP, SP_inicial		; inicializa SP para a palavra a seguir
						; à última da pilha

; inicializações
    MOV  R2, TEC_LIN   	; endereço do periférico das linhas
    MOV  R3, TEC_COL   	; endereço do periférico das colunas
    MOV  R4, DISPLAYS  	; endereço do periférico dos displays
    MOV  R5, MASCARA   	; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
	MOV  R1, 1   		; para guardar a linha que está a ser testada
	MOV  R7, ZERO		; iniciar o R7 a zero
	MOV  R11, ZERO		; registo com o valor do display

                            
     MOV  [APAGA_AVISO], R1	; apaga o aviso de nenhum cenário selecionado (o valor de R1 não é relevante)
     MOV  [APAGA_ECRÃ], R1	; apaga todos os pixels já desenhados (o valor de R1 não é relevante)
	MOV	R1, 0			; cenário de fundo número 0
     MOV  [SELECIONA_CENARIO_FUNDO], R1	; seleciona o cenário de fundo
	MOV	R7, 1			; valor a somar à coluna do boneco, para o movimentar

	CALL desenha_nave
	CALL desenha_tiro
	CALL desenha_ast

; corpo principal do programa
ciclo:
	MOV R1, 1
    MOV [R4], R11      	; escreve linha e coluna a zero nos displays

espera_tecla:          	; neste ciclo espera-se até uma tecla ser premida
    ROL R1, 1	
    MOVB [R2], R1      	; escrever no periférico de saída (linhas)
    MOVB R0, [R3]      	; ler do periférico de entrada (colunas)
    AND  R0, R5        	; elimina bits para além dos bits 0-3
    CMP  R0, ZERO       ; há tecla premida?
    JZ   espera_tecla  	; se nenhuma tecla premida, repete
						; vai mostrar a linha e a coluna da tecla
	
	CALL converte_valor	; converte o valor da linha e guarda no R7
    SHL R7, 4         	; coloca linha no nibble high
	MOV R6, R7		   	; copia o novo valor da linha para o R6
	MOV R1, R0		   	; copia a coluna para o R1
	CALL converte_valor	; reseta o contador (R7)
	MOV R0, R7			; copia o novo valor da coluna para o R0
	CALL conv_hexa		; converte a tecla premida para um valor hexadecimal
	CALL verifica_tecla ; verifica se a tecla premida corresponde a um comando
	
    
ha_tecla:              	; neste ciclo espera-se até NENHUMA tecla estar premida
    MOVB R0, [R3]      	; ler do periférico de entrada (colunas)
    AND  R0, R5        	; elimina bits para além dos bits 0-3
    CMP  R0, 0         	; há tecla premida?
    JNZ  ha_tecla      	; se ainda houver uma tecla premida, espera até não haver
    JMP  ciclo         	; repete ciclo

converte_valor:			; transforma o valor das linhas e colunas para 0,1,2,3
	MOV R7, ZERO	   	; reseta o contador a zero
valor_ciclo:
	ADD R7, 1			; soma um ao contador
	SHR R1, 1           ; diminui o valor da linha
	JNZ valor_ciclo  	; continua enquanto a linha não for zero
	SUB R7, 1			; subtrai 1 ao valor do contador para o valor ficar certo
	RET
	
conv_hexa:
	SHR R6, 2           ; multiplica o valor da linha por 4
	ADD R6, R0          ; adiciona o valor da coluna e guarda no R6
	RET
	
verifica_tecla:
	MOV R0, 4			; guarda o valor 5 em R0
	CMP R6, R0			; testa se a tecla premida é o 5
	JZ aumenta_display	; incrementa o valor do display
	
	MOV R0, 5			; guarda o valor 6 em R0
	CMP R6, R0			; testa se a tecla premida é o 6
	JZ diminui_display	; decrementa o valor do display
	RET
	
aumenta_display:
	 ADD R11, 1			; incrementa o valor do display
	 MOV [R4], R11		; escreve no periférico do display
	 RET
	 
diminui_display:
	 SUB R11, 1			; decrementa o valor do display
	 MOV [R4], R11		; escreve no periférico do display
	 RET




;*****************************************************************
; ****************** NAVE ***************************************
;*****************************************************************
desenha_nave:
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4
	PUSH R5
	PUSH R6
	MOV R1, LINHA_NAVE
	MOV R2, COLUNA_NAVE
	MOV R4, DEF_NAVE
	MOV R5, LARGURA_NAVE
	MOV R6, ALTURA_NAVE
	JMP linha_seguinte		; comeca a desenhar a nave
	
ciclo_nave:					; altera os valores para desenhar a próxima linha da nave
	MOV R2, COLUNA_NAVE
	MOV R5, LARGURA_NAVE
	ADD R1, 1
	SUB R6, 1
	JNZ linha_seguinte		
	POP R6					; repoe todos os valores nos seus registos
	POP R5
	POP R4
	POP R3
	POP R2
	POP R1
	RET						; volta quando terminou de desenhar a nave

linha_seguinte:
	CALL desenha_pixels
	JMP ciclo_nave
	
	
;*****************************************************************
; ****************** TIRO ***************************************
;*****************************************************************
desenha_tiro:
	PUSH R1
	PUSH R2
	PUSH R3
	MOV R1, LINHA_TIRO
	MOV R2, COLUNA_TIRO
	MOV R3, COR_TIRO
	CALL escreve_pixel
	POP R3
	POP R2
	POP R1
	RET

;*****************************************************************
; ****************** ASTEROIDE ***********************************
;*****************************************************************
desenha_ast:
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4
	PUSH R5
	PUSH R6
	MOV R1, LINHA_AST
	MOV R2, COLUNA_AST
	MOV R4, DEF_AST
	MOV R5, LARGURA_AST
	MOV R6, ALTURA_AST
	JMP linha_seguinte2			;começa a desenhar o asteroide
	
ciclo_ast:						; altera os valores para desenhar a proxima linha do asteroide
	MOV R2, COLUNA_AST
	MOV R5, LARGURA_AST
	ADD R1, 1
	SUB R6, 1
	JNZ linha_seguinte2	
	POP R6						; repoe todos os valores nos seus registos
	POP R5
	POP R4
	POP R3
	POP R2
	POP R1
	RET							; volta quando terminou de desenhar o asteroide
	
linha_seguinte2:
	CALL desenha_pixels
	JMP ciclo_ast


; **********************************************************************
; ESCREVE_PIXEL - Escreve um pixel na linha e coluna indicadas.
; Argumentos:   R1 - linha
;               R2 - coluna
;               R3 - cor do pixel (em formato ARGB de 16 bits)
;
; **********************************************************************
escreve_pixel:
	MOV  [DEFINE_LINHA], R1		; seleciona a linha
	MOV  [DEFINE_COLUNA], R2	; seleciona a coluna
	MOV  [DEFINE_PIXEL], R3		; altera a cor do pixel na linha e coluna já selecionadas
	RET

desenha_pixels:       		; desenha os pixels do boneco a partir da tabela
	MOV	R3, [R4]			; obtém a cor do próximo pixel do boneco
	CALL	escreve_pixel		; escreve cada pixel do boneco
	ADD	R4, 2			; endereço da cor do próximo pixel (2 porque cada cor de pixel é uma word)
     ADD  R2, 1               ; próxima coluna
     SUB  R5, 1			; menos uma coluna para tratar
     JNZ  desenha_pixels      ; continua até percorrer toda a largura do objeto
	RET



