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
LINHA      EQU 1       ; linha a testar (4ª linha, 1000b)
ZERO       EQU 0
MASCARA    EQU 0FH     ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado


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
						
; **********************************************************************
; * Código
; **********************************************************************
	PLACE 0
inicio:

MOV  SP, SP_inicial        ; inicializa SP para a palavra a seguir
                           ; à última da pilha
	
; inicializações
    MOV  R2, TEC_LIN   	; endereço do periférico das linhas
    MOV  R3, TEC_COL   	; endereço do periférico das colunas
    MOV  R4, DISPLAYS  	; endereço do periférico dos displays
    MOV  R5, MASCARA   	; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
	MOV  R1, LINHA	   	; para guardar a linha que está a ser testada
	MOV  R7, ZERO

	
; corpo principal do programa
ciclo:
    MOV  R0, ZERO
	MOV R1, LINHA
    MOVB [R4], R0      	; escreve linha e coluna a zero nos displays

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
    MOVB [R4], R6      	; escreve linha e coluna nos displays
    
ha_tecla:              	; neste ciclo espera-se até NENHUMA tecla estar premida
    MOVB R0, [R3]      	; ler do periférico de entrada (colunas)
    AND  R0, R5        	; elimina bits para além dos bits 0-3
    CMP  R0, 0         	; há tecla premida?
    JNZ  ha_tecla      	; se ainda houver uma tecla premida, espera até não haver
    JMP  ciclo         	; repete ciclo

converte_valor:
	MOV R7, ZERO	   	; reseta o contador a zero
	
valor_ciclo:  	   		; transforma o valor das linhas e colunas para 0,1,2,3
	ADD R7, 1			; soma um ao contador
	SHR R1, 1           ; diminui o valor da linha
	JNZ valor_ciclo  	; continua enquanto a linha não for zero
	SUB R7, 1			; subtrai 1 ao valor do contador para o valor ficar certo
	RET
	
conv_hexa:
	SHR R6, 2
	ADD R6, R0
	RET