*-----------------------------------------------------------
* Title      : GameOverLoading
* Written by : Carter Buell
* Date       : 6/10/2025
* Description: Subroutine to handle loading sequence for the GameOver section
*-----------------------------------------------------------

FISHSCORE_CHARCTER_OFFSET       EQU 12
TOTALSCORE_CHARCTER_OFFSET      EQU 21

END_BANNER_CONTENT_X            EQU 72

FISHSCORE_Y                     EQU 363
MULLETSCORE_Y                   EQU 398
TOTALSCORE_Y                    EQU 433
RETURN_TO_MENU_TEXT_Y           EQU 465
SCORE_TEXT_LINE_OFFSET          EQU 36
END_BANNER_FONT_WIDTH           EQU 12

PRESS_ESC_TO_EXIT_TEXT_X        EQU 15
PRESS_ESC_TO_EXIT_TEXT_Y        EQU 575

END_BANNER_WIDTH                EQU 380
END_BANNER_HEIGHT               EQU 398
END_BANNER_X                    EQU 255

GameOverLoading    
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
    lea LoadingText, a1                                                 ; Variable located in OneTimeGameSetup 
    move.w #LOADING_X, d1                                               ; Equate located in OneTimeGameSetup 
    move.w #LOADING_Y, d2                                               ; Equate located in OneTimeGameSetup                 
    trap #15
    
    * Repaint from double buffer
    move.l #REPAINT_SCREEN_TRAP_CODE, d0
    trap #15
    
    * Clear Screen
    move.l #CLEAR_SCREEN_TRAP_CODE, d0
    move.w #CLEAR_SCREEN_MODE, d1                
    trap #15
    
    * Draw End Banner
    lea END_BANNER_BITMAP, a2
    move.l #PA_OFFSET, -(sp)                                            ; Bitmap Offset
    move.l #END_BANNER_WIDTH, -(sp)                                     ; Bitmap Width
    move.l #(END_BANNER_HEIGHT*2), -(sp)                                ; Bitmap Height
    move.l a2, -(sp)                                                    ; Bitmap Signature
    move.l #0, -(sp)                                                    ; Bitmap Chunk X
    move.l #0, d3
    lea GameState, a2
    moveq #0, d3
    move.b (a2), d3
    subi.b #MULLET_CAUGHT_STATE, d3                                     ; State 3 becomes an offset of 0, state 4 becomes an offset of 1
    mulu.w #END_BANNER_HEIGHT, d3
    move.l d3, -(sp)                                                    ; Bitmap Chunk Y
    move.l #END_BANNER_WIDTH, -(sp)                                     ; Bitmap Chunk Width
    move.l #END_BANNER_HEIGHT, -(sp)                                    ; Bitmap Chunk Height
    move.l #(END_BANNER_X-(END_BANNER_WIDTH/2)), -(sp)                  ; Output Screen X
    move.l #((OUTPUT_WINDOW_HEIGHT/2)-(END_BANNER_HEIGHT/2)), -(sp)     ; Output Screen Y
    jsr DisplayBitmapChunk
	add.l #BM_CHUNKER_STACK_SIZE, sp
	
	* Set Font
    move.l #SET_FONT_TRAP_CODE, d0
    move.l #BLACK, d1
    move.l #END_BANNER_FONT, d2
    trap #15
    
    * Set Fill Color to White
    move.l #SET_FILL_COLOR_TRAP_CODE, d0
    move.l #WHITE, d1
    trap #15
    
    * Get Fish Count
    lea FishingManagerTable, a1
    moveq #0, d4
    moveq #0, d5
    move.b GET_NUM_FISH_CAUGHT(a1), d4
    
    * Mullet count display
    move.l #((SCORE_TEXT_LINE_OFFSET)/3), d6                            ; set offset
    lea GameState, a1
    move.b (a1), d3
    cmpi.b #MULLET_CAUGHT_STATE, d3
    bne.s SkipMulletScoreDisplay
    move.l #TEXT_TO_SCREEN_TRAP_CODE, d0
    lea MulletScoreText, a1
    move.l #END_BANNER_CONTENT_X, d1
    move.l #MULLETSCORE_Y, d2         
    trap #15    
    addi.l #MULLET_SCORE_BONUS, d4                                      ; add mullet score bonus to total score
    moveq #0, d6                                                        ; set offset to 0
