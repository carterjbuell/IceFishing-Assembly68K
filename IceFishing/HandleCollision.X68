*-----------------------------------------------------------
* Title      : HandleCollision
* Written by : Carter Buell
* Date       : 6/2/2025
* Description: Individual collision subroutines for each GameObject type
*-----------------------------------------------------------

*-----------HandleFishCollision----------*
*     Handles collision with fish
*----------------------------------------*
HandleFishCollision
    
    * Set isFish flag if there is not already a fish on the line
    lea FishingManagerTable, a2
    moveq #0, d0
    move.b GET_IS_FISH_ON_HOOK(a2), d0
    bne.s DontCatchFish
    move.b GET_IS_WORM_ON_HOOK(a2), d0
    beq.s DontCatchFish
    move.b #1, GET_IS_FISH_ON_HOOK(a2)                          ; Set isFish flag to true
    
    * Get X-Coord and Lane
    move.l a6, a0
    lea LocationTable, a1
    move.w GET_X_POS(a0), d5                                    ; d5 = X-Coord
    moveq #0, d6
    move.b GET_LANE(a0), d6                                     ; d6 = Lane
    lsl.b #1, d6
    move.w (a1, d6), d6                                         ; d6 = Lane Location
   
    * Set Pen Color
    move.l #PEN_COLOR_TRAP_CODE, d0
    move.l #WATER_COLOR, d1
    trap #15
    
    * Draw Water Block
    move.w d6, d2
    move.w d6, d4
    addi.w #(FISH_HEIGHT/2), d4
    subi.w #(FISH_HEIGHT/2), d2
    move.w d5, d1
    move.w d5, d3
    addi.w #FISH_WIDTH, d3
    move.l #DRAW_RECT_TRAP_CODE, d0
    trap #15
    
    * Move an invisible fish into the spot the fish used to be
    move.b #INVISIBLE_TYPE, GET_TYPE(a0)
DontCatchFish
    rts


*-----------HandleBootCollision----------*
*     Handles collision with boot
*----------------------------------------*
HandleBootCollision
    * Remove fish from line
    lea FishingManagerTable, a1
    moveq #0, d0
    move.b GET_IS_FISH_ON_HOOK(a1), d0
    beq.s NoFishOnLine
    move.b #0, GET_IS_FISH_ON_HOOK(a1)                          ; Set isFish flag to false
    
    * Fish Flee Sound Effect                        
    move.l #PLAY_SOUND_TRAP_CODE, d0
    lea FishFlee, a1
    trap #15
    
    * Get lane location of boot
    move.l a6, a0
    lea LocationTable, a1
    moveq #0, d6
    move.b GET_LANE(a0), d6                                     ; d6 = Lane
    lsl.b #1, d6
    move.w (a1, d6), d6                                         ; d6 = Lane Location
    
    * Set starting x-velocity for physics animation
    move.w #FISH_FLEE_X_VELOCITY, d1                            ; set velocity to positive
    move.b GET_SPEED(a0), d0
    bpl.b PositiveXVelocity
    move.w #-FISH_FLEE_X_VELOCITY, d1                           ; set velocity to negative if boot was moving left
PositiveXVelocity

    * Set starting values for physics animation
    lea FleeingFishPhysicsManager, a2
    move.w d1, GET_X_VELOCITY(a2)
    move.w #POLE_X-(CAUGHT_FISH_WIDTH/2), GET_X_POSITION(a2)
    lsl.l #NUM_FRACTIONAL_BITS, d6   
    move.l d6, GET_Y_POSITION(a2)                               ; d5 = y-pos
    move.l #0, GET_Y_VELOCITY(a2)                               ; d6 = velocity

NoFishOnLine
    rts


*-----------HandleJellyCollision---------*
*     Handles collision with jellyfish
*----------------------------------------*
HandleJellyCollision
    * Remove fish from line
    lea FishingManagerTable, a1
    move.b #0, GET_IS_FISH_ON_HOOK(a1)                          ; Set isFish flag to false
    
    * Remove bait if there is any of your line
    moveq #0, d0
    move.b GET_IS_WORM_ON_HOOK(a1), d0
    beq.s NoBaitOnLine
    
    * End game if you lose all bait
    move.b GET_NUM_WORMS_LEFT(a1), d0
    bne.s StillHaveBaitLeft
    
    * Change Game State to MULLET_ESCAPED_STATE
    lea GameState, a2
    move.b #MULLET_ESCAPED_STATE, (a2)
StillHaveBaitLeft
    
    * Remove bait from rod
    move.b #0, GET_IS_WORM_ON_HOOK(a1)

    * Line Zap Sound Effect                          
    move.l #PLAY_SOUND_TRAP_CODE, d0
    lea LineZap, a1
    trap #15
NoBaitOnLine
    
    rts
    
    
*---------HandleMulletCollision----------*
*     Handles collision with the mullet
*----------------------------------------*   
HandleMulletCollision
    * Set isFish flag if there is not already a fish on the line
    lea FishingManagerTable, a2
    moveq #0, d0
    move.b GET_IS_FISH_ON_HOOK(a2), d0
    beq.s DontCatchMullet
    
    * Play Reel in sound
    move.l #PLAY_SOUND_TRAP_CODE, d0
    lea ReelInSound, a1
    trap #15
    
    * Change Game State to MULLET_CAUGHT_STATE
    lea GameState, a2
    move.b #MULLET_CAUGHT_STATE, (a2)
DontCatchMullet

    rts


*-------------Global Variables-------------*
FishFlee dc.w 'Assets\sounds\fish_flee.wav', 0
LineZap dc.w 'Assets\sounds\line_zap.wav', 0
ReelInSound dc.w 'Assets\sounds\reel_in.wav', 0


*~Font name~Courier New~
*~Font size~12~
*~Tab type~1~
*~Tab size~4~
