*-----------------------------------------------------------
* Title      : GetNewWorm
* Written by : Carter Buell
* Date       : 6/6/2025
* Description: Handles catching fish
*-----------------------------------------------------------

GetNewWorm
    * Check for mouse click input 
    move.l #MOUSE_INPUT_TRAP_CODE, d0
    moveq #0, d1                                        ; Set mode to "read mouse down state"
    trap #15
    btst #0, d0 
    beq CannotGetNewWorm

    * Check if you do not have a worm
    lea FishingManagerTable, a1
    moveq #0, d0
    move.b GET_IS_WORM_ON_HOOK(a1), d0
    bne.s CannotGetNewWorm
    
    * Check for correct bounds to catch fish
    lea CurrentMouseY, a1
    move.l (a1), d5                                     ; d5 = CurrentMouseY
    cmpi.l #ABOVE_WATER, d5
    bgt.s CannotGetNewWorm
    
    * Catch Fish
    lea FishingManagerTable, a1
    sub.b #1, GET_NUM_WORMS_LEFT(a1)                    ; Decrease worm count by 1
    move.b #1, GET_IS_WORM_ON_HOOK(a1)                  ; Add worm to line
    
    * Change worm counter display
    move.b GET_NUM_WORMS_LEFT(a1), d0
    lea WORM_COUNT_BITMAP, a2
    move.l #PA_OFFSET, -(sp)                             ; Bitmap Offset
    move.l #WORM_COUNT_WIDTH, -(sp)                      ; Bitmap Width
    move.l #(WORM_COUNT_HEIGHT*4), -(sp)                 ; Bitmap Height
    move.l a2, -(sp)                                     ; Bitmap Signature
    move.l #0, -(sp)                                     ; Bitmap Chunk X
    mulu #WORM_COUNT_HEIGHT, d0
    move.l d0, -(sp)                                     ; Bitmap Chunk Y
    move.l #WORM_COUNT_WIDTH, -(sp)                      ; Bitmap Chunk Width
    move.l #WORM_COUNT_HEIGHT, -(sp)                     ; Bitmap Chunk Height
    move.l #WORM_COUNT_X, -(sp)                          ; Output Screen X
    move.l #WORM_COUNT_Y, -(sp)                          ; Output Screen Y
    jsr DisplayBitmapChunk
	add.l #BM_CHUNKER_STACK_SIZE, sp
    
    * Play ding sound?                      
    move.l #PLAY_SOUND_TRAP_CODE, d0
    lea DingSound, a1
    trap #15
    
CannotGetNewWorm

    rts
    
*--------------------Global Variables--------------------*
DingSound dc.w 'Assets\sounds\new_worm.wav', 0

*~Font name~Courier New~
*~Font size~12~
*~Tab type~1~
*~Tab size~4~
