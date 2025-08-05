*-----------------------------------------------------------
* Title      : LeaderboardManagement
* Written by : Carter Buell
* Date       : 6/19/2025
* Description: Subroutines to manage the leaderboard
*-----------------------------------------------------------

BackspaceASCIIValue             EQU 8
LeaderboardDataSize             EQU 40
FileNotFoundID                  EQU $FFFFFFFF

MIN_PRINATBLE_CHARACTER         EQU 33
MAX_PRINATBLE_CHARACTER         EQU 126

NAME_PROMPT_CURSOR_POSITION_1   EQU $0803
NAME_PROMPT_CURSOR_POSITION_2   EQU $0903
NAME_PROMPT_CURSOR_POSITION_3   EQU $0A03

NAME_CHARCTER_OFFSET            EQU 0
HIGHSCORE_CHARCTER_OFFSET       EQU 9

LEADERBOARD_ENTRY_X             EQU 528
LEADERBOARD_ENTRY_Y             EQU 165
LEADERBOARD_ENTRY_LINE_SPACE    EQU 30

LEADERBOARD_WIDTH               EQU 190
LEADERBOARD_HEIGHT              EQU 398
LEADERBOARD_X                   EQU 595

OPEN_EXISTING_FILE_TRAP_CODE    EQU 51
OPEN_NEW_FILE_TRAP_CODE         EQU 52
READ_FILE_TRAP_CODE             EQU 53
WRITE_FILE_TRAP_CODE            EQU 54
CLOSE_FILE_TRAP_CODE            EQU 56

PRESS_TO_DELETE_X               EQU 200
PRESS_TO_DELETE_Y               EQU 520
PRESS_TO_DELETE_WIDTH           EQU 360
PRESS_TO_DELETE_HEIGHT          EQU 24


*-------------------------------SaveFileInitialization---------------------------*
*   Try to get save data and create new save data from template if none exists
*--------------------------------------------------------------------------------*
SaveFileInitialization
    * Try opening existing save file
    move.l #OPEN_EXISTING_FILE_TRAP_CODE, d0
    lea LeaderboardFilePath, a1
    trap #15
    cmpi.l #FileNotFoundID, d1
    bne.s FileExists
    
    * Load Blank Leaderboard
    move.l #OPEN_EXISTING_FILE_TRAP_CODE, d0
    lea BlankLeaderboardFilePath, a1
    trap #15
    
    * Read from Blank Leaderboard
    move.l #READ_FILE_TRAP_CODE, d0
    lea LEADERBOARD_DATA, a1
    move.l #LeaderboardDataSize, d2
    trap #15
    
    * Close file to confirm write
    move.l #CLOSE_FILE_TRAP_CODE, d0
    trap #15
    
    * Create new leaderboard file
    move.l #OPEN_NEW_FILE_TRAP_CODE, d0
    lea LeaderboardFilePath, a1
    trap #15
    
    * Write to new leaderboard file
    move.l #WRITE_FILE_TRAP_CODE, d0
    lea LEADERBOARD_DATA, a1
    move.l #LeaderboardDataSize, d2
    trap #15
    
    * Close file to confirm write
    move.l #CLOSE_FILE_TRAP_CODE, d0
    trap #15
    
    * Open file we just created
    move.l #OPEN_EXISTING_FILE_TRAP_CODE, d0
    lea LeaderboardFilePath, a1
    trap #15

FileExists
    
    * Read from Leaderboard file
    move.l #READ_FILE_TRAP_CODE, d0
    lea LEADERBOARD_DATA, a1
    move.l #LeaderboardDataSize, d2
    trap #15
    
    * Close file
    move.l #CLOSE_FILE_TRAP_CODE, d0
    trap #15
    
    rts


