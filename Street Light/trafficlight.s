/*
Name: Peter T Ronning (Siffy)
Date: 20221207 1348
Purpose: Simulate a walk signal at a traffic light using ARM language and
a Raspberry Pi connected to a Breadboard
Notes: 
*/
.equ INPUT, 0		//TXT CONVERSIONS OF BOOLEAN STATUSES FOR PI INTERFACE
.equ OUTPUT, 1
.equ LOW, 0
.equ HIGH, 1

.equ BLNKDLY, 750	//COMMONLY USED TIME VALUABLES TO QUICKLY ADJUST PROGRAM
.equ WALK, 10000
.equ SAFETY, 2000
.equ YLWLIGHT, 3000
.equ BLNKQTY, 7

.equ PINRT, 22		//PIN NUMBERS LABELLED BY FUNCTION
.equ PINYT, 23		//RT = RED-TRAFFIC, GW = GREEN WALK, ETC.
.equ PINGT, 24		
.equ PINRW, 27
.equ PINYW, 28
.equ PINGW, 29
.equ WLKSW, 25		//WALK BUTTON
.equ OFFSW, 26		//OFF SWITCH

.align 4			//NEVER HURTS TO MAKE SURE

.text
.global main
main:
	push {lr}		

setHrdWre:				//SET HARDWARE OUTPUT/INPUT MODES
	bl wiringPiSetup

	mov r0, #PINRT		//TRAFFIC LIGHTS OUTPUT
	mov r1, #OUTPUT
	bl pinMode
	mov r0, #PINYT
	mov r1, #OUTPUT
	bl pinMode
	mov r0, #PINGT
	mov r1, #OUTPUT
	bl pinMode

	mov r0, #PINRW		//WALK LIGHTS OUTPUT
	mov r1, #OUTPUT
	bl pinMode
	mov r0, #PINYW
	mov r1, #OUTPUT
	bl pinMode
	mov r0, #PINGW
	mov r1, #OUTPUT
	bl pinMode

	mov r0, #WLKSW		//BUTTONS INPUT
	mov r1, #INPUT
	bl pinMode
	mov r0, #OFFSW
	mov r1, #INPUT
	bl pinMode

setTrafficGo:			//CLEAR PREVIOUS STATES AND SET LIGHTS TO DEFAULT
	mov r0, #PINGT		//SET TRAFFIC LIGHTS TO DEFAULT ON
	mov r1, #HIGH
	bl digitalWrite
	mov r0, #PINRW
	mov r1, #HIGH
	bl digitalWrite
	
	mov r0, #PINGW		//SET TRAFFIC LIGHTS TO DEFAULT OFF
	mov r1, #LOW
	bl digitalWrite
	mov r0, #PINYW
	mov r1, #LOW
	bl digitalWrite
	mov r0, #PINYT
	mov r1, #LOW
	bl digitalWrite
	mov r0, #PINRT
	mov r1, #LOW
	bl digitalWrite

lp:						//CONTINUOUS STATE MACHINE - CHECKS FOR BUTTON PRESS
	mov r0, #OFFSW
	bl digitalRead
	cmp r0, #1
	beq offswitch		//OFF SWITCH WAS PRESSED, SHUT DOWN LIGHTS
	
	mov r0, #WLKSW		
	bl digitalRead
	cmp r0, #1
	beq signal			//WALK SWITCH WAS PRESSED, RUN SIGNAL ROUTINE
						//FOR TRAFFIC LIGHTS AT INTERSECTION, INPUT TRAFFIC LIGHT ROUTINE HERE
	bal lp				


signal:					//WALK SIGNAL PROGRAM WITH BLINK LOOP
	
	ldr r0, =#1000		//INITIAL DELAY FROM PRESS TO STARTING LIGHT CYCLE
	bl delay

	mov r0, #PINGT
	mov r1, #LOW
	bl digitalWrite

	mov r0, #PINYT
	mov r1, #HIGH
	bl digitalWrite

	ldr r0, =#YLWLIGHT		//YELLOW LIGHT FOR TRAFFIC TIMER
	bl delay

	mov r0, #PINRT
	mov r1, #HIGH
	bl digitalWrite
	mov r0, #PINYT
	mov r1, #LOW
	bl digitalWrite

	ldr r0, =#SAFETY	//DELAY BETWEEN FLIPPING RED AND WALK GOING GREEN
	bl delay			//SAFETY FIRST

	mov r0, #PINRW		//WALK SIGN ACTIVE
	mov r1, #LOW
	bl digitalWrite
	mov r0, #PINGW
	mov r1, #HIGH
	bl digitalWrite

	ldr r0, =#WALK		//TIME TO CROSS
	bl delay
	
	mov r0, #PINYW		//INITIALIZE YELLOW LIGHT
	mov r1, #HIGH		
	bl digitalWrite
	ldr r0, =#BLNKDLY	//BLINK DELAY
	bl delay
	
	mov r8, #0
		
for_lp:					//RUN BLINK LOOP SEVEN TIMES
	cmp r8, #BLNKQTY
	beq end_signal
	add r8, #1
	
	mov r0, #PINYW		//LIGHTS OFF
	mov r1, #LOW		
	bl digitalWrite
	mov r0, #PINGW		
	mov r1, #LOW		
	bl digitalWrite
	ldr r0, =#BLNKDLY	//BLINK DELAY
	bl delay
	mov r0, #PINGW		//LIGHTS ON
	mov r1, #HIGH		
	bl digitalWrite
	mov r0, #PINYW		
	mov r1, #HIGH		
	bl digitalWrite
	ldr r0, =#BLNKDLY	//BLINK DELAY
	bl delay
	
	bal for_lp	

end_signal:				//NOT SAFE TO CROSS
	mov r0, #PINGW
	mov r1, #LOW
	bl digitalWrite
	mov r0, #PINYW
	mov r1, #LOW
	bl digitalWrite
	mov r0, #PINRW
	mov r1, #HIGH
	bl digitalWrite
	
	ldr r0, =#SAFETY	//DELAY BETWEEN FLIPPING RED AND TRAFFIC GOING GREEN
	bl delay			//SAFETY FIRST

	mov r0, #PINRT
	mov r1, #LOW
	bl digitalWrite
	mov r0, #PINGT
	mov r1, #HIGH
	bl digitalWrite
	/*FINISH SIGNAL PROGRAM*/

	b lp				//RETURN TO STATE MACHINE

offswitch:				//TURN OFF DEFAULT LIGHTS AND EXIT PROGRAM
	mov r0, #PINGT
	mov r1, #LOW
	bl digitalWrite
	mov r0, #PINRW
	mov r1, #LOW
	bl digitalWrite


	mov r0, #0
	pop {pc}
