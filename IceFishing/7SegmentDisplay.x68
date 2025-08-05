*-----------------------------------------------------------
* Title      : 7SegmentDisplay
* Written by : Carter Buell
* Date       : 5/29/2025
* Description: Draws a seven segment display given a digit 0-9
*              as well as a location and segment size 
*-----------------------------------------------------------

USED_REG                            REG D0-D7/A0-A2
SEVEN_SEGMENT_DRAW_STACK_SIZE       EQU 8

SEVEN_SEGMENT_DISPLAY_X_DRAW        EQU 58
SEVEN_SEGMENT_DISPLAY_Y_DRAW        EQU 56
SEVEN_SEGMENT_SIZE_LOCAL_DRAW       EQU 54

SEVEN_SEGMENT_DISPLAY_X_LOCAL       EQU 54
SEVEN_SEGMENT_DISPLAY_Y_LOCAL       EQU 52
SEVEN_SEGMENT_SIZE_LOCAL            EQU 50
SEVEN_SEGMENT_NUMBER_LOCAL          EQU 48

SEVEN_SEGMENT_PEN_WIDTH             EQU 1
NUMBER_OF_SEGMENTS                  EQU 7
BITMASK_TABLE_ENTRY_SIZE            EQU 4

DrawNumber
    movem.l USED_REG, -(sp)

    lea SEVEN_SEGMENT_BITMASK_TABLE, a0
    lea SEVEN_SEGMENT_FUNCTION_TABLE, a1
    move.w SEVEN_SEGMENT_NUMBER_LOCAL(sp), d5           ; number to display (0-9)
    move.b (a0, d5), d5
    move.l #(NUMBER_OF_SEGMENTS-1), d6                  ; Loop for each segment (adjust for dbra)
    
    * Set Pen Color
    move.l #PEN_COLOR_TRAP_CODE, d0
    move.l #COOLER_COLOR, d1
    trap #15
    
    * Set Fill Color
    move.l #SET_FILL_COLOR_TRAP_CODE, d0
    move.l #COOLER_COLOR, d1
    trap #15
    
    * Fill previous display so new one can be drawn
    move.w SEVEN_SEGMENT_SIZE_LOCAL(sp), d0
    move.w SEVEN_SEGMENT_DISPLAY_X_LOCAL(sp), d1
    move.w d1, d3
    move.w SEVEN_SEGMENT_DISPLAY_Y_LOCAL(sp), d2
    move.w d2, d4
    sub.w d0, d2
    add.w d0, d4
    lsr.w #1, d0
    sub.w d0, d1
    add.w d0, d3
    subi.w #(COOLER_SEGMENT_WIDTH/2), d2
    addi.w #(COOLER_SEGMENT_WIDTH/2), d4
    addi.w #COOLER_SLANT_OFFSET, d4
    subi.w #(COOLER_SEGMENT_WIDTH/2), d1
    addi.w #(COOLER_SEGMENT_WIDTH/2), d3
    move.l #DRAW_RECT_TRAP_CODE, d0
    trap #15
    
    * Set Pen Color
    move.l #PEN_COLOR_TRAP_CODE, d0
    move.l #COOLER_TEXT_COLOR, d1
    trap #15
    
    * Set Pen Width
    move.l #PEN_WIDTH_TRAP_CODE, d0
    move.l #COOLER_SEGMENT_WIDTH, d1
    trap #15
    
CheckBits
    btst #0, d5
    beq.s DoNotDrawSegment
    move.l (a1), a2
    move.l #DRAW_LINE_TRAP_CODE, d0
    jsr (a2)
DoNotDrawSegment
    lsr.w #1, d5
    lea BITMASK_TABLE_ENTRY_SIZE(a1), a1
    dbra d6, CheckBits
    movem.l (sp)+, USED_REG
    
    * Set Pen Width
    move.l #PEN_WIDTH_TRAP_CODE, d0
    move.l #SEVEN_SEGMENT_PEN_WIDTH, d1
    trap #15
    
    rts
    
