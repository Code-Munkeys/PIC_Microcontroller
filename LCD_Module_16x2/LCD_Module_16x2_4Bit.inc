;LANGUAGE               RISC-like architecture
;WRITTEN BY             Franz Ayestaran
;DATE                   08/08/97               
;UPDATED                31/03/18 
;FILE SAVED AS          LCD_Module_16x2_4Bit.inc
;RESONATOR              4MHz
;CODE PROTECTION        OFF
;SOFTWARE FUNCTION      'LCD/LED/OLED Driver'

;==== DECLARE VARIABLES (f) ====
;===============================

PC          EQU     2
STATUS      EQU     3
C           EQU     0
OPTREG      EQU     81H
RP0FLAG     EQU     5
CHAR        EQU     010H
NIBBLE      EQU     011H
LETTER      EQU     012H
DIRECTION   EQU     013H
DISPLAY     EQU     014H
ZERO        EQU     00H

LEFT        EQU     B'00100000'
RIGHT       EQU     B'00100100'
LINE1       EQU     B'00101000'
LINE2       EQU     B'00101100'
DISPLAY_ON  EQU     B'00101111'
DISPLAY_OFF EQU     B'00101011'

BIT0        EQU     0
BIT1        EQU     1
BIT2        EQU     2
BIT3        EQU     3
BIT4        EQU     4
BIT5        EQU     5
BIT6        EQU     6
BIT7        EQU     7

DB4         EQU     0 ;Pin1 Gray
DB5         EQU     1 ;Pin2 White
DB6         EQU     2 ;Pin3 Black
DB7         EQU     3 ;Pin4 Brown

RS          EQU     4 ;Pin5 Yellow
ENABLE      EQU     5 ;Pin6 Blue

;== DEFINE PORT-B (B0-B7) ==

TRISB       EQU     86H    
PORTIOB     EQU     06H
OPTIONS     EQU     88H

;===========================

;*** SUBROUTINES ***
;*******************

DELAY
        SLEEP
        RETURN

DELAY5  
        CALL    DELAY
        CALL    DELAY
        CALL    DELAY
        CALL    DELAY
        CALL    DELAY
        RETURN

DELAY10
        CALL    DELAY5
        CALL    DELAY5
        RETURN

DELAY50
        CALL    DELAY10
        CALL    DELAY10
        CALL    DELAY10
        CALL    DELAY10
        CALL    DELAY10
        RETURN

SET_DELAY                          ;SLEEP Function
        BSF     STATUS,RP0FLAG     ;SELECT REGISTER BANK 1
        MOVWF   OPTREG^80H         ;ASSIGN PRESCALER (1:4) TO WDT 
                                   ;COMMENT OUT ABOVE WHEN DEVELOPING ON SIMULATOR
        BCF     STATUS,RP0FLAG     ;SELECT REGISTER BANK 0
        RETURN

STROBE
        CALL    DELAY                      
        BCF     PORTIOB,ENABLE       
        RETURN

;RS RW DB7 DB6 DB5 DB4 DB3 DB2 DB1 DB0                               
;0  0   0   0   1  DL   N   F   *   *    
SET_FUNCTION
        MOVLW   B'00100010'     
        MOVWF   PORTIOB
        CALL    STROBE      
        MOVLW   B'00100010'     
        MOVWF   PORTIOB
        CALL    STROBE
        MOVLW   B'00101000'    
        MOVWF   PORTIOB
        CALL    STROBE
        RETURN

;RS RW DB7 DB6 DB5 DB4 DB3 DB2 DB1 DB0                               
;0  0   0   0   0   0   0   1  I/D  S  
ENTRY_MODE_SET
        MOVLW   B'00100000'
        MOVWF   PORTIOB
        CALL    STROBE
        MOVLW   B'00100110'     
        MOVWF   PORTIOB
        CALL    STROBE
        RETURN

;RS RW DB7 DB6 DB5 DB4 DB3 DB2 DB1 DB0                               
;0  0   0   0   0   0   1   D   C   B  
SET_DISPLAY
        MOVWF   DISPLAY
        MOVLW   B'00100000'
        MOVWF   PORTIOB
        CALL    STROBE
        MOVFW   DISPLAY
        MOVWF   PORTIOB
        CALL    STROBE
        RETURN