*-------------------------DeleteSaveData-------------------------*
*   Deletes previous save data and replaces it with blank data
*----------------------------------------------------------------*
DeleteSaveData
    * Poll for Delete Key
    move.l #GET_KEY_STATE_TRAP_CODE, d0
    move.l #BackspaceASCIIValue, d1
    trap #15
    
    btst.l #0, d1                           ; test for Backspace pressed
    beq.s BackspaceNotPressed
    
    * Set Fill Color to Water Color
    move.l #SET_FILL_COLOR_TRAP_CODE, d0
    move.l #WATER_COLOR, d1
    trap #15
    
    * Set Pen Color to Water Color
    move.l #PEN_COLOR_TRAP_CODE, d0
    move.l #WATER_COLOR, d1
    trap #15
    
    * Fill Click to start message with water
    move.l #DRAW_RECT_TRAP_CODE, d0
    move.w #PRESS_TO_DELETE_X, d1
    move.w #PRESS_TO_DELETE_Y, d2
    move.w d1, d3
    move.w d2, d4
    add.w #PRESS_TO_DELETE_WIDTH, d3
    add.w #PRESS_TO_DELETE_HEIGHT, d4
    trap #15
    
    * Repaint from double buffer
    move.l #REPAINT_SCREEN_TRAP_CODE, d0
    trap #15

    * Load Blank Leaderboard
    move.l #OPEN_EXISTING_FILE_TRAP_CODE, d0
    lea BlankLeaderboardFilePath, a1
    trap #15
    
    * Read from Blank Leaderboard
    move.l #READ_FILE_TRAP_CODE, d0
    lea LEADERBOARD_DATA, a1
    move.l #LeaderboardDataSize, d2
    trap #15
    
    * Close file to confirm write
    move.l #CLOSE_FILE_TRAP_CODE, d0
    trap #15
    
    * Open leaderboard file
    move.l #OPEN_EXISTING_FILE_TRAP_CODE, d0
    lea LeaderboardFilePath, a1
    trap #15
    
    * Write to leaderboard file
    move.l #WRITE_FILE_TRAP_CODE, d0
    lea LEADERBOARD_DATA, a1
    move.l #LeaderboardDataSize, d2
    trap #15
    
    * Close file to confirm write
    move.l #CLOSE_FILE_TRAP_CODE, d0
    trap #15
    
BackspaceNotPressed
    
    rts
    

*-----------------------------GetPlayerName------------------------------*
*   Prompts the player for a 3 letter name to be saved on the leaderboard
*------------------------------------------------------------------------*
GetPlayerName
    * Clear Screen
    move.l #CLEAR_SCREEN_TRAP_CODE, d0
    move.w #CLEAR_SCREEN_MODE, d1                
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
    
    * Clear Screen
    move.l #CLEAR_SCREEN_TRAP_CODE, d0
    move.w #CLEAR_SCREEN_MODE, d1                
    trap #15
    
    * Draw Name Prompt
    lea NAME_PROMPT_BITMAP, a2
    move.l #PA_OFFSET, -(sp)                                            ; Bitmap Offset
    move.l #END_BANNER_WIDTH, -(sp)                                     ; Bitmap Width
    move.l #END_BANNER_HEIGHT, -(sp)                                    ; Bitmap Height
    move.l a2, -(sp)                                                    ; Bitmap Signature
    move.l #0, -(sp)                                                    ; Bitmap Chunk X
    move.l #0, -(sp)                                                    ; Bitmap Chunk Y
    move.l #END_BANNER_WIDTH, -(sp)                                     ; Bitmap Chunk Width
    move.l #END_BANNER_HEIGHT, -(sp)                                    ; Bitmap Chunk Height
    move.l #((OUTPUT_WINDOW_WIDTH/2)-(END_BANNER_WIDTH/2)), -(sp)       ; Output Screen X
    move.l #((OUTPUT_WINDOW_HEIGHT/2)-(END_BANNER_HEIGHT/2)), -(sp)     ; Output Screen Y
    jsr DisplayBitmapChunk
	add.l #BM_CHUNKER_STACK_SIZE, sp

    * Repaint from double buffer
    move.l #REPAINT_SCREEN_TRAP_CODE, d0
    trap #15 
    
    * Set Fill Color to White
    move.l #SET_FILL_COLOR_TRAP_CODE, d0
    move.l #WHITE, d1
    trap #15
    
    * Set Font
    move.l #SET_FONT_TRAP_CODE, d0
    move.l #BLACK, d1
    move.l #NAME_PROMPT_FONT, d2
    trap #15
    
    lea PlayerName, a0                                                  ; load PlayerName memory

