*-----------------------------------------------------------
* Title      : FrameUpdate
* Written by : Carter Buell
* Date       : 5/30/2025
* Description: Updates GameObject position and frame and goes to next GameObject in the list
*-----------------------------------------------------------

FrameUpdate
    * Skip updates if current time goal has not been met
    move.l #GET_TIME_TRAP_CODE, d0
    trap #15
    lea TimeGoal, a1
    move.l (a1), d0
    cmp.l d0, d1
    blt SkipUpdate
    
    * Set time Goal to (current time + frame duration)
    move.l #GET_TIME_TRAP_CODE, d0
    trap #15
    addi.l #FRAME_DURATION, d1
    lea TimeGoal, a1
    move.l d1, (a1)

    * Increase position and change frame
    move.l a6, a0                                   ; get current GameObject being updated
    move.b GET_SPEED(a0), d0
    ext.w d0
    add.w d0, GET_X_POS(a0)                         ; add speed to x-pos
    addi.b #1, GET_FRAME(a0)                        ; increment to next frame
    cmpi.b #FRAME_RESET, GET_FRAME(a0)              ; check if the frame needs to be reset
    blt.s SkipFrameReset
    sub.b #FRAME_RESET, GET_FRAME(a0)
SkipFrameReset

    * Go to next GameObject in list
    add.l #GAME_OBJECT_TABLE_ENTRY_SIZE, a6
    
    * Reset to beginning if max GameObjects reached
    dbra d7, SkipLoopReset
    lea GameObjectTable, a6                         ; reset to start of GameObject table
    lea GetCurrentMaxGameObjects, a0
    moveq #0, d7
    move.b (a0), d7                                 ; d0 = current number of max GameObjects
    subi.b #1, d7                                   ; adjust for dbra
SkipLoopReset

SkipUpdate

    rts

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
