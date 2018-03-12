LIST P=16F84A

;LANGUAGE               RISC-like architecture
;WRITTEN BY             Franz Ayestaran
;DATE                   08/08/97               
;FILE SAVED AS          LCD_Module_16x2_4Bit.ASM
;FOR PIC 16C84          18 pin device
;RESONATOR              4MHz
;CODE PROTECTION        OFF
;SOFTWARE FUNCTION      'Create a 16 character message 
;                        using the <UP><DOWN><ENTER> key'

;= 16x2 LCD MODULE =
;===================

;Pin D Symbol Level I/O Function 
; 1  9  Vss    -     -  Power supply (GND) 
; 2  0  Vdd    -     -  Power supply (+5V) 
; 3  9  V0     -     -  Contrast adjust 
; 4  5  RS     0/1   I  0 = Instruction input 1 = Data input 
; 5  9  R/W    0/1   I  0 = Write to LCD module 1 = Read from LCD module 
; 6  6  E      1-->0 I  Enable signal 
; 7  -  DB0    0/1  I/O Data bus line 0 (LSB) 
; 8  -  DB1    0/1  I/O Data bus line 1 
; 9  -  DB2    0/1  I/O Data bus line 2 
;10  -  DB3    0/1  I/O Data bus line 3 
;11  1  DB4    0/1  I/O Data bus line 4 
;12  2  DB5    0/1  I/O Data bus line 5 
;13  3  DB6    0/1  I/O Data bus line 6 
;14  4  DB7    0/1  I/O Data bus line 7 (MSB) 
;15  0  LED             BACKLIGHT +
;16  9  LED             BACKLIGHT -

;    8  LED             RED ANODE
;    7  LED             GREEN ANODE
;    0  +5V             POWER SUPPLY
;    -                  NOT USED
 
;==== DECLARE VARIABLES (f) ====
;===============================

PC      EQU     2
STATUS  EQU     3
PA0     EQU     0
OPTREG  EQU     81H
RP0     EQU     5
CHAR    EQU     010H
NIBBLE  EQU     011H
LETTER  EQU     012H
DIRECTION EQU   013H
DISPLAY EQU     014H
ZERO    EQU     00H

LEFT    EQU     B'00100000'
RIGHT   EQU     B'00100100'
LINE1   EQU     B'00101000'
LINE2   EQU     B'00101100'
DISPLAY_ON  EQU B'00101111'
DISPLAY_OFF EQU B'00101011'

BIT0    EQU     0
BIT1    EQU     1
BIT2    EQU     2
BIT3    EQU     3
BIT4    EQU     4
BIT5    EQU     5
BIT6    EQU     6
BIT7    EQU     7

DB4     EQU     0 ;Pin1 Gray
DB5     EQU     1 ;Pin2 White
DB6     EQU     2 ;Pin3 Black
DB7     EQU     3 ;Pin4 Brown

RS      EQU     4 ;Pin5 Yellow
ENABLE  EQU     5 ;Pin6 Blue

;== DEFINE PORT-A (A0-A4) ==

PORTA   EQU     05H

;== DEFINE PORT-B (B0-B7) ==

TRISB   EQU     86H    
PORTB   EQU     06H
OPTION  EQU     88H

;===========================

GOTO    INITIALISE

;*** SUBROUTINES ***
;*******************

SET_DELAY                       ;Sleep Function
        BSF     STATUS,RP0      ;SELECT REGISTER BANK 1
        MOVWF   OPTREG^80H      ;ASSIGN PRESCALER (1:4) TO WDT
        BCF     STATUS,RP0      ;SELECT REGISTER BANK 0
        RETURN

STROBE
        SLEEP
        BCF     PORTB,ENABLE       
        RETURN

;RS RW DB7 DB6 DB5 DB4 DB3 DB2 DB1 DB0                               
;0  0   0   0   1  DL   N   F   *   *    
SET_FUNCTION
        MOVLW   B'00100010'     
        MOVWF   PORTB
        CALL    STROBE      
        MOVLW   B'00100010'     
        MOVWF   PORTB
        CALL    STROBE
        MOVLW   B'00101000'    
        MOVWF   PORTB
        CALL    STROBE
        RETURN

;RS RW DB7 DB6 DB5 DB4 DB3 DB2 DB1 DB0                               
;0  0   0   0   0   0   0   1  I/D  S  
ENTRY_MODE_SET
        MOVLW   B'00100000'
        MOVWF   PORTB
        CALL    STROBE
        MOVLW   B'00100110'     
        MOVWF   PORTB
        CALL    STROBE
        RETURN

;RS RW DB7 DB6 DB5 DB4 DB3 DB2 DB1 DB0                               
;0  0   0   0   0   0   1   D   C   B  
SET_DISPLAY
        MOVWF   DISPLAY
        MOVLW   B'00100000'
        MOVWF   PORTB
        CALL    STROBE
        MOVFW   DISPLAY
        MOVWF   PORTB
        CALL    STROBE
        RETURN

