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
         JSR   led_enable
         
MAIN     
         JSR   DataIn
         STAA  PORTB
         BRA   MAIN
         

; Note: main program is an endless loop and subroutines follow
; (Must press reset to quit.)

;===================================================================

        
; ISR must test to see which button was pressed, because there ;is only one ISR for the two enabled buttons

DataIn   
         BRSET  PIFH, %00000001,Read  ; test btn0 IF flag
         bra    QUIT
Read     LDAA   PTH
         LSRA
         LSRA
         LSRA
         LSRA
         ANDA   #%00001111         
         JSR    INIT   ; clear interrupt flags initially
QUIT        
         RTS
         
INIT
         MOVB  #$03, PIFH   ; clear Port H interrupt flags
         RTS
                           
                         
;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
      
            
;***********************************************************
            
                            
 