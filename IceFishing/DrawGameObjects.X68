*-----------------------------------------------------------
* Title      : DrawGameObjects
* Written by : Carter Buell
* Date       : 5/30/2025
* Description: Draws the GameObject bitmap at the current table location
*-----------------------------------------------------------
DrawGameObjects
    move.l a6, a0
    lea LocationTable, a1
    
    * Get X-Coord and Lane
    move.w GET_X_POS(a0), d5                            ; d5 = X-Coord
    moveq #0, d6
    move.b GET_LANE(a0), d6                             ; d6 = Lane
    lsl.b #1, d6
    move.w (a1, d6), d6                                 ; d6 = Lane Location
   
    * Set Pen Color
    move.l #PEN_COLOR_TRAP_CODE, d0
    move.l #WATER_COLOR, d1
    trap #15
    
    * Draw Water Block
    move.w d6, d2
    move.w d6, d4
    addi.w #(JELLY_HEIGHT/2), d4                        ; d4 = ypos + (JELLY_HEIGHT/2)
    subi.w #(JELLY_HEIGHT/2), d2                        ; d2 = ypos - (JELLY_HEIGHT/2)
    move.w d5, d1
    move.b GET_SPEED(a0), d0
    ext.w d0                                            ; Get change in position (speed)
    sub.w d0, d1                                        ; d1 = xpos - speed                                     
    move.w d5, d3
    addi.w #FISH_WIDTH, d3
    sub.w d0, d3                                        ; d3 = xpos + FISH_WIDTH - speed
    move.l #DRAW_RECT_TRAP_CODE, d0
    trap #15
    
    * Get Type and Frame
    move.b GET_TYPE(a0), d2                             ; d2 = Type
    moveq #0, d3                                 
    move.b GET_FRAME(a0), d3                            ; d3 = Frame                                 
    
    * Check for fish direction
    cmpi.b #FISH_TYPE, d2
    bne.s NotFish
    lea FishQuickSave, a2
    move.b GET_SPEED(a0), d0
    bpl.b PositiveSpeed
    lea FlippedFishQuickSave, a2
PositiveSpeed

    *----------Draw Fish----------*
    mulu.w #(FISH_WIDTH*FISH_HEIGHT), d3                ; Set offset baed on current frame
    move.l d3, -(sp)                                    ; Save Offset
    move.l a2, -(sp)                                    ; Save Location
    move.l #FISH_WIDTH, -(sp)                           ; Save width
    move.l #FISH_HEIGHT, -(sp)                          ; Save height
    move.l d5, -(sp)                                    ; Display X
    subi.w #(FISH_HEIGHT/2), d6
    move.l d6, -(sp)                                    ; Display Y
    jsr QuickDraw
	add.l #QUICK_DRAW_STACK_SIZE, sp
NotFish
    
    *----------Draw Boot----------*
    cmpi.b #BOOT_TYPE, d2
    bne.s NotBoot

	lea BootQuickSave, a2
    mulu.w #(BOOT_WIDTH*BOOT_HEIGHT), d3                ; Set offset baed on current frame
    move.l d3, -(sp)                                    ; Save Offset
    move.l a2, -(sp)                                    ; Save Location
    move.l #BOOT_WIDTH, -(sp)                           ; Save width
    move.l #BOOT_HEIGHT, -(sp)                          ; Save height
    move.l d5, -(sp)                                    ; Display X
    subi.w #(BOOT_HEIGHT/2), d6
    move.l d6, -(sp)                                    ; Display Y
    jsr QuickDraw
	add.l #QUICK_DRAW_STACK_SIZE, sp
NotBoot
    
    *----------Draw Jelly----------*
    cmpi.b #JELLY_TYPE, d2
    bne.s NotJelly

    lea JellyQuickSave, a2
    mulu.w #(JELLY_WIDTH*JELLY_HEIGHT), d3              ; Set offset baed on current frame
    move.l d3, -(sp)                                    ; Save Offset
    move.l a2, -(sp)                                    ; Save Location
    move.l #JELLY_WIDTH, -(sp)                          ; Save width
    move.l #JELLY_HEIGHT, -(sp)                         ; Save height
    move.l d5, -(sp)                                    ; Display X
    subi.w #(JELLY_HEIGHT/2), d6
    move.l d6, -(sp)                                    ; Display Y
    jsr QuickDraw
	add.l #QUICK_DRAW_STACK_SIZE, sp
NotJelly
    
    *----------Draw Mullet----------*
    cmpi.b #MULLET_TYPE, d2
    bne.s NotMullet

    lea MulletQuickSave, a2
    mulu.w #(MULLET_WIDTH*MULLET_HEIGHT), d3            ; Set offset baed on current frame
    move.l d3, -(sp)                                    ; Save Offset
    move.l a2, -(sp)                                    ; Save Location
    move.l #MULLET_WIDTH, -(sp)                         ; Save width
    move.l #MULLET_HEIGHT, -(sp)                        ; Save height
    move.l d5, -(sp)                                    ; Display X
    subi.w #(MULLET_HEIGHT/2), d6
    move.l d6, -(sp)                                    ; Display Y
    jsr QuickDraw
	add.l #QUICK_DRAW_STACK_SIZE, sp
NotMullet

    rts

    
	















*~Font name~Courier New~
*~Font size~16~
*~Tab type~1~
*~Tab size~4~
