Program description

Our project is a disassembler written in 68K language using the Easy68K program. It will read series of memory image of instructions and decode data back to the 68K assembly language and finally prints the decoded output. The project is designed in a way that it’s split into three parts: I/O, Op-codes, and EA.

The general run through of the program will prompt the user to input an address range that they want the disassembler to decode, and the I/O will read each line of instructions to decode using the decode program ran by the OP and EA. If invalid input is detected, the program will prompt the user again until valid inputs are typed in. 

The decoded instruction and effective addresses will be printed back to the user to see in the terminal.  The decode process will repeat it self until the program has reached the ending address. After reaching certain amounts of lines printed, the program will pause until the user hits the Enter key to display the next page of decoded instructions. After all the instructions are printed, the program will ask if the user wants to restart or quit.
