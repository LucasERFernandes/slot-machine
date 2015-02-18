	list p = '16F877A'
	org 0x00
	goto ini

	org 0x04
	goto interrupt
	ini:

	bcf 0x03, 6
	bsf 0x03, 5

	clrf 0x85
	clrf 0x86
	clrf 0x87
	clrf 0x88
	clrf 0x89

	bsf 0x86, 0 ; Configurando botões de entrada
	bsf 0x86, 7 ; Duas interrupções no RB0 e no RB7

	movlw 0x04
	movwf 0x81 ; Configurando Option_Reg
	
	movlw 0x03
	movwf 0x8C ; configurando tmr1 e tmr2
	
	movlw 0x05
	movwf 0x92 ; contagem máxima do tmr2

	movlw 0x06
	movwf 0x97 ; Ativando entradas digitais

	bcf 0x03, 5
	
	; limpando PORTS
	clrf 0x05
	clrf 0x06
	clrf 0x07
	clrf 0x08
	clrf 0x09

	movlw 0xF8
	movwf 0x0B ; Configurando IntCon - Interrupções usadas RBO, RB7, TMR0, TMR1 e TMR2

	movlw 0x06
	movwf 0x01 ; Inicializando TRM0

	; zerando os contadores do tmr1
	clrf 0x0E
	clrf 0x0F

	movlw 0x30 ; configurando t1con1
	movwf 0x10

	movlw 0x44
	movwf 0x12 ; configurando t2con

	movlw .64 ; Manda 32 para o contador 
	movwf 0x27 ; Diz qual é o valor atual para o variável auxiliar do TMR0
	movf 0x27, 0
	movwf 0x20 ; Inicializando variável auxiliar para o TMR0

	clrf 0x21 ; Variável para trocar o valor dos leds
	clrf 0x22 ; Variável com o valor do led 1
	clrf 0x23 ; Variável com o valor do led 2
	clrf 0x24 ; Variável com o valor do led 3
	clrf 0x25 ; Variável com o valor do led 4
	
 	clrf 0x30 ; variável para impedir o uso dos dois botões em uma mesma 'partida'

	movlw 0x04
	movwf 0x26 ; variavel que conta quantos leds estão acessos

	clrf 0x28  ; variável auxiliar do timer 1
	
	loop: 
		; função acende e apaga os leds
		; Uma variável contém os dados/ informação de cada led em especifico 
		movf 0x22, 0
		movwf 0x07
		bcf 0x08 , 0
		bsf 0x08 , 0

		movf 0x23, 0
		movwf 0x07
		bcf 0x08 , 1
		bsf 0x08 , 1

		movf 0x24, 0
		movwf 0x07
		bcf 0x08 , 2
		bsf 0x08 , 2
		
		movf 0x25, 0
		movwf 0x07
		bcf 0x08 , 3
		bsf 0x08 , 3

	goto loop

	interrupt:
	
	btfsc 0x0B, 0
		goto RB7
	btfsc 0x0B, 1
		goto RB0
	btfsc 0x0B, 2
		goto TMR0
	btfsc 0x0C, 0
		goto TMR1
	btfsc 0x0C, 1
		goto TMR2

	RETFIE

	RB7:
		; bcf 0x0B, 0
		bsf 0x06, 7
		bcf 0x0B, 0


		btfsc 0x30, 7
			RETFIE
		
		movlw 0x04
		subwf 0x26, 0
		btfsc 0x03, 2			
			goto RB7quatroLed

		movlw 0x03
		subwf 0x26, 0
		btfsc 0x03, 2			
			goto RB7tresLed

		movlw 0x02
		subwf 0x26, 0
		btfsc 0x03, 2			
			goto RB7doisLed
  
		movlw 0x01
		subwf 0x26, 0
		btfsc 0x03, 2			
			goto RB7umLed
		RETFIE
		
		RB7quatroLed:
	
			movlw .3
			movwf 0x26		
			movlw .32
			movwf 0x27

		RETFIE
		
		RB7tresLed:
		
			movlw .2
			movwf 0x26
			movlw .16
			movwf 0x27
		
			movf 0x22, 0
			subwf 0x23, 0
			btfss 0x03, 2
				goto retro		

		RETFIE

		RB7doisLed:
			movlw .1
			movwf 0x26
			movlw .8
			movwf 0x27

			movf 0x23, 0
			subwf 0x24, 0
			btfss 0x03, 2
				goto retro
		RETFIE
		RB7umLed:
			movlw .0
			movwf 0x26
			movlw .4
			movwf 0x27
	

			movf 0x24, 0
			subwf 0x25, 0
			btfss 0x03, 2
				goto retro
			bsf 0x05, 0
				goto retro
		RETFIE

		retro: ; reiniciar o contador / Espera um segundo e reinicia 
			; zerando os contadores do tmr1
			clrf 0x0E
			clrf 0x0F
			
			movf 0x11, 0 ; pegando número 'aleatório' do Tmr2
			movwf 0x28 ; 
			incf 0x28, 1
	
			
		
			clrf 0x26 ; não pode trocar o valor de nenhuma variável
			movlw 0x04 ;
			movwf 0x28 ; Configura o timer1 para esperar 2 segundos e reiniciar tudo
			bsf 0x22, 7 ; flag que informa que tudo deve ser reiniciado
		
			bsf 0x10, 0; ativando interrupção do tmr1
		RETFIE
	
	RB0: 
		bcf 0x0B, 1
	
		movlw 0x04 ; Não pode abertar o botão enquanto uma função está rodando
		subwf 0x26, 0
		btfss 0x03, 2
			RETFIE
		movlw .3
		movwf 0x26
		
		movlw .32
		movwf 0x27
	
		; zerando os contadores do tmr1
		clrf 0x0E
		clrf 0x0F
		
		movf 0x11, 0 ; pegando número 'aleatório' do Tmr2
		movwf 0x28 ; 
		incf 0x28, 1

		bsf 0x10, 0; ativando interrupção do tmr1
		bsf 0x30, 7; seta uma flag para caso o botão do outro jogo seja apertado, não causa algum efeito
		RETFIE


	TMR0:
		bcf 0x0B, 2	; limpa flag do tmr0
		movlw 0x06 ; repõe o valor de inicio de contagem do tmr0
		movwf 0x01
		decfsz 0x20, 1 ; Verficar váriavel auxiliar da contagem
			RETFIE
		movf 0x27, 0 ; repondo valor da várivel auxiliar de contagem que está no registrador 0x27
		movwf 0x20

		movlw 0x05 ; verificar valor máximo
		subwf 0x21, 0
		btfsc 0x03, 2
			goto reset
		incf 0x21, 1;
		goto trocaLed
		reset:
			clrf 0x21
		goto trocaLed

		trocaLed:
			movlw 0x04
			subwf 0x26, 0
			btfsc 0x03, 2			
				goto quatroLed
			movlw 0x03
			subwf 0x26, 0
			btfsc 0x03, 2			
				goto tresLed
			movlw 0x02
			subwf 0x26, 0
			btfsc 0x03, 2			
				goto doisLed
			movlw 0x01
			subwf 0x26, 0
			btfsc 0x03, 2			
				goto umLed
			RETFIE

			quatroLed:
				movf 0x21,0 
				movwf 0x22
				movwf 0x23
				movwf 0x24
				movwf 0x25			
				RETFIE
			tresLed:
				movf 0x21,0
				movwf 0x23
				movwf 0x24
				movwf 0x25	
				RETFIE
			doisLed:
				movf 0x21,0
				movwf 0x24
				movwf 0x25
				RETFIE
			umLed:
				movf 0x21,0
				movwf 0x25	
				RETFIE

	TMR1:
		bcf 0x0C, 0
		decfsz 0x28, 1
			RETFIE
		; verifica se o tmr1 não está contando o tempo para reiniciar os leds
		; uso um bit do primeiro led para verficar se precisar dar um refresh na tela		
		btfsc 0x22, 7
			goto refresh

		movlw 0x03
		subwf 0x26, 0
		btfsc 0x03, 2			
			goto verTresLed
		movlw 0x02
		subwf 0x26, 0
		btfsc 0x03, 2			
			goto verDoisLed
		movlw 0x01
		subwf 0x26, 0
		btfsc 0x03, 2			
			goto verUmLed
		verTresLed:
			
			movlw .2
			movwf 0x26
			movlw .16
			movwf 0x27
		
			movf 0x22, 0
			subwf 0x23, 0
			btfss 0x03, 2
				goto reiniciar
			
			movf 0x11, 0 ; pegando número 'aleatório' do Tmr2
			movwf 0x28 ; 
			incf 0x28, 1

		RETFIE
		verDoisLed:
			movlw .1
			movwf 0x26
			movlw .8
			movwf 0x27

			movf 0x23, 0
			subwf 0x24, 0
			btfss 0x03, 2
				goto reiniciar
			movf 0x11, 0 ; pegando número 'aleatório' do Tmr2
			movwf 0x28 ; 
			incf 0x28, 1
		
		RETFIE
		verUmLed
			movlw .0
			movwf 0x26
			movlw .4
			movwf 0x27
	

			movf 0x24, 0
			subwf 0x25, 0
			btfss 0x03, 2
				goto reiniciar
			bsf 0x05, 0
				goto reiniciar
		RETFIE

		reiniciar: ; reiniciar o contador / Espera um segundo e reinicia 
			clrf 0x26
			movlw 0x04 ;
			movwf 0x28 ; Configura o timer1 para esperar 2 segundos e reiniciar tudo
			bsf 0x22, 7
		RETFIE

		refresh;
		bcf 0x22, 7
		bcf 0x10, 0; desativando interrupção do tmr1
		bcf 0x05, 0; apagar led
		clrf 0x21 ; Variável para trocar o valor dos leds
	
		movlw 0x05 ; reinicia e aparecer 0 como primeiro número
		movwf 0x21
		clrf 0x22 ; Variável com o valor do led 1
		clrf 0x23 ; Variável com o valor do led 2
		clrf 0x24 ; Variável com o valor do led 3
		clrf 0x25 ; Variável com o valor do led 4
	
		movlw .64 ; Manda 32 para o contador 
		movwf 0x27 ; Diz qual é o valor atual para o variável auxiliar do TMR0
			
		movlw 0x04
		movwf 0x26 ; variavel que conta quantos leds estão acessos
		bcf 0x30, 7; limpa a flag dos botões, independente da onde tenha vindo
		RETFIE
		
	TMR2:
		bcf 0x0C, 1
		RETFIE
	end