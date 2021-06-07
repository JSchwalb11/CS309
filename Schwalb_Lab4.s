@ Filename :    Schwalb_Lab4.s
@ Author   :    Joseph Schwalb
@ Email    :    jds0099@uah.edu
@ CS309-01 :    2020
@ Purpose  :    ARM Lab 4: Simple Program to sum the even/odd numbers
@               less than or equal to some number [1,100]
@ 
@
@ Use these commands to assemble, link, run and debug this program:
@    as -o Schwalb_Lab5.o Schwalb_Lab5.s
@    gcc -o Schwalb_Lab5 Schwalb_Lab5.o
@    ./Schwalb_Lab5 ;echo $?
@    gdb --args ./Schwalb_Lab5 

@ ***********************************************************************
@ The = (equal sign) is used in the ARM Assembler to get the address of a
@ label declared in the .data section. This takes the place of the ADR
@ instruction used in the textbook. 
@ ***********************************************************************

.equ READERROR, 0 @Used to check for scanf read error.

.global main @ Have to use main because of C library uses. 

main:

@*******************
int_prompt:
@*******************

@ Ask the user to enter a number.
 
   ldr r0, =strInputPrompt    @ Put the address of my string into the first parameter
   bl  printf                 @ Call the C printf to display input prompt. 

@*******************
get_int_input:
@*******************

@ Set up r0 with the address of input pattern.
@ scanf puts the input value at the address stored in r1. We are going
@ to use the address for our declared variable in the data section - intInput. 
@ After the call to scanf the input is at the address pointed to by r1 which 
@ in this case will be intInput. 

   ldr r0, =numInputPattern    @ Setup to read in one number.
   ldr r1, =intInput           @ load r1 with the address of where the
                               @ input value will be stored. 
   bl  scanf                   @ scan the keyboard.
   cmp r0, #READERROR          @ Check for a read error.
   beq readerror               @ If there was a read error go handle it.  
   ldr r1, =intInput           @ Have to reload r1 because it gets wiped out. 
   ldr r1, [r1]                @ Read the contents of intInput and store in r1 so that
                               @ it can be printed.

@ Print the input out as a number.
@ r1 c ontains the value input to keyboard. 
    cmp r1, #100               @ Compare user input to the immediate value 100 (greater than)
    bgt myexit                 @ branch to myexit if true
    cmp r1, #2                 @ Compare user input to the immediate value 2 (less than)
    blt myexit                 @ branch to myexit if true
    mov r6, r1                 @ move the user input in r1 into r6 for use later to free r1
    ldr r0, =strOutputNum      @ Load string into r0 before printf branch
    bl printf                  @ call to printf, return here after
    

@***********
determine_input_parity:
@***********
    bl odd_input               @ call to odd_input and return here
    ldr r0, =new_line          @ load carriage return into r0
    bl printf                  @ call to printf and return here
    bl even_input              @ call to even_input and return here

@***********
done:
@***********
    b myexit                   @ branch to myexit


@***********
odd_input:
@***********
    push {r9, lr}              @ push lr to r9, used to store return locations within nested functions
    ldr r0, =oddNumbers1tox    @ load r0 with string to print
    mov r1, r6                 @ load r1 with user input stored in r6
    bl printf                  @ call printf, return here
    mov r5, #1                 @ 1 is the first non-negative odd integer, so we start our summation here
    bl running_total           @ calling summation function, returning r7
    ldr r0, =oddSum            @ load r0 with string to print
    mov r1, r7                 @ load r1 with user input stored in r6
    bl printf                  @ call printf, return here
    pop {r9, pc}               @ pop r9 to pc, used to return from nested functions
   

@***********
even_input:
@***********
    push {r9, lr}              @ push lr to r9, used to store return locations within nested functions
    ldr r0, =evenNumbers1tox   @ load r0 with string to print
    mov r1, r6                 @ load r1 with user input stored in r6
    bl printf                  @ call printf, return here
    mov r5, #2                 @ 2 is the first integer (2k such that k=1), so we start our summation here
    bl running_total           @ branch to loop
    ldr r0, =evenSum           @ load r0 with string to print
    mov r1, r7                 @ load r1 with user input stored in r6
    bl printf                  @ call printf, return here
    pop {r9, pc}               @ pop r9 to pc, used to return from nested functions

