*-----------------------------------------------------------
* Title      : DrawFishingUI
* Written by : Carter Buell
* Date       : 5/30/2025
* Description: Draws all non-GameObject game elements
*-----------------------------------------------------------

BOBBER_WIDTH                    EQU 4
BOBBER_HEIGHT                   EQU 5

WORM_WIDTH                      EQU 2
WORM_LENGTH                     EQU 8

DrawFishingUI   
    * Set Fishing Line Pen Color
    move.l #PEN_COLOR_TRAP_CODE, d0
    moveq #0, d1
    trap #15

    lea CurrentMouseY, a1
    move.l (a1), d5                                     ; d5 = CurrentMouseY

    * Draw Fishing Line
    move.l #DRAW_LINE_TRAP_CODE, d0
    move.w #TOP_OF_POLE, d2
    move.w d5, d4
    move.w #POLE_X, d1
    move.w #POLE_X, d3
    trap #15

    * Set Bobber Pen Color
    move.l #PEN_COLOR_TRAP_CODE, d0
    move.l #RED, d1
    trap #15
    
    * Set Bobber Fill Color
    move.l #SET_FILL_COLOR_TRAP_CODE, d0
    move.l #WHITE, d1
    trap #15
    
    * Draw Bobber
    move.l #DRAW_RECT_TRAP_CODE, d0
    move.w d5, d2
    move.w d5, d4
    subi.w #BOBBER_HEIGHT, d2
    addi.w #BOBBER_HEIGHT, d4
    move.w #(POLE_X)-BOBBER_WIDTH, d1
    move.w #(POLE_X)+BOBBER_WIDTH, d3
    trap #15
    
    * Draw worm if worm on line
    lea FishingManagerTable, a1
    move.b GET_IS_WORM_ON_HOOK(a1), d0
    beq.s DontDisplayWorm
    
    * Set Worm Pen Color
    move.l #PEN_COLOR_TRAP_CODE, d0
    move.l #WORM_PEN_COLOR, d1
    trap #15
    
    * Set Worm Fill Color
    move.l #SET_FILL_COLOR_TRAP_CODE, d0
    move.l #WORM_FILL_COLOR, d1
    trap #15
    
    * Draw Worm
    move.l #DRAW_RECT_TRAP_CODE, d0
    move.w d5, d2
    move.w d5, d4
    addi.w #WORM_WIDTH, d4
    subi.w #WORM_WIDTH, d2
    move.w #(POLE_X)-WORM_LENGTH, d1
    move.w #(POLE_X)+WORM_LENGTH, d3
    trap #15
DontDisplayWorm

    lea CurrentMouseY, a1
    move.l (a1), d5                                     ; d5 = CurrentMouseY
    
    * Draw fish if fish on line
    lea FishingManagerTable, a1
    move.b GET_IS_FISH_ON_HOOK(a1), d0
    beq.s DontDisplayFish
    lea CAUGHT_FISH_BITMAP, a2
    move.l #PA_OFFSET, -(sp)                            ; Bitmap Offset
    move.l #CAUGHT_FISH_WIDTH, -(sp)                    ; Bitmap Width
    move.l #CAUGHT_FISH_HEIGHT, -(sp)                   ; Bitmap Height
    move.l a2, -(sp)                                    ; Bitmap Signature
    move.l #0, -(sp)                                    ; Bitmap Chunk X
    move.l #0, -(sp)                                    ; Bitmap Chunk Y
    move.l #CAUGHT_FISH_WIDTH, -(sp)                    ; Bitmap Chunk Width
    move.l #CAUGHT_FISH_HEIGHT, -(sp)                   ; Bitmap Chunk Height
    move.l #POLE_X-(CAUGHT_FISH_WIDTH/2), -(sp)         ; Output Screen X
    move.l d5, -(sp)                                    ; Output Screen Y
	jsr DisplayBitmapChunk
	add.l #BM_CHUNKER_STACK_SIZE, sp
