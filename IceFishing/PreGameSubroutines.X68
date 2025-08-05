*-----------------------------------------------------------
* Title      : PreGameSubroutines
* Written by : Carter Buell
* Date       : 6/19/2025
* Description: Contains subtroutines to be done before the main game loop
*-----------------------------------------------------------

WORM_COUNT_X                    EQU 15
WORM_COUNT_Y                    EQU 20
WORM_COUNT_WIDTH                EQU 73
WORM_COUNT_HEIGHT               EQU 68

STARTING_LOCATION_1             EQU -200
STARTING_LOCATION_2             EQU -210
STARTING_LOCATION_3             EQU -70
STARTING_LOCATION_4             EQU 100
STARTING_LOCATION_5             EQU 400
STARTING_LOCATION_6             EQU 300

CLICK_TO_START_X                EQU 155
CLICK_TO_START_Y                EQU 488
CLICK_TO_START_WIDTH            EQU 440
CLICK_TO_START_HEIGHT           EQU 55

STARTING_BAIT                   EQU 3
STARTING_FISH_SPAWNED           EQU 4

FRAME_DURATION                  EQU 3

*----------------PreGameSetup-------------------------*
*   Draws inital background bitmap and loading icons 
*-----------------------------------------------------*    
PreGameSetup
    * Set Fill Color to Water Color
    move.l #SET_FILL_COLOR_TRAP_CODE, d0
    move.l #WATER_COLOR, d1
    trap #15
    
    * Set Pen Color to Water Color
    move.l #PEN_COLOR_TRAP_CODE, d0
    move.l #WATER_COLOR, d1
    trap #15
    
    * Fill Screen with Water Color
    move.l #DRAW_RECT_TRAP_CODE, d0
    move.w #CLICK_TO_START_X, d1
    move.w #CLICK_TO_START_Y, d2
    move.w d1, d3
    move.w d2, d4
    add.w #CLICK_TO_START_WIDTH, d3
    add.w #CLICK_TO_START_HEIGHT, d4
    trap #15

    * Set Font
    move.l #SET_FONT_TRAP_CODE, d0
    move.l #WHITE, d1
    move.l #LOADING_SMALL_FONT, d2
    trap #15

    * Set Fill Color to Purple
    move.l #SET_FILL_COLOR_TRAP_CODE, d0
    move.l #LOADING_PURPLE_COLOR, d1
    trap #15
    
    * Loading Icon
    move.l #TEXT_TO_SCREEN_TRAP_CODE, d0
    lea LoadingText, a1                                             ; Variable located in OneTimeGameSetup 
    move.w #LOADING_X, d1                                           ; Equate located in OneTimeGameSetup 
    move.w #LOADING_Y, d2                                           ; Equate located in OneTimeGameSetup                
    trap #15
    
    * Repaint from double buffer
    move.l #REPAINT_SCREEN_TRAP_CODE, d0
    trap #15

    * Set Fill Color to Water Color
    move.l #SET_FILL_COLOR_TRAP_CODE, d0
    move.l #WATER_COLOR, d1
    trap #15
    
    * Set Pen Color to Water Color
    move.l #PEN_COLOR_TRAP_CODE, d0
    move.l #WATER_COLOR, d1
    trap #15
    
    * Fill Screen with Water Color
    move.l #DRAW_RECT_TRAP_CODE, d0
    move.w #0, d1
    move.w #0, d2
    move.w #OUTPUT_WINDOW_WIDTH, d3
    move.w #OUTPUT_WINDOW_HEIGHT, d4
    trap #15
    
    * Draw Background Top
    lea BG_BITMAP, a2
    move.l #PA_OFFSET, -(sp)                                        ; Bitmap Offset
    move.l #OUTPUT_WINDOW_WIDTH, -(sp)                              ; Bitmap Width
    move.l #OUTPUT_WINDOW_HEIGHT, -(sp)                             ; Bitmap Height
    move.l a2, -(sp)                                                ; Bitmap Signature
    move.l #0, -(sp)                                                ; Bitmap Chunk X
    move.l #0, -(sp)                                                ; Bitmap Chunk Y
    move.l #OUTPUT_WINDOW_WIDTH, -(sp)                              ; Bitmap Chunk Width
    move.l #TOP_OF_WATER, -(sp)                                     ; Bitmap Chunk Height
    move.l #0, -(sp)                                                ; Output Screen X
    move.l #0, -(sp)                                                ; Output Screen Y
    jsr DisplayBitmapChunk
	add.l #BM_CHUNKER_STACK_SIZE, sp
    
    * Draw Background BOTTOM
    lea BG_BITMAP, a2
    move.l #PA_OFFSET, -(sp)                                        ; Bitmap Offset
    move.l #OUTPUT_WINDOW_WIDTH, -(sp)                              ; Bitmap Width
    move.l #OUTPUT_WINDOW_HEIGHT, -(sp)                             ; Bitmap Height
    move.l a2, -(sp)                                                ; Bitmap Signature
    move.l #0, -(sp)                                                ; Bitmap Chunk X
    move.l #BOTTOM_OF_WATER, -(sp)                                  ; Bitmap Chunk Y
    move.l #OUTPUT_WINDOW_WIDTH, -(sp)                              ; Bitmap Chunk Width
    move.l #(OUTPUT_WINDOW_HEIGHT-BOTTOM_OF_WATER), -(sp)           ; Bitmap Chunk Height
    move.l #0, -(sp)                                                ; Output Screen X
    move.l #BOTTOM_OF_WATER, -(sp)                                  ; Output Screen Y
    jsr DisplayBitmapChunk
	add.l #BM_CHUNKER_STACK_SIZE, sp
	
	rts
	
	
