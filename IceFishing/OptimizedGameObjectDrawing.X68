*-----------------------------------------------------------
* Title      : OptimizedGameObjectDrawing
* Written by : Carter Buell
* Date       : 6/20/2025
* Description: Subroutines used to draw frequently drawn 
*              GameObject in a more efficient way
*-----------------------------------------------------------

SAVE_OFFSET                     EQU 24
SAVE_LOCATION                   EQU 20
SAVE_WIDTH                      EQU 16
SAVE_HEIGHT                     EQU 12        
DISPLAY_SAVE_X                  EQU 8
DISPLAY_SAVE_Y                  EQU 4

GET_DESTINATION_ADDRESS_Q       EQU 40
GET_PIXEL_ARRAY_OFFSET_LOCAL_Q  EQU 36
GET_BMAP_WIDTH_LOCAL_Q          EQU 32
GET_BMAP_HEIGHT_LOCAL_Q         EQU 28
BMP_SIGNATURE_LOCAL_Q           EQU 24
CHUNK_START_X_LOCAL_Q           EQU 20
CHUNK_START_Y_LOCAL_Q           EQU 16
CHUNK_WIDTH_LOCAL_Q             EQU 12
CHUNK_HEIGHT_LOCAL_Q            EQU 8        
ROW_OFFSET_LOCAL_Q              EQU 0

QUICK_REFORMAT_STACK_SIZE       EQU 36
QUICK_DRAW_STACK_SIZE           EQU 24


*-----------------QuickDrawReformat-----------------*
*   Saves content of bitmap to a new spot in memory 
*   in a format that is quicker to draw from 
*---------------------------------------------------*
QuickDrawReformat
    subq #4, sp                                 ; Make space for local variable on stack
    
    * Get ptr to destination
    move.l GET_DESTINATION_ADDRESS_Q(sp), a1

    * Get ptr to bitmap
    move.l BMP_SIGNATURE_LOCAL_Q(sp), a0
    
    * Get offset of pixel array
    move.l GET_PIXEL_ARRAY_OFFSET_LOCAL_Q(sp), d0
    
    * Get Bitmap width
    move.l GET_BMAP_WIDTH_LOCAL_Q(sp), d6
    move.l d6, d7
    
    * Get Bitmap height
    move.l GET_BMAP_HEIGHT_LOCAL_Q(sp), d5
    
    * Add offset to a0
    add.l d0, a0
    moveq #0, d0
    
    * Set starting values
    move.l d5, d3
    move.l CHUNK_HEIGHT_LOCAL_Q(sp), d5
    subq #1, d5                                 ; Adjust for dbra
    
    * Calculate and store row offset
    move.l d7, d1                               ; d1 = bitmap width
    sub.l CHUNK_WIDTH_LOCAL_Q(sp), d1           ; d1 = (bitmap width - CHUNK_WIDTH)
    lsl.l #2, d1                                ; multiply by 4 (since there are 4 bytes per pixel
    move.l d1, ROW_OFFSET_LOCAL_Q(sp)           ; move row offset to stack (local variable)

    * Increment in pixel array to correct starting spot
    move.l d7, d1                               ; d1 = bitmap width
    sub.l CHUNK_START_Y_LOCAL_Q(sp), d3
    sub.l CHUNK_HEIGHT_LOCAL_Q(sp), d3
    mulu d3, d1                                 ; d1 = (bitmap width * (bitmap_height-CHUNK_START_Y-CHUNK_HEIGHT))
    add.l CHUNK_START_X_LOCAL_Q(sp), d1         ; d1 = bitmap width * (bitmap_height-CHUNK_START_Y-CHUNK_HEIGHT))) + X
    lsl.l #2, d1                                ; multiply by 4 (since there are 4 bytes per pixel)                          
    lea (a0, d1.l), a0

SaveRows
    move.l CHUNK_WIDTH_LOCAL_Q(sp), d6
    subq.w #1, d6                               ; Adjust for dbra
SaveRow
    * Store Color
    move.l (a0)+, d1 
    move.b d1, d0                               ; Store alpha value in d0
    move.b #1, d1                               ; clear alpha value
    move.b d0, d0                               ; move byte so 0-flag is set for compare
    beq.s Transparent
    subq #1, d1
