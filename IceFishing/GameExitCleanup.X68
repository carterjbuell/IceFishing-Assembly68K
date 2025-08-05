*-----------------------------------------------------------
* Title      : GameExitCleanup
* Written by : Carter Buell
* Date       : 6/20/2025
* Description: Turns off music and clears game screen
*-----------------------------------------------------------

SOUND_PLAYER_STOP_SOUND             EQU 2

GameExitCleanup

    * Stop bg music
    move.l #LOOP_SOUND_TRAP_CODE, d0
    moveq #0, d1
    moveq #SOUND_PLAYER_STOP_SOUND, d2
    trap #15

    * Clear Screen
    move.l #CLEAR_SCREEN_TRAP_CODE, d0
    move.w #CLEAR_SCREEN_MODE, d1                
    trap #15
    
    * Repaint from double buffer
    move.l #REPAINT_SCREEN_TRAP_CODE, d0
    trap #15
    
    rts

*~Font name~Courier New~
*~Font size~12~
*~Tab type~1~
*~Tab size~4~
