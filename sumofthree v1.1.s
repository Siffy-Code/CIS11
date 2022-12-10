/*SUM OF THREE UNSIGNED INTEGERS*/
/*CIS11 FALL2022*/
/*PETER T RONNING (SIFFY)*/
.data
/*Initialize Variables*/
x: .word 0
y: .word 0
z: .word 0
sum: .word 0
/*Initialize Strings*/
sngl : .asciz "%d\n"
output : .asciz "You entered %d, %d, and %d, and the sum is "
scnr : .asciz "%u %u %u"
prmpt : .asciz "Enter three integer values: "

.text
.global main
main:
	push {lr}			/*non-simple function*/
	ldr r8, =x			/*Set long-term registries*/
	ldr r9, =y
	ldr r10, =z
	ldr r4, =sum		/*Set short-term registry*/
						
	ldr r0, =prmpt		/*Load Display Prompt per Assignment*/
	bl printf			/*Execute printf for loaded registries*/
		
	ldr r0, =scnr		/*read three variables from keyboard*/
	mov r1, r8			/*place pointer for variables in scan registries*/
	mov r2, r9
	mov r3, r10
	bl scanf
	
	
	ldr r0, =output		/*Load beginning display txt*/
	mov r1, r8			/*Load variables for printf function in order*/
	ldr r1, [r1]
	mov r2, r9
	ldr r2, [r2]
	mov r3, r10
	ldr r3, [r3]
	bl printf			/*execute printing for loaded variables in display string*/
	
	
	ldr r10, [r10]		/*sequenially load and sum variables into open register5*/
	add r5, r5, r10		
	ldr r9, [r9]
	add r5, r5, r9
	ldr r8, [r8]
	add r5, r5, r8
	str r5, [r4]		/*store register5 into register4*/
	
	ldr r0, =sngl		/*Load single variable display*/
	mov r1, r4			/*Place and load summed total in register1 for printing*/
	ldr r1, [r1]		
	bl printf			/*execute printing for loaded sum variable*/
	
	
						/*program end*/
exit:
	mov r0, #0
	pop {pc}

