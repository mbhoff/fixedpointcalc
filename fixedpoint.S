/*************************************************************************//**
 * @file 
 *
 * @mainpage Fixed Point Calculator
 * 
 * @section course_section Course Information 
 *
 * @author Mark Buttenhoff
 * 
 * @section program_section Program Information 
 * 
 * @details This program prints a table for the equation
 * f(x) = ((5x^2 - 3x^2 + 2x + 20)/11).
 * The table is generated with user inputted lower and
 * upper values, number of rows, and number of
 * fractional precision.
 *
 * The program begins in main, where the table values
 * are inputted. printS converts the lower and upper values
 * from strings to fixed point
 * binary representations, and are stored in registers  
 * The delta x value for each row is found and stored.
 * A loop is called which branch links to the equation function,
 * calculates the y value and prints it using printS.
 *
 *
 *
 * @section compile_section Compiling and Usage 
 *
 * @par Compiling Instructions: 
 *      Compile using gcc and include fixedfuncs.c and divide.S
 * 
 * @par Usage:
   @verbatim  
   c:\> ./fixedpoint.S
   d:\> c:\bin\./fixedpoint.S
   @endverbatim 
 *
 * @section todo_bugs_modification_section Todo, Bugs, and Modifications
 *		
 * 
 * @bug
 *
 * 
 * @todo
 * 
 *
 *****************************************************************************/
			.data

percents:		.asciz	"%s"
			.align	2

percentd:		.asciz	"%d"
			.align	2

info:			.asciz	"This program will create a table for f(x) = ((5x^2 - 3x^2 + 2x + 20)/11)\n"
			.align	2

enterlower:		.asciz	"Enter a lower limit of x: "
			.align	2

enterupper:		.asciz	"Enter an upper limit of x: "
			.align	2

enterrows:		.asciz	"Enter number of table rows: "
			.align	2

enterfracprecision:	.asciz	"Enter the number of bits of fractional precision: "
			.align 	2


lower:			.skip 16

upper:			.skip 16

rows:			.word 0

fracprecision:		.word 0

deltaX:			.word 0

result:			.word 0

x:			.word 0

y:			.word 0


debugprint:		.asciz " %d \n"
			.align 2

debugprintfraction:	.asciz " %d \n"
			.align 2


tabledivider:		.asciz " | "
			.align 2

newline:		.asciz "\n"
			.align 2

xheader:		.asciz "x"
			.align 2

yheader:		.asciz "y"
			.align 2


/**************************************************************************//** 
 * @author Mark Buttenhoff
 * 
 * @par Description: This function passes in an x value in r4 and returns the
 * y value for the equation f(x) = ((5x^2 - 3x^2 + 2x + 20)/11) in r8
 * It uses the smull instruction to multiply a variable times a variable,
 * and add and shift to multiply a variable times a constant.
 *****************************************************************************/



equation:
	stmfd sp!, {r4-r11, lr}	@pop r4-r11 off the stack
	

	ldr r9, =fracprecision
	ldr r9, [r9]



	mov r4, r0		@move x to r4 - r4 reused for x throughout




	smull r0, r1, r4, r4 	@multiply r4 by itself, store lower bits in r0, upper bits in r1
	mov r2, #32		@move 32 into r2
	sub r2, r2, r9		@subtract 32 - r9 (32 minus fractional bits)
	lsl r1, r1, r9		@shift upper bits left by 32 - fractional bits
	lsr r0, r9		@shift lower bits right by 16
	orr r0, r1, r0		@orr lower and upper bits, store in r0
	mov r5, r0		@move x^2 to r5





	@5x^3

	smull r0, r1, r5, r4 	@multiply x by x^3
	mov r2, #32		@move 32 into r2
	sub r2, r2, r9		@subtract 32 - r9 (32 minus fractional bits)
	lsl r1, r1, r9		@shift upper bits left by 32 - fractional bits
	lsr r0, r9		@shift lower bits right by 16
	orr r0, r1, r0		@orr upper and lower bits, store in r0
	mov r6, r0		@move x^3 to r6
	add	r6, r6, r6, lsl #2  @5x^3




	@3x^2



	add r5, r5, r5, lsl #1 	@x^2 + x^2 #lsl #1 = 3x^2



	sub r7, r6, r5		@store 5x^3 - 3x^2 in r7



	@2x

	lsl r4, r4, #1  	@x #lsl 1 = 2x





	add r7, r7, r4		@add 5x^3 - 3x^2 and 2x, store in r7
	mov r8, #20		@mov #20 into r8


	lsl r8, r8, r9		@shift 20 left by fractional bits
	add r7, r7, r8		@add 5x^3 - 3x^2 + 2x and 20, store in r7
	


	
	mov r8, #11		@mov 11 to r8


	@r7/r8

	mov r0, r7		@move numerator to r1
	mov r1, r8		@move denominator to r8


	bl sdiv32





	mov r1, r9		@move r9 to r1 for fractional bits arguement
	mov r2, #4		@move #4 to r2 for decimal points argument
	bl printS


	ldmfd sp!, {r4-r11, lr} @push r4-r11 onto the stack
	mov pc, lr


	.text
	.global main

