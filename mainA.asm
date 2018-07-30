;*****************************************************************
;* KeyWakeup.ASM
;* 
;*****************************************************************
; export symbols
            XDEF Entry, _Startup            ; export 'Entry' symbol
            ABSENTRY Entry        ; for absolute assembly: mark this as application entry point

; Include derivative-specific definitions 
		INCLUDE 'derivative.inc' 
		
;-------------------------------------------------- 
; Equates Section  
;----------------------------------------------------  
ROMStart    EQU  $2000  ; absolute address to place my code

;---------------------------------------------------- 
; Variable/Data Section
;----------------------------------------------------  
            ORG RAMStart   ; loc $1000  (RAMEnd = $3FFF)
; Insert here your data definitions here

COUNT  DS.B  1


       INCLUDE 'utilities.inc'
       INCLUDE 'LCD.inc'

;---------------------------------------------------- 
; Code Section
;---------------------------------------------------- 
            ORG   ROMStart  ; loc $2000
Entry:
_Startup:
            ; remap the RAM &amp; EEPROM here. See EB386.pdf
 ifdef _HCS12_SERIALMON
            ; set registers at $0000
            CLR   $11                  ; INITRG= $0
            ; set ram to end at $3FFF
            LDAB  #$39
            STAB  $10                  ; INITRM= $39

            ; set eeprom to end at $0FFF
            LDAA  #$9
            STAA  $12                  ; INITEE= $9
            JSR   PLL_init      ; initialize PLL  
  endif

;---------------------------------------------------- 
; Insert your code here
;---------------------------------------------------- 
         LDS   #ROMStart ; load stack pointer
* Port H interrupt program for Dragon12
* Lights LED 0 (and clears LED1) when sw5 is pressed (PH0)
* Lights LED 1 (and clears LED0) when sw4 is pressed (PH1)
          jsr led_enable
; note Port H is all inputs after reset
          BCLR    PPSH, #$07    ; set Port H pins 0-1 for falling edge
          MOVB    #$07, PIFH    ; clear interrupt flags initially
          BSET    PIEH, $07     ; enable interrupts on Port H  pins 0-1
          CLI                   ; enable interrupts
          CLR     COUNT
          
LOOP      JSR     GREEN
          JSR     DELAY
          BCLR    PTP, $10 + $20 + $40
          JSR     DELAY
          BRA     LOOP
          
                          ; endless loop waiting for reset (and for interrupts)


; Note: main program is an endless loop and subroutines follow
; (Must press reset to quit.)

;===================================================================

        
; ISR must test to see which button was pressed, because there ;is only one ISR for the two enabled buttons

PTHISR:  ; the interrupt service routine
         BRSET  PIFH, %00000001,PUSHBTN0  ; test btn0 IF flag
         JSR    DELAY
         BRSET  PIFH, %00000010,PUSHBTN1  ; test btn1 IF flag
         JSR    DELAY
         BRSET  PIFH, %00000100,PUSHBTN2  ; test btn1 IF flag
         JSR    DELAY
; NOTE:  Flags are tested –not the switches
         BRA    DONE
PUSHBTN0:
         BCLR  PORTB, %11110000    ; clear LED7-4
         LDAA  PTH
         LSRA
         LSRA
         LSRA
         LSRA
         ANDA  #%00001111
         STAA  COUNT
         STAA  PORTB  
         BRA   DONE
PUSHBTN1:
         LDAA  PORTB
         CMPA  #%1111
         BHS   ZERO
         INC   COUNT
         LDAA  COUNT
         STAA  PORTB
         BRA   DONE
ZERO     CLR   COUNT
         CLR   PORTB
         BRA   DONE
PUSHBTN2:
         LDAA  PORTB
         CMPA  #0
         BEQ   ONE
         DEC   COUNT
         LDAA  COUNT
         STAA  PORTB
         BRA   DONE
ONE      LDAA  #%00001111
         STAA  COUNT
         STAA  PORTB
         BRA   DONE        
DONE
         MOVB  #$07, PIFH    ; clear Port H interrupt flags
         RTI
       
GREEN    BSET  PTP, $40
         RTS
        
DELAY    ldab    #250    ;  1 cycle
dly1:    ldy     #6000   ; 6000 x 4 = 24,000 cycles = 1ms
dly:     dey             ; 1 cycle
         bne     dly     ; 3 cycles
         decb            ; 1 cycle
         bne     dly1    ; max. 3 cycles (3/1)
         rts               
                         
;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
            ORG   Vreset
            DC.W  Entry         ; Reset Vector
            
;***********************************************************
            ORG     Vporth     ; setup  Port H interrupt Vector
            DC.W    PTHISR
                            
 