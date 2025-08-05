*-----------------------------------------------------------
* Title      : DisplayBitmapChunk
* Written by : Carter Buell
* Date       : 5/22/2025
* Description:
*
* The arguments required for this subroutine are:
*   - Pointer to .bmp file (NOT a pointer to the pixel data)
*   - Top, Left corner (x,y) of the bitmap chunk you want to display
*   - Width and Height of the bitmap chunk you want to display
*   - Top, Left corner (x,y) on the output screen to display your chunk
* This only accepts 32-bit bitmaps
*-----------------------------------------------------------

GET_PIXEL_ARRAY_OFFSET_LOCAL    EQU 48
GET_BMAP_WIDTH_LOCAL            EQU 44
GET_BMAP_HEIGHT_LOCAL           EQU 40
BMP_SIGNATURE_LOCAL             EQU 36
CHUNK_START_X_LOCAL             EQU 32
CHUNK_START_Y_LOCAL             EQU 28
CHUNK_WIDTH_LOCAL               EQU 24
CHUNK_HEIGHT_LOCAL              EQU 20        
DISPLAY_X_LOCAL                 EQU 16
DISPLAY_Y_LOCAL                 EQU 12
ROW_OFFSET_LOCAL                EQU 4

BM_CHUNKER_STACK_SIZE           EQU 40
COLOR_DATA_SHIFT                EQU 8

DisplayBitmapChunk
    subq #4, sp                           ; Make space for local variable on stack
    movem.l d7, -(sp)

    * Get ptr to bitmap
    move.l BMP_SIGNATURE_LOCAL(sp), a0
    
    * Get offset of pixel array
    move.l GET_PIXEL_ARRAY_OFFSET_LOCAL(sp), d0
    
    * Get Bitmap width
    move.l GET_BMAP_WIDTH_LOCAL(sp), d6
    move.l d6, d7
    
    * Get Bitmap height
    move.l GET_BMAP_HEIGHT_LOCAL(sp), d5
    
    * Add offset to a0
    add.l d0, a0
    moveq #0, d0
    
    * Set starting values
    move.l DISPLAY_Y_LOCAL(sp), d2          ; Set Starting Y
    subq #1, d2
    add.l CHUNK_HEIGHT_LOCAL(sp), d2
    move.l d5, d3
    move.l CHUNK_HEIGHT_LOCAL(sp), d5
    subq #1, d5                           ; Adjust for dbra
    
    * Calculate and store row offset
    move.l d7, d1                           ; d1 = bitmap width
    sub.l CHUNK_WIDTH_LOCAL(sp), d1         ; d1 = (bitmap width - CHUNK_WIDTH)
    lsl.l #2, d1                            ; multiply by 4 (since there are 4 bytes per pixel
    move.l d1, ROW_OFFSET_LOCAL(sp)         ; move row offset to stack (local variable)

    * Increment in pixel array to correct starting spot
    move.l d7, d1                           ; d1 = bitmap width
    sub.l CHUNK_START_Y_LOCAL(sp), d3
    sub.l CHUNK_HEIGHT_LOCAL(sp), d3
    mulu d3, d1                             ; d1 = (bitmap width * (bitmap_height-CHUNK_START_Y-CHUNK_HEIGHT))
    add.l CHUNK_START_X_LOCAL(sp), d1       ; d1 = bitmap width * (bitmap_height-CHUNK_START_Y-CHUNK_HEIGHT))) + X
    lsl.l #2, d1                            ; multiply by 4 (since there are 4 bytes per pixel)                          
    lea (a0, d1.l), a0

DrawRows
    move.l DISPLAY_X_LOCAL(sp), d3          ; Set Starting X
    move.l CHUNK_WIDTH_LOCAL(sp), d6
    subq.w #1, d6                           ; Adjust for dbra
DrawRow
    * Set Pen Color
    move.l #PEN_COLOR_TRAP_CODE, d0
    move.l (a0)+, d1
    move.b d1, d1
    beq.s TransparentPixel
    lsr.l #COLOR_DATA_SHIFT , d1            ; Shift from [BB GG RR 00] to [00 BB GG RR]
    trap #15
   
    * Draw Pixel
    move.l d3, d1
    move.l #DRAW_PIXEL_TRAP_CODE, d0
    trap #15
TransparentPixel
    addq.w #1, d3                           ; Increment Position-X
    dbra d6, DrawRow
    subq #1, d2                           ; Increment Position-Y
    * Increment to next row
    move.l ROW_OFFSET_LOCAL(sp), d1
    lea (a0, d1), a0
    dbra d5, DrawRows
    movem.l (sp)+, d7
    add.l   #4, sp                          ; fix stack from local variable
	rts


















*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