*----------Get First character----------*
GetCharacterOne
    * Set Cursor Position
    move.l #SET_CURSOR_POSITION_TRAP_CODE, d0
    move.l #NAME_PROMPT_CURSOR_POSITION_1, d1
    trap #15
    
    * Get Single ASCII Char and make sure its printable
    move.l #GET_SINGLE_CHAR_TRAP_CODE, d0
    trap #15
    cmpi.b #MAX_PRINATBLE_CHARACTER, d1
    bgt GetCharacterOne
    cmpi.b #MIN_PRINATBLE_CHARACTER, d1
    blt GetCharacterOne
    move.b d1, (a0)+                                                    ; move charachter to PlayerName memory
    
*----------Get Second character----------*
GetCharacterTwo
    * Set Cursor Position
    move.l #SET_CURSOR_POSITION_TRAP_CODE, d0
    move.l #NAME_PROMPT_CURSOR_POSITION_2, d1
    trap #15
    
    * Get Single ASCII Char and make sure its printable
    move.l #GET_SINGLE_CHAR_TRAP_CODE, d0
    trap #15
    cmpi.b #MAX_PRINATBLE_CHARACTER, d1
    bgt GetCharacterTwo
    cmpi.b #MIN_PRINATBLE_CHARACTER, d1
    blt GetCharacterTwo
    move.b d1, (a0)+                                                    ; move charachter to PlayerName memory
    
*----------Get Third character----------*
GetCharacterThree
    * Set Cursor Position
    move.l #SET_CURSOR_POSITION_TRAP_CODE, d0
    move.l #NAME_PROMPT_CURSOR_POSITION_3, d1
    trap #15
    
    * Get Single ASCII Char and make sure its printable
    move.l #GET_SINGLE_CHAR_TRAP_CODE, d0
    trap #15
    cmpi.b #MAX_PRINATBLE_CHARACTER, d1
    bgt GetCharacterThree
    cmpi.b #MIN_PRINATBLE_CHARACTER, d1
    blt GetCharacterThree
    move.b d1, (a0)+
    
    rts
    
*----------------AddScoreToLeaderboard----------------*
*   Adds players score to leaderboard in the correct  
*   spot and saves it to the leaderboard.bin file
*-----------------------------------------------------*
AddScoreToLeaderboard   
    lea PlayerName, a1
    move.l (a1), d0                             ; d0 = player name
    
    * Get Fish Count
    lea FishingManagerTable, a2
    moveq #0, d4
    move.b GET_NUM_FISH_CAUGHT(a2), d4          ; score = d4
     
    * Add mullet bonus
    lea GameState, a2
    move.b (a2), d3
    cmpi.b #MULLET_CAUGHT_STATE, d3
    bne.s SkipMulletScoreAddition
    addi.l #MULLET_SCORE_BONUS, d4              ; score += mullet bonus
SkipMulletScoreAddition
    move.b d4, d0                               ; d0 = player name and score

    lea LEADERBOARD_DATA, a0
    move.l #9, d7
InsertScoreLoop
    move.l (a0), d1
    cmp.b d1, d0
    ble.s SkipSwap                              ; update if current min > current GameObject
    
    * Update Min
    move.l d0, (a0)
    move.l d1, d0
SkipSwap
    add.l #4, a0                                ; Increment to next GameObject
    dbra d7, InsertScoreLoop
    
    * Open leaderboard file
    move.l #OPEN_EXISTING_FILE_TRAP_CODE, d0
    lea LeaderboardFilePath, a1
    trap #15
    
    * Write updated scores to leaderboard file
    move.l #WRITE_FILE_TRAP_CODE, d0
    lea LEADERBOARD_DATA, a1
    move.l #LeaderboardDataSize, d2
    trap #15
    
    * Close file to confirm write
    move.l #CLOSE_FILE_TRAP_CODE, d0
    trap #15
    
    rts
    
