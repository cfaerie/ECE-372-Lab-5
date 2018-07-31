# ECE 372 Lab 5
Authors: Rachel & Ali

The objective of this lab is to introduce using interrupts in assembly language. 
The lab is divided into two parts. Part A will have students use interrupts and Part B will force
students to work without the help of interrupts, in order to see why they are useful. 

Program Part A is to have a main program loop and one interrupt service routine.

Main Program Loop:
Constanty flash the GREEN LED on the RGB display at a rate of 2Hz in an endless loop
Call to initialize the interrupt on PORT H (PORTH).

Interrupt Service Routine:
Respond to external interrupt on PORT H so that push buttons PH0 - PH2 can cause an interrupt.
Test the IF flag bits to see which switch caused the interupt
Branch to the corresponding part of the interrupt service routine to perform the specified actions:
PH0: Read the four leftmost DIP switch bits. They will represent a 4-bit counter in the program.
Display the bits on the PORT B 8-bit LEDs
PH1: Increment the value of the 4-bit counter displayed on PORT B. When the value displayed is 1111,
the next button press should roll over to 0000.
PH2: Decrement the value of the 4-bit counter displayed on PORT B. When the value displayed is 0000,
the next button press should roll over to 1111.


Program Part B forces us to work without the interrupts and instead, read the interrupt flag bits
to ac when a button is pressed. There is one main program loop and two subroutines.

Main Program Loop:
Call initialization routine
Begin label MAIN
Call data input subroutine, which will return a 4-bit value in one of the registers
Display the 4-bit value on PORT B LEDs
Loop back to label MAIN

Subroutines:
INIT
Clear interrupt flag on PH0

DATAIN
Check if PH0 is pressed by looking at PIFH flag bit 0. Loop until PH0 is pressed.
If PH0 is pressed, read 4 leftmost DIP switch bits, shift right by four positions so that the value
reads as a correct 4-bit value
Clear the PIFH flag
Return the 4-bit value to the main function