;RS RW DB7 DB6 DB5 DB4 DB3 DB2 DB1 DB0                               
;0  0   0   1   A   A   A   A   A   A  
SET_CG_RAM_ADDRESS
        MOVLW   B'00100100'
        MOVWF   PORTIOB
        CALL    STROBE
        MOVLW   B'00100000'
        MOVWF   PORTIOB
        CALL    STROBE
        RETURN

;RS RW DB7 DB6 DB5 DB4 DB3 DB2 DB1 DB0                               
;0  0   1   A   A   A   A   A   A   A  
SET_DD_RAM_ADDRESS
        MOVLW   B'00101000'
        MOVWF   PORTIOB
        CALL    STROBE
        MOVLW   B'00100000'
        MOVWF   PORTIOB
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
        MOVWF   PORTIOB
        CALL    STROBE
        MOVLW   B'00101000'
        MOVWF   PORTIOB
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
        MOVWF   PORTIOB
        CALL    STROBE
        MOVLW   B'00101100'
        MOVWF   PORTIOB
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
        MOVWF   PORTIOB
        CALL    STROBE
        MOVFW   DIRECTION
        MOVWF   PORTIOB
        CALL    STROBE
        RETURN

;RS RW DB7 DB6 DB5 DB4 DB3 DB2 DB1 DB0                               
;0  0   0   0   0   0   0   0   0   1   
CLEAR_DISPLAY
        MOVLW   B'00100000'
        MOVWF   PORTIOB
        CALL    STROBE
        MOVLW   B'00100001'
        MOVWF   PORTIOB
        CALL    STROBE
        RETURN

;RS RW DB7 DB6 DB5 DB4 DB3 DB2 DB1 DB0                               
;0  0   0   0   0   0   0   0   1   0   
RETURN_HOME
        MOVLW   B'00100000'
        MOVWF   PORTIOB
        CALL    STROBE
        MOVLW   B'00100010'
        MOVWF   PORTIOB
        CALL    STROBE
        RETURN

GOTO_LINE
        MOVWF   PORTIOB
        CALL    STROBE
        MOVLW   B'00100000'
        MOVWF   PORTIOB
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
        MOVWF   PORTIOB         ;MOVE CONTENTS OF REGISTER 'W' INTO
                                ;THE ELEMENT OF VARIABLE PORTIOB
        CALL    STROBE   
        MOVFW   CHAR            ;MOVE THE CONTENTS OF VARIABLE 'CHAR'
                                ;INTO THE REGISTER 'W'
        ANDLW   B'00001111'     
        ADDLW   B'00110000'
        MOVWF   PORTIOB
        CALL    STROBE
        RETURN

DEFINE_CHARACTER_0
        CALL 	SET_CG_RAM_ADDRESS
       
        MOVLW   B'00001000'       
        CALL 	SEND_CHAR
        MOVLW   B'00001100' 
        CALL 	SEND_CHAR
        MOVLW   B'00001010' 
        CALL 	SEND_CHAR
        MOVLW   B'00001001' 
        CALL 	SEND_CHAR
        MOVLW   B'00001001' 
        CALL 	SEND_CHAR
        MOVLW   B'00001010' 
        CALL 	SEND_CHAR
        MOVLW   B'00001100' 
        CALL 	SEND_CHAR
        MOVLW   B'00001000' 
        CALL 	SEND_CHAR
        RETURN

INITIALISE_LCD 
        CLRF    PORTIOB         ;ENSURE PORT IS CLEAR
        MOVLW   B'00000000'     ;SET PORT BITS 0-7 AS OUTPUT
        BANKSEL TRISB
        MOVWF   PORTIOB
        
        MOVLW   ZERO            ;SET DELAY BY SETTING REGISTER 'W' TO ZERO
        CALL    SET_DELAY       ;SET WDT TO ZERO
        CALL    SET_FUNCTION    ;SET LCD FUNCTION
        MOVLW   DISPLAY_OFF
        CALL    SET_DISPLAY     ;SET LCD DISPLAY
        CALL    ENTRY_MODE_SET  ;SET LCD ENTRY MODE
        CALL    DEFINE_CHARACTER_0
        MOVLW   LINE1
        CALL    GOTO_LINE        
        RETURN