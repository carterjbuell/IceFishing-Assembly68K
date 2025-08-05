*-----------------------------------------------------------
* Title      : FleeingFishPhysicsUpdate
* Written by : Carter Buell
* Date       : 6/16/2025
* Description: Updates the fish flee animation physics
*-----------------------------------------------------------
GET_Y_POSITION                  EQU 0
GET_Y_VELOCITY                  EQU 4
GET_X_POSITION                  EQU 8
GET_X_VELOCITY                  EQU 10

NUM_FRACTIONAL_BITS             EQU 4
GRAVITY                         EQU %01100              ; 0.1100 = 0.75
FISH_FLEE_X_VELOCITY            EQU 2

FleeingFishPhysicsUpdate
    lea FleeingFishPhysicsManager, a2
    moveq #0, d4
    move.w GET_X_POSITION(a2), d3                       ; d4 = x-pos
    move.l GET_Y_POSITION(a2), d5                       ; d5 = y-pos
    move.l GET_Y_VELOCITY(a2), d6                       ; d6 = y velocity
    lsr.l #NUM_FRACTIONAL_BITS, d5
    lsr.l #NUM_FRACTIONAL_BITS, d6
    
    cmpi.l #(OUTPUT_WINDOW_HEIGHT-CAUGHT_FISH_HEIGHT), d5
	bge SkipPhysicsUpdate
    
    * Draw BG
    lea BG_BITMAP, a2
    move.l #PA_OFFSET, -(sp)                            ; Bitmap Offset
    move.l #OUTPUT_WINDOW_WIDTH, -(sp)                  ; Bitmap Width
    move.l #OUTPUT_WINDOW_HEIGHT, -(sp)                 ; Bitmap Height
    move.l a2, -(sp)                                    ; Bitmap Signature
    move.l d3, -(sp)                                    ; Bitmap Chunk X
    move.l d5, -(sp)                                    ; Bitmap Chunk Y
    move.l #CAUGHT_FISH_WIDTH, -(sp)                    ; Bitmap Chunk Width
    move.l #CAUGHT_FISH_HEIGHT, -(sp)                   ; Bitmap Chunk Height
    move.l d3, -(sp)                                    ; Output Screen X
    move.l d5, -(sp)                                    ; Output Screen Y
	jsr DisplayBitmapChunk
	add.l #BM_CHUNKER_STACK_SIZE, sp
	
	* Update position and velocity
	moveq #0, d3
	moveq #0, d4
	lea FleeingFishPhysicsManager, a2
	move.w GET_X_POSITION(a2), d3                       ; d3 = x-pos
    move.w GET_X_VELOCITY(a2), d4                       ; d4 = x velocity
    move.l GET_Y_POSITION(a2), d5                       ; d5 = y-pos
    move.l GET_Y_VELOCITY(a2), d6                       ; d6 = y velocity

	add.l #GRAVITY, d6                                  ; Increase y velocity
	add.l d6, d5                                        ; Increase y position
	add.w d4, d3                                        ; Increase x position
	move.w d3, GET_X_POSITION(a2)
	move.l d5, GET_Y_POSITION(a2)
	move.l d6, GET_Y_VELOCITY(a2)
	lsr.l #NUM_FRACTIONAL_BITS, d5
    lsr.l #NUM_FRACTIONAL_BITS, d6

	cmpi.l #OUTPUT_WINDOW_HEIGHT-CAUGHT_FISH_HEIGHT, d5
	bge SkipPhysicsUpdate
	
    * Draw fish
    lea CAUGHT_FISH_BITMAP, a2
    move.l #PA_OFFSET, -(sp)                            ; Bitmap Offset
    move.l #CAUGHT_FISH_WIDTH, -(sp)                    ; Bitmap Width
    move.l #CAUGHT_FISH_HEIGHT, -(sp)                   ; Bitmap Height
    move.l a2, -(sp)                                    ; Bitmap Signature
    move.l #0, -(sp)                                    ; Bitmap Chunk X
    move.l #0, -(sp)                                    ; Bitmap Chunk Y
    move.l #CAUGHT_FISH_WIDTH, -(sp)                    ; Bitmap Chunk Width
    move.l #CAUGHT_FISH_HEIGHT, -(sp)                   ; Bitmap Chunk Height
    move.l d3, -(sp)                                    ; Output Screen X
    move.l d5, -(sp)                                    ; Output Screen Y
	jsr DisplayBitmapChunk
	add.l #BM_CHUNKER_STACK_SIZE, sp
	
SkipPhysicsUpdate
    
    rts

*-----------------Global Variables-----------------*

*--3 longs: [y-pos with 4 fractional bits] + [y-velocity with 4 fractional bits] + [Upper Word = x-position, Lower Word = x-velocity]--*
FleeingFishPhysicsManager ds.l 3



*~Font name~Courier New~
*~Font size~12~
*~Tab type~1~
*~Tab size~4~
