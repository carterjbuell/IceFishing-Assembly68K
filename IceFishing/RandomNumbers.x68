*-----------------------------------------------------------
* Title      : RandomNumbers
* Written by : Utsab Das
* Changes by : Carter Buell
* Date       : 5/29/2025
* Description: Handles generating random values
*-----------------------------------------------------------

*----------------------SeedRandomNumber---------------------*
*   Uses the system time to seed random number generation
*-----------------------------------------------------------*
SeedRandomNumber
        clr.l   d6
        move.b  #GET_TIME_TRAP_CODE, d0
        TRAP    #15
        move.l  d1, RandomVal
        rts

*----------------------GetRandomByteIntoD6------------------*
*   Generates a random byte into the D6 register
*-----------------------------------------------------------*
GetRandomByteIntoD6
        move.l  RandomVal, d0
       	moveq	#$AF-$100, d1
       	moveq	#18, d2
Ninc0	
	add.l	d0, d0
	bcc	Ninc1
	eor.b	d1,d0
Ninc1
	dbf	d2, Ninc0
	
	move.l	d0, RandomVal 
	clr.l	d6
	move.b	d0, d6
	
        rts
        
*----------------------Global Variables---------------------*
RandomVal ds.l 1

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~8~
