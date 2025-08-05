*-----------------------------------------------------------
* Title      : DoneSpawningCheck
* Written by : CarterBuell
* Date       : 6/11/2025
* Description: Checks if all 6 GameObjects in the GameObjectTable are invisible
*              and sets the state so the mullet sequence starts
*-----------------------------------------------------------

DoneSpawningCheck
    lea GameObjectTable, a1
    move.l #(MAX_GAME_OBJECTS-1), d3
    
CheckIfAllGameObjectAreInvisible
    move.b GET_TYPE(a1), d0
    add.l #GAME_OBJECT_TABLE_ENTRY_SIZE, a1
    cmpi.b #INVISIBLE_TYPE, d0
    bne.s StillVisibleGameObjects
    dbra d3, CheckIfAllGameObjectAreInvisible
    
    * Change game state to start Mullet Sequence
    lea GameState, a1
    move.b #DO_MULLET_SETUP_STATE, (a1)
    
StillVisibleGameObjects
    
    rts


*~Font name~Courier New~
*~Font size~12~
*~Tab type~1~
*~Tab size~4~
