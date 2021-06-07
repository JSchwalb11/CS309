@ Filename :    Schwalb_Lab4.s
@ Author   :    Joseph Schwalb
@ Email    :    jds0099@uah.edu
@ CS309-01 :    2020
@ Purpose  :    ARM Lab 5: ARM Advance Program
@               Furniture Factory Saw
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

@r4 will store board 1
@r5 will store board 2
@r6 will store board 3
@r7 used for running total
@r8 used for cut counter
@r10 for arithmetic and stack operations
@r11 used to store user input, freeing r1


@ Assign registers to appropriate initial immediate values for use
mov r4, #144
mov r5, #144
mov r6, #144
mov r7, #0
mov r8, #0


@*******************
welcome_prompt:
@*******************

@ Ask the user to enter a number.
 
   ldr r0, =cutItUpWelcome    @ Put the address of my string into the first parameter
   bl  printf                 @ Call the C printf to display input prompt. 

   bl status                  @ branch to status and return
   b get_int_input            @ branch to get_int_input, do not return


@*******************
status:
@*******************

   push {r10, lr}               @ push lr to r13, used to store return locations within nested functions

   ldr r0, =new_line            @ load a new line into printf
   bl  printf                   @ Call the C printf to display input prompt. 

   ldr r0, =boardsCutSoFar      @ load string into r0 for printing
   mov r1, r8                   @ move cut counter into r1 for printing
   bl  printf                   @ Call the C printf to display input prompt. 

   ldr r0, =linerLength         @ load string into r0 for printing
   mov r1, r7                   @ move sum into r1 for printing
   bl  printf                   @ Call the C printf to display input prompt. 

   ldr r0, =currentBoardLengths @ load string into r0 for printing
   bl  printf                   @ Call the C printf to display input prompt. 

   ldr r0, =boardOne            @ load string into r0 for printing
   mov r1, r4                   @ move the remaining length in board 1 into r1 for printing
   bl  printf                   @ Call the C printf to display input prompt. 

   ldr r0, =boardTwo            @ load string into r0 for printing
   mov r1, r5                   @ move the remaining length in board 2 into r1 for printing
   bl  printf                   @ Call the C printf to display input prompt. 

   ldr r0, =boardThree          @ load string into r0 for printing
   mov r1, r6                   @ move the remaining length in board 3 into r1 for printing
   bl  printf                   @ Call the C printf to display input prompt. 

   ldr r0, =new_line            @ load string into r0 for printing
   bl  printf                   @ Call the C printf to display input prompt. 

   pop {r10, pc}                @ pop r10 to pc, used to return from nested functions


@*******************
get_int_input:
@*******************

@ Ask the user to enter a number.
 
   ldr r0, =strInputPrompt    @ Put the address of my string into the first parameter
   bl  printf                 @ Call the C printf to display input prompt. 

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
    cmp r1, #144               @ Compare user input to the immediate value 144 (greater than)
    bgt myexit                 @ branch to myexit if true
    cmp r1, #6                 @ Compare user input to the immediate value 6 (less than)
    blt myexit                 @ branch to myexit if true
    mov r11, r1                @ move the user input in r1 into r11 for use later to free r1
    ldr r0, =strOutputNum      @ Load string into r0 before printf branch
    bl printf                  @ call to printf, return here after


@***********
cut_boards:
@***********
    @ Loop begins here
    mov r10, r4                @ move r4 into r10, using r10 as a scratch pad
    cmp r10, r11               @ Check if board 1 has enough length to cut 
    bpl cut_board_one          @ If CCR flags show positive or zero, branch
    
    mov r10, r5                @ move r5 into r10, using r10 as a scratch pad
    cmp r10, r11               @ Check if board 2 has enough length to cut 
    bpl cut_board_two          @ If CCR flags show positive or zero, branch

    mov r10, r6                @ move r6 into r10, using r10 as a scratch pad
    cmp r10, r11               @ Check if board 3 has enough length to cut 
    bpl cut_board_three        @ If CCR flags show positive or zero, branch


@***********
cut_board_one:
@***********
    cmp r4, r11                @ check if the input is bigger then the length remaining
    bmi cut_too_big            @ if CCR flags are negative, branch to cut_too_big

    sub r4, r4, r11            @ decrement board 1 length by r11
    add r7, r7, r11            @ add to total length cut
    add r8, r8, #1             @ increment cut counter

        
    b check_inventory_left     @ branch to check_inventory_left, do not return


