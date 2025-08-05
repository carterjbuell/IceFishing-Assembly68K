*-----------------------------------------------------------
* Title      : MulletSequenceSetup
* Written by : Carter Buell
* Date       : 6/9/2025
* Description: Setup for ending red mullet sequence
*-----------------------------------------------------------

STARTING_LOCATION_7             EQU -FISH_WIDTH
STARTING_LOCATION_8             EQU -200
STARTING_LOCATION_9             EQU -400

MulletSequenceSetup
    * Set proper number of GameObjects in mullet sequence
    lea GetCurrentMaxGameObjects, a0
    move.b #NUM_BONUS_GAME_OBJECTS, (a0)
    
    * Fish 1
    lea GameObjectTable, a5
    move.w #STARTING_LOCATION_7, (a5)+     
    move.b #FAST_RIGHT, (a5)+  
    move.b #LANE_2, (a5)+
    move.b #FISH_TYPE, (a5)+
    move.b #FRAME_0, (a5)+
    
    * Fish 2
    move.w #STARTING_LOCATION_8, (a5)+     
    move.b #FAST_RIGHT, (a5)+  
    move.b #LANE_2, (a5)+
    move.b #FISH_TYPE, (a5)+
    move.b #FRAME_0, (a5)+
    
    * Mullet
    move.w #STARTING_LOCATION_9, (a5)+     
    move.b #FAST_RIGHT, (a5)+  
    move.b #LANE_2, (a5)+
    move.b #MULLET_TYPE, (a5)+
    move.b #FRAME_0, (a5)+
    
    * Set pointer to GameObjectTable 
    lea GameObjectTable, a6
    
    * Set GameObjectTable loop variable
    move.l #NUM_BONUS_GAME_OBJECTS-1, d7                ; d7 = current number of max GameObjects (adjusted for dbra)
    
    * Change game state
    lea GameState, a1
    move.b #MULLET_SEQUENCE_RUNNING_STATE, (a1)

    rts


*~Font name~Courier New~
*~Font size~12~
*~Tab type~1~
*~Tab size~4~
