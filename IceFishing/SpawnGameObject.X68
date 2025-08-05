*-----------------------------------------------------------
* Title      : SpawnGameObject
* Written by : Carter Buell
* Date       : 5/29/2025
* Description: Spawn a new random GameObject
*-----------------------------------------------------------

RAND_BYTE_TO_2_BITS             EQU 6

SpawnGameObject
    jsr GetRandomByteIntoD6
    
    * Set spawn point based on direction of speed
    moveq #0, d5
    sub.w #FISH_WIDTH, d5
    move.b GET_SPEED(a5), d0                            ; Get speed from GameObject table
    bpl.b PosSpeed
    move.w #OUTPUT_WINDOW_WIDTH, d5
PosSpeed

    * Move spawn point to x-position
    move.w d5, GET_X_POS(a5)
    
    * Switch speed to opposite of current speed
    move.b GET_SPEED(a5), d3
    
    * Set speed to fast-right if previous speed was slow-right
    cmpi.b #SLOW_RIGHT, d3
    bne.s NotSlowRight
    move.b #FAST_RIGHT, GET_SPEED(a5)
NotSlowRight

    * Set speed to slow-right if previous speed was fast-right
    cmpi.b #FAST_RIGHT, d3
    bne.s NotFastRight
    move.b #SLOW_RIGHT, GET_SPEED(a5)
NotFastRight

    * Set speed to fast-left if previous speed was slow-left 
    cmpi.b #SLOW_LEFT, d3
    bne.s NotSlowLeft
    move.b #FAST_LEFT, GET_SPEED(a5)
NotSlowLeft

    * Set speed to slow-left if previous speed was fast-left 
    cmpi.b #FAST_LEFT, d3
    bne.s NotFastLeft
    move.b #SLOW_LEFT, GET_SPEED(a5)
NotFastLeft
    
    * Add variation to x-pos if in lane 0
    move.b GET_LANE(a5), d4 
    cmpi.b #0, d4
    bne.s SkipRandomOffset
    sub.w d6, GET_X_POS(a5)
SkipRandomOffset

    * Set random type
    lsr.b #RAND_BYTE_TO_2_BITS, d6
    beq.s SkipSubtract                                          
    subq #1, d6                                                 ; If the type is not 0, subtract 1 (brings range to 0, 1, 2)
SkipSubtract
    move.b d6, GET_TYPE(a5)
    
    * If max number have fish have spawned, only spawn invisible GameObjects
    lea NumFishSpawned, a0
    cmpi.b #NUMBER_OF_FISH_TO_SPAWN, (a0)
    blt.s SkipSpawnInvisible
    move.b #INVISIBLE_TYPE, GET_TYPE(a5)                        ; Make GameObject invisible
    move.b #INVISIBLE_TYPE, d6
    
    * Change game state if all GameObjects are invisible
    jsr DoneSpawningCheck
    
SkipSpawnInvisible
 
    * Increase number of fish spawned (if type is 0)
    cmpi.b #FISH_TYPE, d6
    bne.s NotAFish
    lea NumFishSpawned, a0
    addi.b #1, (a0)
NotAFish
    
    * Set Frame to 0
    move.b #FRAME_0, GET_FRAME(a5)
    
    rts


*~Font name~Courier New~
*~Font size~12~
*~Tab type~1~
*~Tab size~4~