/**************************************************************************//** 
 * @author Mark Buttenhoff
 * 
 * @par Description: The main function pops r4-r11 off of the stack, and loads
 * the .word enterlower as a prompt for the lower value. It uses scanf to get
 * a string from the command line, stores it in a .skip 16 memory address,
 * and calls strtoSfixed to convert the string to a fixed point number.
 * The same is done for the upper value. The rows and fractional precision are
 * stored in .word addresses. From there, the delta x of the table is found
 * by finding (upper-lower)/(rows - 1). The function sdiv32 is used for this
 * divide. The table header is printed, and r10 and r11 are used to
 * iterate through the loop function.
 *****************************************************************************/

main:
	stmfd sp!, {r4-r11,lr}


	ldr	r0, =info	@print main program information
	bl	printf


	ldr	r0, =enterlower @print lower limit prompt
	bl 	printf

	ldr	r0, =percents	@ scanf("%s\0",&lower)
	ldr	r1, =lower
	bl	scanf





	ldr	r0, =enterupper @print upper limit prompt
	bl 	printf

	ldr	r0, =percents	@ scanf("%s\0",&lower)
	ldr	r1, =upper
	bl	scanf






	ldr	r0, =enterrows	@prompt for rows
	bl 	printf

	ldr	r0, =percentd	@ scanf("%d\0",&rows)
	ldr	r1, =rows
	bl	scanf


	ldr	r0, =enterfracprecision
	bl	printf
	

	ldr	r0, =percentd	@ scanf("%d\0",&fracprecision)
	ldr	r1, =fracprecision
	bl	scanf

	ldr	r9, =fracprecision @load fractional precision into r9
	ldr	r9, [r9]

	ldr	r0, =lower	
	mov	r1, r9		@convert lower limit to fixed point integer
	bl	strtoSfixed	@pass in lower limit, and fractional precision of 16


	mov	r4, r0		@move fixed point lower value to r4	

	ldr	r0, =upper 	@convert upper limit to fixed point integer
	mov	r1, r9		@pass in upper limit, and fractional precision of 16
	bl	strtoSfixed

	mov	r5, r0		@move fixed point upper value to r5


	sub	r6, r5, r4 @subtract upper from lower and store in r4
	

	
	ldr	r5, =rows @load rows to r5
	ldr	r5, [r5]

	sub	r5, r5, #1 @subtract 1 from rows





	mov r0, r6	@move upper-lower to r6
	mov r1, r5	@move rows-1 to r5
	
	bl sdiv32 @divide (upper-lower)/(rows-1)


	mov r7, r0	@store delta x in r7

	


	

	ldr	r0, =xheader		@print x label for table
	bl	printf

	ldr	r0, =tabledivider	@print table divider to separate x and y values
	bl	printf

	ldr	r0, =yheader		@print y header for table
	bl	printf
	
	ldr	r0, =newline		@print newline
	bl	printf



	mov r10, #0			@move 0 to r10, use as loop counter
	ldr r11, =rows			@move rows to r11, use later to compare with loop counter
	ldr r11, [r11]


	
/**************************************************************************//** 
 * @author Mark Buttenhoff
 * 
 * @par Description: The loop function moves x to r0, fractional bits to r1,
 * and the decimal points to r2, and calls printS to print the value of x.
 * r4 is again loaded to r0, and the equation function is called, which
 * calculates the y value, and prints it. The lower value is then incremented
 * by the delta x found in main, the loop counter is incremented by one
 * and compared to the number of rows in the table. If the loop counter
 * is greater or equal, the end function is brached to.
 *****************************************************************************/	
	

loop:
	

	mov r0,r4		@move x into r0
	mov r1,r9		@move f9 into r1 for the fractional bits arguement
	mov r2, #4		@move #4 to r2 for decimal points argument




	bl printS		
	ldr r0, =tabledivider	@print table divider
	bl printf		
	
	mov r0, r4
	bl equation		@send r0 to equation

	
	ldr r0, =newline       	@print new line
	bl printf




	add r4, r4, r7		@increments the lower value by delta x
	add r10, r10, #1	@increments the loop counter by 1
	cmp r10, r11		@compares the counter to number of rows
	bge end			@branches to end if counter is greater or equal
	b loop

end:

	ldmfd sp!, {r4-r11, lr}
	mov r0, #0
	mov pc, lr
	.end