Transparent
    
    ror.l #8, d1
    move.l d1, (a1)+

    dbra d6, SaveRow
    * Increment to next row
    move.l ROW_OFFSET_LOCAL_Q(sp), d1
    lea (a0, d1), a0
    dbra d5, SaveRows
    add.l   #4, sp                              ; fix stack from local variable
	rts


*----------------SaveGameObjectBitmaps-------------------*
*    Saves all GameObject bitmaps for use in QuickDraw
*--------------------------------------------------------*
SaveGameObjectBitmaps
    lea FISH_BITMAP, a2
    lea FishQuickSave, a0
    move.l a0, -(sp)                                    ; Destination
    move.l #PA_OFFSET, -(sp)                            ; Bitmap Offset
    move.l #FISH_WIDTH, -(sp)                           ; Bitmap Width
    move.l #(FISH_HEIGHT*4), -(sp)                      ; Bitmap Height
    move.l a2, -(sp)                                    ; Bitmap Signature
    move.l #0, -(sp)                                    ; Bitmap Chunk X
    move.l #0, -(sp)                                    ; Bitmap Chunk Y
    move.l #FISH_WIDTH, -(sp)                           ; Bitmap Chunk Width
    move.l #(FISH_HEIGHT*4), -(sp)                      ; Bitmap Chunk Height
    jsr QuickDrawReformat 
	add.l #QUICK_REFORMAT_STACK_SIZE, sp
	
	lea FISH_BITMAP_FLIPPED , a2
    lea FlippedFishQuickSave, a0
    move.l a0, -(sp)                                    ; Destination
    move.l #PA_OFFSET, -(sp)                            ; Bitmap Offset
    move.l #FISH_WIDTH, -(sp)                           ; Bitmap Width
    move.l #(FISH_HEIGHT*4), -(sp)                      ; Bitmap Height
    move.l a2, -(sp)                                    ; Bitmap Signature
    move.l #0, -(sp)                                    ; Bitmap Chunk X
    move.l #0, -(sp)                                    ; Bitmap Chunk Y
    move.l #FISH_WIDTH, -(sp)                           ; Bitmap Chunk Width
    move.l #(FISH_HEIGHT*4), -(sp)                      ; Bitmap Chunk Height
    jsr QuickDrawReformat 
	add.l #QUICK_REFORMAT_STACK_SIZE, sp
    
    lea BOOT_BITMAP, a2
    lea BootQuickSave, a0
    move.l a0, -(sp)                                    ; Destination
    move.l #PA_OFFSET, -(sp)                            ; Bitmap Offset
    move.l #BOOT_WIDTH, -(sp)                           ; Bitmap Width
    move.l #(BOOT_HEIGHT*4), -(sp)                      ; Bitmap Height
    move.l a2, -(sp)                                    ; Bitmap Signature
    move.l #0, -(sp)                                    ; Bitmap Chunk X
    move.l #0, -(sp)                                    ; Bitmap Chunk Y
    move.l #BOOT_WIDTH, -(sp)                           ; Bitmap Chunk Width
    move.l #(BOOT_HEIGHT*4), -(sp)                      ; Bitmap Chunk Height
    jsr QuickDrawReformat 
	add.l #QUICK_REFORMAT_STACK_SIZE, sp

    lea JELLY_BITMAP, a2
    lea JellyQuickSave, a0
    move.l a0, -(sp)                                    ; Destination
    move.l #PA_OFFSET, -(sp)                            ; Bitmap Offset
    move.l #JELLY_WIDTH, -(sp)                          ; Bitmap Width
    move.l #(JELLY_HEIGHT*4), -(sp)                     ; Bitmap Height
    move.l a2, -(sp)                                    ; Bitmap Signature
    move.l #0, -(sp)                                    ; Bitmap Chunk X
    move.l #0, -(sp)                                    ; Bitmap Chunk Y
    move.l #JELLY_WIDTH, -(sp)                          ; Bitmap Chunk Width
    move.l #(JELLY_HEIGHT*4), -(sp)                     ; Bitmap Chunk Height
    jsr QuickDrawReformat 
	add.l #QUICK_REFORMAT_STACK_SIZE, sp

    lea MULLET_BITMAP, a2
    lea MulletQuickSave, a0
    move.l a0, -(sp)                                    ; Destination
    move.l #PA_OFFSET, -(sp)                            ; Bitmap Offset
    move.l #MULLET_WIDTH, -(sp)                         ; Bitmap Width
    move.l #(MULLET_HEIGHT*4), -(sp)                    ; Bitmap Height
    move.l a2, -(sp)                                    ; Bitmap Signature
    move.l #0, -(sp)                                    ; Bitmap Chunk X
    move.l #0, -(sp)                                    ; Bitmap Chunk Y
    move.l #MULLET_WIDTH, -(sp)                         ; Bitmap Chunk Width
    move.l #(MULLET_HEIGHT*4), -(sp)                    ; Bitmap Chunk Height
    jsr QuickDrawReformat 
	add.l #QUICK_REFORMAT_STACK_SIZE, sp

    rts
    