DontDisplayFish

    lea CurrentMouseY, a1
    move.l (a1), d5                                     ; d5 = CurrentMouseY

    * Check if GameObjects and line should be hidden by ice
    cmpi.l #(ICE_SEGMENT_TOP-CAUGHT_FISH_HEIGHT), d5
    blt DontDrawIceSegment
    
    * Fill behind fishing line
    lea BG_BITMAP, a2
    move.l #PA_OFFSET, -(sp)                            ; Bitmap Offset
    move.l #OUTPUT_WINDOW_WIDTH, -(sp)                  ; Bitmap Width
    move.l #OUTPUT_WINDOW_HEIGHT, -(sp)                 ; Bitmap Height
    move.l a2, -(sp)                                    ; Bitmap Signature
    move.l #POLE_X, -(sp)                               ; Bitmap Chunk X
    move.l #ICE_SEGMENT_TOP, -(sp)                      ; Bitmap Chunk Y
    move.l #1, -(sp)                                    ; Bitmap Chunk Width
    move.l #ICE_SEGMENT_HEIGHT, -(sp)                    ; Bitmap Chunk Height
    move.l #POLE_X, -(sp)                               ; Output Screen X
    move.l #ICE_SEGMENT_TOP, -(sp)                      ; Output Screen Y
	jsr DisplayBitmapChunk
	add.l #BM_CHUNKER_STACK_SIZE, sp
    
    lea CurrentMouseY, a1
    move.l (a1), d5                                     ; d5 = CurrentMouseY
    
    * Check if only GameObjects should be hidden by ice
    cmpi.l #ICE_SEGMENT_BOTTOM, d5
    bgt.s DontDrawIceSegment
    
    * Draw Ice Segment
    lea BG_BITMAP, a2
    move.l #PA_OFFSET, -(sp)                            ; Bitmap Offset
    move.l #OUTPUT_WINDOW_WIDTH, -(sp)                  ; Bitmap Width
    move.l #OUTPUT_WINDOW_HEIGHT, -(sp)                 ; Bitmap Height
    move.l a2, -(sp)                                    ; Bitmap Signature
    move.l #POLE_X-(CAUGHT_FISH_WIDTH/2), -(sp)         ; Bitmap Chunk X
    move.l #(ICE_SEGMENT_TOP), -(sp)                    ; Bitmap Chunk Y
    move.l #CAUGHT_FISH_WIDTH, -(sp)                    ; Bitmap Chunk Width
    move.l #(ICE_SEGMENT_HEIGHT), -(sp)                 ; Bitmap Chunk Height
    move.l #POLE_X-(CAUGHT_FISH_WIDTH/2), -(sp)         ; Output Screen X
    move.l #ICE_SEGMENT_TOP, -(sp)   ; Output Screen Y
	jsr DisplayBitmapChunk
	add.l #BM_CHUNKER_STACK_SIZE, sp