*--------------------DrawLeaderboard--------------------*
*   Draws the leaderboard scores to the screen in order
*-------------------------------------------------------*    
DrawLeaderboard
    * Draw Leaderboard
    lea LEADERBOARD_BITMAP, a2
    move.l #PA_OFFSET, -(sp)                                            ; Bitmap Offset
    move.l #LEADERBOARD_WIDTH, -(sp)                                    ; Bitmap Width
    move.l #LEADERBOARD_HEIGHT, -(sp)                                   ; Bitmap Height
    move.l a2, -(sp)                                                    ; Bitmap Signature
    move.l #0, -(sp)                                                    ; Bitmap Chunk X
    move.l #0, -(sp)                                                    ; Bitmap Chunk Y
    move.l #LEADERBOARD_WIDTH, -(sp)                                    ; Bitmap Chunk Width
    move.l #LEADERBOARD_HEIGHT, -(sp)                                   ; Bitmap Chunk Height
    move.l #(LEADERBOARD_X-(LEADERBOARD_WIDTH/2)), -(sp)                ; Output Screen X
    move.l #((OUTPUT_WINDOW_HEIGHT/2)-(LEADERBOARD_HEIGHT/2)), -(sp)    ; Output Screen Y
    jsr DisplayBitmapChunk
	add.l #BM_CHUNKER_STACK_SIZE, sp
	
	* Draw Scores
    lea LEADERBOARD_DATA, a0
    lea LeaderboardScoreText, a1
    move.l #9, d7
    move.l #LEADERBOARD_ENTRY_Y, d2
    
DrawScore
    moveq #0, d4
    moveq #0, d5
    move.l (a0)+, d0                    
    move.b d0, d4                                   ; d4 = score
    move.b #SPACE_ASCII_CHAR, d0                    ; d0 = "name "
    move.l d0, NAME_CHARCTER_OFFSET(a1)             ; add name to string
    
    * Display 0 score if score is -1 (placeholder score)
    move.b d4, d4                                   ; move byte of d4 to itself to trigger the branch
    bpl.s NotPlaceholderScore                       ; skip reset if score is positive
    moveq #0, d4                                    ; set score to 0
NotPlaceholderScore
    
    * Get Score
    divu #10, d4
    move.w d4, d5                                   ; d5 = tens place
    swap d4                                         ; d4 = ones place
    addi.b #DEC_TO_ASCII, d5                        ; d5 = tens place (ascii charachter)
    addi.b #DEC_TO_ASCII, d4                        ; d4 = ones place (ascii charachter)
    move.b d5, HIGHSCORE_CHARCTER_OFFSET(a1)        ; add tens place to string
    move.b d4, (HIGHSCORE_CHARCTER_OFFSET+1)(a1)    ; add ones place to string
    
    * Display Line
    move.l #TEXT_TO_SCREEN_TRAP_CODE, d0
    move.l #LEADERBOARD_ENTRY_X, d1               
    trap #15
    
    addi.l #LEADERBOARD_ENTRY_LINE_SPACE , d2
    dbra d7, DrawScore
    
    * Repaint from double buffer
    move.l #REPAINT_SCREEN_TRAP_CODE, d0
    trap #15
    
    rts


*--------------------Global Variables--------------------*
LEADERBOARD_BITMAP 	
    INCBIN "Assets\leaderboard_display.bmp"
END_LEADERBOARD_BITMAP

NAME_PROMPT_BITMAP
    INCBIN "Assets\name_prompt.bmp"
END_NAME_PROMPT_BITMAP

LEADERBOARD_DATA ds.l 10
LeaderboardFilePath dc.b 'SaveData\leaderboard.bin', 0
BlankLeaderboardFilePath dc.b 'SaveData\blank_leaderboard.bin', 0
PlayerName ds.l 1
LeaderboardScoreText dc.w '---      00', 0


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
