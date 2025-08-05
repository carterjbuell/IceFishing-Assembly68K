*-----------------------------------------------------------
* Title      : BoundsCheck
* Written by : Carter Buell
* Date       : 6/9/2025
* Description: Manages when to spawn new GameObjects
*-----------------------------------------------------------
BoundsCheck
    lea GameState, a1
    cmpi.b #MULLET_SEQUENCE_RUNNING_STATE, (a1)
    bne MulletNotSpawned
    
    * End Sequence if mullet out of bounds
    move.l a6, a0
    move.b GET_TYPE(a0), d0
    cmpi.b #MULLET_TYPE, d0                             ; MULLET_TYPE equate located in main
    bne.s MulletNotSpawned
    move.w GET_X_POS(a0), d1
    cmpi.w #(OUTPUT_WINDOW_WIDTH), d1
    blt.s MulletNotSpawned
    
    * Change Game State
    move.b #MULLET_ESCAPED_STATE, (a1)

MulletNotSpawned

    cmpi.b #MULLET_SEQUENCE_RUNNING_STATE, (a1)
    bge MulletHasSpawned
    
    * Spawn new GameObject if out of bounds
    move.l a6, a0
    move.w GET_X_POS(a0), d1
    move.b GET_SPEED(a0), d0
    bpl.b PosSpeedBranch 
    cmpi.w #(-FISH_WIDTH), d1
    bgt.s StillInBounds
    move.l a0, a5
    jsr SpawnGameObject
PosSpeedBranch
    move.l a6, a0
    move.b GET_SPEED(a0), d0
    bmi.b StillInBounds
    cmpi.w #(OUTPUT_WINDOW_WIDTH), d1
    blt.s StillInBounds
    move.l a0, a5
    jsr SpawnGameObject
StillInBounds

MulletHasSpawned

    rts

    











*~Font name~Courier New~
*~Font size~12~
*~Tab type~1~
*~Tab size~4~