*----------------------VariableInitialization----------------------*
*   Initializes tables and variables to correct starting values 
*------------------------------------------------------------------* 
VariableInitialization
    
    * Reset fishing manager table
    lea FishingManagerTable, a6 
    move.b #0, GET_NUM_FISH_CAUGHT(a6)
    move.b #0, GET_IS_FISH_ON_HOOK(a6)
    move.b #STARTING_BAIT, GET_NUM_WORMS_LEFT(a6)
    move.b #1, GET_IS_WORM_ON_HOOK(a6)                              ; IS_WORM_ON_HOOK = True
    
    * Update 7 Segment Display Ones Place
    lea FishingManagerTable, a1
    move.w #COOLER_ONES_X, -(sp)                                    ; display coordinate X         
    move.w #COOLER_ONES_Y, -(sp)                                    ; display coordinate Y
    move.w #COOLER_SEGMENT_SIZE, -(sp)                              ; segment size
    moveq #0, d0
    move.b GET_NUM_FISH_CAUGHT(a1), d0
    divu #10, d0
    swap d0
    move.w d0, -(sp)                                                ; number to display (0-9)
    jsr DrawNumber
    add.l #SEVEN_SEGMENT_DRAW_STACK_SIZE, sp
    
    * Update 7 Segment Display Tens Place
    lea FishingManagerTable, a1
    move.w #COOLER_TENS_X, -(sp)                                    ; display coordinate X         
    move.w #COOLER_TENS_Y, -(sp)                                    ; display coordinate Y
    move.w #COOLER_SEGMENT_SIZE, -(sp)                              ; segment size
    moveq #0, d0
    move.b GET_NUM_FISH_CAUGHT(a1), d0
    divu #10, d0
    move.w d0, -(sp)                                                ; number to display (0-9)
    jsr DrawNumber
    add.l #SEVEN_SEGMENT_DRAW_STACK_SIZE, sp
    
    * Update worm counter to starting value
    lea FishingManagerTable, a6 
    move.b GET_NUM_WORMS_LEFT(a6), d0
    lea WORM_COUNT_BITMAP, a2
    move.l #PA_OFFSET, -(sp)                                        ; Bitmap Offset
    move.l #WORM_COUNT_WIDTH, -(sp)                                 ; Bitmap Width
    move.l #(WORM_COUNT_HEIGHT*4), -(sp)                            ; Bitmap Height
    move.l a2, -(sp)                                                ; Bitmap Signature
    move.l #0, -(sp)                                                ; Bitmap Chunk X
    mulu #WORM_COUNT_HEIGHT, d0
    move.l d0, -(sp)                                                ; Bitmap Chunk Y
    move.l #WORM_COUNT_WIDTH, -(sp)                                 ; Bitmap Chunk Width
    move.l #WORM_COUNT_HEIGHT, -(sp)                                ; Bitmap Chunk Height
    move.l #WORM_COUNT_X, -(sp)                                     ; Output Screen X
    move.l #WORM_COUNT_Y, -(sp)                                     ; Output Screen Y
    jsr DisplayBitmapChunk
	add.l #BM_CHUNKER_STACK_SIZE, sp
	
	* Set Current max GameObjects to MAX_GAME_OBJECTS
	lea GetCurrentMaxGameObjects, a0
    move.b #MAX_GAME_OBJECTS, (a0)
    
    * Set GameState to main game state
	lea GameState, a0
    move.b #0, (a0)                                                 ; GameState = main game loop
    
    * Reset FleeingFishPhysicsManager table values
    lea FleeingFishPhysicsManager, a2  
    move.l #(OUTPUT_WINDOW_HEIGHT<<NUM_FRACTIONAL_BITS), (a2)       ; d5 = y-pos (adjusted for 4 fractional bits)
    move.l #0, GET_Y_VELOCITY(a2)                                   ; d6 = velocity
    
    * Set inital pointer to GameObjectTable 
    lea GameObjectTable, a6
    
    * Set inital GameObjectTable loop variable
    move.l #NUM_BONUS_GAME_OBJECTS-1, d7                ; d7 = current number of max GameObjects (adjusted for dbra)
    
    * Set time Goal to (current time + frame duration)
    move.l #GET_TIME_TRAP_CODE, d0
    trap #15
    addi.l #FRAME_DURATION, d1
    lea TimeGoal, a1
    move.l d1, (a1)
    
    rts
    
    
