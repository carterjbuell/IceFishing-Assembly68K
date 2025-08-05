*-----------------------------------------------------------
* Title      : OneTimeGameSetup
* Written by : Carter Buell
* Date       : 6/11/2025
* Description: Contains tasks that only need to be done once and
*              should not be redone every time you restart the game.
*-----------------------------------------------------------

SOUND_PLAYER_LOOP_MODE          EQU 1

LOADING_X                       EQU 665             ; Also used in PreGameSetup and GameOverLoading
LOADING_Y                       EQU 575             ; Also used in PreGameSetup and GameOverLoading

OneTimeGameSetup
    * Set Output Size
    move.l #SET_OUTPUT_RESOLUTION_TRAP_CODE, d0
    move.w #OUTPUT_WINDOW_WIDTH, d1
    swap d1
    move.w #OUTPUT_WINDOW_HEIGHT, d1
    trap #15
    
    * Load Background music into memory
    move.l #LOAD_SOUND_TRAP_CODE, d0
    lea BGMusic, a1
    moveq #0, d1              
    trap #15
    
    * Play Background Music on loop
    move.l #LOOP_SOUND_TRAP_CODE, d0
    lea BGMusic, a1
    moveq #0, d1                                    ; Set DirectX player to play sound 0
    moveq #SOUND_PLAYER_LOOP_MODE, d2               ; Play sound in loop
    trap #15
    
    * Enable double buffering
    move.l #DRAW_MODE_TRAP_CODE, d0
    move.b #DOUBLE_BUFFERING_MODE_NUMBER, d1
    trap #15
    
    * Set Font
    move.l #SET_FONT_TRAP_CODE, d0
    move.l #WHITE, d1
    move.l #LOADING_SMALL_FONT, d2
    trap #15
    
    * Set Fill Color to Black
    move.l #SET_FILL_COLOR_TRAP_CODE, d0
    move.l #BLACK, d1
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
    
    rts
    
*-----------------Global Variables-----------------*
LoadingText dc.w 'Loading', 0                     ; Also used in PreGameSetup and GameOverLoading  
BGMusic dc.w 'Assets\sounds\bg_music.wav', 0

*~Font name~Courier New~
*~Font size~12~
*~Tab type~1~
*~Tab size~4~