DontDrawIceSegment
    
    * Repaint from double buffer
    move.l #REPAINT_SCREEN_TRAP_CODE, d0
    trap #15
    
    lea CurrentMouseY, a1
    move.l (a1), d5                                     ; d5 = CurrentMouseY

    * Fill behind fishing line
    lea BG_BITMAP, a2
    move.l #PA_OFFSET, -(sp)                            ; Bitmap Offset
    move.l #OUTPUT_WINDOW_WIDTH, -(sp)                  ; Bitmap Width
    move.l #OUTPUT_WINDOW_HEIGHT, -(sp)                 ; Bitmap Height
    move.l a2, -(sp)                                    ; Bitmap Signature
    move.l #POLE_X, -(sp)                               ; Bitmap Chunk X
    move.l #TOP_OF_POLE, -(sp)                          ; Bitmap Chunk Y
    move.l #1, -(sp)                                    ; Bitmap Chunk Width
    move.l d5, d0
    sub.l #TOP_OF_POLE, d0
    move.l d0, -(sp)                                    ; Bitmap Chunk Height
    move.l #POLE_X, -(sp)                               ; Output Screen X
    move.l #TOP_OF_POLE, -(sp)                          ; Output Screen Y
	jsr DisplayBitmapChunk
	add.l #BM_CHUNKER_STACK_SIZE, sp
    
    lea CurrentMouseY, a1
    move.l (a1), d5                                     ; d5 = CurrentMouseY
    
    * Fill behind bobber
    subi.w #BOBBER_HEIGHT, d5
    lea BG_BITMAP, a2
    move.l #PA_OFFSET, -(sp)                            ; Bitmap Offset
    move.l #OUTPUT_WINDOW_WIDTH, -(sp)                  ; Bitmap Width
    move.l #OUTPUT_WINDOW_HEIGHT, -(sp)                 ; Bitmap Height
    move.l a2, -(sp)                                    ; Bitmap Signature
    move.l #(POLE_X)-BOBBER_WIDTH, -(sp)                ; Bitmap Chunk X
    move.l d5, -(sp)                                    ; Bitmap Chunk Y
    move.l #(BOBBER_WIDTH*2)+1, -(sp)                   ; Bitmap Chunk Width
    move.l #(BOBBER_HEIGHT*2)+1, -(sp)                    ; Bitmap Chunk Height
    move.l #(POLE_X)-BOBBER_WIDTH, -(sp)                ; Output Screen X
    move.l d5, -(sp)                                    ; Output Screen Y
	jsr DisplayBitmapChunk
	add.l #BM_CHUNKER_STACK_SIZE, sp
	
	* Fill behind worm if worm on line
    lea FishingManagerTable, a1
    move.b GET_IS_WORM_ON_HOOK(a1), d0
    beq.s DontFillWorm
    
    lea CurrentMouseY, a1
    move.l (a1), d5                                     ; d5 = CurrentMouseY
    
	* Fill behind worm
	subi.l #WORM_WIDTH, d5
    lea BG_BITMAP, a2
    move.l #PA_OFFSET, -(sp)                            ; Bitmap Offset
    move.l #OUTPUT_WINDOW_WIDTH, -(sp)                  ; Bitmap Width
    move.l #OUTPUT_WINDOW_HEIGHT, -(sp)                 ; Bitmap Height
    move.l a2, -(sp)                                    ; Bitmap Signature
    move.l #(POLE_X)-WORM_LENGTH, -(sp)                 ; Bitmap Chunk X
    move.l d5, -(sp)                                    ; Bitmap Chunk Y
    move.l #(WORM_LENGTH*2)+1, -(sp)                    ; Bitmap Chunk Width
    move.l #(WORM_WIDTH*2)+1, -(sp)                     ; Bitmap Chunk Height
    move.l #(POLE_X)-WORM_LENGTH, -(sp)                 ; Output Screen X
    move.l d5, -(sp)                                    ; Output Screen Y
	jsr DisplayBitmapChunk
	add.l #BM_CHUNKER_STACK_SIZE, sp
DontFillWorm
    
    lea CurrentMouseY, a1
    move.l (a1), d5                                     ; d5 = CurrentMouseY
    
    * Fill fish if fish on line
    lea FishingManagerTable, a1
    move.b GET_IS_FISH_ON_HOOK(a1), d0
    beq.s DontFillFish
    lea BG_BITMAP, a2
    move.l #PA_OFFSET, -(sp)                            ; Bitmap Offset
    move.l #OUTPUT_WINDOW_WIDTH, -(sp)                  ; Bitmap Width
    move.l #OUTPUT_WINDOW_HEIGHT, -(sp)                 ; Bitmap Height
    move.l a2, -(sp)                                    ; Bitmap Signature
    move.l #POLE_X-(CAUGHT_FISH_WIDTH/2), -(sp)         ; Bitmap Chunk X
    move.l d5, -(sp)                                    ; Bitmap Chunk Y
    move.l #CAUGHT_FISH_WIDTH, -(sp)                    ; Bitmap Chunk Width
    move.l #CAUGHT_FISH_HEIGHT, -(sp)                   ; Bitmap Chunk Height
    move.l #POLE_X-(CAUGHT_FISH_WIDTH/2), -(sp)         ; Output Screen X
    move.l d5, -(sp)                                    ; Output Screen Y
	jsr DisplayBitmapChunk
	add.l #BM_CHUNKER_STACK_SIZE, sp
DontFillFish

    * Set Water Pen Color
    move.l #PEN_COLOR_TRAP_CODE, d0
    move.l #WATER_COLOR, d1
    trap #15
    
    * Set Water Fill Color
    move.l #SET_FILL_COLOR_TRAP_CODE, d0
    move.l #WATER_COLOR, d1
    trap #15
    
    rts

*~Font name~Courier New~
*~Font size~12~
*~Tab type~1~
*~Tab size~4~
