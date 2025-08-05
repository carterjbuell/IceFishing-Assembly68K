*-----------------------------------------------------------
* Title      : TitleScreenSetup
* Written by : Caretr Buell
* Date       : 6/11/2025
* Description: Setup title screen and draw bitmap background
*-----------------------------------------------------------

PRESS_ESC_TO_EXIT_TEXT_WIDTH    EQU 400
PRESS_ESC_TO_EXIT_TEXT_HEIGHT   EQU 50

TitleScreenSetup
    * Set Font
    move.l #SET_FONT_TRAP_CODE, d0
    move.l #WHITE, d1
    move.l #LOADING_SMALL_FONT, d2
    trap #15
    
    * Set Fill Color to Black
    move.l #SET_FILL_COLOR_TRAP_CODE, d0
    move.l #BLACK, d1
    trap #15
    
    * Set Pen Color to Black
    move.l #PEN_COLOR_TRAP_CODE, d0
    move.l #BLACK, d1
    trap #15
    
    * Fill Bottom left corner with black
    move.l #DRAW_RECT_TRAP_CODE, d0
    move.w #0, d1
    move.w #(OUTPUT_WINDOW_HEIGHT-PRESS_ESC_TO_EXIT_TEXT_HEIGHT), d2
    move.w #PRESS_ESC_TO_EXIT_TEXT_WIDTH, d3
    move.w #OUTPUT_WINDOW_HEIGHT, d4
    trap #15
    
    * Loading Icon
    move.l #TEXT_TO_SCREEN_TRAP_CODE, d0
    lea LoadingText, a1
    move.w #LOADING_X, d1
    move.w #LOADING_Y, d2                 
    trap #15
    
    * Repaint from double buffer
    move.l #REPAINT_SCREEN_TRAP_CODE, d0
    trap #15
    
    * Clear Screen
    move.l #CLEAR_SCREEN_TRAP_CODE, d0
    move.w #CLEAR_SCREEN_MODE, d1                
    trap #15
	
	* Draw Title Screen
    lea TITLE_BITMAP, a2
    move.l #PA_OFFSET, -(sp)                                                ; Bitmap Offset
    move.l #OUTPUT_WINDOW_WIDTH, -(sp)                                      ; Bitmap Width
    move.l #OUTPUT_WINDOW_HEIGHT, -(sp)                                     ; Bitmap Height
    move.l a2, -(sp)                                                        ; Bitmap Signature
    move.l #0, -(sp)                                                        ; Bitmap Chunk X
    move.l #0, -(sp)                                                        ; Bitmap Chunk Y
    move.l #OUTPUT_WINDOW_WIDTH, -(sp)                                      ; Bitmap Chunk Width
    move.l #OUTPUT_WINDOW_HEIGHT, -(sp)                                     ; Bitmap Chunk Height
    move.l #0, -(sp)                                                        ; Output Screen X
    move.l #0, -(sp)                                                        ; Output Screen Y
    jsr DisplayBitmapChunk
	add.l #BM_CHUNKER_STACK_SIZE, sp
	
	* Repaint from double buffer
    move.l #REPAINT_SCREEN_TRAP_CODE, d0
    trap #15
    
    rts

*------------Global Variables------------*
TITLE_BITMAP 	
    INCBIN "Assets\title_screen.bmp"
END_TITLE_BITMAP
*~Font name~Courier New~
*~Font size~12~
*~Tab type~1~
*~Tab size~4~