;RS RW DB7 DB6 DB5 DB4 DB3 DB2 DB1 DB0                               
;0  0   0   1   A   A   A   A   A   A  
SET_CG_RAM_ADDRESS
        MOVLW   B'00100100'
        MOVWF   PORTB
        CALL    STROBE
        MOVLW   B'00100000'
        MOVWF   PORTB
        CALL    STROBE
        RETURN

;RS RW DB7 DB6 DB5 DB4 DB3 DB2 DB1 DB0                               
;0  0   1   A   A   A   A   A   A   A  
SET_DD_RAM_ADDRESS
        MOVLW   B'00101000'
        MOVWF   PORTB
        CALL    STROBE
        MOVLW   B'00100000'
        MOVWF   PORTB
        CALL    STROBE
        RETURN

;RS RW DB7 DB6 DB5 DB4 DB3 DB2 DB1 DB0                               
;0  0   0   0   0   1  S/C R/L  *   *   

;S/C R/L                                          
;=== ===                                          
; 1   0   Shifts the entire display to the left  
;         The cursor follows the display shift   
; 1   1   Shifts the entire display to the right 
;         The cursor follows the display shift   

SHIFT_DISPLAY_LEFT
        MOVLW   B'00100001'
        MOVWF   PORTB
        CALL    STROBE
        MOVLW   B'00101000'
        MOVWF   PORTB
        CALL    STROBE
        RETURN

;RS RW DB7 DB6 DB5 DB4 DB3 DB2 DB1 DB0                               
;0  0   0   0   0   1  S/C R/L  *   *   

;S/C R/L                                          
;=== ===                                          
; 1   0   Shifts the entire display to the left  
;         The cursor follows the display shift   
; 1   1   Shifts the entire display to the right 
;         The cursor follows the display shift   

SHIFT_DISPLAY_RIGHT
        MOVLW   B'00100001'
        MOVWF   PORTB
        CALL    STROBE
        MOVLW   B'00101100'
        MOVWF   PORTB
        CALL    STROBE
        RETURN

;RS RW DB7 DB6 DB5 DB4 DB3 DB2 DB1 DB0                               
;0  0   0   0   0   1  S/C R/L  *   *   

;S/C R/L                                          
;=== ===                                          
; 0   0   Shifts the cursor position to the left 
;         (Address Counter is decremented by 1)   
; 0   1   Shifts the cursor position to the right
;         (Address Counter is incremented by 1)  

MOVE_CURSOR
        MOVWF   DIRECTION
        MOVLW   B'00100001'
        MOVWF   PORTB
        CALL    STROBE
        MOVFW   DIRECTION
        MOVWF   PORTB
        CALL    STROBE
        RETURN

;RS RW DB7 DB6 DB5 DB4 DB3 DB2 DB1 DB0                               
;0  0   0   0   0   0   0   0   0   1   
CLEAR_DISPLAY
        MOVLW   B'00100000'
        MOVWF   PORTB
        CALL    STROBE
        MOVLW   B'00100001'
        MOVWF   PORTB
        CALL    STROBE
        RETURN

;RS RW DB7 DB6 DB5 DB4 DB3 DB2 DB1 DB0                               
;0  0   0   0   0   0   0   0   1   0   
RETURN_HOME
        MOVLW   B'00100000'
        MOVWF   PORTB
        CALL    STROBE
        MOVLW   B'00100010'
        MOVWF   PORTB
        CALL    STROBE
        RETURN

GOTO_LINE
        MOVWF   PORTB
        CALL    STROBE
        MOVLW   B'00100000'
        MOVWF   PORTB
        CALL    STROBE
        RETURN

SEND_CHAR      
        MOVWF   CHAR            ;MOVE CONTENTS OF REGISTER 'W' INTO
                                ;THE ELEMENT OF VARIABLE 'CHAR' 
        ANDLW   B'11110000'     ;MASK OUT UPPER 4-BITS
        ADDLW   B'00000011'     ;ADD 2-BITS (BIT 1 & 2)
        MOVWF   NIBBLE          ;MOVE CONTENTS OF REGISTER 'W' INTO
                                ;CONTENTS OF VARIABLE 'NIBBLE'
        SWAPF   NIBBLE,W        ;SWAP UPPER AND LOWER 4-BITS AND
                                ;PLACE RESULT INTO REGISTER 'W'
        MOVWF   PORTB           ;MOVE CONTENTS OF REGISTER 'W' INTO
                                ;THE ELEMENT OF VARIABLE PORTB
        CALL    STROBE   
        MOVFW   CHAR            ;MOVE THE CONTENTS OF VARIABLE 'CHAR'
                                ;INTO THE REGISTER 'W'
        ANDLW   B'00001111'     
        ADDLW   B'00110000'
        MOVWF   PORTB
        CALL    STROBE
        RETURN

