*-----------------------------------------------------------
* Title      : CatchFish
* Written by : Carter Buell
* Date       : 6/6/2025
* Description: Handles catching fish
*-----------------------------------------------------------

COOLER_ONES_X                   EQU 289
COOLER_ONES_Y                   EQU 110
COOLER_TENS_X                   EQU 270
COOLER_TENS_Y                   EQU 115

COOLER_SEGMENT_SIZE             EQU 10
COOLER_SEGMENT_WIDTH            EQU 3
COOLER_SLANT_OFFSET             EQU 2

CatchFish
    * Check for mouse click input 
    move.l #MOUSE_INPUT_TRAP_CODE, d0
    moveq #0, d1                                        ; Set mode to "read mouse down state"
    trap #15
    btst #0, d0 
    beq CannotCatchFish

    * Check if fish is on line
    lea FishingManagerTable, a1
    moveq #0, d0
    move.b GET_IS_FISH_ON_HOOK(a1), d0
    beq.s CannotCatchFish
    
    * Check for correct bounds to catch fish
    lea CurrentMouseY, a1
    move.l (a1), d5                                     ; d5 = CurrentMouseY
    cmpi.l #ABOVE_WATER, d5
    bgt.s CannotCatchFish
    
    * Catch Fish
    lea FishingManagerTable, a1
    addi.b #1, GET_NUM_FISH_CAUGHT(a1)                  ; Increase fish count by 1
    move.b #0, GET_IS_FISH_ON_HOOK(a1)                  ; Remove fish from line
    
    * Update 7 Segment Display Ones Place
    lea FishingManagerTable, a1
    move.w #COOLER_ONES_X, -(sp)                        ; display coordinate X         
    move.w #COOLER_ONES_Y, -(sp)                        ; display coordinate Y
    move.w #COOLER_SEGMENT_SIZE, -(sp)                  ; segment size
    moveq #0, d0
    move.b GET_NUM_FISH_CAUGHT(a1), d0
    divu #10, d0
    swap d0
    move.w d0, -(sp)                                    ; number to display (0-9)
    jsr DrawNumber
    add.l #8, sp
    
    * Update 7 Segment Display Tens Place
    lea FishingManagerTable, a1
    move.w #COOLER_TENS_X, -(sp)                        ; display coordinate X         
    move.w #COOLER_TENS_Y, -(sp)                        ; display coordinate Y
    move.w #COOLER_SEGMENT_SIZE, -(sp)                  ; segment size
    moveq #0, d0
    move.b GET_NUM_FISH_CAUGHT(a1), d0
    divu #10, d0
    move.w d0, -(sp)                                    ; number to display (0-9)
    jsr DrawNumber
    add.l #8, sp
    
    * Catch Fish Sound Effect                        
    move.l #PLAY_SOUND_TRAP_CODE, d0
    lea CatchFishSound, a1
    trap #15
    
CannotCatchFish

    rts
    
*-----------------Global Variables------------------*
CatchFishSound dc.w 'Assets\sounds\get_fish.wav', 0
*~Font name~Courier New~
*~Font size~12~
*~Tab type~1~
*~Tab size~4~
