;
; Trabalho_final.asm
;
; Created: 05/12/2017 23:15:35
; Author : Miguel Castro
;



.NOLIST
.INCLUDE "m324adef.inc" ;
.LIST



.CSEG
.ORG 0x0000
JMP INICIO

.CSEG
.ORG 0x0002
JMP PARA_CONVERSAO  ;interrup��o externa INT0 - p�ra de converter (OFF) = PD2

.CSEG
.ORG 0x0004
JMP CONVERSAO  ;interrup��o externa INT1 - inicia a convers�o (ON) = PD3

.CSEG
.ORG 0x001C  ;posi��o de mem�ria associada ao Timer/Coutner1 Compare Match B
JMP RENCICIAR_TIMER

.CSEG
.ORG 0x0028  ;interrup��o de esvaziamento do buffer do USART_RX
RETI

.CSEG
.ORG 0X0030   ;corresponde ao fim da convers�o do ADC - ADC Conversion Complete
JMP ADC_EOC_INT

.CSEG
.ORG 0X0060 ; indica que o c�digo vai ser colocado na numa posi��o acima dos vectores de interrup��o



INICIO:
	;LED a piscar
	LDI R16,0XFF ; carrega imediato de 0XFF para R16
	OUT DDRB,R16 ; inicializa o porto B como porto de sa�da

	LDI R16,(1<<ISC11)|(1<<ISC10)|(1<<ISC01)|(1<<ISC00)  ;INT0 e INT1 ativam quando recebem uma tens�o crescente
	STS EICRA,R16  ;EICRA - External Interrupt Control Register A
	LDI R16,(1<<INT1)|(1<<INT0)  ;ativa��o das interrup��es externas
	OUT EIMSK,R16  ; EIMSK - External Interrupt Mask Register
	
	CALL USART
	CALL ADC_INIT
	SEI  ;ativar interrup��o global



CICLO:  ;rotina de espera
	NOP
	NOP
	JMP CICLO



CONVERSAO:  ;vai ser a interrup��o externa 1 = INT1
	LDS R16,ADCSRA  ;defini os par�metros de funcionamento do ADC
	;ADSC: ativa o bit de in�cio de convers�o iniciando a primeira convers�o
	;ADATE: modo auto-trigger
	ORI R16,(1<<ADSC)|(1<<ADATE)  ;ORI = Logical OR with Immediate
	STS ADCSRA,R16  ;ADCSRA - ADC Control and Status Register A

	CALL INICIO_TIMER  ;in�cio do timer
	RETI



PARA_CONVERSAO:  ;vai ser a interrup��o externa 0 = INT0
	LDS R16,ADCSRA  ;defini os par�metros de funcionamento do ADC
	ORI R16,(0<<ADSC)|(0<<ADATE)  ;desativa o bit de in�cio de convers�o (ADSC) e o modo auto-trigger (ADATE), ORI = Logical OR with Immediate
	STS ADCSRA,R16
	LDI R16,0XFF  ;R16 = 0xFF = 11111111
	STS DIDR0,R16  ;DIDR0 => desativa os pinos e assim permite um menor gasto de energia
	LDI R16,(0<<CS12)|(0<<CS11)|(0<<CS10)  ;desativar timer, p�ra o clock
	STS TCCR1B,R16  ;TCCR1B - TC1 Control Register B
	RETI



INICIO_TIMER:
	LDI R16,(0<<CS12)|(0<<CS11)|(1<<CS10)  ;coloca o timer sem prescaling
	STS TCCR1B,R16

	LDI R16,(1<<OCIE1B)  ;ativa a interrup��o aquando a compara��o com o timer
	STS TIMSK1,R16  ;TIMSK1 - Timer/Counter 1 Interrupt Mask Register

	;famostragem total = 20Hz * 3 = 60Hz (3 ADC). Tempo = 1/60 (divis�o por 3 canais) = 0.016667/3 = 0.005556 s = 5556 us = ciclos de rel�gio e arredondado 5600 = 00010101 11100000
	LDI R26,0xE0  ;0xE0 = 11100000
	LDI R27,0x15  ;0x15 = 00010101  
	STS OCR1BL,R26  ;OCR1BL e OCR1BH - Output Compare Register 1 B Low and High byte
	STS OCR1BH,R27   
	RET
	


RENCICIAR_TIMER:     ; reinicia o timer
	LDI R16,0x00
	STS TCNT1L,R16  ;reset no timer relativamente aos registos Low
	STS TCNT1H,R16  ;reset no timer relativamente aos registos High

	RETI