DEFINE_CHARACTER_0
        CALL SET_CG_RAM_ADDRESS
       
        MOVLW B'00001000'       
        CALL SEND_CHAR
        MOVLW B'00001100' 
        CALL SEND_CHAR
        MOVLW B'00001010' 
        CALL SEND_CHAR
        MOVLW B'00001001' 
        CALL SEND_CHAR
        MOVLW B'00001001' 
        CALL SEND_CHAR
        MOVLW B'00001010' 
        CALL SEND_CHAR
        MOVLW B'00001100' 
        CALL SEND_CHAR
        MOVLW B'00001000' 
        CALL SEND_CHAR

MESSAGE_PAGE
        MOVLW   'E'
        CALL    SEND_CHAR             
        MOVLW   'n'
        CALL    SEND_CHAR             
        MOVLW   't'
        CALL    SEND_CHAR             
        MOVLW   'e'
        CALL    SEND_CHAR             
        MOVLW   'r'
        CALL    SEND_CHAR
        MOVLW   ' '
        CALL    SEND_CHAR             
        MOVLW   'M'
        CALL    SEND_CHAR             
        MOVLW   'e'
        CALL    SEND_CHAR             
        MOVLW   's'
        CALL    SEND_CHAR             
        MOVLW   's'
        CALL    SEND_CHAR             
        MOVLW   'a'
        CALL    SEND_CHAR             
        MOVLW   'g'
        CALL    SEND_CHAR             
        MOVLW   'e'
        CALL    SEND_CHAR             
        MOVLW   0
        CALL    SEND_CHAR
        RETURN

SLEEP5  SLEEP
        SLEEP
        SLEEP
        SLEEP
        SLEEP
        RETURN

CHAR_UP
        INCF    LETTER,W        ;INCREMENT VARIABLE 'LETTER' AND PLACE
                                ;THE RESULT IN REGISTER 'W'
        MOVWF   LETTER          ;STORE RESULT BACK IN VARIABLE 'LETTER'
        CALL    SEND_CHAR  
        MOVLW   LEFT                 
        CALL    MOVE_CURSOR
        BSF     PORTB,BIT6      ;GREEN LED ON
        CALL    SLEEP5
        BCF     PORTB,BIT6      ;GREEN LED OFF
        RETURN

CHAR_DOWN
        DECF    LETTER,W        ;DECREMENT VARIABLE 'LETTER' AND PLACE
                                ;THE RESULT IN REGISTER 'W'
        MOVWF   LETTER          ;STORE RESULT BACK IN VARIABLE 'LETTER'
        CALL    SEND_CHAR  
        MOVLW   LEFT
        CALL    MOVE_CURSOR
        BSF     PORTB,BIT6      ;GREEN LED ON
        CALL    SLEEP5
        BCF     PORTB,BIT6      ;GREEN LED OFF
        RETURN

NEXT_CHAR
        MOVLW   RIGHT
        CALL    MOVE_CURSOR
        BSF     PORTB,BIT7      ;RED LED ON
        SLEEP
        BCF     PORTB,BIT7      ;RED LED OFF
        CALL    SLEEP5
        RETURN

;**************************

INITIALISE

SET_PORTA_IN
         CLRF    PORTA           ;CLEAR PORT BITS
         MOVLW   B'00011111'     ;SET UP A0-A4 AS INPUTS
         TRIS    PORTA           ;DO IT
 
SET_PORTB_OUT
        CLRF    PORTB           ;ENSURE PORT IS CLEAR
        MOVLW   B'00000000'     ;SET PORT BITS 0-7 AS OUTPUT
        TRIS    PORTB           ;DO IT
        
MAIN    MOVLW   ZERO            ;SET DELAY BY SETTING REGISTER 'W' TO ZERO
        CALL    SET_DELAY       ;SET WDT TO ZERO
        CALL    SET_FUNCTION    ;SET LCD FUNCTION
        MOVLW   DISPLAY_OFF
        CALL    SET_DISPLAY     ;SET LCD DISPLAY
        CALL    ENTRY_MODE_SET  ;SET LCD ENTRY MODE
        CALL    DEFINE_CHARACTER_0
        MOVLW   LINE1
        CALL    GOTO_LINE        
        CALL    MESSAGE_PAGE    ;DISPLAY TITLE PAGE
        MOVLW   DISPLAY_ON
        CALL    SET_DISPLAY
        MOVLW   'A'
        MOVWF   LETTER
        MOVLW   LINE2
        CALL    GOTO_LINE

LOOP    SLEEP
        BTFSS   PORTA,BIT0      ;TEST PORTA BIT0
        CALL    CHAR_DOWN       ;IF BIT0 IS SET LO THEN CALL DOWN
        BTFSS   PORTA,BIT1      ;TEST PORTA BIT1
        CALL    CHAR_UP         ;IF BIT1 IS SET LO THEN CALL UP
        BTFSS   PORTA,BIT2      ;TEST PORTA BIT2
        CALL    NEXT_CHAR       ;IF BIT2 IS SET LO THEN CALL NEXT
        
        GOTO    LOOP
        END