SkipMulletScoreDisplay
    
    * Get Total Score
    divu #10, d4
    move.w d4, d5                                                       ; d5 = tens place
    swap d4                                                             ; d4 = ones place
    addi.b #DEC_TO_ASCII, d5                                            ; d5 = tens place (ascii charachter)
    addi.b #DEC_TO_ASCII, d4                                            ; d4 = ones place (ascii charachter)
    cmpi.b #DEC_TO_ASCII, d5
    bne DontClearTensDigitTotal
    move.b d4, d5                                                       ; display ones digit first if tens digit is 
    move.b #SPACE_ASCII_CHAR, d4
DontClearTensDigitTotal
    
    * Total score display
    move.l #TEXT_TO_SCREEN_TRAP_CODE, d0
    lea TotalScoreText, a1
    move.b d5, TOTALSCORE_CHARCTER_OFFSET(a1)
    move.b d4, (TOTALSCORE_CHARCTER_OFFSET+1)(a1)
    move.l #END_BANNER_CONTENT_X, d1
    move.l #TOTALSCORE_Y, d2
    sub.l d6, d2                                                        ; subtract offset to center text     
    trap #15
    
    * Get Fish Count
    lea FishingManagerTable, a1
    moveq #0, d4
    moveq #0, d5
    move.b GET_NUM_FISH_CAUGHT(a1), d4
    divu #10, d4
    move.w d4, d5                                                       ; d5 = tens place
    swap d4                                                             ; d4 = ones place
    addi.b #DEC_TO_ASCII, d5                                            ; d5 = tens place (ascii charachter)
    addi.b #DEC_TO_ASCII, d4                                            ; d4 = ones place (ascii charachter)
    lea TwoDigitFishScoreText, a1
    cmpi.b #DEC_TO_ASCII, d5
    bne.s DontClearTensDigitFish
    move.b d4, d5
    move.b #SPACE_ASCII_CHAR, d4                                        ; display ones digit first if tens digit is 0
    lea OneDigitFishScoreText, a1                                       ; load OneDigitFishScoreText if the score is only 1 digit
DontClearTensDigitFish
    
	* Fish count display
    move.l #TEXT_TO_SCREEN_TRAP_CODE, d0
    move.b d5, FISHSCORE_CHARCTER_OFFSET(a1)
    move.b d4, (FISHSCORE_CHARCTER_OFFSET+1)(a1)
    move.l #END_BANNER_CONTENT_X, d1
    move.l #FISHSCORE_Y, d2  
    add.l d6, d2                                                        ; add offset to center text                
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
    
    * Press escape to exit text
    move.l #TEXT_TO_SCREEN_TRAP_CODE, d0
    lea PressEscToExitText, a1
    move.l #PRESS_ESC_TO_EXIT_TEXT_X, d1
    move.l #PRESS_ESC_TO_EXIT_TEXT_Y, d2               
    trap #15
    
    * Set Font
    move.l #SET_FONT_TRAP_CODE, d0
    move.l #BLACK, d1
    move.l #END_BANNER_FONT_BOLD, d2
    trap #15
    
    * Set Fill Color to White
    move.l #SET_FILL_COLOR_TRAP_CODE, d0
    move.l #WHITE, d1
    trap #15

    * Click to restart text
    move.l #TEXT_TO_SCREEN_TRAP_CODE, d0
    lea ClickToReturnText, a1
    move.l #(END_BANNER_CONTENT_X+END_BANNER_FONT_WIDTH), d1
    move.l #RETURN_TO_MENU_TEXT_Y, d2               
    trap #15
      
    rts
    
*----------------------Global Variables----------------------*

END_BANNER_BITMAP 	
    INCBIN "Assets\end_banner.bmp"
END_END_BANNER_BITMAP 

ClickToReturnText dc.w 'CLICK TO RETURN TO MAIN MENU', 0
OneDigitFishScoreText dc.w ' You caught 0 fish!', 0
TwoDigitFishScoreText dc.w ' You caught 00 fish!', 0
MulletScoreText dc.w ' You caught the Mullet!', 0
TotalScoreText dc.w ' Your total score is 00', 0
PressEscToExitText dc.w 'PRESS ESCAPE TO EXIT GAME', 0





*~Font name~Courier New~
*~Font size~12~
*~Tab type~1~
*~Tab size~4~
