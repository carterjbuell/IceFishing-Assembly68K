*-----------------------------------------------------------
* Title      : CheckForCollision
* Written by : Carter Buell
* Date       : 6/3/2025
* Description: Checks for collisions between hook and GameObjects 
*              and calls appropriate handler subroutine.
*-----------------------------------------------------------
CheckForCollision  
    move.l a6, a0                                       ; get current GameObject 
    move.b GET_TYPE(a0), d4                             ; d4 = Type

    
    *---FISH COLLISION---*
    cmpi.b #FISH_TYPE, d4       
    bne.s NotFishCollision
    
    lea CurrentMouseY, a1
    move.l (a1), d5                                     ; d5 = CurrentMouseY

    * Get Location and type
    lea LocationTable, a1                               ; get LocationTable
    move.w GET_X_POS(a0), d0                            ; get current GameObject x-position
    moveq #0, d2
    move.b GET_LANE(a0), d2                             ; d2 = Lane
    lsl.b #1, d2
    move.w (a1, d2), d2                                 ; d2 = Lane Location
    
    * Check X-Collision fish
    cmpi.w #(POLE_X-FISH_WIDTH), d0
    blt NoCollision
    cmpi.w #POLE_X, d0
    bgt NoCollision
    
    * Check Y-Collision fish
    move.w d2, d3
    subi.w #(FISH_HEIGHT/2), d2
    addi.w #(FISH_HEIGHT/2), d3
    cmp.w d2, d5
    blt NoCollision
    cmp.w d3, d5
    bgt NoCollision
    jsr HandleFishCollision
NotFishCollision
    
    move.l a6, a0                                       ; get current GameObject 
    move.b GET_TYPE(a0), d4                             ; d4 = Type
    
    
    *---BOOT COLLISION---*
    cmpi.b #BOOT_TYPE, d4
    bne.s NotBootCollision
    
    lea CurrentMouseY, a1
    move.l (a1), d5                                     ; d5 = CurrentMouseY5
    
    * Get Location and type
    lea LocationTable, a1                               ; get LocationTable
    move.w GET_X_POS(a0), d0                            ; get current GameObject x-position
    moveq #0, d2
    move.b GET_LANE(a0), d2                             ; d2 = Lane
    lsl.b #1, d2
    move.w (a1, d2), d2                                 ; d2 = Lane Location
    
    * Check X-Collision boot
    cmpi.w #(POLE_X-BOOT_WIDTH), d0
    blt NoCollision
    cmpi.w #POLE_X, d0
    bgt NoCollision
    
    * Check Y-Collision boot
    move.w d2, d3
    subi.w #(BOOT_HEIGHT/2), d2
    addi.w #(BOOT_HEIGHT/2), d3
    cmp.w d2, d5
    blt NoCollision
    cmp.w d3, d5
    bgt NoCollision
    jsr HandleBootCollision
NotBootCollision
    
    move.l a6, a0                                       ; get current GameObject 
    move.b GET_TYPE(a0), d4                             ; d4 = Type
    
    *---JELLY COLLISION---*
    cmpi.b #JELLY_TYPE, d4
    bne.s NotJellyCollision
    
    lea CurrentMouseY, a1
    move.l (a1), d5                                     ; d5 = CurrentMouseY
    
    * Get Location and type
    lea LocationTable, a1                               ; get LocationTable
    move.w GET_X_POS(a0), d0                            ; get current GameObject x-position
    moveq #0, d2
    move.b GET_LANE(a0), d2                             ; d2 = Lane
    lsl.b #1, d2
    move.w (a1, d2), d2                                 ; d2 = Lane Location
    
    * Check X-Collision jelly
    cmpi.w #(POLE_X-JELLY_WIDTH), d0
    blt NoCollision
    cmpi.w #POLE_X, d0
    bgt NoCollision
    
    * Check Y-Collision jelly
    sub.w #(JELLY_HEIGHT/2), d2
    cmp.w d5, d2
    bgt NoCollision
    jsr HandleJellyCollision
NotJellyCollision 

    move.l a6, a0                                       ; get current GameObject 
    move.b GET_TYPE(a0), d4                             ; d4 = Type
    
    *---MULLET COLLISION---*
    cmpi.b #MULLET_TYPE, d4
    bne.s NotMulletCollision
    
    lea CurrentMouseY, a1
    move.l (a1), d5                                     ; d5 = CurrentMouseY
    
    * Get Location and type
    lea LocationTable, a1                               ; get LocationTable
    move.w GET_X_POS(a0), d0                            ; get current GameObject x-position
    moveq #0, d2
    move.b GET_LANE(a0), d2                             ; d2 = Lane
    lsl.b #1, d2
    move.w (a1, d2), d2                                 ; d2 = Lane Location
    
    * Check X-Collision jelly
    cmpi.w #(POLE_X-MULLET_WIDTH), d0
    blt NoCollision
    cmpi.w #POLE_X, d0
    bgt NoCollision
    
    * Check Y-Collision jelly
    sub.w #(MULLET_HEIGHT/2), d2
    cmp.w d5, d2
    bgt NoCollision
    jsr HandleMulletCollision
NotMulletCollision

NoCollision

    rts




    









*~Font name~Courier New~
*~Font size~12~
*~Tab type~1~
*~Tab size~4~