*----------------------------QuickDraw----------------------------*
* Draws from saved memory in a more efficent way 
* Cannot draw chunks of bitmap but can draw with a constant offset 
*-----------------------------------------------------------------*
QuickDraw

    * Get saved pixel data and adjust for offset
    move.l SAVE_LOCATION(sp), a0
    move.l SAVE_OFFSET(sp), d0
    lsl.l #2, d0
    lea (a0, d0.l), a0
    
    * Set starting values
    move.l DISPLAY_SAVE_Y(sp), d2           ; Set Starting Y
    subq #1, d2
    add.l SAVE_HEIGHT(sp), d2
    move.l SAVE_HEIGHT(sp), d5              ; Set Y loop Counter
    subq #1, d5                             ; Adjust for dbra

QuickDrawRows
    move.l DISPLAY_SAVE_X(sp), d3           ; Set Starting X
    move.l SAVE_WIDTH(sp), d6               ; Set X loop Counter
    subq #1, d6                             ; Adjust for dbra
QuickDrawRow
    * Set Pen Color
    move.l #PEN_COLOR_TRAP_CODE, d0
    move.l (a0)+, d1
    btst #24, d1                            ; Check 24th bit for transparency
    bne.s DoNotDrawPixel
    trap #15
   
    * Draw Pixel
    move.l d3, d1
    move.l #DRAW_PIXEL_TRAP_CODE, d0
    trap #15
DoNotDrawPixel
    addq #1, d3                             ; Increment Position-X
    dbra d6, QuickDrawRow
    subq #1, d2                             ; Increment Position-Y
    dbra d5, QuickDrawRows
	rts


*----------------------Global Variables----------------------*

FISH_BITMAP 	
    INCBIN "Assets\fish.bmp"
END_FISH_BITMAP

FISH_BITMAP_FLIPPED 	
    INCBIN "Assets\fish_flipped.bmp"
END_FISH_BITMAP_FLIPPED

CAUGHT_FISH_BITMAP 	
    INCBIN "Assets\caught_fish.bmp"
END_CAUGHT_FISH_BITMAP

MULLET_BITMAP 	
    INCBIN "Assets\mullet.bmp"
END_MULLET_BITMAP

JELLY_BITMAP 	
    INCBIN "Assets\jelly.bmp"
END_JELLY_BITMAP

BOOT_BITMAP 	
    INCBIN "Assets\boot.bmp"
END_BOOT_BITMAP

FishQuickSave ds.l (FISH_WIDTH*FISH_HEIGHT*4)
FlippedFishQuickSave ds.l (FISH_WIDTH*FISH_HEIGHT*4)
BootQuickSave ds.l (BOOT_WIDTH*BOOT_HEIGHT*4)
JellyQuickSave ds.l (JELLY_WIDTH*JELLY_HEIGHT*4)
MulletQuickSave ds.l (MULLET_WIDTH*MULLET_HEIGHT*4)


*~Font name~Courier New~
*~Font size~12~
*~Tab type~1~
*~Tab size~4~
