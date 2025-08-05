*-----------------------------------------------------------
* Title      : MoveEyes
* Written by : Carter Buell
* Date       : 6/13/2025
* Description: Moves the eyes so the penguin is looking forward when his reel is above the ice
*-----------------------------------------------------------

EYE_WIDTH                       EQU 3
EYE_HEIGHT                      EQU 5

EYE_DOWN_Y                      EQU 62
EYE_UP_Y                        EQU 59

LEFT_EYE_X                      EQU 475
RIGHT_EYE_X                     EQU 481

MoveEyes   
    * Set Pen Color
    move.l #PEN_COLOR_TRAP_CODE, d0
    move.l #WHITE, d1
    trap #15

    * Set Fill Color
    move.l #SET_FILL_COLOR_TRAP_CODE, d0
    move.l #WHITE, d1
    trap #15
    
    * Clear Face
    move.l #LEFT_EYE_X, d1
    move.l #(RIGHT_EYE_X+EYE_WIDTH-1), d3
    move.l #EYE_UP_Y, d2  
    move.l #(EYE_DOWN_Y+EYE_HEIGHT-2), d4
    move.l #DRAW_RECT_TRAP_CODE, d0
    trap #15

    * Set Pen Color
    move.l #PEN_COLOR_TRAP_CODE, d0
    move.l #BLACK, d1
    trap #15
    
    * Set Fill Color
    move.l #SET_FILL_COLOR_TRAP_CODE, d0
    move.l #BLACK, d1
    trap #15

    * Check if mouse above water
    lea CurrentMouseY, a1
    move.l (a1), d5                                     ; d5 = CurrentMouseY
    cmpi.l #ABOVE_WATER, d5
    bgt.s EyesNotPointingForward
    
    * Draw Left Eye
    move.l #LEFT_EYE_X, d1
    move.l #(LEFT_EYE_X+EYE_WIDTH-1), d3
    move.l #EYE_UP_Y, d2
    move.l #(EYE_UP_Y+EYE_HEIGHT-1), d4
    move.l #DRAW_RECT_TRAP_CODE, d0
    trap #15
    
    * Draw Right Eye
    move.l #RIGHT_EYE_X, d1
    move.l #(RIGHT_EYE_X+EYE_WIDTH-1), d3
    move.l #EYE_UP_Y, d2
    move.l #(EYE_UP_Y+EYE_HEIGHT-1), d4
    move.l #DRAW_RECT_TRAP_CODE, d0
    trap #15
    
    * Set Pen Color
    move.l #PEN_COLOR_TRAP_CODE, d0
    move.l #WHITE, d1
    trap #15
    
    * Draw Left Eye Whites
    move.l #(LEFT_EYE_X+EYE_WIDTH-1), d1
    move.l #EYE_UP_Y, d2
    move.l #DRAW_PIXEL_TRAP_CODE, d0
    trap #15
    
    * Draw Right Eye
    move.l #(RIGHT_EYE_X+EYE_WIDTH-1), d1
    move.l #EYE_UP_Y, d2
    move.l #DRAW_PIXEL_TRAP_CODE, d0
    trap #15

    
EyesNotPointingForward   
    
    
    * Check if mouse below water
    lea CurrentMouseY, a1
    move.l (a1), d5                                     ; d5 = CurrentMouseY
    cmpi.l #ABOVE_WATER, d5
    ble.s EyesNotPointingDown
    
    * Draw Left Eye
    move.l #LEFT_EYE_X, d1
    move.l #(LEFT_EYE_X+EYE_WIDTH-1), d3
    move.l #EYE_DOWN_Y, d2
    move.l #(EYE_DOWN_Y+EYE_HEIGHT-1), d4
    move.l #DRAW_RECT_TRAP_CODE, d0
    trap #15
    
    * Draw Right Eye
    move.l #RIGHT_EYE_X, d1
    move.l #(RIGHT_EYE_X+EYE_WIDTH-1), d3
    move.l #EYE_DOWN_Y, d2
    move.l #(EYE_DOWN_Y+EYE_HEIGHT-1), d4
    move.l #DRAW_RECT_TRAP_CODE, d0
    trap #15
    
    * Set Pen Color
    move.l #PEN_COLOR_TRAP_CODE, d0
    move.l #WHITE, d1
    trap #15
    
    * Draw Left Eye Whites
    move.l #(LEFT_EYE_X+EYE_WIDTH-1), d1
    move.l #EYE_DOWN_Y, d2
    move.l #DRAW_PIXEL_TRAP_CODE, d0
    trap #15
    
    * Draw Right Eye
    move.l #(RIGHT_EYE_X+EYE_WIDTH-1), d1
    move.l #EYE_DOWN_Y, d2
    move.l #DRAW_PIXEL_TRAP_CODE, d0
    trap #15

EyesNotPointingDown

    * Set Fill Color
    move.l #SET_FILL_COLOR_TRAP_CODE, d0
    move.l #WATER_COLOR, d1
    trap #15
    
    rts






*~Font name~Courier New~
*~Font size~12~
*~Tab type~1~
*~Tab size~4~
