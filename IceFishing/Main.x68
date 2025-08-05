*-----------------------------------------------------------
* Title      : Main
* Written by : Carter Buell
* Date       : 5/29/2025
* Description:
*
* Main file for the Ice Fishing game. 
* Includes commonly used equates, global variables, 
* and game loops.
*-----------------------------------------------------------

*--------------------TRAP CODES--------------------*
GET_SINGLE_CHAR_TRAP_CODE       EQU 5
GET_TIME_TRAP_CODE              EQU 8
CLEAR_SCREEN_TRAP_CODE          EQU 11
SET_CURSOR_POSITION_TRAP_CODE   EQU 11
CLEAR_SCREEN_MODE               EQU $FF00
NO_BUFFERING_MODE_NUMBER        EQU 16
DOUBLE_BUFFERING_MODE_NUMBER    EQU 17
GET_KEY_STATE_TRAP_CODE         EQU 19
SET_FONT_TRAP_CODE              EQU 21
SET_OUTPUT_RESOLUTION_TRAP_CODE EQU 33
MOUSE_INPUT_TRAP_CODE           EQU 61
PLAY_SOUND_TRAP_CODE            EQU 73
LOAD_SOUND_TRAP_CODE            EQU 74
LOOP_SOUND_TRAP_CODE            EQU 77
PEN_COLOR_TRAP_CODE             EQU 80
SET_FILL_COLOR_TRAP_CODE        EQU 81
DRAW_PIXEL_TRAP_CODE            EQU 82
DRAW_LINE_TRAP_CODE             EQU 84
DRAW_RECT_TRAP_CODE             EQU 87
DRAW_MODE_TRAP_CODE             EQU 92
PEN_WIDTH_TRAP_CODE             EQU 93
REPAINT_SCREEN_TRAP_CODE        EQU 94
TEXT_TO_SCREEN_TRAP_CODE        EQU 95

*----------------WINDOW DIMENSIONS-----------------*
OUTPUT_WINDOW_WIDTH             EQU 760
OUTPUT_WINDOW_HEIGHT            EQU 600

*---------------------COLORS-----------------------*
WHITE                           EQU $FFFFFF
BLACK                           EQU $000000
RED                             EQU $0000FF
WATER_COLOR                     EQU $D28049
WORM_FILL_COLOR                 EQU $8888FF
WORM_PEN_COLOR                  EQU $4117A4
COOLER_COLOR                    EQU $98E5FE
COOLER_TEXT_COLOR               EQU $405D67
LOADING_PURPLE_COLOR            EQU $7E5958

*----------------GAME OBJECT SIZES-----------------*
FISH_WIDTH                      EQU 72
FISH_HEIGHT                     EQU 36

CAUGHT_FISH_WIDTH               EQU 18
CAUGHT_FISH_HEIGHT              EQU 36

BOOT_WIDTH                      EQU 48
BOOT_HEIGHT                     EQU 48

JELLY_WIDTH                     EQU 48
JELLY_HEIGHT                    EQU 48

MULLET_WIDTH                    EQU 120
MULLET_HEIGHT                   EQU 48

*----------------SCREEN POSITIONS------------------*
LANE_0_LOCATION                 EQU 226
LANE_1_LOCATION                 EQU 298
LANE_2_LOCATION                 EQU 370
LANE_3_LOCATION                 EQU 442

TOP_OF_WATER                    EQU 190
BOTTOM_OF_WATER                 EQU 478

ICE_SEGMENT_TOP                 EQU 159
ICE_SEGMENT_BOTTOM              EQU 179
ICE_SEGMENT_HEIGHT              EQU (ICE_SEGMENT_BOTTOM-ICE_SEGMENT_TOP)

ABOVE_WATER                     EQU (ICE_SEGMENT_BOTTOM-CAUGHT_FISH_HEIGHT)
TOP_OF_POLE                     EQU 42
POLE_X                          EQU 367

*----------------------FONTS-----------------------*
LOADING_SMALL_FONT              EQU $020A0001
END_BANNER_FONT                 EQU $06100000
END_BANNER_FONT_BOLD            EQU $06100001
NAME_PROMPT_FONT                EQU $06360001

*-----------------------ASCII----------------------*
EscapeASCIIValue                EQU $1B
DEC_TO_ASCII                    EQU 48
SPACE_ASCII_CHAR                EQU 32

*-----------------GAME OBJECT TYPES----------------*
FISH_TYPE                       EQU 0
BOOT_TYPE                       EQU 1
JELLY_TYPE                      EQU 2
INVISIBLE_TYPE                  EQU 3
MULLET_TYPE                     EQU 4