*----------------SpawnInitialGameObjects---------------*
*   Spawns the first preset GameObjects on the screen
*------------------------------------------------------*
SpawnInitialGameObjects
    * Slow jelly moving right in lane 0
    lea GameObjectTable, a6
    move.w #STARTING_LOCATION_1, (a6)+     
    move.b #SLOW_RIGHT, (a6)+  
    move.b #LANE_0, (a6)+
    move.b #JELLY_TYPE, (a6)+
    move.b #FRAME_0, (a6)+
    
    * Slow fish moving right in lane 2
    move.w #STARTING_LOCATION_2, (a6)+     
    move.b #SLOW_RIGHT, (a6)+  
    move.b #LANE_2, (a6)+
    move.b #FISH_TYPE, (a6)+
    move.b #FRAME_0, (a6)+
    
    * Fast fish moving right in lane 2
    move.w #STARTING_LOCATION_3, (a6)+     
    move.b #FAST_RIGHT, (a6)+  
    move.b #LANE_2, (a6)+
    move.b #FISH_TYPE, (a6)+
    move.b #FRAME_0, (a6)+
    
    * Fast fish moving left in lane 1
    move.w #(OUTPUT_WINDOW_WIDTH)+STARTING_LOCATION_4, (a6)+     
    move.b #FAST_LEFT, (a6)+  
    move.b #LANE_1, (a6)+
    move.b #FISH_TYPE, (a6)+
    move.b #FRAME_0, (a6)+
    
    * Slow boot moving left in lane 3
    move.w #(OUTPUT_WINDOW_WIDTH)+STARTING_LOCATION_5, (a6)+     
    move.b #SLOW_LEFT, (a6)+  
    move.b #LANE_3, (a6)+
    move.b #BOOT_TYPE, (a6)+
    move.b #FRAME_0, (a6)+
    
    * Slow fish moving left in lane 3
    move.w #(OUTPUT_WINDOW_WIDTH)+STARTING_LOCATION_6, (a6)+     
    move.b #SLOW_LEFT, (a6)+  
    move.b #LANE_3, (a6)+
    move.b #FISH_TYPE, (a6)+
    move.b #FRAME_0, (a6)+
    
    * Set correct starting fish number
    lea NumFishSpawned, a0
    move.b #STARTING_FISH_SPAWNED, (a0)
    
    rts
    
    
*------------------Global Variables-------------------*
BG_BITMAP 	
    INCBIN "Assets\bg.bmp"
END_BG_BITMAP

WORM_COUNT_BITMAP 	
    INCBIN "Assets\worm_counter.bmp"
END_WORM_COUNT_BITMAP

TimeGoal ds.l 1








*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