USART:  ;rotina que inicializa a porta s�rie
	LDI R17,0X00  ;registo 17 tudo a zeros
	LDI R16,12  ;baud rate = 9600, para frequ�ncia de oscila��o a 1MHz; 12 porque usamos a velocidade a dobrar
	STS UBRR0L,R16  ;relacionado com os bits menos significativos
	STS UBRR0H,R17  ;relacionado com os bits mais significativos
	LDI R18,(1<<U2X0)  ;define Asynchronous Double Speed mode => duplica a taxa de tranfer�ncia de dados e reduz a percentagem de erros relativos
	STS UCSR0A,R18  ;UCSR0A - USART Control and Status Register n A
	LDI R16,(1<<RXEN0)|(1<<TXEN0)  ;activa o envio e recep��o pela porta s�rie; RXEN - receiver enable e TXNE - transmitter enable
	STS UCSR0B,R16  ;UCSR0B - USART Control and Status Register n B
	LDI R16,(1<<USBS0)|(3<<UCSZ00)  ;set frame format: dois stops bits (1<<USBS0) e tamanho do carater = 8 bits (3<<UCSZ00)
	STS UCSR0C,R16  ;UCSR0C - USART Control and Status Register n C
	RET



ADC_INIT:  ;rotina que inicializa o ADC
    LDI R16,(1<<ADTS2)|(0<<ADTS1)|(1<<ADTS0)  ;escolhe quem decide a convers�o: Timer/Counter1 Compare Match B
	STS ADCSRB,R16

	LDI R16,0xFF ;coloca todos os pins a 1 de modo reduzir o consumo de energia na entrada digital
	STS DIDR0,R16  ;DIDR0 - Digital Input Disable Register 0

	;ADEN: ADC enable  
	;ADIE: ADC interrupt enable
	;ADPSn: ADC prescaler select (100 => fator de divis�o = 16), com n = [0:2], para melhorar o sinal
	LDI R16,(1<<ADEN)|(1<<ADIE)|(1<<ADPS2)  ;liga o ADC e liga a interrup��o de fim de conversao
	STS ADCSRA,R16
	
	LDI R17,(1<<REFS1)|(1<<REFS0)  ;defini��o da refer�ncia do ADC a 2.56V
	STS ADMUX,R17

	RET



ADC_EOC_INT:
	LDS R28,UCSR0A  ;indica se o buffer de transmiss�o est� vazio (1 = buffer vazio)
	SBRS R28,UDRE0  ;aguarda que o buffer fique vazio; UDRE0 - Data Register Empty
	RJMP ADC_EOC_INT
	
	LDS R16,ADMUX  ; l� a configura�ao do admux para identifica�ao do canal convertido 
	STS UDR0,R16  ; e envia pela porta s�rie 
	
	CALL MUDA_CANAL

MANDA_LOW:
	LDS R28,UCSR0A  ;indica se o buffer de transmiss�o est� vazio (1 = buffer vazio)
	SBRS R28,UDRE0  ;aguarda que o buffer fique vazio
	RJMP MANDA_LOW

	LDS R26,ADCL  ;l� os bits menos significativos convertidos pelo ADC
	STS UDR0,R26  ; e envia pela porta s�rie
	;LDI R16,0xAA - TESTE
	;STS UDR0,R16 - TESTE

MANDA_HIGH:
	LDS R28,UCSR0A  ;indica se o buffer de transmiss�o est� vazio (1 = buffer vazio)
	SBRS R28,UDRE0  ;aguarda que o buffer fique vazio
	RJMP MANDA_HIGH

	LDS R27,ADCH  ;l� os bits mais significativos convertidos pelo ADC
	STS UDR0,R27  ; e envia pela porta s�rie
	;LDI R16,0xBB - TESTE
	;STS UDR0,R16 - TESTE

	CALL TOGGLE

	RETI



MUDA_CANAL:
ADC3:	
	LDS R16,ADMUX  ;verifica se o canal convertido foi o ADC0
	LDI R17,0xC3  ;uma vez que os tr�s �ltimos bits s�o constantes, assim obtemos 0xC3 = 11000011
	CP R16,R17  ;compara��o dos registos
	BREQ ENDR3  ;se forem iguais salta para ENDR0, sen�o segue para o pr�ximo c�digo

ADC4:
	LDS R16,ADMUX  ;verifica se o canal convertido foi o ADC1
	LDI R17,0xC4  ;0xC4 = 11000100
	CP R16,R17
	BREQ ENDR4

ADC5:
	LDS R16,ADMUX   ;verifica se o canal convertido foi o ADC2
	LDI R17,0xC5  ;0xC5 = 11000101
	CP R16,R17
	BREQ ENDR5

ENDR3:  ;caso o ADC0 tenha sido lido na �ltima convers�o na pr�xima convers�o dever� ser lido o ADC1
	LDI R16,0xC4;
	STS ADMUX,R16
	JMP END

ENDR4:  ;caso o ADC1 tenha sido lido na �ltima convers�o na pr�xima convers�o dever� ser lido o ADC2
	LDI R16,0xC5
	STS ADMUX,R16
	JMP END

ENDR5:  ;caso o ADC2 tenha sido lido na �ltima convers�o na pr�xima convers�o dever� ser lido o ADC0
	LDI R16,0xC3
	STS ADMUX,R16
	JMP  END

END:
	RET



TOGGLE:  ;faz o toggle do PB0
	IN	R16,PORTB
	LDI R17,0X01  ;0x01 = 00000001
	EOR R16,R17  ;EOR = exclusive OR
	OUT PORTB,R16

	RET