FRAME_0                         EQU 0
FRAME_1                         EQU 1
FRAME_2                         EQU 2
FRAME_3                         EQU 3
FRAME_RESET                     EQU 4

LANE_0                          EQU 0
LANE_1                          EQU 1
LANE_2                          EQU 2
LANE_3                          EQU 3

SLOW_RIGHT                      EQU 5
SLOW_LEFT                       EQU -5
FAST_RIGHT                      EQU 7
FAST_LEFT                       EQU -7

*---------------TABLE ACCESS OFFSETS---------------*
GAME_OBJECT_TABLE_ENTRY_SIZE    EQU 6

GET_X_POS                       EQU 0
GET_SPEED                       EQU 2
GET_LANE                        EQU 3
GET_TYPE                        EQU 4
GET_FRAME                       EQU 5

GET_NUM_FISH_CAUGHT             EQU 0
GET_IS_FISH_ON_HOOK             EQU 1
GET_NUM_WORMS_LEFT              EQU 2
GET_IS_WORM_ON_HOOK             EQU 3

*-------------------GAME STATES--------------------*
MAIN_GAME_STATE                 EQU 0
DO_MULLET_SETUP_STATE           EQU 1
MULLET_SEQUENCE_RUNNING_STATE   EQU 2
MULLET_CAUGHT_STATE             EQU 3
MULLET_ESCAPED_STATE            EQU 4

*-------------------GAME SETTINGS------------------*
NUMBER_OF_FISH_TO_SPAWN         EQU 14
MULLET_SCORE_BONUS              EQU 5

*-----------------------OTHER----------------------*
MAX_GAME_OBJECTS                EQU 6
NUM_BONUS_GAME_OBJECTS          EQU 3
PA_OFFSET                       EQU $8A                 ; Offset in bitmap to pixel array

START   ORG     $1000

*------------------------------------------------------------------------------------*
*-----------------------------------One-Time-Setup-----------------------------------*
*------------------------------------------------------------------------------------*
    jsr OneTimeGameSetup                                ; Enable double buffering, play music, change screen size
    jsr SaveFileInitialization                          ; Get save data or create blank save if none exists
    jsr SaveGameObjectBitmaps                           ; Saves all GameObject bitmaps for use in QuickDraw
    
RestartPoint

*------------------------------------------------------------------------------------*
*------------------------------------Title-Screen------------------------------------*
*------------------------------------------------------------------------------------*
    jsr TitleScreenSetup                                ; Draw title screen bitmap
TitleScreenLoop

    jsr DeleteSaveData                                  ; Delete save data if player presses backspace
    
    * Check for mouse click input 
    move.l #MOUSE_INPUT_TRAP_CODE, d0
    moveq #0, d1                                        ; Set mode to "read mouse down state"
    trap #15
    btst #0, d0                                         ; Check "mouse down" state
    beq.s TitleScreenLoop                               ; Loop if mouse button was not pressed
  
*------------------------------------------------------------------------------------*
*--------------------------------------Pre-Game--------------------------------------*
*------------------------------------------------------------------------------------*
    jsr SeedRandomNumber
	jsr PreGameSetup                                    ; Draws inital background bitmap and loading icons 
	jsr SpawnInitialGameObjects                         ; Add the inital GameObjects to the GameObject table
	jsr VariableInitialization	                        ; Initialize variables and tables to starting values
    
*------------------------------------------------------------------------------------*
*-----------------------------------Main-Game-Loop-----------------------------------*
*------------------------------------------------------------------------------------*
MainGameLoop
    jsr DrawGameObjects                                 ; Draws the current GameObject
    jsr MouseInputHandler                               ; Gets mouse-y input and saves it to variable
    jsr MoveEyes                                        ; Moves eyes if mouse is above the ice
    jsr CheckForCollision                               ; Checks for collision with mouse and GameObject
    jsr FleeingFishPhysicsUpdate                        ; Upadates and draws the fleeing fish physics object
    jsr CatchFish                                       ; Catches a fish if the player clicks above the ice and has a fish on the line
    jsr GetNewWorm                                      ; Gets a new worm if the player clicks above the ice and needs a worm
    jsr BoundsCheck                                     ; Checks for GameObjects leaving the screen and spawns new ones
    jsr DrawFishingUI                                   ; Draws UI elements such as the bait, bobber, line, and caught fish

    * FrameUpdate only happens if TimeGoal has been met
    jsr FrameUpdate
    
    * Start mullet sequence if correct number of fish have been spawned
    lea GameState, a1
    cmpi.b #DO_MULLET_SETUP_STATE, (a1)
    bne.s NotReadyForMullet                             ; Skip MulletSequenceSetup if the state is not DO_MULLET_SETUP_STATE
    jsr MulletSequenceSetup                             ; Reset looping variables, spawn fish and mullet
