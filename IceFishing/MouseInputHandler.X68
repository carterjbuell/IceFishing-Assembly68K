*-----------------------------------------------------------
* Title      : MouseInputHandler
* Written by : Carter Buell
* Date       : 6/6/2025
* Description: Gets mouse input, and performs bounds checks 
*-----------------------------------------------------------

MOUSE_LOWER_BOUND               EQU TOP_OF_POLE+10
MOUSE_UPPER_BOUND               EQU (OUTPUT_WINDOW_HEIGHT-CAUGHT_FISH_HEIGHT)-10

MouseInputHandler
    * Get Mouse Input
    move.l #MOUSE_INPUT_TRAP_CODE, d0
    moveq #0, d1
    trap #15
    clr.w d1
    swap d1
    
    * Check for out of bounds
    cmpi.l #MOUSE_LOWER_BOUND, d1
    bgt.s CorrectLowerBound
    move.l #MOUSE_LOWER_BOUND, d1
CorrectLowerBound
    cmpi.l #MOUSE_UPPER_BOUND, d1
    blt.s CorrectUpperBound
    move.l #MOUSE_UPPER_BOUND, d1
CorrectUpperBound
    
    * Set CurrentMouseY variable
    lea CurrentMouseY, a1
    move.l d1, (a1)
    
    rts
    
*--------------------Global Variables--------------------*
CurrentMouseY ds.l 1
*~Font name~Courier New~
*~Font size~12~
*~Tab type~1~
*~Tab size~4~