*-----------Segment Drawing Subroutines---------*
*   The next 7 subroutines each draw a specific  
*   segment of the 7 segment display
*-----------------------------------------------*
DrawA
    move.w SEVEN_SEGMENT_DISPLAY_X_DRAW(sp), d1
    move.w SEVEN_SEGMENT_DISPLAY_Y_DRAW(sp), d2
    move.w SEVEN_SEGMENT_SIZE_LOCAL_DRAW(sp), d7
    move.w d1, d3
    sub.w d7, d2
    move.w d2, d4
    addi.w #COOLER_SLANT_OFFSET, d2
    lsr.w #1, d7
    add.w d7, d3
    sub.w d7, d1
    trap #15
    rts
    
    
DrawB
    move.w SEVEN_SEGMENT_DISPLAY_X_DRAW(sp), d1
    move.w SEVEN_SEGMENT_DISPLAY_Y_DRAW(sp), d2
    move.w SEVEN_SEGMENT_SIZE_LOCAL_DRAW(sp), d7
    move.w d2, d4
    sub.w d7, d2
    lsr.w #1, d7
    add.w d7, d1
    move.w d1, d3
    trap #15
    rts
 
 
DrawC
    move.w SEVEN_SEGMENT_DISPLAY_X_DRAW(sp), d1
    move.w SEVEN_SEGMENT_DISPLAY_Y_DRAW(sp), d2
    move.w SEVEN_SEGMENT_SIZE_LOCAL_DRAW(sp), d7
    move.w d2, d4
    add.w d7, d2
    lsr.w #1, d7
    add.w d7, d1
    move.w d1, d3
    trap #15
    rts
    
    
DrawD
    move.w SEVEN_SEGMENT_DISPLAY_X_DRAW(sp), d1
    move.w SEVEN_SEGMENT_DISPLAY_Y_DRAW(sp), d2
    move.w SEVEN_SEGMENT_SIZE_LOCAL_DRAW(sp), d7
    move.w d1, d3
    add.w d7, d2
    move.w d2, d4
    addi.w #COOLER_SLANT_OFFSET, d2
    lsr.w #1, d7
    add.w d7, d3
    sub.w d7, d1
    trap #15
    rts   
    
    
DrawE
    move.w SEVEN_SEGMENT_DISPLAY_X_DRAW(sp), d1
    move.w SEVEN_SEGMENT_DISPLAY_Y_DRAW(sp), d2
    addi.w #COOLER_SLANT_OFFSET, d2
    move.w SEVEN_SEGMENT_SIZE_LOCAL_DRAW(sp), d7
    move.w d2, d4
    add.w d7, d2
    lsr.w #1, d7
    sub.w d7, d1
    move.w d1, d3
    trap #15
    rts     
    
    
DrawF
    move.w SEVEN_SEGMENT_DISPLAY_X_DRAW(sp), d1
    move.w SEVEN_SEGMENT_DISPLAY_Y_DRAW(sp), d2
    addi.w #COOLER_SLANT_OFFSET, d2
    move.w SEVEN_SEGMENT_SIZE_LOCAL_DRAW(sp), d7
    move.w d2, d4
    sub.w d7, d2
    lsr.w #1, d7
    sub.w d7, d1
    move.w d1, d3
    trap #15
    rts
    
    
DrawG
    move.w SEVEN_SEGMENT_DISPLAY_X_DRAW(sp), d1
    move.w SEVEN_SEGMENT_DISPLAY_Y_DRAW(sp), d2
    move.w SEVEN_SEGMENT_SIZE_LOCAL_DRAW(sp), d7
    move.w d1, d3
    move.w d2, d4
    addi.w #COOLER_SLANT_OFFSET, d2
    lsr.w #1, d7
    add.w d7, d3
    sub.w d7, d1
    trap #15
    rts
        

*-----------------------------Global Variables------------------------------------*
SEVEN_SEGMENT_BITMASK_TABLE dc.b $7E, $30, $6D, $79, $33, $5B, $5F, $70, $7F, $7B
SEVEN_SEGMENT_FUNCTION_TABLE dc.l DrawG, DrawF, DrawE, DrawD, DrawC, DrawB, DrawA


*~Font name~Courier New~
*~Font size~12~
*~Tab type~1~
*~Tab size~4~