NotReadyForMullet
    
    * Keep looping in MainGameLoop if mullet hasn't been caught or hasn't escaped
    lea GameState, a1
    cmpi.b #MULLET_CAUGHT_STATE, (a1)
    blt MainGameLoop
    
*------------------------------------------------------------------------------------*
*-------------------------------------Game-Over--------------------------------------*
*------------------------------------------------------------------------------------*
GameOver
    jsr GetPlayerName                                   ; Gets a 3-character player name
    jsr AddScoreToLeaderboard                           ; Adds name and score to leaderboard (if it qualifies) and save it to file
    jsr GameOverLoading                                 ; Draws game over screen and player score
    jsr DrawLeaderboard                                 ; Draws the leaderboard with names and scores

*------------------------------------------------------------------------------------*
*----------------------------------Restart-Game-Loop---------------------------------*
*------------------------------------------------------------------------------------*    
RestartGameLoop    
    * Check for mouse click input 
    move.l #MOUSE_INPUT_TRAP_CODE, d0
    moveq #0, d1                                        ; Set mode to "read mouse down state"
    trap #15
    btst #0, d0                                         ; Check "mouse down" state
    bne RestartPoint                                    ; Branch to restart the game if the mouse is clicked
    
    * Poll for Escape Key
    move.l #GET_KEY_STATE_TRAP_CODE, d0
    move.l #EscapeASCIIValue, d1
    trap #15
    
    btst.l #0, d1                                       ; Test for escape pressed
    beq.s RestartGameLoop                               ; Loop if escape has not been pressed
    
    jsr GameExitCleanup                                 ; Turn off music and clear screen

    SIMHALT

*--------------------FUNCTION INCLUDES--------------------*
    INCLUDE "OptimizedGameObjectDrawing.X68"
    INCLUDE "BitmapChunker.X68"
    INCLUDE "RandomNumbers.X68"
    INCLUDE "SpawnGameObject.X68"
    INCLUDE "HandleCollision.X68"
    INCLUDE "7SegmentDisplay.X68"
    INCLUDE "DoneSpawningCheck.X68"
    INCLUDE "LeaderboardManagement.X68"
    INCLUDE "GameOverLoading.X68"
    INCLUDE "PreGameSubroutines.X68"
    INCLUDE "TitleScreenSetup.X68"
    INCLUDE "OneTimeGameSetup.X68"
    INCLUDE "MulletSequenceSetup.X68"
    INCLUDE "GameExitCleanup.X68"
    INCLUDE "DrawGameObjects.X68"
    INCLUDE "MouseInputHandler.X68"
    INCLUDE "MoveEyes.X68"
    INCLUDE "CheckForCollision.X68"
    INCLUDE "FleeingFishPhysicsUpdate.X68"
    INCLUDE "CatchFish.X68"
    INCLUDE "GetNewWorm.X68"
    INCLUDE "BoundsCheck.X68"
    INCLUDE "DrawFishingUI.X68"
    INCLUDE "FrameUpdate.X68"
    
*--------------------Global Variables--------------------*

*--1 word + 4 bytes per GameObject: [x-pos] + [speed][lane][type][frame]--*
GameObjectTable ds.w (3*MAX_GAME_OBJECTS)

*--1 byte each: [Number of Fish caught][Is there a fish on the hook?][Number of worms remaining][Is there a worm on the hook]--*
FishingManagerTable ds.l 1

*--0 = Normal Game State, 1 = Ready for Mullet Spawn, 2 = Mullet Sequence Running, 3 = Mullet Caught, 4 = Mullet Escaped--*
GameState ds.b 1

*--Table holding actual screen location of lanes 0, 1, 2, and 3--*
LocationTable dc.w LANE_0_LOCATION, LANE_1_LOCATION, LANE_2_LOCATION, LANE_3_LOCATION

*--Number of fish that have spawned--*
NumFishSpawned ds.b 1

*--Current number of GameObjects allowed at one time--*
GetCurrentMaxGameObjects ds.b 1

    END     START
















































































*~Font name~Courier New~
*~Font size~12~
*~Tab type~1~
*~Tab size~4~