@***********
running_total:
@***********
    push {r10, lr}             @ push lr to r10, used to store return locations within nested functions
    mov r7, #0                 @ init sum to 0
next:
    add r7, r7, r5             @ Add the current integer in r5 to the sum in r7
    ldr r0, =current_val       @ load r0 with string to print
    mov r1, r5                 @ load r1 with counter stored in r5
    bl printf                  @ call printf, return here
    add r5, r5, #2             @ Increment the integer by 2, r5 will maintain parity (2k+1 for odd or 2k for even)
    cmp r5, r6                 @ Compare the new integer in r5 to the input in r6
    ble next                   @ call next until r5 is greater than the input in r6
    pop {r10, pc}              @ pop r10 to pc, used to return from nested functions


@***********
readerror:
@***********
@ Got a read error from the scanf routine. Clear out the input buffer then
@ branch back for the user to enter a value. 
@ Since an invalid entry was made we now have to clear out the input buffer by
@ reading with this format %[^\n] which will read the buffer until the user 
@ presses the CR. 

   ldr r0, =strInputPattern
   ldr r1, =strInputError   @ Put address into r1 for read.
   bl scanf                 @ scan the keyboard.
@  Not going to do anything with the input. This just cleans up the input buffer.  
@  The input buffer should now be clear so get another input.

   b int_prompt


@*******************
myexit:
@*******************
@ End of my code. Force the exit and return control to OS

   mov r7, #0x01 @ SVC call to exit
   svc 0         @ Make the system call. 


.data

@ Declare the strings and data needed

.balign 4
strInputPrompt: .asciz "Input a number between [1,100]: \n"

.balign 4
strOutputNum: .asciz "You entered: %d \n"

.balign 4
oddSum: .asciz "The odd sum is: %d \n"

.balign 4
evenSum: .asciz "The even sum is: %d \n"

.balign 4
current_val: .asciz "%d\n"

.balign 4
new_line: .asciz "\n"

.balign 4
evenNumbers1tox: .asciz "The even numbers from 1 to %d are:\n"

.balign 4
oddNumbers1tox: .asciz "The odd numbers from 1 to %d are:\n"

@ Format pattern for scanf call.

.balign 4
numInputPattern: .asciz "%d"  @ integer format for read. 

.balign 4
strInputPattern: .asciz "%[^\n]" @ Used to clear the input buffer for invalid input. 

.balign 4
strInputError: .skip 100*4  @ User to clear the input buffer for invalid input. 

.balign 4
intInput: .word 0   @ Location used to store the user input.

@ Let the assembler know these are the C library functions. 

.global printf
@  To use printf:
@     r0 - Contains the starting address of the string to be printed. The string
@          must conform to the C coding standards.
@     r1 - If the string contains an output parameter i.e., %d, %c, etc. register
@          r1 must contain the value to be printed. 
@ When the call returns registers: r0, r1, r2, r3 and r12 are changed. 

.global scanf
@  To use scanf:
@      r0 - Contains the address of the input format string used to read the user
@           input value. In this example it is numInputPattern.  
@      r1 - Must contain the address where the input value is going to be stored.
@           In this example memory location intInput declared in the .data section
@           is being used.  
@ When the call returns registers: r0, r1, r2, r3 and r12 are changed.
@ Important Notes about scanf:
@   If the user entered an input that does NOT conform to the input pattern, 
@   then register r0 will contain a 0. If it is a valid format
@   then r0 will contain a 1. The input buffer will NOT be cleared of the invalid
@   input so that needs to be cleared out before attempting anything else.
@
@ Additional notes about scanf and the input patterns:
@    1. If the pattern is %s or %c it is not possible for the user input to generate
@       and error code. Anything that can be typed by the user on the keyboard
@       will be accepted by these two input patterns. 
@    2. If the pattern is %d and the user input 12.123 scanf will accept the 12 as
@       valid input and leave the .123 in the input buffer. 
@    3. If the pattern is "%c" any white space characters are left in the input
@       buffer. In most cases user entered carrage return remains in the input buffer
@       and if you do another scanf with "%c" the carrage return will be returned. 
@       To ignore these "white" characters use " $c" as the input pattern. This will
@       ignore any of these non-printing characters the user may have entered.
@

@ End of code and end of file. Leave a blank line after this.