@***********
cut_board_two:
@***********
    cmp r5, r11                @ check if the input is bigger then the length remaining
    bmi cut_too_big            @ if CCR flags are negative, branch to cut_too_big

    sub r5, r5, r11            @ decrement board 2 length by r11
    add r7, r7, r11            @ add to total length cut
    add r8, r8, #1             @ increment cut counter

    b check_inventory_left     @ branch to check_inventory_left, do not return


@***********
cut_board_three:
@***********
    cmp r6, r11                @ check if the input is bigger then the length remaining
    bmi cut_too_big            @ if CCR flags are negative, branch to cut_too_big

    sub r6, r6, r11            @ decrement board 3 length by r11
    add r7, r7, r11            @ decrement board 2 length by r11
    add r8, r8, #1             @ increment cut counter

    b check_inventory_left     @ branch to check_inventory_left, do not return


@***********
check_inventory_left:
@***********

    bl status                  @ branch to status, return here
    
    mov r10, r4                @ mov r4 into scratch pad
    cmp r10, #6                @ set CCR flags
    bgt get_int_input          @ if r10 (holding r4) is greater than 6, branch to get_int_input

    mov r10, r5                @ mov r5 into scratch pad
    cmp r10, #6                @ set CCR flags
    bgt get_int_input          @ if r10 (holding r5) is greater than 6, branch to get_int_input

    mov r10, r6                @ mov r6 into scratch pad
    cmp r10, #6                @ set CCR flags
    bgt get_int_input          @ if r10 (holding r6) is greater than 6, branch to get_int_input
    
    b done_cutting             @ no length left to cut, branch to done_cutting


@***********
done_cutting:
@***********
    ldr r0, =new_line          @ load string into r0 for printing
    bl printf                  @ call to printf, return here after

    ldr r0, =finalInventory    @ load string into r0 for printing
    bl printf                  @ call to printf, return here after

    bl status                  @ call to status, return here after

    mov r10, #0                @ zero out scratch pad
    add r10, r10, r4           @ add length remaining in r4 to scratch pad
    add r10, r10, r5           @ add length remaining in r5 to scratch pad
    add r10, r10, r6           @ add length remaining in r6 to scratch pad

    ldr r0, =terminatePrompt   @ load string into r0 for printing
    mov r1, r10                @ load scratch pad into r1 for printing
    bl printf                  @ call to printf, return here after

    b myexit                   @ branch to myexit


@***********
cut_too_big:
@***********

    ldr r0, =cutTooBig         @ load string into r0 for printing
    bl printf                  @ call to printf, return here after

    bl status                  @ call to status, return here after
    b get_int_input            @ branch to get_int_input, do not return



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

   b myexit


@*******************
myexit:
@*******************
@ End of my code. Force the exit and return control to OS

   mov r7, #0x01 @ SVC call to exit
   svc 0         @ Make the system call. 


.data

@ Declare the strings and data needed

.balign 4
cutItUpWelcome: .asciz "Cut-It-Up Saw \n"

.balign 4
linerLength: .asciz "Liner length of boards cut so far: %d inches \n"

.balign 4
boardsCutSoFar: .asciz "Boards cut so far: %d \n"

.balign 4
currentBoardLengths: .asciz "Current Board Lengths:\n"

.balign 4
boardOne: .asciz "One: %d inches\n"

.balign 4
boardTwo: .asciz "Two: %d inches\n"

.balign 4
boardThree: .asciz "Three: %d inches\n"

.balign 4
terminatePrompt: .asciz "Inventory levels have dropped below minimum levels and will now terminate. Waste is %d inches.\n"

.balign 4
finalInventory: .asciz "**********************  Final Inventory  **********************\n"

.balign 4
strInputPrompt: .asciz "Enter the length of board to cut in inches (at least 6 and no more than 144):\n"

.balign 4
cutTooBig: .asciz "The length you entered is too big, but there is still some board left to use!\n Please enter a smaller length.\n"

.balign 4
strOutputNum: .asciz "You entered: %d \n"

.balign 4
new_line: .asciz "\n"


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
