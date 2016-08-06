
*******************************************************************************
* Sai Badey 
* Sean Lai 
* Duong Chau 
* TEAM LITTLE INDIAN AND BIG FRIENDS
* Motorola 68k Disassembler
*******************************************************************************

    ORG    $1000
    START:                  ; first instruction of program
    
START:                  
    
        LEA        INTRO,A1         Load Introduction
        MOVE.B     #14,D0           Trap #14 to print intro
        TRAP       #15              Print introduction to screen
		MOVE.B     #0, LINECOUNT   Initialize line count
STARTADDR  
        LEA        STARTADDRMS,A1   Load starting address prompt
        MOVE.B     #14,D0           Trap #14 to print
        TRAP       #15              print prompt          
        LEA        STARTINPUT,A1      Store the starting address into A1
        MOVEQ      #2,D0            Trap #2 takes the input from user
        TRAP       #15              Take the input
        JSR        CHECKLENGTH      Check input for validity
        CMP.B      #0, D4           If 0, the input passed
        BEQ        NEXT2            Continue if correct
        LEA        FAILMESSAGE,A1   Load Fail message if failed
        MOVE.B     #14,D0           Trap #14 to print
        TRAP       #15              Print fail message
        BRA        STARTADDR        Ask for the starting addr again           
NEXT2
        JSR        ASCHEX           Convert the ascii input to hex
        MOVEA.L    D3,A5            Move the addr into A5
        JSR        EVENTEST         Make sure input is not odd
        CMP.B      #0,D4            If 0, input is even and passed
        BEQ        NEXT3            Continue after odd check
        BRA        STARTADDR        Failed odd check, prompt again
NEXT3    
        JSR        RANGETEST       Test if the input is within the range
        CMP.B      #1,D4            If 1, it counts as fail
        BEQ        STARTADDR        Prompt the start addr again
        MOVE.L     D3,D7            Moving the address           
        MOVEA.L    D3,A5            Input all passed, move to A5
ENDADDR    
        LEA        ENDADDRMSG,A1    Store the ending addr prompt message
        MOVE.B     #14,D0           Trap #14
        TRAP       #15              Print prompt
        LEA        ENDINPUT,A1      Store the input prompt
        MOVEQ      #2,D0            trap #2 to get input
        TRAP       #15              Get input
        CLR.L      D3               Clear D3 for the addr   
        JSR        CHECKLENGTH      Test if the ending address is valid
        CMP.B      #0,D4            If 0, it is pass
        BEQ        NEXTEND2         If pass, continue the program
        LEA        FAILMESSAGE,A1   Load fail message
        MOVE.B     #14,D0           Trap #14 to print
        TRAP       #15              Print the fail message
        BRA        ENDADDR          Prompt for end addr again           
NEXTEND2   
        JSR        ASCHEX           Branch to convert ascii to hex
        MOVEA.L    D3,A6            Store ending addr D6
        JSR        EVENTEST         Check if the ending addr is odd
        CMP.B      #0,D4            If 0, the address passed
        BEQ        NEXTEND3         If pass, continue program
        BRA        ENDADDR          If fail, prompt again
NEXTEND3   
        JSR        RANGETEST        Tests if the input is within valid range
        CMP.B      #1,D4            If 1, it's fail
        BEQ        ENDADDR          Prompt the addr again
        MOVEA.L    D3,A6            All address passed, move to D6
        JSR        HIGHLOWCHECK     Check if the ending addr is higher
        CMP.B      #1,D4            If 1, ending addr not valid
        BEQ        ENDADDR          prompt ending addr again
        MOVEA.L    D3,A6            All addr passed, move to D6
        CLR.L      D7               Clear D7
        ADD        #2,A6            Set offset to A6
        LEA        KEYENTER, A1     Store next step message
        MOVE.B     #14,D0           Trap $14 to print
        TRAP       #15              Prints
        BRA        GETKEY           Goes to GETKEY, grabs keyboard input
ASCHEX     
        CMPI.B     #$0,D1          Compares if all ascii are converted
        BEQ        DONE            If yes branch
        MOVE.B     (A1)+,D2        If not, move to D2
        CMPI.B     #$39,D2         Check if D2 is a number or alphabet
        BLE        NUMCONV         If ascii is number, skip letter conversion
LETTERCONV     
        SUBI.B     #$37,D2         Convert ascii to hex (alphabet)
        BRA        COUNTER 
NUMCONV     
        SUBI.B     #$30,D2         Convert ascii to hex (number)
        BRA        COUNTER            
COUNTER     
        SUBI.B     #$1,D1          Decrement counter
        ADD.B      D2,D3           Store the converted hex to D3
        CMPI.B     #$0,D1          Check if everything is converted
        BEQ        ASCHEX          Keep converting
        ROL.L      #4,D3           Rotate first 4 bits. So continue the convert
        BRA        ASCHEX          Continue converting
CHECKLENGTH        
        CLR.L      D4              	Clear D4
        MOVEQ      #$0,D5          	Use D5 for compare if input is 0
        CMP.B      D5,D1           	Check if input is null or not
        BEQ        INPUTFAIL       	Test if input is null
        CMPI       #$8,D1          	Check if address is longer than 8 bits
        BGT        INPUTFAIL       	input failed
        MOVE.B     #$0,D4          	input is of correct length
        RTS
INPUTFAIL   
        MOVEQ       #$1,D4          	Move 1 in the D4 to mean fail
        RTS             
EVENTEST     
        CLR.L       D2             	    Clear D2
        CLR.L       D4             	    Clear D4
        MOVE.W      D3,D2          	    Move D3 to D2 to use it for temp
        MOVE.L      #$00000002,D1  	    Put 2 into D1
        DIVU        D1,D2          	    Divive the input by 2
        SWAP        D2             	    Store the remainder
        CMP.B       #1,D2          	    Check if the remaider is 1
        BEQ         EVENTESTFAIL  	    If remainder exists. It is a fail
        MOVE.B      #$0,D4          	Other wise, 0 means pass
        RTS                        	
EVENTESTFAIL   
        LEA         ODDADDRMSG,A1  	    Store odd error msg
        MOVE.B      #14,D0          	Trap #14 to print
        TRAP        #15                 Print the msg
        MOVEQ       #$1,D4          	If fail, put 1 into D4
        CLR.L       D3              	Clear D3
        RTS                
RANGETEST   
        CLR.L       D4              	Clear D4
        MOVE.L      #MINSTART,D1     	Load the minimum address $7000
        CMP.L       D1,D3           	Compare the two
        BLT         TOOLOW             	input too low
        MOVE.L      #MAXEND,D1  	    Load the maximum address $00FFFFFE
        CMP.L       D1,D3           	Compare the two
        BGT         TOOHIGH         	input too high
        MOVEQ       #$0,D4          	Passed test, put 0 into D4
        RTS                        	
TOOLOW    
        LEA         TOOLOWMSG,A1      	Store too low error
        MOVE.B      #14,D0          	Trap #14 to print
        TRAP        #15                 print error
        MOVE.B      #$1,D4          	Failed test, put 1 into D4
        CLR.L       D3              	Clear D3
        RTS
TOOHIGH    
        LEA         TOOHIGHMSG,A1   	Store too high error
        MOVE.B      #14,D0          	Trap #14 to print
        TRAP        #15                 print error
        MOVE.B      #$1,D4          	Failed test, put 1 into D4
        CLR.L       D3              	Clear D3
        RTS    
HIGHLOWCHECK  
        CLR.L       D4              	Clear D4
        CMP.L       D3,D7           	Compare the start and ending addr
        BGT         HIGHLOWFAIL      	If starting addr is higher than ending
        MOVEQ       #$0,D4          	If not, pass
        RTS        
HIGHLOWFAIL
        LEA         HIGHLOWMSG,A1     	Store the error msg
        MOVE.B      #14,D0				Trap #14 to print
        TRAP        #15				    Print msg
        MOVE.B      #$1,D4          	Put 1 into D4 for test fail
        CLR.L       D3          		Clear D3
        RTS							     
DONE        
        RTS
GETKEY
        MOVE.B      #12,D0              Keyboard echo trap
        MOVE.B      #0,D1               Reset keyboard input
        TRAP        #15                 Run the above commands
        MOVE.B      #5, D0              Keyboard echo
        TRAP        #15                 Trap the keyboard echo
        CMP.B       #$D, D1             Compare key to Enter
        BEQ         OPCODESETUP         Run the program
        CMP.B       #$52, D1            Compare key to R
        BEQ         RESTART             restart program
        CMP.B       #$72, D1            Compare key to r
        BEQ         RESTART             restart program
        CMP.B       #$71, D1            Compare key to q
        BEQ         THEEND              end program
        CMP.B       #$51, D1            Compare key to Q
        BEQ         THEEND              end program
        BRA         GETKEY              
ENDGETKEY
        MOVE.B      #12,D0              Keyboard echo trap
        MOVE.B      #0,D1               Reset keyboard input
        TRAP        #15                 Run the above
        MOVE.B      #5, D0              Keyboard echo
        TRAP        #15                 Trap echo
        CMP.B       #$52, D1            Compare key to r
        BEQ         RESTART             restart program
        CMP.B       #$72, D1            Compare key to R
        BEQ         RESTART             restart program
        CMP.B       #$71, D1            Compare key to q
        BEQ         THEEND              end program
        CMP.B       #$51, D1            Compare key to Q
        BEQ         THEEND              end program
        BRA         GETKEY 
RESTART     
        MOVE.B      #11,D0              Trap #11
        MOVE.W      #$FF00,D1           Clear Screen
        TRAP        #15                 Trap the above
        MOVE.B      #12,D0              Keyboard echo
        MOVE.B      #1,D1               Display String
        TRAP        #15                 Trap above
        CLR.L       D1                  Reset from D1 to D7
        CLR.L       D1                  
        CLR.L       D2                  
        CLR.L       D3                  
        CLR.L       D4                  
        CLR.L       D5                  
        CLR.L       D6                  
        MOVE.L      #$0000000,A0       Reset from A1 to A7
        MOVE.L      #$0000000,A1       
        MOVE.L      #$0000000,A2       
        MOVE.L      #$0000000,A3       
        MOVE.L      #$0000000,A4       
        MOVE.L      #$0000000,A5       
        MOVE.L      #$0000000,A6       
        MOVEA.L     #$01000000,A7       
        BRA         START               
OPCODESETUP
        MOVE.B      #11,D0             Trap #11 to clear screen
        MOVE.W      #$FF00,D1          Clear Screen
        TRAP        #15                Trap
        BRA         MAINLOOP           Go to Main Loop     
MAINLOOP
        MOVE.B      #$00,D7            Good flag     
        MOVE.W      (A5)+,D3           Move Instruction to D3
        LEA         buffer,A3          init. good buffer
        
        CLR.L       D6                 Print out the addresses
        MOVE.W      A5,D6
        SUBQ.B      #2,D6
        LSR.W       #8,D6
        LSR.W       #4,D6
        JSR         print_absoluteAdd 
        MOVE.W      A5,D6
        SUBQ.B      #2,D6
        LSL.W       #4,D6
        LSR.W       #8,D6
        LSR.W       #4,D6
        JSR         print_absoluteAdd
        MOVE.W      A5,D6
        SUBQ.B      #2,D6
        LSL.W       #8,D6
        LSR.W       #8,D6
        LSR.W       #4,D6
        JSR         print_absoluteAdd
        MOVE.W      A5,D6
        SUBQ.B      #2,D6
        LSL.W       #8,D6
        LSL.W       #4,D6
        LSR.W       #8,D6
        LSR.W       #4,D6
        JSR         print_absoluteAdd
    
        
        MOVE.B	    #' ',(A3)+          Print spaces
        MOVE.B	    #' ',(A3)+
        MOVE.B	    #' ',(A3)+
    

        LEA         BADBUFFER, A4       store bad buffer
        JSR         PUSHADDR            Push the good addr for process
        JSR		    SETUPBADDATA		Set up the bad data print
        JSR         JTableSetUp         Get the first 4 bits of instruction
        CMP.B       #$FF,D7             Check if instruction is Bad
        BEQ         HANDLINGINVALIDS	If it's bad data, print bad data
        MOVE.B      #$00,(A3)+          Else add 00 to good data
        LEA         buffer,A1		    print good data
        MOVEQ       #13,D0				Print
        TRAP        #15					call Trap
        
OUTERLOOP        
        CMPA.L      A5,A6				Compare the starting pointer to ending addr
        BEQ         END					If hit the end
        CMPA.L	    A5,A6				Compare starting and ending address
        BLT		    END					The starting is greater than ending!! End program
        ADD.B       #1, LINECOUNT       Line count increment
        CMP.B       #25, LINECOUNT      Each page will have 25 lines. Then prompt user
        BEQ         ENDOFPAGE		Hit end of page. 25 Lines, check prompt
        BRA         MAINLOOP				
        
PUSHADDR
        MOVEQ	    #8,D0               Move current counter to D0
        MOVE.L      A5,D4               Move address to D4
        SUB.B	    #2,D4				Subtract 2 to the counter
        RTS
SETUPBADDATA
   	    MOVE.B	    #'I',(A4)+			Insert I into the output
        MOVE.B	    #'N',(A4)+			Insert N into the output
        MOVE.B	    #'V',(A4)+			Insert V into the output
        MOVE.B	    #'A',(A4)+			Insert A space into the output
        MOVE.B	    #'L',(A4)+			Insert L into output
        MOVE.B	    #'I',(A4)+			Insert I into output
        MOVE.B	    #'D',(A4)+			Insert D into output
        MOVE.B	    #' ',(A4)+			Insert space into output
        MOVE.B	    #'$',(A4)+			Insert a $ into output
        RTS

HANDLINGINVALIDS
             
        LEA         EmptyStr, A3        Prints the invalid msgs
        CLR.L       D6
        MOVE.W      A5,D6
        SUBQ.B      #2,D6
        LSR.W       #8,D6
        LSR.W       #4,D6
        JSR         print_absoluteAdd 
        MOVE.W      A5,D6
        SUBQ.B      #2,D6
        LSL.W       #4,D6
        LSR.W       #8,D6
        LSR.W       #4,D6
        JSR         print_absoluteAdd
        MOVE.W      A5,D6
        SUBQ.B      #2,D6
        LSL.W       #8,D6
        LSR.W       #8,D6
        LSR.W       #4,D6
        JSR         print_absoluteAdd
        MOVE.W      A5,D6
        SUBQ.B      #2,D6
        LSL.W       #8,D6
        LSL.W       #4,D6
        LSR.W       #8,D6
        LSR.W       #4,D6
        JSR         print_absoluteAdd
        
        MOVE.B	    #' ',(A3)+
        MOVE.B	    #' ',(A3)+
        MOVE.B	    #' ',(A3)+
        
        MOVE.B      #'D',(A3)+
        MOVE.B      #'A',(A3)+
        MOVE.B      #'T',(A3)+
        MOVE.B      #'A',(A3)+
        
        MOVE.B      #' ',(A3)+
        MOVE.B      #' ',(A3)+
        MOVE.B      #' ',(A3)+
        MOVE.B      #' ',(A3)+
        
        MOVE.B      #'$',(A3)+
        MOVE.B      #'W',(A3)+
        MOVE.B      #'X',(A3)+
        MOVE.B      #'Y',(A3)+
        MOVE.B      #'Z',(A3)+
        
        LEA         EmptyStr,A1
        MOVE.B      #13,D0
        TRAP        #15
        BRA         OUTERLOOP
ENDOFPAGE
        MOVEQ       #13,D0              Set trap to 13 to print
        MOVE.B      #$00, LINECOUNT     Reset the Line Count
        LEA         KEYENTER,A1         Print out next step instruction
        MOVE.B      #13, D0             Set trap to 13 to print
        TRAP        #15                 Call trap
        BRA         GETKEY              Find out what the user wants to do
END
        LEA         ENDPROMPT,A1        Print out next step message
        MOVE.B      #13, D0             Set trap to 13 to print
        TRAP        #15                 Call trap
        BRA         ENDGETKEY           Find out what the user wants to do
THEEND     
	    LEA         ENDMSG,A1           print the end message on the screen
        MOVEQ       #14,D0				Set printing trap
        TRAP        #15					Call trip
        
        
*----------------------------------------------------------------
*                           JUMP TABLES                         *
*----------------------------------------------------------------
* Jump tables are used to quickly determine the op code by removing
* possibilities by comparing different sections of the binary command.
* Each jump table checks 4-bit lengths to see if it is valid.

JTableSetUp               *This section sets up jumping for first 4 bits
        CLR.L   D4
        MOVE.W  D3,D4     *grab the 16 bits
        LSR.W   #4,D4
        LSR.W   #8,D4     *shift to obtain first 4 bits
        MULU    #6,D4     *set offset
        LEA     TABLEPRIME,A4 *load table prime for jumping
        JSR     0(A4,D4)      *jump
        RTS

TABLEPRIME 
        JMP     PRIME0000  *SUBI,ORI,EORI,BTST,CMPI
        JMP     PRIME0001  *MOVE.B
        JMP     PRIME0010  *MOVE.L,MOVEA.L
        JMP     PRIME0011  *MOVE.W,MOVEA.W
        JMP     PRIME0100  *MOVEM,NEG,NOT,JSR,RTS,LEA
        JMP     PRIME0101  *ADDQ
        JMP     PRIME0110  *BCC,BRA
        JMP     PRIME0111  *----------
        JMP     PRIME1000  *DIVS
        JMP     PRIME1001  *SUB,SUBA
        JMP     PRIME1010  *----------
        JMP     PRIME1011  *EOR,CMP,CMPA
        JMP     PRIME1100  *AND,MULS
        JMP     PRIME1101  *ADD,ADDA
        JMP     PRIME1110  *LSL,LSR,ASL,ASR,ROL,ROR
        JMP     PRIME1111  *----------

TABLE0000                  *SUBI,ORI,EORI,CMPI
        JMP     subtab1_0000    *ORI
        JMP     subtab1_0001    *----------
        JMP     subtab1_0010    *----------
        JMP     subtab1_0011    *----------
        JMP     subtab1_0100    *SUBI
        JMP     subtab1_0101    *----------
        JMP     subtab1_0110    *----------
        JMP     subtab1_0111    *----------
        JMP     subtab1_1000    *----------
        JMP     subtab1_1001    *----------
        JMP     subtab1_1010    *EORI
        JMP     subtab1_1011    *----------
        JMP     subtab1_1100    *CMPI
        JMP     subtab1_1101    *----------
        JMP     subtab1_1110    *----------
        JMP     subtab1_1111    *----------
        
TABLE0100                  *MOVEM_,NEG,NOT,JSR,RTS,LEA_
        JMP     subtab2_0000    *----------
        JMP     subtab2_0001    *----------
        JMP     subtab2_0010    *----------
        JMP     subtab2_0011    *----------
        JMP     subtab2_0100    *NEG
        JMP     subtab2_0101    *----------
        JMP     subtab2_0110    *NOT
        JMP     subtab2_0111    *----------
        JMP     subtab2_1000    *----------
        JMP     subtab2_1001    *----------
        JMP     subtab2_1010    *----------
        JMP     subtab2_1011    *----------
        JMP     subtab2_1100    *----------
        JMP     subtab2_1101    *----------
        JMP     subtab2_1110    *JSR,RTS
        JMP     subtab2_1111    *----------

*----------------------------------------------------------------
*                       TABLE SUBROUTINES                       *
*----------------------------------------------------------------
* The following subroutines work by determining the op code that
* is given in data register 3. They check for multiple 
* possibilities before finalizing the actual op code. 
* Once it is determined, the opcode subroutines are called to 
* load the pertinent command to the buffer.

PRIME0000                  *SUBI,ORI,EORI,BTST,CMPI
                           *BTST checked before TABLE0000
        CLR.L   D4
        MOVE.W  D3,D4
        LSL.W   #$4,D4      *Remove first 4 bits,
        LSR.W   #$4,D4
        LSR.W   #$6,D4      *Remove last 6 bits
        CMP.W   #%100000,D4 *Compare remaining to BTST
        BEQ     BTST_v2OP
        
        CLR.L   D4
        MOVE.W  D3,D4       *Grab original 16 bits again
        LSL.W   #$7,D4
        LSR.W   #$7,D4
        LSR.W   #$6,D4      *shift out first 7 and last 6
        CMP.W   #%100,D4    *Check alternative BTST
        BEQ     BTST_v1OP

        CLR.L   D4          *Check values against table
        MOVE.W  D3,D4       
        LSR.W   #$8,D4
        ANDI.W  #$000F,D4   *Remove first 12 bits
        MULU    #$6,D4
        LEA     TABLE0000,A4 *Table 0000 checked
        JSR     0(A4,D4)
        RTS
        
PRIME0001                  *MOVE.B
        CLR.L   D4
        MOVE.W  D3,D4
        LSL.W   #$7,D4
        LSR.W   #$7,D4
        LSR.W   #$6,D4      *error check
        CMP.W   #%001,D4    *cannot be addr reg
        BEQ     FLAGINVALID
        BRA     MOVEBOP
        RTS
        
PRIME0010                  *MOVE.L, MOVEA.L
        CLR.L   D4
        MOVE.W  D3,D4
        LSL.W   #$7,D4
        LSR.W   #$7,D4
        LSR.W   #$6,D4
        CMP.W   #%001,D4   *is addr reg destination?
        BEQ     MOVEALOP   *yes = movea
        BRA     MOVELOP    *no  = move
        RTS
        
PRIME0011                  *MOVE.W, MOVEA.W
        CLR.L   D4
        MOVE.W  D3,D4
        LSL.W   #$7,D4
        LSR.W   #$7,D4
        LSR.W   #$6,D4
        CMP.W   #%001,D4   *is addr reg destination?
        BEQ     MOVEAWOP   *yes = movea
        BRA     MOVEWOP    *no  = move
        RTS
PRIME0100                  *MOVEM,NEG,NOT,JSR,RTS,LEA
                           *Check for MOVEM & LEA ahead of time
        CLR.L   D4
        MOVE.W  D3,D4
        LSL.W   #$4,D4      *Remove first 4 bits
        LSR.W   #$4,D4
        LSR.W   #$7,D4      *Remove last 7 bits
        CMP.W   #%10001,D4
        BEQ     MOVEM_0OP
        CMP.W   #%11001,D4  *Check 2 types of MOVEM
        BEQ     MOVEM_1OP
        
        CLR.L   D4
        MOVE.W  D3,D4
        LSL.W   #$7,D4      *Reset and check diff bits for LEA
        LSR.W   #$7,D4
        LSR.W   #$6,D4
        CMP.W   #%111,D4    *Reset and check for LEA
        BEQ     LEAOP

        CLR.L   D4
        MOVE.W  D3,D4
        LSR.W   #$8,D4
        ANDI.W  #$000F,D4
        MULU    #$6,D4
        LEA     TABLE0100,A4    *Check table 0100
        JSR     0(A4,D4)
        RTS
PRIME0101                  *ADDQ
        CLR.W   D4
        MOVE.W  D3,D4
        LSL.W   #7,D4
        LSR.W   #7,D4
        LSR.W   #6,D4
        CMP.W   #%000,D4    *Determine type of ADDQ
        BEQ     ADDQBOP     *Must be B,W,L size
        CMP.W   #%001,D4    *or invalid
        BEQ     ADDQWOP
        CMP.W   #%010,D4
        BEQ     ADDQLOP    
        
        MOVE.L  #$FF,D7     *put in the bad flag value
        RTS
        
PRIME0110                  *BCC,BRA
        CLR.W   D4
        MOVE.W  D3,D4
        LSL.W   #4,D4
        LSR.W   #4,D4
        LSR.W   #8,D4
        CMP.W   #%0000,D4   *Check for bra
        BEQ     BRAOP
        CMP.W   #%0010,D4   *check for bhi
        BEQ     BHIOP
        CMP.W   #%0110,D4   *check for bne
        BEQ     BNEOP
        CMP.W   #%0111,D4   *check for beq
        BEQ     BEQOP
        CMP.W   #%1101,D4   *check for blt
        BEQ     BLTOP
        MOVE.L  #$FF,D7     *put in the bad flag value
        RTS
   
PRIME0111                  *----------
        MOVE.L  #$FF,D7     *put in the bad flag value
        RTS
        
PRIME1000                  *DIVS
        CLR.W   D4
        MOVE.W  D3,D4
        LSL.W   #7,D4
        LSR.W   #7,D4
        LSR.W   #6,D4
        CMP.W   #%111,D4
        BEQ     DIVSOP
        MOVE.L  #$FF,D7     *put in the bad flag value
        RTS

*This method checks for all the different versions of
*sub and suba
PRIME1001                  *SUB,SUBA
        CLR.W   D4
        MOVE.W  D3,D4
        LSL.W   #7,D4
        LSR.W   #7,D4
        LSR.W   #6,D4
        CMP.W   #%000,D4
        BEQ     SUBB_v1OP
        CMP.W   #%001,D4
        BEQ     SUBW_v1OP
        CMP.W   #%010,D4
        BEQ     SUBL_v1OP
        CMP.W   #%011,D4
        BEQ     SUBAWOP
        CMP.W   #%100,D4
        BEQ     SUBB_v2OP
        CMP.W   #%101,D4
        BEQ     SUBW_v2OP
        CMP.W   #%110,D4
        BEQ     SUBL_v2OP
        CMP.W   #%111,D4
        BEQ     SUBALOP
        
PRIME1010                  *---------
        MOVE.L  #$FF,D7     *put in the bad flag value
        RTS
        
PRIME1011                  *EOR,CMP,CMPA
        CLR.W   D4
        MOVE.W  D3,D4
        LSL.W   #7,D4
        LSR.W   #7,D4
        LSR.W   #6,D4
        CMP.W   #%000,D4
        BEQ     CMPBOP
        CMP.W   #%001,D4
        BEQ     CMPWOP
        CMP.W   #%010,D4
        BEQ     CMPLOP
        CMP.W   #%011,D4
        BEQ     CMPAWOP
        CMP.W   #%100,D4
        BEQ     EORBOP
        CMP.W   #%101,D4
        BEQ     EORWOP        
        CMP.W   #%110,D4
        BEQ     EORLOP
        CMP.W   #%111,D4
        BEQ     CMPALOP
        
*This method checks for all the versions of
*AND and MULS
PRIME1100                  *AND,MULS
        CLR.W   D4
        MOVE.W  D3,D4
        LSL.W   #7,D4
        LSR.W   #7,D4
        LSR.W   #6,D4
        CMP.W   #%000,D4
        BEQ     ANDB_v1OP
        CMP.W   #%001,D4
        BEQ     ANDW_v1OP
        CMP.W   #%010,D4
        BEQ     ANDL_v1OP
        CMP.W   #%011,D4
        BEQ     FLAGINVALID
        CMP.W   #%100,D4
        BEQ     ANDB_v2OP
        CMP.W   #%101,D4
        BEQ     ANDW_v2OP        
        CMP.W   #%110,D4
        BEQ     ANDL_v2OP
        CMP.W   #%111,D4
        BEQ     MULSOP

        
*This method checks for all the ADD and ADDA
PRIME1101                  *ADD,ADDA
        CLR.W   D4
        MOVE.W  D3,D4
        LSL.W   #7,D4
        LSR.W   #7,D4
        LSR.W   #6,D4
        CMP.W   #%000,D4
        BEQ     ADDB_v1OP
        CMP.W   #%001,D4
        BEQ     ADDW_v1OP        
        CMP.W   #%010,D4
        BEQ     ADDL_v1OP
        CMP.W   #%011,D4
        BEQ     ADDAWOP
        CMP.W   #%100,D4
        BEQ     ADDB_v2OP
        CMP.W   #%101,D4
        BEQ     ADDW_v2OP
        CMP.W   #%110,D4
        BEQ     ADDL_v2OP
        CMP.W   #%111,D4
        BEQ     ADDALOP

*This funciton relies on MEMSHIFT and the REGOP
PRIME1110                  *LSL,LSR,ASL,ASR,ROL,ROR

        CLR.W   D4
        MOVE.W  D3,D4
        LSL.W   #8,D4
        LSR.W   #8,D4
        LSR.W   #6,D4
        CMP.W   #%11,D4
        BEQ     MEMSHIFT

        CLR.W   D4
        MOVE.W  D3,D4
        LSL.W   #8,D4
        LSL.W   #3,D4
        LSR.W   #8,D4
        LSR.W   #3,D4
        LSR.W   #3,D4
        CMP.W   #%11,D4
        BEQ     ROTATE_REGOP
        CMP.W   #%01,D4
        BEQ     LSHIFT_REGOP
        CMP.W   #%00,D4
        BEQ     ASHIFT_REGOP

        MOVE.L  #$FF,D7     *put in the bad flag value
        RTS

*This funciton calls on the rotate and shifts for memory
MEMSHIFT
        CLR.W   D4
        MOVE.W  D3,D4
        LSL.W   #4,D4
        LSR.W   #4,D4
        LSR.W   #8,D4
        CMP.W   #%0111,D4   ;check for direction, type of shift/rotate
        BEQ     ROL_MEMOP
        CMP.W   #%0110,D4
        BEQ     ROR_MEMOP
        CMP.W   #%0011,D4
        BEQ     LSL_MEMOP
        CMP.W   #%0010,D4
        BEQ     LSR_MEMOP
        CMP.W   #%0001,D4
        BEQ     ASL_MEMOP
        CMP.W   #%0000,D4
        BEQ     ASR_MEMOP
        
        MOVE.L  #$FF,D7     *put in the bad flag value
        RTS

ROTATE_REGOP
        CLR.W   D4
        MOVE.W  D3,D4
        LSL.W   #7,D4
        LSR.W   #7,D4
        LSR.W   #8,D4
        CMP.W   #%0,D4
        BEQ     ROR_REGOP
        BRA     ROL_REGOP

LSHIFT_REGOP
        CLR.W   D4
        MOVE.W  D3,D4
        LSL.W   #7,D4
        LSR.W   #7,D4
        LSR.W   #8,D4
        CMP.W   #%0,D4
        BEQ     LSR_REGOP
        BRA     LSL_REGOP

ASHIFT_REGOP
        CLR.W   D4
        MOVE.W  D3,D4
        LSL.W   #7,D4
        LSR.W   #7,D4
        LSR.W   #8,D4
        CMP.W   #%0,D4
        BEQ     ASR_REGOP
        BRA     ASL_REGOP


PRIME1111                  *---------
        MOVE.L  #$FF,D7     *put in the bad flag value
        RTS

subtab1_0000                  *ORI, determine byte/word/long
        CLR.W   D4
        MOVE.W  D3,D4
        LSL.W   #8,D4
        LSR.W   #8,D4
        LSR.W   #6,D4
        CMP.W   #%00,D4     ;check opmode
        BEQ     ORIBOP
        CMP.W   #%01,D4
        BEQ     ORIWOP
        CMP.W   #%10,D4
        BEQ     ORILOP
        
        MOVE.L  #$FF,D7     *put in the bad flag value
        RTS
        
subtab1_0001
        MOVE.L  #$FF,D7     *put in the bad flag value
        RTS
        
subtab1_0010
        MOVE.L  #$FF,D7     *put in the bad flag value
        RTS
        
subtab1_0011
        MOVE.L  #$FF,D7     *put in the bad flag value
        RTS
        
subtab1_0100                  *SUBI,determine byte,word,long
        CLR.W   D4
        MOVE.W  D3,D4
        LSL.W   #8,D4
        LSR.W   #8,D4
        LSR.W   #6,D4
        CMP.W   #%00,D4     ;check opmode
        BEQ     SUBIBOP
        CMP.W   #%01,D4
        BEQ     SUBIWOP
        CMP.W   #%10,D4
        BEQ     SUBILOP
        
        BRA     FLAGINVALID
        
subtab1_0101
        BRA     FLAGINVALID
        
subtab1_0110
        BRA     FLAGINVALID
subtab1_0111 
        BRA     FLAGINVALID
subtab1_1000
        BRA     FLAGINVALID
subtab1_1001
        BRA     FLAGINVALID
subtab1_1010                  *EORI,determine byte/word/long
        CLR.W   D4
        MOVE.W  D3,D4
        LSL.W   #8,D4
        LSR.W   #8,D4
        LSR.W   #6,D4
        CMP.W   #%00,D4
        BEQ     EORIBOP
        CMP.W   #%01,D4
        BEQ     EORIWOP
        CMP.W   #%10,D4
        BEQ     EORILOP
        
        BRA     FLAGINVALID
        
subtab1_1011
        BRA     FLAGINVALID
        
subtab1_1100                  *CMPI,determine byte/word/long
        CLR.W   D4
        MOVE.W  D3,D4
        LSL.W   #8,D4
        LSR.W   #8,D4
        LSR.W   #6,D4
        CMP.W   #%00,D4 ;check opmode
        BEQ     CMPIBOP
        CMP.W   #%01,D4
        BEQ     CMPIWOP
        CMP.W   #%10,D4
        BEQ     CMPILOP
        
        BRA     FLAGINVALID
        
subtab1_1101
        BRA     FLAGINVALID
        
subtab1_1110
        BRA     FLAGINVALID
        
subtab1_1111 
        BRA     FLAGINVALID
        
subtab2_0000
        BRA     FLAGINVALID

subtab2_0001
        BRA     FLAGINVALID

subtab2_0010
        BRA     FLAGINVALID

subtab2_0011
        BRA     FLAGINVALID

subtab2_0100    *NEG,determine byte/word/long
        CLR.W   D4
        MOVE.W  D3,D4 ;check opmode
        LSL.W   #8,D4
        LSR.W   #8,D4
        LSR.W   #6,D4
        CMP.W   #%00,D4
        BEQ     NEGBOP
        CMP.W   #%01,D4
        BEQ     NEGWOP
        CMP.W   #%10,D4
        BEQ     NEGLOP
        
        BRA     FLAGINVALID

subtab2_0101
        BRA     FLAGINVALID

subtab2_0110    *NOT, determine byte/word/long
        CLR.W   D4
        MOVE.W  D3,D4
        LSL.W   #8,D4
        LSR.W   #8,D4
        LSR.W   #6,D4
        CMP.W   #%00,D4 ;check opmode
        BEQ     NOTBOP
        CMP.W   #%01,D4
        BEQ     NOTWOP
        CMP.W   #%10,D4
        BEQ     NOTLOP
        
        BRA     FLAGINVALID
        
subtab2_0111
        BRA     FLAGINVALID

subtab2_1000
        BRA     FLAGINVALID

subtab2_1001
        BRA     FLAGINVALID

subtab2_1010
        BRA     FLAGINVALID


subtab2_1011
        BRA     FLAGINVALID

subtab2_1100
        BRA     FLAGINVALID

subtab2_1101
        BRA     FLAGINVALID

subtab2_1110    *JSR,RTS
        CLR.W   D4
        MOVE.W  D3,D4
        LSL.W   #8,D4
        LSR.W   #8,D4
        LSR.W   #6,D4
        CMP.W   #%10,D4
        BEQ     JSROP
        
        CLR.W   D4
        MOVE.W  D3,D4
        LSL.W   #7,D4
        LSR.W   #7,D4
        CMP.W   #%01110101,D4
        BEQ     RTSOP
        
subtab2_1111
        BRA     FLAGINVALID


*----------------------------------------------------------------
*               INSERTING OP CODES TO BUFFER                    *
*----------------------------------------------------------------
* This section of the code has determined the final op codes and
* so it uploads the command and size (if relevant) to the buffer.
* It then branches to the relevant EA section of the code

ORIBOP
        MOVE.B  #'O',(A3)+                  Insert O into output
        MOVE.B  #'R',(A3)+                  Insert R into output
        MOVE.B  #'I',(A3)+                  Insert I into output
        MOVE.B  #'.',(A3)+                  Insert . into output
        MOVE.B  #'B',(A3)+                  Insert B into output
        MOVE.B  #' ',(A3)+
        BRA     ORI
        
ORIWOP
        MOVE.B  #'O',(A3)+                  Insert O into output
        MOVE.B  #'R',(A3)+                  Insert R into output
        MOVE.B  #'I',(A3)+                  Insert I into output
        MOVE.B  #'.',(A3)+                  Insert . into output
        MOVE.B  #'W',(A3)+                  Insert W into output
        MOVE.B  #' ',(A3)+
        MOVE.B  #%0,D5
        BRA     ORI
        
ORILOP
        MOVE.B  #'O',(A3)+                  Insert O into output
        MOVE.B  #'R',(A3)+                  Insert R into output
        MOVE.B  #'I',(A3)+                  Insert I into output
        MOVE.B  #'.',(A3)+                  Insert . into output
        MOVE.B  #'L',(A3)+                  Insert L into output
        MOVE.B  #' ',(A3)+
        MOVE.B  #%1,D5
        BRA     ORI

ADDB_v1OP
        MOVE.B  #'A',(A3)+                  Insert A into output
        MOVE.B  #'D',(A3)+                  Insert D into output
        MOVE.B  #'D',(A3)+                  Insert D into output
        MOVE.B  #'.',(A3)+                  Insert . into output
        MOVE.B  #'B',(A3)+                  Insert B into output
        MOVE.B  #' ',(A3)+                  
        MOVE.B  #%0,D5
        BRA     ADD_v1

ADDB_v2OP
        MOVE.B  #'A',(A3)+                  Insert A into output
        MOVE.B  #'D',(A3)+                  Insert D into output
        MOVE.B  #'D',(A3)+                  Insert D into output
        MOVE.B  #'.',(A3)+                  Insert . into output
        MOVE.B  #'B',(A3)+                  Insert B into output
        MOVE.B  #' ',(A3)+                  
        MOVE.B  #%0,D5
        BRA     ADD_v2

ADDW_v1OP
        MOVE.B  #'A',(A3)+                  Insert A into output
        MOVE.B  #'D',(A3)+                  Insert D into output
        MOVE.B  #'D',(A3)+                  Insert D into output
        MOVE.B  #'.',(A3)+                  Insert . into output
        MOVE.B  #'W',(A3)+                  Insert W into output
        MOVE.B  #' ',(A3)+                  
        MOVE.B  #%0,D5
        BRA     ADD_v1

ADDW_v2OP
        MOVE.B  #'A',(A3)+                  Insert A into output
        MOVE.B  #'D',(A3)+                  Insert D into output
        MOVE.B  #'D',(A3)+                  Insert D into output
        MOVE.B  #'.',(A3)+                  Insert . into output
        MOVE.B  #'W',(A3)+                  Insert W into output
        MOVE.B  #' ',(A3)+                  
        MOVE.B  #%0,D5
        BRA     ADD_v2

ADDL_v1OP
        MOVE.B  #'A',(A3)+                  Insert A into output
        MOVE.B  #'D',(A3)+                  Insert D into output
        MOVE.B  #'D',(A3)+                  Insert D into output
        MOVE.B  #'.',(A3)+                  Insert . into output
        MOVE.B  #'L',(A3)+                  Insert L into output
        MOVE.B  #' ',(A3)+                  
        MOVE.B  #%1,D5
        BRA     ADD_v1

ADDL_v2OP
        MOVE.B  #'A',(A3)+                  Insert A into output
        MOVE.B  #'D',(A3)+                  Insert D into output
        MOVE.B  #'D',(A3)+                  Insert D into output
        MOVE.B  #'.',(A3)+                  Insert . into output
        MOVE.B  #'L',(A3)+                  Insert L into output
        MOVE.B  #' ',(A3)+                  
        MOVE.B  #%1,D5
        BRA     ADD_v2

ADDAWOP
        MOVE.B  #'A',(A3)+                  Insert A into output
        MOVE.B  #'D',(A3)+                  Insert D into output
        MOVE.B  #'D',(A3)+                  Insert D into output
        MOVE.B  #'A',(A3)+                  Insert A into output
        MOVE.B  #'.',(A3)+                  Insert . into output
        MOVE.B  #'W',(A3)+                  Insert W into output
        MOVE.B  #' ',(A3)+                  
        MOVE.B  #%0,D5
        BRA     ADDA
        
ADDALOP
        MOVE.B  #'A',(A3)+                  Insert A into output
        MOVE.B  #'D',(A3)+                  Insert D into output
        MOVE.B  #'D',(A3)+                  Insert D into output
        MOVE.B  #'A',(A3)+                  Insert A into output
        MOVE.B  #'.',(A3)+                  Insert . into output
        MOVE.B  #'L',(A3)+                  Insert L into output
        MOVE.B  #' ',(A3)+                  
        MOVE.B  #%1,D5
        BRA     ADDA

ADDAOP
        MOVE.B  #'A',(A3)+                  Insert A into output
        MOVE.B  #'D',(A3)+                  Insert D into output
        MOVE.B  #'D',(A3)+                  Insert D into output
        MOVE.B  #'A',(A3)+                  Insert A into output
        MOVE.B  #' ',(A3)+                  
        
        BRA     ADDA

ANDB_v1OP
        MOVE.B  #'A',(A3)+                  Insert A into output
        MOVE.B  #'N',(A3)+                  Insert N into output
        MOVE.B  #'D',(A3)+                  Insert D into output
        MOVE.B  #'.',(A3)+                  Insert . into output
        MOVE.B  #'B',(A3)+                  Insert B into output
        MOVE.B  #' ',(A3)+
        MOVE.B  #%0,D5                  
        BRA     AND_v1
        
ANDB_v2OP
        MOVE.B  #'A',(A3)+                  Insert A into output
        MOVE.B  #'N',(A3)+                  Insert N into output
        MOVE.B  #'D',(A3)+                  Insert D into output
        MOVE.B  #'.',(A3)+                  Insert . into output
        MOVE.B  #'B',(A3)+                  Insert B into output
        MOVE.B  #' ',(A3)+
        MOVE.B  #%0,D5                  
        BRA     AND_v2

ANDW_v1OP
        MOVE.B  #'A',(A3)+                  Insert A into output
        MOVE.B  #'N',(A3)+                  Insert N into output
        MOVE.B  #'D',(A3)+                  Insert D into output
        MOVE.B  #'.',(A3)+                  Insert . into output
        MOVE.B  #'W',(A3)+                  Insert W into output
        MOVE.B  #' ',(A3)+
        MOVE.B  #%0,D5                  
        BRA     AND_v1

ANDW_v2OP
        MOVE.B  #'A',(A3)+                  Insert A into output
        MOVE.B  #'N',(A3)+                  Insert N into output
        MOVE.B  #'D',(A3)+                  Insert D into output
        MOVE.B  #'.',(A3)+                  Insert . into output
        MOVE.B  #'W',(A3)+                  Insert W into output
        MOVE.B  #' ',(A3)+
        MOVE.B  #%0,D5                  
        BRA     AND_v2
        
ANDL_v1OP
        MOVE.B  #'A',(A3)+                  Insert A into output
        MOVE.B  #'N',(A3)+                  Insert N into output
        MOVE.B  #'D',(A3)+                  Insert D into output
        MOVE.B  #'.',(A3)+                  Insert . into output
        MOVE.B  #'L',(A3)+                  Insert L into output
        MOVE.B  #' ',(A3)+
        MOVE.B  #%1,D5                  
        BRA     AND_v1
        
ANDL_v2OP
        MOVE.B  #'A',(A3)+                  Insert A into output
        MOVE.B  #'N',(A3)+                  Insert N into output
        MOVE.B  #'D',(A3)+                  Insert D into output
        MOVE.B  #'.',(A3)+                  Insert . into output
        MOVE.B  #'L',(A3)+                  Insert L into output
        MOVE.B  #' ',(A3)+
        MOVE.B  #%1,D5                  
        BRA     AND_v2
        
MULSOP
        MOVE.B  #'M',(A3)+                  Insert M into output
        MOVE.B  #'U',(A3)+                  Insert U into output
        MOVE.B  #'L',(A3)+                  Insert L into output
        MOVE.B  #'S',(A3)+                  Insert S into output
        MOVE.B  #'.',(A3)+                  Insert . into output
        MOVE.B  #'W',(A3)+                  Insert W into output
        MOVE.B  #' ',(A3)+                  
        MOVE.B  #%0,D5 
        BRA     MULS
        
NEGBOP
        MOVE.B  #'N',(A3)+                  Insert N into output
        MOVE.B  #'E',(A3)+                  Insert E into output
        MOVE.B  #'G',(A3)+                  Insert G into output
        MOVE.B  #'.',(A3)+                  Insert . into output
        MOVE.B  #'B',(A3)+                  Insert B into output
        MOVE.B  #' ',(A3)+                  
        
        BRA     NEG
        
NEGWOP
        MOVE.B  #'N',(A3)+                  Insert N into output
        MOVE.B  #'E',(A3)+                  Insert E into output
        MOVE.B  #'G',(A3)+                  Insert G into output
        MOVE.B  #'.',(A3)+                  Insert . into output
        MOVE.B  #'W',(A3)+                  Insert W into output
        MOVE.B  #' ',(A3)+                  
        MOVE.B  #%0,D5
        BRA     NEG

NEGLOP
        MOVE.B  #'N',(A3)+                  Insert N into output
        MOVE.B  #'E',(A3)+                  Insert E into output
        MOVE.B  #'G',(A3)+                  Insert G into output
        MOVE.B  #'.',(A3)+                  Insert . into output
        MOVE.B  #'L',(A3)+                  Insert L into output
        MOVE.B  #' ',(A3)+                  
        MOVE.B  #%1,D5
        BRA     NEG
        
NOTBOP
        MOVE.B  #'N',(A3)+                  Insert N into output
        MOVE.B  #'O',(A3)+                  Insert O into output
        MOVE.B  #'T',(A3)+                  Insert T into output
        MOVE.B  #'.',(A3)+                  Insert . into output
        MOVE.B  #'B',(A3)+                  Insert B into output
        MOVE.B  #' ',(A3)+                  
        MOVE.B  #%0,D5
        BRA     NOT
        
NOTWOP
        MOVE.B  #'N',(A3)+                  Insert N into output
        MOVE.B  #'O',(A3)+                  Insert O into output
        MOVE.B  #'T',(A3)+                  Insert T into output
        MOVE.B  #'.',(A3)+                  Insert . into output
        MOVE.B  #'W',(A3)+                  Insert W into output
        MOVE.B  #' ',(A3)+                  
        MOVE.B  #%0,D5
        BRA     NOT
        
NOTLOP
        MOVE.B  #'N',(A3)+                  Insert N into output
        MOVE.B  #'O',(A3)+                  Insert O into output
        MOVE.B  #'T',(A3)+                  Insert T into output
        MOVE.B  #'.',(A3)+                  Insert . into output
        MOVE.B  #'L',(A3)+                  Insert L into output
        MOVE.B  #' ',(A3)+                  
        MOVE.B  #%1,D5
        BRA     NOT
        
EORIBOP
        MOVE.B  #'E',(A3)+                  Insert E into output
        MOVE.B  #'O',(A3)+                  Insert O into output
        MOVE.B  #'R',(A3)+                  Insert R into output
        MOVE.B  #'I',(A3)+                  Insert I into output
        MOVE.B  #'.',(A3)+                  Insert . into output
        MOVE.B  #'B',(A3)+                  Insert B into output
        MOVE.B  #' ',(A3)+
        MOVE.B  #%0,D5
        BRA     EORI
        
EORIWOP
        MOVE.B  #'E',(A3)+                  Insert E into output
        MOVE.B  #'O',(A3)+                  Insert O into output
        MOVE.B  #'R',(A3)+                  Insert R into output
        MOVE.B  #'I',(A3)+                  Insert I into output
        MOVE.B  #'.',(A3)+                  Insert . into output
        MOVE.B  #'W',(A3)+                  Insert W into output
        MOVE.B  #' ',(A3)+
        MOVE.B  #%0,D5
        BRA     EORI

EORILOP
        MOVE.B  #'E',(A3)+                  Insert E into output
        MOVE.B  #'O',(A3)+                  Insert O into output
        MOVE.B  #'R',(A3)+                  Insert R into output
        MOVE.B  #'I',(A3)+                  Insert I into output
        MOVE.B  #'.',(A3)+                  Insert . into output
        MOVE.B  #'L',(A3)+                  Insert L into output
        MOVE.B  #' ',(A3)+
        MOVE.B  #%1,D5
        BRA     EORI

SUBIBOP
        MOVE.B  #'S',(A3)+                  Insert S into output
        MOVE.B  #'U',(A3)+                  Insert U into output
        MOVE.B  #'B',(A3)+                  Insert B into output
        MOVE.B  #'I',(A3)+                  Insert I into output
        MOVE.B  #'.',(A3)+                  Insert . into output
        MOVE.B  #'B',(A3)+                  Insert B into output  
        MOVE.B  #' ',(A3)+
        MOVE.B  #%0,D5
        BRA     SUBI
        
SUBIWOP
        MOVE.B  #'S',(A3)+                  Insert S into output
        MOVE.B  #'U',(A3)+                  Insert U into output
        MOVE.B  #'B',(A3)+                  Insert B into output
        MOVE.B  #'I',(A3)+                  Insert I into output
        MOVE.B  #'.',(A3)+                  Insert . into output
        MOVE.B  #'W',(A3)+                  Insert W into output  
        MOVE.B  #' ',(A3)+
        MOVE.B  #%0,D5
        BRA     SUBI
        
SUBILOP
        MOVE.B  #'S',(A3)+                  Insert S into output
        MOVE.B  #'U',(A3)+                  Insert U into output
        MOVE.B  #'B',(A3)+                  Insert B into output
        MOVE.B  #'I',(A3)+                  Insert I into output
        MOVE.B  #'.',(A3)+                  Insert . into output
        MOVE.B  #'L',(A3)+                  Insert L into output  
        MOVE.B  #' ',(A3)+
        MOVE.B  #%1,D5
        BRA     SUBI

SUBB_v1OP
        MOVE.B  #'S',(A3)+                  Insert S into output
        MOVE.B  #'U',(A3)+                  Insert U into output
        MOVE.B  #'B',(A3)+                  Insert B into output  
        MOVE.B  #'.',(A3)+                  Insert . into output
        MOVE.B  #'B',(A3)+                  Insert B into output      
        MOVE.B  #' ',(A3)+                  
        MOVE.B  #%0,D5
        BRA     SUB_v1
        
SUBB_v2OP
        MOVE.B  #'S',(A3)+                  Insert S into output
        MOVE.B  #'U',(A3)+                  Insert U into output
        MOVE.B  #'B',(A3)+                  Insert B into output  
        MOVE.B  #'.',(A3)+                  Insert . into output
        MOVE.B  #'B',(A3)+                  Insert B into output      
        MOVE.B  #' ',(A3)+                  
        MOVE.B  #%0,D5
        BRA     SUB_v2

SUBW_v1OP
        MOVE.B  #'S',(A3)+                  Insert S into output
        MOVE.B  #'U',(A3)+                  Insert U into output
        MOVE.B  #'B',(A3)+                  Insert B into output  
        MOVE.B  #'.',(A3)+                  Insert . into output
        MOVE.B  #'W',(A3)+                  Insert W into output      
        MOVE.B  #' ',(A3)+                  
        MOVE.B  #%0,D5
        BRA     SUB_v1
        
SUBW_v2OP
        MOVE.B  #'S',(A3)+                  Insert S into output
        MOVE.B  #'U',(A3)+                  Insert U into output
        MOVE.B  #'B',(A3)+                  Insert B into output  
        MOVE.B  #'.',(A3)+                  Insert . into output
        MOVE.B  #'W',(A3)+                  Insert W into output      
        MOVE.B  #' ',(A3)+                  
        MOVE.B  #%0,D5
        BRA     SUB_v2
        
SUBL_v1OP
        MOVE.B  #'S',(A3)+                  Insert S into output
        MOVE.B  #'U',(A3)+                  Insert U into output
        MOVE.B  #'B',(A3)+                  Insert B into output  
        MOVE.B  #'.',(A3)+                  Insert . into output
        MOVE.B  #'L',(A3)+                  Insert L into output      
        MOVE.B  #' ',(A3)+                  
        MOVE.B  #%1,D5
        BRA     SUB_v1
        
SUBL_v2OP
        MOVE.B  #'S',(A3)+                  Insert S into output
        MOVE.B  #'U',(A3)+                  Insert U into output
        MOVE.B  #'B',(A3)+                  Insert B into output  
        MOVE.B  #'.',(A3)+                  Insert . into output
        MOVE.B  #'L',(A3)+                  Insert L into output      
        MOVE.B  #' ',(A3)+                  
        MOVE.B  #%1,D5
        BRA     SUB_v2
        
SUBAWOP
        MOVE.B  #'S',(A3)+                  Insert S into output
        MOVE.B  #'U',(A3)+                  Insert U into output
        MOVE.B  #'B',(A3)+                  Insert B into output 
        MOVE.B  #'A',(A3)+                  Insert A into output        
        MOVE.B  #'.',(A3)+                  Insert . into output
        MOVE.B  #'W',(A3)+                  Insert W into output      
        MOVE.B  #' ',(A3)+                  
        MOVE.B  #%0,D5
        BRA     SUBA
        
SUBALOP
        MOVE.B  #'S',(A3)+                  Insert S into output
        MOVE.B  #'U',(A3)+                  Insert U into output
        MOVE.B  #'B',(A3)+                  Insert B into output  
        MOVE.B  #'A',(A3)+                  Insert A into output       
        MOVE.B  #'.',(A3)+                  Insert . into output
        MOVE.B  #'L',(A3)+                  Insert L into output      
        MOVE.B  #' ',(A3)+                  
        MOVE.B  #%1,D5
        BRA     SUBA
        
JSROP
        MOVE.B  #'J',(A3)+                  Insert J into output
        MOVE.B  #'S',(A3)+                  Insert S into output
        MOVE.B  #'R',(A3)+                  Insert R into output        
        MOVE.B  #' ',(A3)+                  
        
        BRA     JSR
        
RTSOP
        MOVE.B  #'R',(A3)+                  Insert R into output
        MOVE.B  #'T',(A3)+                  Insert T into output
        MOVE.B  #'S',(A3)+                  Insert S into output
        MOVE.B  #' ',(A3)+           
        
        BRA     RTS
        
BEQOP
        MOVE.B  #'B',(A3)+                  Insert B into output
        MOVE.B  #'E',(A3)+                  Insert E into output
        MOVE.B  #'Q',(A3)+                  Insert Q into output
        MOVE.B  #' ',(A3)+           
        
        BRA     Bcc
BNEOP
        MOVE.B  #'B',(A3)+                  Insert B into output
        MOVE.B  #'N',(A3)+                  Insert N into output
        MOVE.B  #'E',(A3)+                  Insert E into output
        MOVE.B  #' ',(A3)+           
        
        BRA     Bcc
BLTOP
        MOVE.B  #'B',(A3)+                  Insert B into output
        MOVE.B  #'L',(A3)+                  Insert L into output
        MOVE.B  #'T',(A3)+                  Insert T into output
        MOVE.B  #' ',(A3)+           
        
        BRA     Bcc
BHIOP
        MOVE.B  #'B',(A3)+                  Insert B into output
        MOVE.B  #'H',(A3)+                  Insert H into output
        MOVE.B  #'I',(A3)+                  Insert I into output
        MOVE.B  #' ',(A3)+           
        
        BRA     Bcc
BRAOP
        MOVE.B  #'B',(A3)+                  Insert B into output
        MOVE.B  #'R',(A3)+                  Insert R into output
        MOVE.B  #'A',(A3)+                  Insert A into output
        MOVE.B  #' ',(A3)+           
        
        BRA     BRANCH        
        
MOVEBOP
        MOVE.B  #'M',(A3)+                  Insert M into output
        MOVE.B  #'O',(A3)+                  Insert O into output
        MOVE.B  #'V',(A3)+                  Insert V into output
        MOVE.B  #'E',(A3)+                  Insert E into output
        MOVE.B  #'.',(A3)+                  Insert . into output
        MOVE.B  #'B',(A3)+                  Insert B into output
        MOVE.B  #' ',(A3)+
        MOVE.B  #%0,D5
        
        BRA     MOVE

MOVELOP        
        MOVE.B  #'M',(A3)+                  Insert M into output
        MOVE.B  #'O',(A3)+                  Insert O into output
        MOVE.B  #'V',(A3)+                  Insert V into output
        MOVE.B  #'E',(A3)+                  Insert E into output
        MOVE.B  #'.',(A3)+                  Insert . into output
        MOVE.B  #'L',(A3)+                  Insert L into output
        MOVE.B  #' ',(A3)+
        MOVE.B  #%1,D5
        
        BRA     MOVE
MOVEALOP
        MOVE.B  #'M',(A3)+                  Insert M into output
        MOVE.B  #'O',(A3)+                  Insert O into output
        MOVE.B  #'V',(A3)+                  Insert V into output
        MOVE.B  #'E',(A3)+                  Insert E into output
        MOVE.B  #'A',(A3)+                  Insert A into output
        MOVE.B  #'.',(A3)+                  Insert . into output
        MOVE.B  #'L',(A3)+                  Insert L into output
        MOVE.B  #' ',(A3)+
        MOVE.B  #%1,D5

        BRA     MOVEA
MOVEWOP
        MOVE.B  #'M',(A3)+                  Insert M into output
        MOVE.B  #'O',(A3)+                  Insert O into output
        MOVE.B  #'V',(A3)+                  Insert V into output
        MOVE.B  #'E',(A3)+                  Insert E into output
        MOVE.B  #'.',(A3)+                  Insert . into output
        MOVE.B  #'W',(A3)+                  Insert W into output
        MOVE.B  #' ',(A3)+
        MOVE.B  #%0,D5

        BRA     MOVE

MOVEAWOP
        MOVE.B  #'M',(A3)+                  Insert M into output
        MOVE.B  #'O',(A3)+                  Insert O into output
        MOVE.B  #'V',(A3)+                  Insert V into output
        MOVE.B  #'E',(A3)+                  Insert E into output
        MOVE.B  #'A',(A3)+                  Insert A into output
        MOVE.B  #'.',(A3)+                  Insert . into output
        MOVE.B  #'W',(A3)+                  Insert W into output
        MOVE.B  #' ',(A3)+
        MOVE.B  #%0,D5

        BRA     MOVEA

BTST_v1OP
        MOVE.B  #'B',(A3)+                  Insert B into output
        MOVE.B  #'T',(A3)+                  Insert T into output
        MOVE.B  #'S',(A3)+                  Insert S into output
        MOVE.B  #'T',(A3)+                  Insert T into output
        MOVE.B  #' ',(A3)+

        BRA     BTST_v1

BTST_v2OP
        MOVE.B  #'B',(A3)+                  Insert B into output
        MOVE.B  #'T',(A3)+                  Insert T into output
        MOVE.B  #'S',(A3)+                  Insert S into output
        MOVE.B  #'T',(A3)+                  Insert T into output
        MOVE.B  #' ',(A3)+
        
        BRA     BTST_v2

MOVEM_0OP
        CLR.W   D4
        MOVE.W  D3,D4
        LSL.W   #8,D4
        LSL.W   #1,D4
        LSR.W   #8,D4
        LSR.W   #1,D4
        LSR.W   #6,D4
        CMP.W   #%0,D4
        BEQ     MOVEM_0WOP

        MOVE.B  #'M',(A3)+                  Insert M into output
        MOVE.B  #'O',(A3)+                  Insert O into output
        MOVE.B  #'V',(A3)+                  Insert V into output
        MOVE.B  #'E',(A3)+                  Insert E into output
        MOVE.B  #'M',(A3)+                  Insert M into output
        MOVE.B  #'.',(A3)+                  Insert . into output
        MOVE.B  #'L',(A3)+                  Insert L into output
        MOVE.B  #%1,D5
        BRA     MOVEM_0L
        
MOVEM_1OP
        CLR.W   D4
        MOVE.W  D3,D4
        LSL.W   #8,D4
        LSL.W   #1,D4
        LSR.W   #8,D4
        LSR.W   #1,D4
        LSR.W   #6,D4
        CMP.W   #%0,D4
        BEQ     MOVEM_1WOP

        MOVE.B  #'M',(A3)+                  Insert M into output
        MOVE.B  #'O',(A3)+                  Insert O into output
        MOVE.B  #'V',(A3)+                  Insert V into output
        MOVE.B  #'E',(A3)+                  Insert E into output
        MOVE.B  #'M',(A3)+                  Insert M into output
        MOVE.B  #'.',(A3)+                  Insert . into output
        MOVE.B  #'L',(A3)+                  Insert L into output
        MOVE.B  #%1,D5
        BRA     MOVEM_1L

MOVEM_0WOP
        MOVE.B  #'M',(A3)+                  Insert M into output
        MOVE.B  #'O',(A3)+                  Insert O into output
        MOVE.B  #'V',(A3)+                  Insert V into output
        MOVE.B  #'E',(A3)+                  Insert E into output
        MOVE.B  #'M',(A3)+                  Insert M into output
        MOVE.B  #'.',(A3)+                  Insert . into output
        MOVE.B  #'W',(A3)+                  Insert W into output
        MOVE.B  #%0,D5
        BRA     MOVEM_0W

MOVEM_1WOP
        MOVE.B  #'M',(A3)+                  Insert M into output
        MOVE.B  #'O',(A3)+                  Insert O into output
        MOVE.B  #'V',(A3)+                  Insert V into output
        MOVE.B  #'E',(A3)+                  Insert E into output
        MOVE.B  #'M',(A3)+                  Insert M into output
        MOVE.B  #'.',(A3)+                  Insert . into output
        MOVE.B  #'W',(A3)+                  Insert W into output
        MOVE.B  #%0,D5
        BRA     MOVEM_1W
        
ADDQBOP
        MOVE.B  #'A',(A3)+                  Insert A into output
        MOVE.B  #'D',(A3)+                  Insert D into output
        MOVE.B  #'D',(A3)+                  Insert D into output
        MOVE.B  #'Q',(A3)+                  Insert Q into output
        MOVE.B  #'.',(A3)+                  Insert . into output
        MOVE.B  #'B',(A3)+                  Insert B into output
        MOVE.B  #' ',(A3)+
        MOVE.B  #%0,D5
        BRA     ADDQ

ADDQWOP
        MOVE.B  #'A',(A3)+                  Insert A into output
        MOVE.B  #'D',(A3)+                  Insert D into output
        MOVE.B  #'D',(A3)+                  Insert D into output
        MOVE.B  #'Q',(A3)+                  Insert Q into output
        MOVE.B  #'.',(A3)+                  Insert . into output
        MOVE.B  #'W',(A3)+                  Insert W into output
        MOVE.B  #' ',(A3)+
        MOVE.B  #%0,D5
        BRA     ADDQ

ADDQLOP
        MOVE.B  #'A',(A3)+                  Insert A into output
        MOVE.B  #'D',(A3)+                  Insert D into output
        MOVE.B  #'D',(A3)+                  Insert D into output
        MOVE.B  #'Q',(A3)+                  Insert Q into output
        MOVE.B  #'.',(A3)+                  Insert . into output
        MOVE.B  #'L',(A3)+                  Insert L into output
        MOVE.B  #' ',(A3)+
        MOVE.B  #%1,D5
        BRA     ADDQ
        
LEAOP
        MOVE.B  #'L',(A3)+                  Insert L into output
        MOVE.B  #'E',(A3)+                  Insert E into output
        MOVE.B  #'A',(A3)+                  Insert A into output
        
        BRA     LEA
        
DIVSOP
        MOVE.B  #'D',(A3)+                  Insert D into output
        MOVE.B  #'I',(A3)+                  Insert I into output
        MOVE.B  #'V',(A3)+                  Insert V into output
        MOVE.B  #'S',(A3)+                  Insert S into output
        MOVE.B  #'.',(A3)+                  Insert . into output
        MOVE.B  #'W',(A3)+                  Insert W into output
        MOVE.B  #' ',(A3)+
        MOVE.B  #%0,D5 
        BRA     DIVS
        
EORBOP
        MOVE.B  #'E',(A3)+                  Insert E into output
        MOVE.B  #'O',(A3)+                  Insert O into output
        MOVE.B  #'R',(A3)+                  Insert R into output
        MOVE.B  #'.',(A3)+                  Insert . into output
        MOVE.B  #'B',(A3)+                  Insert B into output
        MOVE.B  #' ',(A3)+
        MOVE.B  #%0,D5
        BRA     EOR
        
EORWOP
        MOVE.B  #'E',(A3)+                  Insert E into output
        MOVE.B  #'O',(A3)+                  Insert O into output
        MOVE.B  #'R',(A3)+                  Insert R into output
        MOVE.B  #'.',(A3)+                  Insert . into output
        MOVE.B  #'W',(A3)+                  Insert W into output
        MOVE.B  #' ',(A3)+
        MOVE.B  #%0,D5
        BRA     EOR
        
EORLOP
        MOVE.B  #'E',(A3)+                  Insert E into output
        MOVE.B  #'O',(A3)+                  Insert O into output
        MOVE.B  #'R',(A3)+                  Insert R into output
        MOVE.B  #'.',(A3)+                  Insert . into output
        MOVE.B  #'L',(A3)+                  Insert L into output
        MOVE.B  #' ',(A3)+
        MOVE.B  #%1,D5
        BRA     EOR
        
CMPIBOP
        MOVE.B  #'C',(A3)+                  Insert C into output
        MOVE.B  #'M',(A3)+                  Insert M into output
        MOVE.B  #'P',(A3)+                  Insert P into output
        MOVE.B  #'I',(A3)+                  Insert I into output
        MOVE.B  #'.',(A3)+                  Insert . into output
        MOVE.B  #'B',(A3)+                  Insert B into output
        MOVE.B  #' ',(A3)+
        MOVE.B  #%0,D5
        BRA     CMPI
        
CMPIWOP
        MOVE.B  #'C',(A3)+                  Insert C into output
        MOVE.B  #'M',(A3)+                  Insert M into output
        MOVE.B  #'P',(A3)+                  Insert P into output
        MOVE.B  #'I',(A3)+                  Insert I into output
        MOVE.B  #'.',(A3)+                  Insert . into output
        MOVE.B  #'W',(A3)+                  Insert W into output
        MOVE.B  #' ',(A3)+
        MOVE.B  #%0,D5
        BRA     CMPI
        
CMPILOP
        MOVE.B  #'C',(A3)+                  Insert C into output
        MOVE.B  #'M',(A3)+                  Insert M into output
        MOVE.B  #'P',(A3)+                  Insert P into output
        MOVE.B  #'I',(A3)+                  Insert I into output
        MOVE.B  #'.',(A3)+                  Insert . into output
        MOVE.B  #'L',(A3)+                  Insert L into output
        MOVE.B  #' ',(A3)+
        MOVE.B  #%1,D5
        BRA     CMPI
        
CMPBOP
        MOVE.B  #'C',(A3)+                  Insert C into output
        MOVE.B  #'M',(A3)+                  Insert M into output
        MOVE.B  #'P',(A3)+                  Insert P into output
        MOVE.B  #'.',(A3)+                  Insert . into output
        MOVE.B  #'B',(A3)+                  Insert B into output
        MOVE.B  #' ',(A3)+
        MOVE.B  #%0,D5
        BRA     CMP
        
CMPWOP
        MOVE.B  #'C',(A3)+                  Insert C into output
        MOVE.B  #'M',(A3)+                  Insert M into output
        MOVE.B  #'P',(A3)+                  Insert P into output
        MOVE.B  #'.',(A3)+                  Insert . into output
        MOVE.B  #'W',(A3)+                  Insert W into output
        MOVE.B  #' ',(A3)+
        MOVE.B  #%0,D5
        BRA     CMP
        
CMPLOP
        MOVE.B  #'C',(A3)+                  Insert C into output
        MOVE.B  #'M',(A3)+                  Insert M into output
        MOVE.B  #'P',(A3)+                  Insert P into output
        MOVE.B  #'.',(A3)+                  Insert . into output
        MOVE.B  #'L',(A3)+                  Insert L into output
        MOVE.B  #' ',(A3)+
        MOVE.B  #%1,D5
        BRA     CMP
        
CMPAWOP
        MOVE.B  #'C',(A3)+                  Insert C into output
        MOVE.B  #'M',(A3)+                  Insert M into output
        MOVE.B  #'P',(A3)+                  Insert P into output
        MOVE.B  #'A',(A3)+                  Insert A into output
        MOVE.B  #'.',(A3)+                  Insert . into output
        MOVE.B  #'W',(A3)+                  Insert W into output
        MOVE.B  #' ',(A3)+
        MOVE.B  #%0,D5
        BRA     CMPA

CMPALOP
        MOVE.B  #'C',(A3)+                  Insert C into output
        MOVE.B  #'M',(A3)+                  Insert M into output
        MOVE.B  #'P',(A3)+                  Insert P into output
        MOVE.B  #'A',(A3)+                  Insert A into output
        MOVE.B  #'.',(A3)+                  Insert . into output
        MOVE.B  #'L',(A3)+                  Insert L into output
        MOVE.B  #' ',(A3)+
        MOVE.B  #%1,D5
        BRA     CMPA

ROL_MEMOP
        MOVE.B  #'R',(A3)+                  Insert R into output
        MOVE.B  #'O',(A3)+                  Insert O into output
        MOVE.B  #'L',(A3)+                  Insert L into output
        MOVE.B  #' ',(A3)+
        BRA     ROd_v1
        
ROR_MEMOP
        MOVE.B  #'R',(A3)+                  Insert R into output
        MOVE.B  #'O',(A3)+                  Insert O into output
        MOVE.B  #'R',(A3)+                  Insert R into output
        MOVE.B  #' ',(A3)+
        BRA     ROd_v1
        
ROLB_REGOP
        MOVE.B  #'R',(A3)+                  Insert R into output
        MOVE.B  #'O',(A3)+                  Insert O into output
        MOVE.B  #'L',(A3)+                  Insert L into output
        MOVE.B  #'.',(A3)+                  Insert . into output
        MOVE.B  #'B',(A3)+                  Insert B into output
        MOVE.B  #' ',(A3)+
        MOVE.B  #%0,D5
        BRA     ROd_v2
ROLW_REGOP
        MOVE.B  #'R',(A3)+                  Insert R into output
        MOVE.B  #'O',(A3)+                  Insert O into output
        MOVE.B  #'L',(A3)+                  Insert L into output
        MOVE.B  #'.',(A3)+                  Insert . into output
        MOVE.B  #'W',(A3)+                  Insert W into output
        MOVE.B  #' ',(A3)+
        MOVE.B  #%0,D5
        BRA     ROd_v2
ROLL_REGOP
        MOVE.B  #'R',(A3)+                  Insert R into output
        MOVE.B  #'O',(A3)+                  Insert O into output
        MOVE.B  #'L',(A3)+                  Insert L into output
        MOVE.B  #'.',(A3)+                  Insert . into output
        MOVE.B  #'L',(A3)+                  Insert L into output
        MOVE.B  #' ',(A3)+
        MOVE.B  #%1,D5
        BRA     ROd_v2
RORB_REGOP
        MOVE.B  #'R',(A3)+                  Insert R into output
        MOVE.B  #'O',(A3)+                  Insert O into output
        MOVE.B  #'R',(A3)+                  Insert R into output
        MOVE.B  #'.',(A3)+                  Insert . into output
        MOVE.B  #'B',(A3)+                  Insert B into output
        MOVE.B  #' ',(A3)+
        MOVE.B  #%0,D5
        BRA     ROd_v2
RORW_REGOP
        MOVE.B  #'R',(A3)+                  Insert R into output
        MOVE.B  #'O',(A3)+                  Insert O into output
        MOVE.B  #'R',(A3)+                  Insert R into output
        MOVE.B  #'.',(A3)+                  Insert . into output
        MOVE.B  #'W',(A3)+                  Insert W into output
        MOVE.B  #' ',(A3)+
        MOVE.B  #%0,D5
        BRA     ROd_v2
RORL_REGOP     
        MOVE.B  #'R',(A3)+                  Insert R into output
        MOVE.B  #'O',(A3)+                  Insert O into output
        MOVE.B  #'R',(A3)+                  Insert R into output
        MOVE.B  #'.',(A3)+                  Insert . into output
        MOVE.B  #'L',(A3)+                  Insert L into output
        MOVE.B  #' ',(A3)+
        MOVE.B  #%1,D5
        BRA     ROd_v2

                ;Determine which  reg op type to call
ROL_REGOP
        CLR.W   D4
        MOVE.W  D3,D4
        LSL.W   #8,D4
        LSR.W   #8,D4
        LSR.W   #6,D4
        CMP.W   #%00,D4
        BEQ     ROLB_REGOP
        CMP.W   #%01,D4
        BEQ     ROLW_REGOP
        CMP.W   #%10,D4
        BEQ     ROLL_REGOP

        BRA     FLAGINVALID
        
                ;Determine which regop type to call
ROR_REGOP
        CLR.W   D4
        MOVE.W  D3,D4
        LSL.W   #8,D4
        LSR.W   #8,D4
        LSR.W   #6,D4
        CMP.W   #%00,D4
        BEQ     RORB_REGOP
        CMP.W   #%01,D4
        BEQ     RORW_REGOP
        CMP.W   #%10,D4
        BEQ     RORL_REGOP

        BRA     FLAGINVALID
        
LSLB_REGOP
        MOVE.B  #'L',(A3)+                  Insert L into output
        MOVE.B  #'S',(A3)+                  Insert S into output
        MOVE.B  #'L',(A3)+                  Insert L into output
        MOVE.B  #'.',(A3)+                  Insert . into output
        MOVE.B  #'B',(A3)+                  Insert B into output
        MOVE.B  #' ',(A3)+
        MOVE.B  #%0,D5
        BRA     LSd_v2
LSLW_REGOP
        MOVE.B  #'L',(A3)+                  Insert L into output
        MOVE.B  #'S',(A3)+                  Insert S into output
        MOVE.B  #'L',(A3)+                  Insert L into output
        MOVE.B  #'.',(A3)+                  Insert . into output
        MOVE.B  #'W',(A3)+                  Insert W into output
        MOVE.B  #' ',(A3)+
        MOVE.B  #%0,D5
        BRA     LSd_v2
LSLL_REGOP
        MOVE.B  #'L',(A3)+                  Insert L into output
        MOVE.B  #'S',(A3)+                  Insert S into output
        MOVE.B  #'L',(A3)+                  Insert L into output
        MOVE.B  #'.',(A3)+                  Insert . into output
        MOVE.B  #'L',(A3)+                  Insert L into output
        MOVE.B  #' ',(A3)+
        MOVE.B  #%1,D5
        BRA     LSd_v2
LSRB_REGOP
        MOVE.B  #'L',(A3)+                  Insert L into output
        MOVE.B  #'S',(A3)+                  Insert S into output
        MOVE.B  #'R',(A3)+                  Insert R into output
        MOVE.B  #'.',(A3)+                  Insert . into output
        MOVE.B  #'B',(A3)+                  Insert B into output
        MOVE.B  #' ',(A3)+
        MOVE.B  #%0,D5
        BRA     LSd_v2
LSRW_REGOP
        MOVE.B  #'L',(A3)+                  Insert L into output
        MOVE.B  #'S',(A3)+                  Insert S into output
        MOVE.B  #'R',(A3)+                  Insert R into output
        MOVE.B  #'.',(A3)+                  Insert . into output
        MOVE.B  #'W',(A3)+                  Insert W into output
        MOVE.B  #' ',(A3)+
        MOVE.B  #%0,D5
        BRA     LSd_v2
LSRL_REGOP     
        MOVE.B  #'L',(A3)+                  Insert L into output
        MOVE.B  #'S',(A3)+                  Insert S into output
        MOVE.B  #'R',(A3)+                  Insert R into output
        MOVE.B  #'.',(A3)+                  Insert . into output
        MOVE.B  #'L',(A3)+                  Insert L into output
        MOVE.B  #' ',(A3)+
        MOVE.B  #%1,D5
        BRA     LSd_v2
        
        ;Determine which ls regop to call
LSL_REGOP
        CLR.W   D4
        MOVE.W  D3,D4
        LSL.W   #8,D4
        LSR.W   #8,D4
        LSR.W   #6,D4
        CMP.W   #%00,D4
        BEQ     LSLB_REGOP
        CMP.W   #%01,D4
        BEQ     LSLW_REGOP
        CMP.W   #%10,D4
        BEQ     LSLL_REGOP

        BRA     FLAGINVALID

        ;Determine which ls regop to call
LSR_REGOP
        CLR.W   D4
        MOVE.W  D3,D4
        LSL.W   #8,D4
        LSR.W   #8,D4
        LSR.W   #6,D4
        CMP.W   #%00,D4
        BEQ     LSRB_REGOP
        CMP.W   #%01,D4
        BEQ     LSRW_REGOP
        CMP.W   #%10,D4
        BEQ     LSRL_REGOP

        BRA     FLAGINVALID
       
LSL_MEMOP
        MOVE.B  #'L',(A3)+                  Insert L into output
        MOVE.B  #'S',(A3)+                  Insert S into output
        MOVE.B  #'L',(A3)+                  Insert L into output
        MOVE.B  #' ',(A3)+
        BRA     ROd_v1
LSR_MEMOP
        MOVE.B  #'L',(A3)+                  Insert L into output
        MOVE.B  #'S',(A3)+                  Insert S into output
        MOVE.B  #'R',(A3)+                  Insert R into output
        MOVE.B  #' ',(A3)+
        BRA     ROd_v1

ASLB_REGOP
        MOVE.B  #'A',(A3)+                  Insert A into output
        MOVE.B  #'S',(A3)+                  Insert S into output
        MOVE.B  #'L',(A3)+                  Insert L into output
        MOVE.B  #'.',(A3)+                  Insert . into output
        MOVE.B  #'B',(A3)+                  Insert B into output
        MOVE.B  #' ',(A3)+
        MOVE.B  #%0,D5
        BRA     LSd_v2
ASLW_REGOP
        MOVE.B  #'A',(A3)+                  Insert A into output
        MOVE.B  #'S',(A3)+                  Insert S into output
        MOVE.B  #'L',(A3)+                  Insert L into output
        MOVE.B  #'.',(A3)+                  Insert . into output
        MOVE.B  #'W',(A3)+                  Insert W into output
        MOVE.B  #' ',(A3)+
        MOVE.B  #%0,D5
        BRA     LSd_v2
ASLL_REGOP
        MOVE.B  #'A',(A3)+                  Insert A into output
        MOVE.B  #'S',(A3)+                  Insert S into output
        MOVE.B  #'L',(A3)+                  Insert L into output
        MOVE.B  #'.',(A3)+                  Insert . into output
        MOVE.B  #'L',(A3)+                  Insert L into output
        MOVE.B  #' ',(A3)+
        MOVE.B  #%1,D5
        BRA     LSd_v2
ASRB_REGOP
        MOVE.B  #'A',(A3)+                  Insert A into output
        MOVE.B  #'S',(A3)+                  Insert S into output
        MOVE.B  #'R',(A3)+                  Insert R into output
        MOVE.B  #'.',(A3)+                  Insert . into output
        MOVE.B  #'B',(A3)+                  Insert B into output
        MOVE.B  #' ',(A3)+
        MOVE.B  #%0,D5
        BRA     LSd_v2
ASRW_REGOP
        MOVE.B  #'A',(A3)+                  Insert A into output
        MOVE.B  #'S',(A3)+                  Insert S into output
        MOVE.B  #'R',(A3)+                  Insert R into output
        MOVE.B  #'.',(A3)+                  Insert . into output
        MOVE.B  #'W',(A3)+                  Insert W into output
        MOVE.B  #' ',(A3)+
        MOVE.B  #%0,D5
        BRA     LSd_v2
ASRL_REGOP     
        MOVE.B  #'A',(A3)+                  Insert A into output
        MOVE.B  #'S',(A3)+                  Insert S into output
        MOVE.B  #'R',(A3)+                  Insert R into output
        MOVE.B  #'.',(A3)+                  Insert . into output
        MOVE.B  #'L',(A3)+                  Insert L into output
        MOVE.B  #' ',(A3)+
        MOVE.B  #%1,D5
        BRA     LSd_v2
        
        ;Determine ASL regops
ASL_REGOP
        CLR.W   D4
        MOVE.W  D3,D4
        LSL.W   #8,D4
        LSR.W   #8,D4
        LSR.W   #6,D4
        CMP.W   #%00,D4
        BEQ     ASLB_REGOP
        CMP.W   #%01,D4
        BEQ     ASLW_REGOP
        CMP.W   #%10,D4
        BEQ     ASLL_REGOP

        BRA     FLAGINVALID

        ;Determine ASR regops
ASR_REGOP
        CLR.W   D4
        MOVE.W  D3,D4
        LSL.W   #8,D4
        LSR.W   #8,D4
        LSR.W   #6,D4
        CMP.W   #%00,D4
        BEQ     ASRB_REGOP
        CMP.W   #%01,D4
        BEQ     ASRW_REGOP
        CMP.W   #%10,D4
        BEQ     ASRL_REGOP

        BRA     FLAGINVALID

ASL_MEMOP
        MOVE.B  #'A',(A3)+                  Insert A into output
        MOVE.B  #'S',(A3)+                  Insert S into output
        MOVE.B  #'L',(A3)+                  Insert L into output
        MOVE.B  #' ',(A3)+                  Insert . into output
        BRA     ASd_v1

ASR_MEMOP
        MOVE.B  #'A',(A3)+                  Insert A into output
        MOVE.B  #'S',(A3)+                  Insert S into output
        MOVE.B  #'R',(A3)+                  Insert R into output
        MOVE.B  #' ',(A3)+                  Insert . into output
        BRA     ASd_v1
        
FLAGINVALID
        MOVE.L  #$FF,D7     *put in the bad flag value
        RTS
        

************************EFFECTIVE ADDRESS**************************
MOVE
    LEA     addressing_mode,A4  *load the jump table for addressing_mode
    
    CLR.L   D6          *ZERO OUT D6
    CLR.L   D7          *ZERO OUT D7
    MOVE.L  D3,D6       *COPY DOWN THE WHOLE 16BIT BINARY TO D6
    MOVE.L  D3,D7       *COPY DOWN THE WHOLE 16BIT BINARY TO D7
    *getting the source mode and register
    LSL.W   #8,D6       *SHIFT TO THE LEFT 8
    LSL.W   #2,D6       *SHIFT TO THE LEFT 2
    LSR.W   #8,D6       *SHIFT TO THE RIGHT 8
    LSR.W   #5,D6       *SHIFT TO THE RIGHT 5
    
    LSL.W   #8,D7       *SHIFT TO THE LEFT 8
    LSL.W   #5,D7       *SHIFT TO THE LEFT 5
    LSR.W   #8,D7       *SHIFT TO THE RIGHT 8
    LSR.W   #5,D7       *SHIFT TO THE RIGHT 5
    
    MULU    #6,D6       *FORM OFFSET - SEE ADDENDUM
    JSR     0(A4,D6)    *JUMP INDIRECT WITH INDEX
    
    MOVE.B  #' ',(A3)+
    MOVE.B  #',',(A3)+
    
    CLR.L   D6          *ZERO OUT D6
    CLR.L   D7          *ZERO OUT D7
    MOVE.L  D3,D6       *COPY DOWN THE WHOLE 16BIT BINARY TO D6
    MOVE.L  D3,D7       *COPY DOWN THE WHOLE 16BIT BINARY TO D7
    
    *getting the destination mode and register
    LSL.W   #7,D6       *SHIFT TO THE LEFT 7
    LSR.W   #8,D6       *SHIFT TO THE RIGHT 8
    LSR.W   #5,D6       *SHIFT TO THE RIGHT 5

    LSL.W   #4,D7       *SHIFT TO THE LEFT 4
    LSR.W   #8,D7       *SHIFT TO THE RIGHT 8
    LSR.W   #5,D7       *SHIFT TO THE RIGHT 5
    
    *error checking
    CMP.B   #%001,D6    
    BEQ     FLAGINVALID
    CMP.B   #%111,D6
    BNE     whatever
    CMP.B   #%100,D7
    BEQ     FLAGINVALID
     
whatever     
    MULU    #6,D6       *FORM OFFSET - SEE ADDENDUM
    JSR     0(A4,D6)    *JUMP INDIRECT WITH INDEX
    
    RTS
    

    
MOVEA
    LEA     addressing_mode,A4  *load the jump table for addressing_mode
    
    CLR.L   D6          *ZERO OUT D6
    CLR.L   D7          *ZERO OUT D7
    MOVE.L  D3,D6       *COPY DOWN THE WHOLE 16BIT BINARY TO D6
    MOVE.L  D3,D7       *COPY DOWN THE WHOLE 16BIT BINARY TO D7
    *getting the source mode and register
    LSL.W   #8,D6       *SHIFT TO THE LEFT 8
    LSL.W   #2,D6       *SHIFT TO THE LEFT 2
    LSR.W   #8,D6       *SHIFT TO THE RIGHT 8
    LSR.W   #5,D6       *SHIFT TO THE RIGHT 5
    
    LSL.W   #8,D7       *SHIFT TO THE LEFT 8
    LSL.W   #5,D7       *SHIFT TO THE LEFT 5
    LSR.W   #8,D7       *SHIFT TO THE RIGHT 8
    LSR.W   #5,D7       *SHIFT TO THE RIGHT 5
    
    CMP.B #%101,D6 
    BEQ FLAGINVALID 
    CMP.B #%110,D6 
    BEQ FLAGINVALID 
    
    MULU    #6,D6       *FORM OFFSET - SEE ADDENDUM
    JSR     0(A4,D6)    *JUMP INDIRECT WITH INDEX
    
    MOVE.B  #' ',(A3)+
    MOVE.B  #',',(A3)+
    
    CLR.L   D6          *ZERO OUT D6
    CLR.L   D7          *ZERO OUT D7
    MOVE.L  D3,D7       *COPY DOWN THE WHOLE 16BIT BINARY TO D7
    *getting the destination mode and register
    MOVE.B  #%001,D6    *DESTINATION MODE IS 001 FOR ADDRESS

    LSL.W   #4,D7       *SHIFT TO THE LEFT 4
    LSR.W   #8,D7       *SHIFT TO THE RIGHT 8
    LSR.W   #5,D7       *SHIFT TO THE RIGHT 5
    
    MULU    #6,D6       *FORM OFFSET - SEE ADDENDUM
    JSR     0(A4,D6)    *JUMP INDIRECT WITH INDEX
    
    RTS
        

MOVEM_0W    *Register to Memory - Word size
    LEA     addressing_mode,A4  *load the jump table for addressing_mode
    CLR.L   D6          *ZERO OUT D6
    CLR.L   D7          *ZERO OUT D7
    MOVE.L  D3,D6       *COPY DOWN THE WHOLE 16BIT BINARY TO D6
    MOVE.L  D3,D7       *COPY DOWN THE WHOLE 16BIT BINARY TO D7
    
    ANDI.W  #%0000000000111000,D6
    LSR.W   #3,D6
    ANDI.W  #%0000000000000111,D7
    
    *error checking
    CMP.B #%000,D6 
    BEQ FLAGINVALID 
    CMP.B #%001,D6 
    BEQ FLAGINVALID 
    CMP.B #%011,D6 
    BEQ FLAGINVALID
    CMP.B #%101,D6 
    BEQ FLAGINVALID 
    CMP.B #%110,D6 
    BEQ FLAGINVALID 
    CMP.B #%111,D6 
    BNE   HELP112
    CMP.B   #%100,D7
    BEQ     FLAGINVALID
    *getting the source
HELP112    
    MOVE.B  #'#',(A3)+
    JSR     getWord
    
    MOVE.B  #' ',(A3)+
    MOVE.B  #',',(A3)+
    
    *getting the destination
    CLR.L   D6          *ZERO OUT D6
    CLR.L   D7          *ZERO OUT D7
    MOVE.L  D3,D6       *COPY DOWN THE WHOLE 16BIT BINARY TO D6
    MOVE.L  D3,D7       *COPY DOWN THE WHOLE 16BIT BINARY TO D7
    
    ANDI.W  #%0000000000111000,D6
    LSR.W   #3,D6
    ANDI.W  #%0000000000000111,D7
    
    *error checking
    CMP.B #%000,D6 
    BEQ FLAGINVALID 
    CMP.B #%001,D6 
    BEQ FLAGINVALID 
    CMP.B #%011,D6 
    BEQ FLAGINVALID
    CMP.B #%101,D6 
    BEQ FLAGINVALID 
    CMP.B #%110,D6 
    BEQ FLAGINVALID 
     
   
    MULU    #6,D6
    JSR     0(A4,D6)
    
    RTS
    
MOVEM_0L    *Register to Memory - Long size
    LEA     addressing_mode,A4  *load the jump table for addressing_mode
    
    CLR.L   D6          *ZERO OUT D6
    CLR.L   D7          *ZERO OUT D7
    MOVE.L  D3,D6       *COPY DOWN THE WHOLE 16BIT BINARY TO D6
    MOVE.L  D3,D7       *COPY DOWN THE WHOLE 16BIT BINARY TO D7
    
    ANDI.W  #%0000000000111000,D6
    LSR.W   #3,D6
    ANDI.W  #%0000000000000111,D7
    
    *error checking
    CMP.B #%000,D6 
    BEQ FLAGINVALID 
    CMP.B #%001,D6 
    BEQ FLAGINVALID 
    CMP.B #%011,D6 
    BEQ FLAGINVALID 
    CMP.B #%101,D6 
    BEQ FLAGINVALID 
    CMP.B #%110,D6 
    BEQ FLAGINVALID
    CMP.B #%111,D6 
    BNE   HELP113
    CMP.B   #%100,D7
    BEQ     FLAGINVALID
    *getting the source
HELP113    
    MOVE.B  #'#',(A3)+
    JSR     getWord
    
    MOVE.B  #',',(A3)+
    MOVE.B  #' ',(A3)+
    
    *getting the destination
    CLR.L   D6          *ZERO OUT D6
    CLR.L   D7          *ZERO OUT D7
    MOVE.L  D3,D6       *COPY DOWN THE WHOLE 16BIT BINARY TO D6
    MOVE.L  D3,D7       *COPY DOWN THE WHOLE 16BIT BINARY TO D7
    
    ANDI.W  #%0000000000111000,D6
    LSR.W   #3,D6
    ANDI.W  #%0000000000000111,D7
    
    *error checking
    CMP.B #%000,D6 
    BEQ FLAGINVALID 
    CMP.B #%001,D6 
    BEQ FLAGINVALID 
    CMP.B #%011,D6 
    BEQ FLAGINVALID 
    CMP.B #%101,D6 
    BEQ FLAGINVALID 
    CMP.B #%110,D6 
    BEQ FLAGINVALID
    CMP.B #%111,D6 
    BNE   HELP111
    CMP.B   #%100,D7
    BEQ     FLAGINVALID 

HELP111    
    MULU    #6,D6
    JSR     0(A4,D6)
    
    RTS
    
    
MOVEM_1W    *Memory to Register - Word size
    LEA     addressing_mode,A4  *load the jump table for addressing_mode
    
    *getting the source
    CLR.L   D6          *ZERO OUT D6
    CLR.L   D7          *ZERO OUT D7
    MOVE.L  D3,D6       *COPY DOWN THE WHOLE 16BIT BINARY TO D6
    MOVE.L  D3,D7       *COPY DOWN THE WHOLE 16BIT BINARY TO D7
    
    ANDI.W  #%0000000000111000,D6
    LSR.W   #3,D6
    ANDI.W  #%0000000000000111,D7
    
    *error checking
    CMP.B #%000,D6 
    BEQ FLAGINVALID 
    CMP.B #%001,D6 
    BEQ FLAGINVALID 
    CMP.B #%100,D6 
    BEQ FLAGINVALID
    CMP.B #%101,D6 
    BEQ FLAGINVALID 
    CMP.B #%110,D6 
    BEQ FLAGINVALID
    CMP.B #%111,D6 
    BNE   HELP114
    CMP.B   #%100,D7
    BEQ     FLAGINVALID

HELP114    
    MULU    #6,D6
    JSR     0(A4,D6)
    
    MOVE.B  #',',(A3)+
    MOVE.B  #' ',(A3)+
    *getting the destination
    MOVE.B  #'#',(A3)+            
    JSR     getWord
    
    RTS
    
MOVEM_1L    *Memory to Register - Long size
    LEA     addressing_mode,A4  *load the jump table for addressing_mode
    
    *getting the source     
    CLR.L   D6          *ZERO OUT D6
    CLR.L   D7          *ZERO OUT D7
    MOVE.L  D3,D6       *COPY DOWN THE WHOLE 16BIT BINARY TO D6
    MOVE.L  D3,D7       *COPY DOWN THE WHOLE 16BIT BINARY TO D7
    
    ANDI.W  #%0000000000111000,D6
    LSR.W   #3,D6
    ANDI.W  #%0000000000000111,D7
    
    *error checking
    CMP.B #%000,D6 
    BEQ FLAGINVALID 
    CMP.B #%001,D6 
    BEQ FLAGINVALID 
    CMP.B #%100,D6 
    BEQ FLAGINVALID 
    CMP.B #%101,D6 
    BEQ FLAGINVALID 
    CMP.B #%110,D6 
    BEQ FLAGINVALID
    CMP.B #%111,D6 
    BNE   HELP115
    CMP.B   #%100,D7
    BEQ     FLAGINVALID
    
HELP115    
    MULU    #6,D6
    JSR     0(A4,D6)
    
    MOVE.B  #',',(A3)+
    MOVE.B  #' ',(A3)+
    
    *getting the destination    
    MOVE.B  #'#',(A3)+
    JSR     getWord
    
    RTS    
          
ADD_v1  *SOURCE IS <EA>
    LEA     addressing_mode,A4  *load the jump table for addressing_mode
    
    CLR.L   D6          *ZERO OUT D6
    CLR.L   D7          *ZERO OUT D7
    MOVE.L  D3,D6       *COPY DOWN THE WHOLE 16BIT BINARY TO D6
    MOVE.L  D3,D7       *COPY DOWN THE WHOLE 16BIT BINARY TO D7
    *getting the source mode and register
    LSL.W   #8,D6       *SHIFT TO THE LEFT 8
    LSL.W   #2,D6       *SHIFT TO THE LEFT 2
    LSR.W   #8,D6       *SHIFT TO THE RIGHT 8
    LSR.W   #5,D6       *SHIFT TO THE RIGHT 5
    
    LSL.W   #8,D7       *SHIFT TO THE LEFT 8
    LSL.W   #5,D7       *SHIFT TO THE LEFT 5
    LSR.W   #8,D7       *SHIFT TO THE RIGHT 8
    LSR.W   #5,D7       *SHIFT TO THE RIGHT 5
    
    MULU    #6,D6       *FORM OFFSET - SEE ADDENDUM
    JSR     0(A4,D6)    *JUMP INDIRECT WITH INDEX
    
    MOVE.B  #',',(A3)+
    MOVE.B  #' ',(A3)+
    
    CLR.L   D6          *ZERO OUT D6
    CLR.L   D7          *ZERO OUT D7
    *MOVE.L  D3,D6       *COPY DOWN THE WHOLE 16BIT BINARY TO D6
    MOVE.L  D3,D7       *COPY DOWN THE WHOLE 16BIT BINARY TO D7
    
    *getting the destination mode and register
    MOVE.B  #%000,D6    *DESTINATION IS A DATA REGISTER

    LSL.W   #4,D7       *SHIFT TO THE LEFT 4
    LSR.W   #8,D7       *SHIFT TO THE RIGHT 8
    LSR.W   #5,D7       *SHIFT TO THE RIGHT 5
    
     
    MULU    #6,D6       *FORM OFFSET - SEE ADDENDUM
    JSR     0(A4,D6)    *JUMP INDIRECT WITH INDEX
    
    RTS

    
ADD_v2      *SOURCE IS Dn
    LEA     addressing_mode,A4  *load the jump table for addressing_mode
    
    CLR.L   D6          *ZERO OUT D6
    CLR.L   D7          *ZERO OUT D7
    *MOVE.L  D3,D6       *COPY DOWN THE WHOLE 16BIT BINARY TO D6
    MOVE.L  D3,D7       *COPY DOWN THE WHOLE 16BIT BINARY TO D7
    *getting the source mode and register
    MOVE.B  #%000,D6    *SOURCE IS A DATA REGISTER
    
    LSL.W   #4,D7       *SHIFT TO THE LEFT 4
    LSR.W   #8,D7       *SHIFT TO THE RIGHT 8
    LSR.W   #5,D7       *SHIFT TO THE RIGHT 5
    
    MULU    #6,D6       *FORM OFFSET - SEE ADDENDUM
    JSR     0(A4,D6)    *JUMP INDIRECT WITH INDEX
    
    MOVE.B  #' ',(A3)+
    MOVE.B  #',',(A3)+
    
    CLR.L   D6          *ZERO OUT D6
    CLR.L   D7          *ZERO OUT D7
    MOVE.L  D3,D6       *COPY DOWN THE WHOLE 16BIT BINARY TO D6
    MOVE.L  D3,D7       *COPY DOWN THE WHOLE 16BIT BINARY TO D7
    
    *getting the destination mode and register
    LSL.W   #8,D6       *SHIFT TO THE LEFT 8
    LSL.W   #2,D6       *SHIFT TO THE LEFT 2
    LSR.W   #8,D6       *SHIFT TO THE RIGHT 8
    LSR.W   #5,D6       *SHIFT TO THE RIGHT 5

    LSL.W   #8,D7       *SHIFT TO THE LEFT 8
    LSL.W   #5,D7       *SHIFT TO THE LEFT 5
    LSR.W   #8,D7       *SHIFT TO THE RIGHT 8
    LSR.W   #5,D7       *SHIFT TO THE RIGHT 5
    
    *error checking
    CMP.B   #%000,D6
    BEQ     FLAGINVALID 
    CMP.B   #%001,D6
    BEQ     FLAGINVALID 
    CMP.B   #%111,D6
    BNE     continue
    CMP.B   #%100,D7
    BEQ     FLAGINVALID 
    
continue
    MULU    #6,D6       *FORM OFFSET - SEE ADDENDUM
    JSR     0(A4,D6)    *JUMP INDIRECT WITH INDEX
    
    RTS

ADDA
    LEA     addressing_mode,A4  *load the jump table for addressing_mode
    
    CLR.L   D6          *ZERO OUT D6
    CLR.L   D7          *ZERO OUT D7
    MOVE.L  D3,D6       *COPY DOWN THE WHOLE 16BIT BINARY TO D6
    MOVE.L  D3,D7       *COPY DOWN THE WHOLE 16BIT BINARY TO D7
    *getting the source mode and register
    LSL.W   #8,D6       *SHIFT TO THE LEFT 8
    LSL.W   #2,D6       *SHIFT TO THE LEFT 2
    LSR.W   #8,D6       *SHIFT TO THE RIGHT 8
    LSR.W   #5,D6       *SHIFT TO THE RIGHT 5
    
    LSL.W   #8,D7       *SHIFT TO THE LEFT 8
    LSL.W   #5,D7       *SHIFT TO THE LEFT 5
    LSR.W   #8,D7       *SHIFT TO THE RIGHT 8
    LSR.W   #5,D7       *SHIFT TO THE RIGHT 5
    
    MULU    #6,D6       *FORM OFFSET - SEE ADDENDUM
    JSR     0(A4,D6)    *JUMP INDIRECT WITH INDEX
    
    MOVE.B  #' ',(A3)+
    MOVE.B  #',',(A3)+
    
    CLR.L   D6          *ZERO OUT D6
    CLR.L   D7          *ZERO OUT D7
    *MOVE.L  D3,D6       *COPY DOWN THE WHOLE 16BIT BINARY TO D6
    MOVE.L  D3,D7       *COPY DOWN THE WHOLE 16BIT BINARY TO D7
    
    *getting the destination mode and register
    MOVE.B  #%001,D6    *DESTINATION IS 001 FOR ADDRESS

    LSL.W   #4,D7       *SHIFT TO THE LEFT 4
    LSR.W   #8,D7       *SHIFT TO THE RIGHT 8
    LSR.W   #5,D7       *SHIFT TO THE RIGHT 5
    
     
    MULU    #6,D6       *FORM OFFSET - SEE ADDENDUM
    JSR     0(A4,D6)    *JUMP INDIRECT WITH INDEX
    
    RTS
    
ADDQ
    LEA     addressing_mode,A4  *load the jump table for addressing_mode
    
    CLR.L   D6          *ZERO OUT D6
    CLR.L   D7          *ZERO OUT D7
    MOVE.L  D3,D6       *COPY DOWN THE WHOLE 16BIT BINARY TO D6
    MOVE.L  D3,D7       *COPY DOWN THE WHOLE 16BIT BINARY TO D7
    *getting the source mode and register
    
    LSL.W   #4,D7       *SHIFT TO THE LEFT 4
    LSR.W   #8,D7       *SHIFT TO THE RIGHT 8
    LSR.W   #5,D7       *SHIFT TO THE RIGHT 5
    
    MOVE.B  #'#',(A3)+
    LEA     data_mode,A2    *load the jump table for data
    MULU    #6,D7
    JSR     0(A2,D7)
    
    MOVE.B  #' ',(A3)+
    MOVE.B  #',',(A3)+
    
    CLR.L   D6          *ZERO OUT D6
    CLR.L   D7          *ZERO OUT D7
    MOVE.L  D3,D6       *COPY DOWN THE WHOLE 16BIT BINARY TO D6
    MOVE.L  D3,D7       *COPY DOWN THE WHOLE 16BIT BINARY TO D7
    
    *getting the destination mode and register
    LSL.W   #8,D6       *SHIFT TO THE LEFT 8
    LSL.W   #2,D6       =SHIFT TO THE LEFT 2
    LSR.W   #8,D6       *SHIFT TO THE RIGHT 8
    LSR.W   #5,D6       *SHIFT TO THE RIGHT 5

    LSL.W   #8,D7       *SHIFT TO THE LEFT 8
    LSL.W   #5,D7       *SHIFT TO THE LEFT 5
    LSR.W   #8,D7       *SHIFT TO THE RIGHT 8
    LSR.W   #5,D7       *SHIFT TO THE RIGHT 5
    
    *error checking
    CMP.B   #%111,D6
    BNE     continue2
    CMP.B   #%100,D7
    BEQ     FLAGINVALID 

continue2     
    MULU    #6,D6       *FORM OFFSET - SEE ADDENDUM
    JSR     0(A4,D6)    *JUMP INDIRECT WITH INDEX
    
    RTS
    
SUB_v2      *SOURCE is <EA>
    LEA     addressing_mode,A4  *load the jump table for addressing_mode
    
    CLR.L   D6          *ZERO OUT D6
    CLR.L   D7          *ZERO OUT D7
    ;MOVE.L  D3,D6       *COPY DOWN THE WHOLE 16BIT BINARY TO D6
    MOVE.L  D3,D7       *COPY DOWN THE WHOLE 16BIT BINARY TO D7
    *getting the source mode and register
    MOVE.B  #%000,D6    *SOURCE MODE IS A DATA REGISTER
    
    LSL.W   #4,D7       *SHIFT TO THE LEFT 4
    LSR.W   #8,D7       *SHIFT TO THE RIGHT 8
    LSR.W   #5,D7       *SHIFT TO THE RIGHT 5
    
    MULU    #6,D6       *FORM OFFSET - SEE ADDENDUM
    JSR     0(A4,D6)    *JUMP INDIRECT WITH INDEX
    
    MOVE.B  #' ',(A3)+
    MOVE.B  #',',(A3)+
    
    CLR.L   D6          *ZERO OUT D6
    CLR.L   D7          *ZERO OUT D7
    MOVE.L  D3,D6       *COPY DOWN THE WHOLE 16BIT BINARY TO D6
    MOVE.L  D3,D7       *COPY DOWN THE WHOLE 16BIT BINARY TO D7
    
    *getting the destination mode and register
    LSL.W   #8,D6       *SHIFT TO THE LEFT 8
    LSL.W   #2,D6       *SHIFT TO THE LEFT 2
    LSR.W   #8,D6       *SHIFT TO THE RIGHT 8
    LSR.W   #5,D6       *SHIFT TO THE RIGHT 5

    LSL.W   #8,D7       *SHIFT TO THE LEFT 8
    LSL.W   #5,D7       *SHIFT TO THE LEFT 5
    LSR.W   #8,D7       *SHIFT TO THE RIGHT 8
    LSR.W   #5,D7       *SHIFT TO THE RIGHT 5
    
    *error checking
    CMP.B   #%000,D6
    BEQ     FLAGINVALID 
    CMP.B   #%001,D6
    BEQ     FLAGINVALID 
    CMP.B   #%111,D6
    BNE     continue3
    CMP.B   #%100,D7
    BEQ     FLAGINVALID 
    
continue3
    MULU    #6,D6       *FORM OFFSET - SEE ADDENDUM
    JSR     0(A4,D6)    *JUMP INDIRECT WITH INDEX
    
    RTS


SUB_v1      *Source is Dn
    LEA     addressing_mode,A4  *load the jump table for addressing_mode
    
    CLR.L   D6          *ZERO OUT D6
    CLR.L   D7          *ZERO OUT D7
    MOVE.L  D3,D6       *COPY DOWN THE WHOLE 16BIT BINARY TO D6
    MOVE.L  D3,D7       *COPY DOWN THE WHOLE 16BIT BINARY TO D7
    *getting the source mode and register
    LSL.W   #8,D6       *SHIFT TO THE LEFT 8
    LSL.W   #2,D6       *SHIFT TO THE LEFT 2
    LSR.W   #8,D6       *SHIFT TO THE RIGHT 8
    LSR.W   #5,D6       *SHIFT TO THE RIGHT 5
    
    LSL.W   #8,D7       *SHIFT TO THE LEFT 8
    LSL.W   #5,D7       *SHIFT TO THE LEFT 5
    LSR.W   #8,D7       *SHIFT TO THE RIGHT 8
    LSR.W   #5,D7       *SHIFT TO THE RIGHT 5
    
    MULU    #6,D6       *FORM OFFSET - SEE ADDENDUM
    JSR     0(A4,D6)    *JUMP INDIRECT WITH INDEX
    
    MOVE.B  #' ',(A3)+
    MOVE.B  #',',(A3)+
    
    CLR.L   D6          *ZERO OUT D6
    CLR.L   D7          *ZERO OUT D7
    ;MOVE.L  D3,D6       *COPY DOWN THE WHOLE 16BIT BINARY TO D6
    MOVE.L  D3,D7       *COPY DOWN THE WHOLE 16BIT BINARY TO D7
    
    *getting the destination mode and register
    MOVE.B  #%000,D6    *DESTINATION MODE IS A DATA REGISTER

    LSL.W   #4,D7       *SHIFT TO THE LEFT 4
    LSR.W   #8,D7       *SHIFT TO THE RIGHT 8
    LSR.W   #5,D7       *SHIFT TO THE RIGHT 5
    
     
    MULU    #6,D6       *FORM OFFSET - SEE ADDENDUM
    JSR     0(A4,D6)    *JUMP INDIRECT WITH INDEX
    
    RTS


SUBA
    LEA     addressing_mode,A4  *load the jump table for addressing_mode
    
    CLR.L   D6          *ZERO OUT D6
    CLR.L   D7          *ZERO OUT D7
    MOVE.L  D3,D6       *COPY DOWN THE WHOLE 16BIT BINARY TO D6
    MOVE.L  D3,D7       *COPY DOWN THE WHOLE 16BIT BINARY TO D7
    *getting the source mode and register
    LSL.W   #8,D6       *SHIFT TO THE LEFT 8
    LSL.W   #2,D6       *SHIFT TO THE LEFT 2
    LSR.W   #8,D6       *SHIFT TO THE RIGHT 8
    LSR.W   #5,D6       *SHIFT TO THE RIGHT 5
    
    LSL.W   #8,D7       *SHIFT TO THE LEFT 8
    LSL.W   #5,D7       *SHIFT TO THE LEFT 5
    LSR.W   #8,D7       *SHIFT TO THE RIGHT 8
    LSR.W   #5,D7       *SHIFT TO THE RIGHT 5
    
    MULU    #6,D6       *FORM OFFSET - SEE ADDENDUM
    JSR     0(A4,D6)    *JUMP INDIRECT WITH INDEX
    
    MOVE.B  #' ',(A3)+
    MOVE.B  #',',(A3)+
    
    CLR.L   D6          *ZERO OUT D6
    CLR.L   D7          *ZERO OUT D7
    *MOVE.L  D3,D6       *COPY DOWN THE WHOLE 16BIT BINARY TO D6
    MOVE.L  D3,D7       *COPY DOWN THE WHOLE 16BIT BINARY TO D7
    
    *getting the destination mode and register
    MOVE.B  #%001,D6    *DESTINATION IS 001 FOR ADDRESS

    LSL.W   #4,D7       *SHIFT TO THE LEFT 4
    LSR.W   #8,D7       *SHIFT TO THE RIGHT 8
    LSR.W   #5,D7       *SHIFT TO THE RIGHT 5
    
     
    MULU    #6,D6       *FORM OFFSET - SEE ADDENDUM
    JSR     0(A4,D6)    *JUMP INDIRECT WITH INDEX
    
    RTS


SUBI
    LEA     addressing_mode,A4  *load the jump table for addressing_mode
    
    CLR.L   D6          *ZERO OUT D6
    CLR.L   D7          *ZERO OUT D7
    MOVE.L  D3,D6       *COPY DOWN THE WHOLE 16BIT BINARY TO D6
    MOVE.L  D3,D7       *COPY DOWN THE WHOLE 16BIT BINARY TO D7
    *getting the size of the immediate data
    LSL.W   #8,D6
    LSR.W   #8,D6
    LSR.W   #6,D6

    MOVE.B  #'#',(A3)+
    CMP.B   #%10,D6
    BEQ     comehere    
    
    JSR     getWord
    BRA     mydest

comehere
    JSR     getLong    
mydest    
    MOVE.B  #' ',(A3)+
    MOVE.B  #',',(A3)+
    
    CLR.L   D6          *ZERO OUT D6
    CLR.L   D7          *ZERO OUT D7
    MOVE.L  D3,D6       *COPY DOWN THE WHOLE 16BIT BINARY TO D6
    MOVE.L  D3,D7       *COPY DOWN THE WHOLE 16BIT BINARY TO D7
    
    *getting the destination mode and register
    LSL.W   #8,D6       *SHIFT TO THE LEFT 8
    LSL.W   #2,D6       *SHIFT TO THE LEFT 2
    LSR.W   #8,D6       *SHIFT TO THE RIGHT 8
    LSR.W   #5,D6       *SHIFT TO THE RIGHT 5
    
    LSL.W   #8,D7       *SHIFT TO THE LEFT 8
    LSL.W   #5,D7       *SHIFT TO THE LEFT 5
    LSR.W   #8,D7       *SHIFT TO THE RIGHT 8
    LSR.W   #5,D7       *SHIFT TO THE RIGHT 5
    
    *error checking 
    CMP.B   #%001,D6
    BEQ     FLAGINVALID 
    CMP.B   #%111,D6
    BNE     continue4
    CMP.B   #%100,D7
    BEQ     FLAGINVALID 

continue4     
    MULU    #6,D6       *FORM OFFSET - SEE ADDENDUM
    JSR     0(A4,D6)    *JUMP INDIRECT WITH INDEX
    
    RTS

MULS
    LEA     addressing_mode,A4  *load the jump table for addressing_mode
    
    CLR.L   D6          *ZERO OUT D6
    CLR.L   D7          *ZERO OUT D7
    MOVE.L  D3,D6       *COPY DOWN THE WHOLE 16BIT BINARY TO D6
    MOVE.L  D3,D7       *COPY DOWN THE WHOLE 16BIT BINARY TO D7
    *getting the source mode and register
    LSL.W   #8,D6       *SHIFT TO THE LEFT 8
    LSL.W   #2,D6       *SHIFT TO THE LEFT 2
    LSR.W   #8,D6       *SHIFT TO THE RIGHT 8
    LSR.W   #5,D6       *SHIFT TO THE RIGHT 5
    
    LSL.W   #8,D7       *SHIFT TO THE LEFT 8
    LSL.W   #5,D7       *SHIFT TO THE LEFT 5
    LSR.W   #8,D7       *SHIFT TO THE RIGHT 8
    LSR.W   #5,D7       *SHIFT TO THE RIGHT 5
    
    *error checking
    CMP.B   #%001,D6    
    BEQ     FLAGINVALID 
    
    MULU    #6,D6       *FORM OFFSET - SEE ADDENDUM
    JSR     0(A4,D6)    *JUMP INDIRECT WITH INDEX
    
    MOVE.B  #' ',(A3)+
    MOVE.B  #',',(A3)+
    
    CLR.L   D6          *ZERO OUT D6
    CLR.L   D7          *ZERO OUT D7
    ;MOVE.L  D3,D6       *COPY DOWN THE WHOLE 16BIT BINARY TO D6
    MOVE.L  D3,D7       *COPY DOWN THE WHOLE 16BIT BINARY TO D7
    
    *getting the destination mode and register
    MOVE.B  #%000,D6    *DESTINATION MODE IS A DATA REGISTER
    
    LSL.W   #4,D7       *SHIFT TO THE LEFT 4
    LSR.W   #8,D7       *SHIFT TO THE RIGHT 8
    LSR.W   #5,D7       *SHIFT TO THE RIGHT 5
    
    MULU    #6,D6       *FORM OFFSET - SEE ADDENDUM
    JSR     0(A4,D6)    *JUMP INDIRECT WITH INDEX
    
    RTS
    
DIVS
    LEA     addressing_mode,A4  *load the jump table for addressing_mode
    
    CLR.L   D6          *ZERO OUT D6
    CLR.L   D7          *ZERO OUT D7
    MOVE.L  D3,D6       *COPY DOWN THE WHOLE 16BIT BINARY TO D6
    MOVE.L  D3,D7       *COPY DOWN THE WHOLE 16BIT BINARY TO D7
    *getting the source mode and register
    LSL.W   #8,D6       *SHIFT TO THE LEFT 8
    LSL.W   #2,D6       *SHIFT TO THE LEFT 2
    LSR.W   #8,D6       *SHIFT TO THE RIGHT 8
    LSR.W   #5,D6       *SHIFT TO THE RIGHT 5
    
    LSL.W   #8,D7       *SHIFT TO THE LEFT 8
    LSL.W   #5,D7       *SHIFT TO THE LEFT 5
    LSR.W   #8,D7       *SHIFT TO THE RIGHT 8
    LSR.W   #5,D7       *SHIFT TO THE RIGHT 5
    
    *error checking
    CMP.B   #%001,D6    
    BEQ     FLAGINVALID 

    MULU    #6,D6       *FORM OFFSET - SEE ADDENDUM
    JSR     0(A4,D6)    *JUMP INDIRECT WITH INDEX
    
    MOVE.B  #' ',(A3)+
    MOVE.B  #',',(A3)+
    
    CLR.L   D6          *ZERO OUT D6
    CLR.L   D7          *ZERO OUT D7
    ;MOVE.L  D3,D6       *COPY DOWN THE WHOLE 16BIT BINARY TO D6
    MOVE.L  D3,D7       *COPY DOWN THE WHOLE 16BIT BINARY TO D7
    
    *getting the destination mode and register
    MOVE.B  #%000,D6    *DESTINATION MODE IS A DATA REGISTER
    
    LSL.W   #4,D7       *SHIFT TO THE LEFT 4
    LSR.W   #8,D7       *SHIFT TO THE RIGHT 8
    LSR.W   #5,D7       *SHIFT TO THE RIGHT 5
    
    MULU    #6,D6       *FORM OFFSET - SEE ADDENDUM
    JSR     0(A4,D6)    *JUMP INDIRECT WITH INDEX
    
    RTS

LEA
    LEA     addressing_mode,A4  *load the jump table for addressing_mode
    
    CLR.L   D6          *ZERO OUT D6
    CLR.L   D7          *ZERO OUT D7
    MOVE.L  D3,D6       *COPY DOWN THE WHOLE 16BIT BINARY TO D6
    MOVE.L  D3,D7       *COPY DOWN THE WHOLE 16BIT BINARY TO D7
    *getting the source mode and register
    LSL.W   #8,D6       *SHIFT TO THE LEFT 8
    LSL.W   #2,D6       *SHIFT TO THE LEFT 2
    LSR.W   #8,D6       *SHIFT TO THE RIGHT 8
    LSR.W   #5,D6       *SHIFT TO THE RIGHT 5
    
    LSL.W   #8,D7       *SHIFT TO THE LEFT 8
    LSL.W   #5,D7       *SHIFT TO THE LEFT 5
    LSR.W   #8,D7       *SHIFT TO THE RIGHT 8
    LSR.W   #5,D7       *SHIFT TO THE RIGHT 5
    
    *error checking
    CMP.B   #%001,D6    
    BEQ     FLAGINVALID 
    CMP.B   #%000,D6    
    BEQ     FLAGINVALID 
    CMP.B   #%011,D6    
    BEQ     FLAGINVALID 
    CMP.B   #%100,D6    
    BEQ     FLAGINVALID 
    CMP.B   #%111,D6
    BNE     continue5
    CMP.B   #%100,D7
    BEQ     FLAGINVALID 

continue5        
    MULU    #6,D6       *FORM OFFSET - SEE ADDENDUM
    JSR     0(A4,D6)    *JUMP INDIRECT WITH INDEX
    
    MOVE.B  #' ',(A3)+
    MOVE.B  #',',(A3)+
    
    CLR.L   D6          *ZERO OUT D6
    CLR.L   D7          *ZERO OUT D7
    ;MOVE.L  D3,D6       *COPY DOWN THE WHOLE 16BIT BINARY TO D6
    MOVE.L  D3,D7       *COPY DOWN THE WHOLE 16BIT BINARY TO D7
    
    *getting the destination mode and register
    MOVE.B  #%001,D6    *DESTINATION MODE IS AN ADDRESS REGISTER
    
    LSL.W   #4,D7       *SHIFT TO THE LEFT 4
    LSR.W   #8,D7       *SHIFT TO THE RIGHT 8
    LSR.W   #5,D7       *SHIFT TO THE RIGHT 5
    
    MULU    #6,D6       *FORM OFFSET - SEE ADDENDUM
    JSR     0(A4,D6)    *JUMP INDIRECT WITH INDEX
    
    RTS
    
AND_v1      *SOURCE IS <EA>
    LEA     addressing_mode,A4  *load the jump table for addressing_mode
    
    CLR.L   D6          *ZERO OUT D6
    CLR.L   D7          *ZERO OUT D7
    MOVE.L  D3,D6       *COPY DOWN THE WHOLE 16BIT BINARY TO D6
    MOVE.L  D3,D7       *COPY DOWN THE WHOLE 16BIT BINARY TO D7
    *getting the source mode and register
    LSL.W   #8,D6       *SHIFT TO THE LEFT 8
    LSL.W   #2,D6       *SHIFT TO THE LEFT 2
    LSR.W   #8,D6       *SHIFT TO THE RIGHT 8
    LSR.W   #5,D6       *SHIFT TO THE RIGHT 5
    
    LSL.W   #8,D7       *SHIFT TO THE LEFT 8
    LSL.W   #5,D7       *SHIFT TO THE LEFT 5
    LSR.W   #8,D7       *SHIFT TO THE RIGHT 8
    LSR.W   #5,D7       *SHIFT TO THE RIGHT 5
    
    *error checking
    CMP.B   #%001,D6
    BEQ     FLAGINVALID 
    
    MULU    #6,D6       *FORM OFFSET - SEE ADDENDUM
    JSR     0(A4,D6)    *JUMP INDIRECT WITH INDEX
    
    MOVE.B  #' ',(A3)+
    MOVE.B  #',',(A3)+
    
    CLR.L   D6          *ZERO OUT D6
    CLR.L   D7          *ZERO OUT D7
    ;MOVE.L  D3,D6       *COPY DOWN THE WHOLE 16BIT BINARY TO D6
    MOVE.L  D3,D7       *COPY DOWN THE WHOLE 16BIT BINARY TO D7
    
    *getting the destination mode and register
    MOVE.B  #%000,D6    *DESTINATION MODE IS A DATA REGISTER

    LSL.W   #4,D7       *SHIFT TO THE LEFT 4
    LSR.W   #8,D7       *SHIFT TO THE RIGHT 8
    LSR.W   #5,D7       *SHIFT TO THE RIGHT 5
    
     
    MULU    #6,D6       *FORM OFFSET - SEE ADDENDUM
    JSR     0(A4,D6)    *JUMP INDIRECT WITH INDEX
    
    RTS


AND_v2      *SOURCE IS Dn
    LEA     addressing_mode,A4  *load the jump table for addressing_mode
    
    CLR.L   D6          *ZERO OUT D6
    CLR.L   D7          *ZERO OUT D7
    ;MOVE.L  D3,D6       *COPY DOWN THE WHOLE 16BIT BINARY TO D6
    MOVE.L  D3,D7       *COPY DOWN THE WHOLE 16BIT BINARY TO D7
    *getting the source mode and register
    MOVE.B  #%000,D6    *SOURCE MODE IS A DATA REGISTER
    
    LSL.W   #4,D7       *SHIFT TO THE LEFT 4
    LSR.W   #8,D7       *SHIFT TO THE RIGHT 8
    LSR.W   #5,D7       *SHIFT TO THE RIGHT 5
    
    MULU    #6,D6       *FORM OFFSET - SEE ADDENDUM
    JSR     0(A4,D6)    *JUMP INDIRECT WITH INDEX
    
    MOVE.B  #' ',(A3)+
    MOVE.B  #',',(A3)+
    
    CLR.L   D6          *ZERO OUT D6
    CLR.L   D7          *ZERO OUT D7
    MOVE.L  D3,D6       *COPY DOWN THE WHOLE 16BIT BINARY TO D6
    MOVE.L  D3,D7       *COPY DOWN THE WHOLE 16BIT BINARY TO D7
    
    *getting the destination mode and register
    LSL.W   #8,D6       *SHIFT TO THE LEFT 8
    LSL.W   #2,D6       *SHIFT TO THE LEFT 2
    LSR.W   #8,D6       *SHIFT TO THE RIGHT 8
    LSR.W   #5,D6       *SHIFT TO THE RIGHT 5

    LSL.W   #8,D7       *SHIFT TO THE LEFT 8
    LSL.W   #5,D7       *SHIFT TO THE LEFT 5
    LSR.W   #8,D7       *SHIFT TO THE RIGHT 8
    LSR.W   #5,D7       *SHIFT TO THE RIGHT 5
    
    *error checking
    CMP.B   #%000,D6
    BEQ     FLAGINVALID 
    CMP.B   #%001,D6
    BEQ     FLAGINVALID 
    CMP.B   #%111,D6
    BNE     continue6
    CMP.B   #%100,D7
    BEQ     FLAGINVALID 
    
continue6
    MULU    #6,D6       *FORM OFFSET - SEE ADDENDUM
    JSR     0(A4,D6)    *JUMP INDIRECT WITH INDEX
    
    RTS

ORI
    LEA     addressing_mode,A4  *load the jump table for addressing_mode
    
    CLR.L   D6          *ZERO OUT D6
    CLR.L   D7          *ZERO OUT D7
    MOVE.L  D3,D6       *COPY DOWN THE WHOLE 16BIT BINARY TO D6
    MOVE.L  D3,D7       *COPY DOWN THE WHOLE 16BIT BINARY TO D7
    *getting the size of the immediate data
    LSL.W   #8,D6
    LSR.W   #8,D6
    LSR.W   #6,D6

    MOVE.B  #'#',(A3)+
    CMP.B   #%10,D6
    BEQ     gohere
    
    JSR     getWord
    BRA     jump

gohere    
    JSR     getLong
    
jump    
    MOVE.B  #' ',(A3)+
    MOVE.B  #',',(A3)+
    
    CLR.L   D6          *ZERO OUT D6
    CLR.L   D7          *ZERO OUT D7
    MOVE.L  D3,D6       *COPY DOWN THE WHOLE 16BIT BINARY TO D6
    MOVE.L  D3,D7       *COPY DOWN THE WHOLE 16BIT BINARY TO D7
    
    *getting the destination mode and register
    LSL.W   #8,D6       *SHIFT TO THE LEFT 8
    LSL.W   #2,D6       *SHIFT TO THE LEFT 2
    LSR.W   #8,D6       *SHIFT TO THE RIGHT 8
    LSR.W   #5,D6       *SHIFT TO THE RIGHT 5
    
    LSL.W   #8,D7       *SHIFT TO THE LEFT 8
    LSL.W   #5,D7       *SHIFT TO THE LEFT 5
    LSR.W   #8,D7       *SHIFT TO THE RIGHT 8
    LSR.W   #5,D7       *SHIFT TO THE RIGHT 5
    
    *error checking 
    CMP.B   #%001,D6
    BEQ     FLAGINVALID 
    CMP.B   #%111,D6
    BNE     continue7
    CMP.B   #%100,D7
    BEQ     FLAGINVALID 

continue7     
    MULU    #6,D6       *FORM OFFSET - SEE ADDENDUM
    JSR     0(A4,D6)    *JUMP INDIRECT WITH INDEX
    
    RTS
            
NEG
    LEA     addressing_mode,A4  *load the jump table for addressing_mode
    
    *this one does not have source address. Syntax: NEG  <EA>
    
    CLR.L   D6          *ZERO OUT D6
    CLR.L   D7          *ZERO OUT D7
    MOVE.L  D3,D6       *COPY DOWN THE WHOLE 16BIT BINARY TO D6
    MOVE.L  D3,D7       *COPY DOWN THE WHOLE 16BIT BINARY TO D7
    
    *getting the destination mode and register
    LSL.W   #8,D6       *SHIFT TO THE LEFT 8
    LSL.W   #2,D6       *SHIFT TO THE LEFT 2
    LSR.W   #8,D6       *SHIFT TO THE RIGHT 8
    LSR.W   #5,D6       *SHIFT TO THE RIGHT 5
    
    LSL.W   #8,D7       *SHIFT TO THE LEFT 8
    LSL.W   #5,D7       *SHIFT TO THE LEFT 5
    LSR.W   #8,D7       *SHIFT TO THE RIGHT 8
    LSR.W   #5,D7       *SHIFT TO THE RIGHT 5
    
    *error checking 
    CMP.B   #%001,D6
    BEQ     FLAGINVALID 
    CMP.B   #%111,D6
    BNE     continue8
    CMP.B   #%100,D7
    BEQ     FLAGINVALID 

continue8     
    MULU    #6,D6       *FORM OFFSET - SEE ADDENDUM
    JSR     0(A4,D6)    *JUMP INDIRECT WITH INDEX
    
    RTS

EOR
    LEA     addressing_mode,A4  *load the jump table for addressing_mode
    
    CLR.L   D6          *ZERO OUT D6
    CLR.L   D7          *ZERO OUT D7
    ;MOVE.L  D3,D6       *COPY DOWN THE WHOLE 16BIT BINARY TO D6
    MOVE.L  D3,D7       *COPY DOWN THE WHOLE 16BIT BINARY TO D7
    *getting the size of the immediate data
    MOVE.B  #%000,D6    *SOURCE IS A DATA REGISTER
    
    LSL.W   #4,D7
    LSR.W   #8,D7
    LSR.W   #5,D7
    
    MULU    #6,D6
    JSR     0(A4,D6)
    
    MOVE.B  #' ',(A3)+
    MOVE.B  #',',(A3)+
    
    CLR.L   D6          *ZERO OUT D6
    CLR.L   D7          *ZERO OUT D7
    MOVE.L  D3,D6       *COPY DOWN THE WHOLE 16BIT BINARY TO D6
    MOVE.L  D3,D7       *COPY DOWN THE WHOLE 16BIT BINARY TO D7
    
    *getting the destination mode and register
    LSL.W   #8,D6       *SHIFT TO THE LEFT 8
    LSL.W   #2,D6       *SHIFT TO THE LEFT 2
    LSR.W   #8,D6       *SHIFT TO THE RIGHT 8
    LSR.W   #5,D6       *SHIFT TO THE RIGHT 5
    
    LSL.W   #8,D7       *SHIFT TO THE LEFT 8
    LSL.W   #5,D7       *SHIFT TO THE LEFT 5
    LSR.W   #8,D7       *SHIFT TO THE RIGHT 8
    LSR.W   #5,D7       *SHIFT TO THE RIGHT 5
    
    *error checking 
    CMP.B   #%001,D6
    BEQ     FLAGINVALID 
    CMP.B   #%111,D6
    BNE     continue10
    CMP.B   #%100,D7
    BEQ     FLAGINVALID 

continue10     
    MULU    #6,D6       *FORM OFFSET - SEE ADDENDUM
    JSR     0(A4,D6)    *JUMP INDIRECT WITH INDEX
    
    RTS

    
EORI
    LEA     addressing_mode,A4  *load the jump table for addressing_mode
    
    CLR.L   D6          *ZERO OUT D6
    CLR.L   D7          *ZERO OUT D7
    MOVE.L  D3,D6       *COPY DOWN THE WHOLE 16BIT BINARY TO D6
    MOVE.L  D3,D7       *COPY DOWN THE WHOLE 16BIT BINARY TO D7
    *getting the size of the immediate data
    LSL.W   #8,D6
    LSR.W   #8,D6
    LSR.W   #6,D6

    MOVE.B  #'#',(A3)+
    CMP.B   #%10,D6
    BEQ     jmp1
    CMP.B   #%00,D6
    BEQ     jmp2
    CMP.B   #%01,D6
    BEQ     jmp2

jmp2    JSR     getWord
        BRA     jmp3
    
jmp1    JSR     getLong
    
jmp3    
    MOVE.B  #' ',(A3)+
    MOVE.B  #',',(A3)+
    
    CLR.L   D6          *ZERO OUT D6
    CLR.L   D7          *ZERO OUT D7
    MOVE.L  D3,D6       *COPY DOWN THE WHOLE 16BIT BINARY TO D6
    MOVE.L  D3,D7       *COPY DOWN THE WHOLE 16BIT BINARY TO D7
    
    *getting the destination mode and register
    LSL.W   #8,D6       *SHIFT TO THE LEFT 8
    LSL.W   #2,D6       *SHIFT TO THE LEFT 2
    LSR.W   #8,D6       *SHIFT TO THE RIGHT 8
    LSR.W   #5,D6       *SHIFT TO THE RIGHT 5
    
    LSL.W   #8,D7       *SHIFT TO THE LEFT 8
    LSL.W   #5,D7       *SHIFT TO THE LEFT 5
    LSR.W   #8,D7       *SHIFT TO THE RIGHT 8
    LSR.W   #5,D7       *SHIFT TO THE RIGHT 5
    
    *error checking 
    CMP.B   #%001,D6
    BEQ     FLAGINVALID 
    CMP.B   #%111,D6
    BNE     continue9
    CMP.B   #%100,D7
    BEQ     FLAGINVALID 

continue9     
    MULU    #6,D6       *FORM OFFSET - SEE ADDENDUM
    JSR     0(A4,D6)    *JUMP INDIRECT WITH INDEX
    
    RTS
    
NOT
    LEA     addressing_mode,A4  *load the jump table for addressing_mode
    
    *this one does not have source address. Syntax: NEG  <EA>
    
    CLR.L   D6          *ZERO OUT D6
    CLR.L   D7          *ZERO OUT D7
    MOVE.L  D3,D6       *COPY DOWN THE WHOLE 16BIT BINARY TO D6
    MOVE.L  D3,D7       *COPY DOWN THE WHOLE 16BIT BINARY TO D7
    
    *getting the destination mode and register
    LSL.W   #8,D6       *SHIFT TO THE LEFT 8
    LSL.W   #2,D6       *SHIFT TO THE LEFT 2
    LSR.W   #8,D6       *SHIFT TO THE RIGHT 8
    LSR.W   #5,D6       *SHIFT TO THE RIGHT 5
    
    LSL.W   #8,D7       *SHIFT TO THE LEFT 8
    LSL.W   #5,D7       *SHIFT TO THE LEFT 5
    LSR.W   #8,D7       *SHIFT TO THE RIGHT 8
    LSR.W   #5,D7       *SHIFT TO THE RIGHT 5
    
    *error checking 
    CMP.B   #%001,D6
    BEQ     FLAGINVALID 
    CMP.B   #%111,D6
    BNE     continue11
    CMP.B   #%100,D7
    BEQ     FLAGINVALID 

continue11     
    MULU    #6,D6       *FORM OFFSET - SEE ADDENDUM
    JSR     0(A4,D6)    *JUMP INDIRECT WITH INDEX
    
    RTS

LSd_v1  *MEMORY SHIFT
    LEA     addressing_mode,A4  *load the jump table for addressing_mode
    
    *this one does not have source address. Syntax: LSd  <EA>
    
    CLR.L   D6          *ZERO OUT D6
    CLR.L   D7          *ZERO OUT D7
    MOVE.L  D3,D6       *COPY DOWN THE WHOLE 16BIT BINARY TO D6
    MOVE.L  D3,D7       *COPY DOWN THE WHOLE 16BIT BINARY TO D7
    
    *getting the destination mode and register
    LSL.W   #8,D6       *SHIFT TO THE LEFT 8
    LSL.W   #2,D6       *SHIFT TO THE LEFT 2
    LSR.W   #8,D6       *SHIFT TO THE RIGHT 8
    LSR.W   #5,D6       *SHIFT TO THE RIGHT 5
    
    LSL.W   #8,D7       *SHIFT TO THE LEFT 8
    LSL.W   #5,D7       *SHIFT TO THE LEFT 5
    LSR.W   #8,D7       *SHIFT TO THE RIGHT 8
    LSR.W   #5,D7       *SHIFT TO THE RIGHT 5
    
    *error checking 
    CMP.B   #%001,D6
    BEQ     FLAGINVALID 
    CMP.B   #%000,D6
    BEQ     FLAGINVALID 
    CMP.B   #%111,D6
    BNE     continue12
    CMP.B   #%100,D7
    BEQ     FLAGINVALID 

continue12     
    MULU    #6,D6       *FORM OFFSET - SEE ADDENDUM
    JSR     0(A4,D6)    *JUMP INDIRECT WITH INDEX
    
    RTS
    
LSd_v2  *REGISTER SHIFT
    LEA     addressing_mode,A4  *load the jump table for addressing_mode
    
    CLR.L   D6          *ZERO OUT D6
    CLR.L   D7          *ZERO OUT D7
    MOVE.L  D3,D6       *COPY DOWN THE WHOLE 16BIT BINARY TO D6
    MOVE.L  D3,D7       *COPY DOWN THE WHOLE 16BIT BINARY TO D7
    *getting the source mode and register
    LSL.W   #8,D6
    LSL.W   #2,D6
    LSR.W   #8,D6
    LSR.W   #7,D6
    LSL.W   #4,D7
    LSR.W   #8,D7
    LSR.W   #5,D7
    
    CMP.B   #%0,D6
    BNE     continue13
    MOVE.B  #'#',(A3)+
    LEA     data_mode,A2    *load the jump table for data
    MULU    #6,D7
    JSR     0(A2,D7)
    BRA     skip
    
continue13
    CLR.L   D6          *ZERO OUT D6
    MOVE.B  #%000,D6
    MULU    #6,D6
    JSR     0(A4,D6)    
skip    
    MOVE.B  #' ',(A3)+
    MOVE.B  #',',(A3)+
    
    CLR.L   D6          *ZERO OUT D6
    CLR.L   D7          *ZERO OUT D7
    *MOVE.L  D3,D6       *COPY DOWN THE WHOLE 16BIT BINARY TO D6
    MOVE.L  D3,D7       *COPY DOWN THE WHOLE 16BIT BINARY TO D7
    
    *getting the destination mode and register
    MOVE.B  #%000,D6    *MODE IS A DATA REGISTER
    
    LSL.W   #8,D7       *SHIFT TO THE LEFT 8
    LSL.W   #5,D7       *SHIFT TO THE LEFT 5
    LSR.W   #8,D7       *SHIFT TO THE RIGHT 8
    LSR.W   #5,D7       *SHIFT TO THE RIGHT 5
    
    MULU    #6,D6       *FORM OFFSET - SEE ADDENDUM
    JSR     0(A4,D6)    *JUMP INDIRECT WITH INDEX
    
    RTS
    
ASd_v1  *MEMORY SHIFT
    LEA     addressing_mode,A4  *load the jump table for addressing_mode
    
    *this one does not have source address. Syntax: ASd  <EA>
    
    CLR.L   D6          *ZERO OUT D6
    CLR.L   D7          *ZERO OUT D7
    MOVE.L  D3,D6       *COPY DOWN THE WHOLE 16BIT BINARY TO D6
    MOVE.L  D3,D7       *COPY DOWN THE WHOLE 16BIT BINARY TO D7
    
    *getting the destination mode and register
    LSL.W   #8,D6       *SHIFT TO THE LEFT 8
    LSL.W   #2,D6       *SHIFT TO THE LEFT 2
    LSR.W   #8,D6       *SHIFT TO THE RIGHT 8
    LSR.W   #5,D6       *SHIFT TO THE RIGHT 5
    
    LSL.W   #8,D7       *SHIFT TO THE LEFT 8
    LSL.W   #5,D7       *SHIFT TO THE LEFT 5
    LSR.W   #8,D7       *SHIFT TO THE RIGHT 8
    LSR.W   #5,D7       *SHIFT TO THE RIGHT 5
    
    *error checking 
    CMP.B   #%001,D6
    BEQ     FLAGINVALID 
    CMP.B   #%000,D6
    BEQ     FLAGINVALID 
    CMP.B   #%111,D6
    BNE     continue14
    CMP.B   #%100,D7
    BEQ     FLAGINVALID 

continue14     
    MULU    #6,D6       *FORM OFFSET - SEE ADDENDUM
    JSR     0(A4,D6)    *JUMP INDIRECT WITH INDEX
    
    RTS
    
ASd_v2  *REGISTER SHIFT
    LEA     addressing_mode,A4  *load the jump table for addressing_mode
    
    CLR.L   D6          *ZERO OUT D6
    CLR.L   D7          *ZERO OUT D7
    MOVE.L  D3,D6       *COPY DOWN THE WHOLE 16BIT BINARY TO D6
    MOVE.L  D3,D7       *COPY DOWN THE WHOLE 16BIT BINARY TO D7
    *getting the source mode and register
    LSL.W   #8,D6
    LSL.W   #2,D6
    LSR.W   #8,D6
    LSR.W   #7,D6
    LSL.W   #4,D7
    LSR.W   #8,D7
    LSR.W   #5,D7
    
    CMP.B   #%0,D6
    BNE     continue15
    MOVE.B  #'#',(A3)+
    LEA     data_mode,A2    *load the jump table for data
    MULU    #6,D7
    JSR     0(A2,D7)
    BRA     skip1
    
continue15
    CLR.L   D6          *ZERO OUT D6
    MOVE.B  #%000,D6
    MULU    #6,D6
    JSR     0(A4,D6)    
skip1    
    MOVE.B  #' ',(A3)+
    MOVE.B  #',',(A3)+
    
    CLR.L   D6          *ZERO OUT D6
    CLR.L   D7          *ZERO OUT D7
    ;MOVE.L  D3,D6       *COPY DOWN THE WHOLE 16BIT BINARY TO D6
    MOVE.L  D3,D7       *COPY DOWN THE WHOLE 16BIT BINARY TO D7
    
    *getting the destination mode and register
    MOVE.B  #%000,D6    *MODE IS A DATA REGISTER
    
    LSL.W   #8,D7       *SHIFT TO THE LEFT 8
    LSL.W   #5,D7       *SHIFT TO THE LEFT 5
    LSR.W   #8,D7       *SHIFT TO THE RIGHT 8
    LSR.W   #5,D7       *SHIFT TO THE RIGHT 5
    
    MULU    #6,D6       *FORM OFFSET - SEE ADDENDUM
    JSR     0(A4,D6)    *JUMP INDIRECT WITH INDEX
    
    RTS
    
ROd_v1  *MEMORY SHIFT
    LEA     addressing_mode,A4  *load the jump table for addressing_mode
    
    *this one does not have source address. Syntax: ASd  <EA>
    
    CLR.L   D6          *ZERO OUT D6
    CLR.L   D7          *ZERO OUT D7
    MOVE.L  D3,D6       *COPY DOWN THE WHOLE 16BIT BINARY TO D6
    MOVE.L  D3,D7       *COPY DOWN THE WHOLE 16BIT BINARY TO D7
    
    *getting the destination mode and register
    LSL.W   #8,D6       *SHIFT TO THE LEFT 8
    LSL.W   #2,D6       *SHIFT TO THE LEFT 2
    LSR.W   #8,D6       *SHIFT TO THE RIGHT 8
    LSR.W   #5,D6       *SHIFT TO THE RIGHT 5
    
    LSL.W   #8,D7       *SHIFT TO THE LEFT 8
    LSL.W   #5,D7       *SHIFT TO THE LEFT 5
    LSR.W   #8,D7       *SHIFT TO THE RIGHT 8
    LSR.W   #5,D7       *SHIFT TO THE RIGHT 5
    
    *error checking 
    CMP.B   #%001,D6
    BEQ     FLAGINVALID 
    CMP.B   #%000,D6
    BEQ     FLAGINVALID 
    CMP.B   #%111,D6
    BNE     continue16
    CMP.B   #%100,D7
    BEQ     FLAGINVALID 

continue16     
    MULU    #6,D6       *FORM OFFSET - SEE ADDENDUM
    JSR     0(A4,D6)    *JUMP INDIRECT WITH INDEX
    
    RTS
    
ROd_v2  *REGISTER SHIFT
    LEA     addressing_mode,A4  *load the jump table for addressing_mode
    
    CLR.L   D6          *ZERO OUT D6
    CLR.L   D7          *ZERO OUT D7
    MOVE.L  D3,D6       *COPY DOWN THE WHOLE 16BIT BINARY TO D6
    MOVE.L  D3,D7       *COPY DOWN THE WHOLE 16BIT BINARY TO D7
    *getting the source mode and register
    LSL.W   #8,D6
    LSL.W   #2,D6
    LSR.W   #8,D6
    LSR.W   #7,D6
    LSL.W   #4,D7
    LSR.W   #8,D7
    LSR.W   #5,D7
    
    CMP.B   #%0,D6
    BNE     continue17
    MOVE.B  #'#',(A3)+
    LEA     data_mode,A2    *load the jump table for data
    MULU    #6,D7
    JSR     0(A2,D7)
    BRA     skip2
    
continue17
    CLR.L   D6          *ZERO OUT D6
    MOVE.B  #%000,D6
    MULU    #6,D6
    JSR     0(A4,D6)    
skip2    
    MOVE.B  #' ',(A3)+
    MOVE.B  #',',(A3)+
    
    CLR.L   D6          *ZERO OUT D6
    CLR.L   D7          *ZERO OUT D7
    ;MOVE.L  D3,D6       *COPY DOWN THE WHOLE 16BIT BINARY TO D6
    MOVE.L  D3,D7       *COPY DOWN THE WHOLE 16BIT BINARY TO D7
    
    *getting the destination mode and register
    MOVE.B  #%000,D6    *MODE IS A DATA REGISTER
    
    LSL.W   #8,D7       *SHIFT TO THE LEFT 8
    LSL.W   #5,D7       *SHIFT TO THE LEFT 5
    LSR.W   #8,D7       *SHIFT TO THE RIGHT 8
    LSR.W   #5,D7       *SHIFT TO THE RIGHT 5
    
    MULU    #6,D6       *FORM OFFSET - SEE ADDENDUM
    JSR     0(A4,D6)    *JUMP INDIRECT WITH INDEX
    
    RTS

BTST_v1     *Dn -> <EA>
    LEA     addressing_mode,A4  *load the jump table for addressing_mode
    
    CLR.L   D6          *ZERO OUT D6
    CLR.L   D7          *ZERO OUT D7
    ;MOVE.L  D3,D6       *COPY DOWN THE WHOLE 16BIT BINARY TO D6
    MOVE.L  D3,D7       *COPY DOWN THE WHOLE 16BIT BINARY TO D7
    *getting the source mode and register
    MOVE.B  #%000,D6
    
    LSL.W   #4,D7       *SHIFT TO THE LEFT 4
    LSR.W   #8,D7       *SHIFT TO THE RIGHT 8
    LSR.W   #5,D7       *SHIFT TO THE RIGHT 5
    
    MULU    #6,D6       *FORM OFFSET - SEE ADDENDUM
    JSR     0(A4,D6)    *JUMP INDIRECT WITH INDEX
    
    MOVE.B  #' ',(A3)+
    MOVE.B  #',',(A3)+
    
    CLR.L   D6          *ZERO OUT D6
    CLR.L   D7          *ZERO OUT D7
    MOVE.L  D3,D6       *COPY DOWN THE WHOLE 16BIT BINARY TO D6
    MOVE.L  D3,D7       *COPY DOWN THE WHOLE 16BIT BINARY TO D7
    
    *getting the destination mode and register
    LSL.W   #8,D6       *SHIFT TO THE LEFT 8
    LSL.W   #2,D6       *SHIFT TO THE LEFT 2
    LSR.W   #8,D6       *SHIFT TO THE RIGHT 8
    LSR.W   #5,D6       *SHIFT TO THE RIGHT 5

    LSL.W   #8,D7       *SHIFT TO THE LEFT 8
    LSL.W   #5,D7       *SHIFT TO THE LEFT 5
    LSR.W   #8,D7       *SHIFT TO THE RIGHT 8
    LSR.W   #5,D7       *SHIFT TO THE RIGHT 5
    
    *error checking
    CMP.B   #%001,D6    
    BEQ     FLAGINVALID 
     
    MULU    #6,D6       *FORM OFFSET - SEE ADDENDUM
    JSR     0(A4,D6)    *JUMP INDIRECT WITH INDEX
    
    RTS
        
BTST_v2     *#<DATA> -> <EA>
    LEA     addressing_mode,A4  *load the jump table for addressing_mode
    
    CLR.L   D6          *ZERO OUT D6
    CLR.L   D7          *ZERO OUT D7
    MOVE.L  D3,D6       *COPY DOWN THE WHOLE 16BIT BINARY TO D6
    MOVE.L  D3,D7       *COPY DOWN THE WHOLE 16BIT BINARY TO D7
    *getting the source mode and register
    MOVE.B  #'#',(A3)+
    JSR     getWord
    
    MOVE.B  #' ',(A3)+
    MOVE.B  #',',(A3)+
    
    CLR.L   D6          *ZERO OUT D6
    CLR.L   D7          *ZERO OUT D7
    MOVE.L  D3,D6       *COPY DOWN THE WHOLE 16BIT BINARY TO D6
    MOVE.L  D3,D7       *COPY DOWN THE WHOLE 16BIT BINARY TO D7
    
    *getting the destination mode and register
    LSL.W   #8,D6       *SHIFT TO THE LEFT 8
    LSL.W   #2,D6       *SHIFT TO THE LEFT 2
    LSR.W   #8,D6       *SHIFT TO THE RIGHT 8
    LSR.W   #5,D6       *SHIFT TO THE RIGHT 5

    LSL.W   #8,D7       *SHIFT TO THE LEFT 8
    LSL.W   #5,D7       *SHIFT TO THE LEFT 5
    LSR.W   #8,D7       *SHIFT TO THE RIGHT 8
    LSR.W   #5,D7       *SHIFT TO THE RIGHT 5
    
    *error checking
    CMP.B   #%001,D6    
    BEQ     FLAGINVALID 
     
    MULU    #6,D6       *FORM OFFSET - SEE ADDENDUM
    JSR     0(A4,D6)    *JUMP INDIRECT WITH INDEX
    
    RTS
    
CMP
    LEA     addressing_mode,A4  *load the jump table for addressing_mode
    
    CLR.L   D6          *ZERO OUT D6
    CLR.L   D7          *ZERO OUT D7
    MOVE.L  D3,D6       *COPY DOWN THE WHOLE 16BIT BINARY TO D6
    MOVE.L  D3,D7       *COPY DOWN THE WHOLE 16BIT BINARY TO D7
    *getting the source mode and register
    LSL.W   #8,D6       *SHIFT TO THE LEFT 8
    LSL.W   #2,D6       *SHIFT TO THE LEFT 2
    LSR.W   #8,D6       *SHIFT TO THE RIGHT 8
    LSR.W   #5,D6       *SHIFT TO THE RIGHT 5
    
    LSL.W   #8,D7       *SHIFT TO THE LEFT 8
    LSL.W   #5,D7       *SHIFT TO THE LEFT 5
    LSR.W   #8,D7       *SHIFT TO THE RIGHT 8
    LSR.W   #5,D7       *SHIFT TO THE RIGHT 5
    
    MULU    #6,D6       *FORM OFFSET - SEE ADDENDUM
    JSR     0(A4,D6)    *JUMP INDIRECT WITH INDEX
    
    MOVE.B  #' ',(A3)+
    MOVE.B  #',',(A3)+
    
    CLR.L   D6          *ZERO OUT D6
    CLR.L   D7          *ZERO OUT D7
    ;MOVE.L  D3,D6       *COPY DOWN THE WHOLE 16BIT BINARY TO D6
    MOVE.L  D3,D7       *COPY DOWN THE WHOLE 16BIT BINARY TO D7
    
    *getting the destination mode and register
    MOVE.B  #%000,D6    *DESTINATION IS A DATA REGISTER

    LSL.W   #4,D7       *SHIFT TO THE LEFT 4
    LSR.W   #8,D7       *SHIFT TO THE RIGHT 8
    LSR.W   #5,D7       *SHIFT TO THE RIGHT 5
    
     
    MULU    #6,D6       *FORM OFFSET - SEE ADDENDUM
    JSR     0(A4,D6)    *JUMP INDIRECT WITH INDEX
    
    RTS


CMPI
        LEA     addressing_mode,A4  *load the jump table for addressing_mode
    
    CLR.L   D6          *ZERO OUT D6
    CLR.L   D7          *ZERO OUT D7
    MOVE.L  D3,D6       *COPY DOWN THE WHOLE 16BIT BINARY TO D6
    MOVE.L  D3,D7       *COPY DOWN THE WHOLE 16BIT BINARY TO D7
    *getting the source mode and register
    LSL.W   #8,D6
    LSR.W   #8,D6
    LSR.W   #6,D6

    MOVE.B  #'#',(A3)+
    CMP.B   #%10,D6
    BEQ     jmp4
    CMP.B   #%00,D6
    BEQ     jmp5
    CMP.B   #%01,D6
    BEQ     jmp5

jmp5    JSR     getWord
        BRA     jmp6
    
jmp4    JSR     getLong
    
jmp6
    MOVE.B  #' ',(A3)+
    MOVE.B  #',',(A3)+
    
    CLR.L   D6          *ZERO OUT D6
    CLR.L   D7          *ZERO OUT D7
    MOVE.L  D3,D6       *COPY DOWN THE WHOLE 16BIT BINARY TO D6
    MOVE.L  D3,D7       *COPY DOWN THE WHOLE 16BIT BINARY TO D7
    
    *getting the destination mode and register
    LSL.W   #8,D6       *SHIFT TO THE LEFT 8
    LSL.W   #2,D6       *SHIFT TO THE LEFT 2
    LSR.W   #8,D6       *SHIFT TO THE RIGHT 8
    LSR.W   #5,D6       *SHIFT TO THE RIGHT 5
    
    LSL.W   #8,D7       *SHIFT TO THE LEFT 8
    LSL.W   #5,D7       *SHIFT TO THE LEFT 5
    LSR.W   #8,D7       *SHIFT TO THE RIGHT 8
    LSR.W   #5,D7       *SHIFT TO THE RIGHT 5
    
    *error checking
    CMP.B   #%001,D6    
    BEQ     FLAGINVALID 
    CMP.B   #%111,D6
    BNE     continue18
    CMP.B   #%100,D7
    BEQ     FLAGINVALID 
    
    
continue18    
    MULU    #6,D6       *FORM OFFSET - SEE ADDENDUM
    JSR     0(A4,D6)    *JUMP INDIRECT WITH INDEX
    
    RTS


CMPA
    LEA     addressing_mode,A4  *load the jump table for addressing_mode
    
    CLR.L   D6          *ZERO OUT D6
    CLR.L   D7          *ZERO OUT D7
    MOVE.L  D3,D6       *COPY DOWN THE WHOLE 16BIT BINARY TO D6
    MOVE.L  D3,D7       *COPY DOWN THE WHOLE 16BIT BINARY TO D7
    *getting the source mode and register
    LSL.W   #8,D6       *SHIFT TO THE LEFT 8
    LSL.W   #2,D6       *SHIFT TO THE LEFT 2
    LSR.W   #8,D6       *SHIFT TO THE RIGHT 8
    LSR.W   #5,D6       *SHIFT TO THE RIGHT 5
    
    LSL.W   #8,D7       *SHIFT TO THE LEFT 8
    LSL.W   #5,D7       *SHIFT TO THE LEFT 5
    LSR.W   #8,D7       *SHIFT TO THE RIGHT 8
    LSR.W   #5,D7       *SHIFT TO THE RIGHT 5
    
    MULU    #6,D6       *FORM OFFSET - SEE ADDENDUM
    JSR     0(A4,D6)    *JUMP INDIRECT WITH INDEX
    
    MOVE.B  #' ',(A3)+
    MOVE.B  #',',(A3)+
    
    CLR.L   D6          *ZERO OUT D6
    CLR.L   D7          *ZERO OUT D7
    ;MOVE.L  D3,D6       *COPY DOWN THE WHOLE 16BIT BINARY TO D6
    MOVE.L  D3,D7       *COPY DOWN THE WHOLE 16BIT BINARY TO D7
    
    *getting the destination mode and register
    MOVE.B  #%001,D6    *DESTINATION IS A DATA REGISTER

    LSL.W   #4,D7       *SHIFT TO THE LEFT 4
    LSR.W   #8,D7       *SHIFT TO THE RIGHT 8
    LSR.W   #5,D7       *SHIFT TO THE RIGHT 5
    
     
    MULU    #6,D6       *FORM OFFSET - SEE ADDENDUM
    JSR     0(A4,D6)    *JUMP INDIRECT WITH INDEX
    
    RTS


Bcc
    CLR.L   D6          *ZERO OUT D6
    CLR.L   D7          *ZERO OUT D7
    MOVE.L  D3,D6       *COPY DOWN THE WHOLE 16BIT BINARY TO D6
    MOVE.L  D3,D7       *COPY DOWN THE WHOLE 16BIT BINARY TO D7
    
    LSL.W   #8,D7
    LSR.W   #8,D7
    
    MOVE.B #'$',(A3)+ 
    CMP.B #$0,D7 * Does the branch specify a 16 bit offset?
    BEQ branchw 
    CMP.B #$FF,D7 * Does the branch specify a 32 bit offset?
    BEQ branchl 
    JSR getByte * Branch must be default 8 bit offset
    RTS
     
    
BRANCH
    CLR.L   D6          *ZERO OUT D6
    CLR.L   D7          *ZERO OUT D7
    MOVE.L  D3,D6       *COPY DOWN THE WHOLE 16BIT BINARY TO D6
    MOVE.L  D3,D7       *COPY DOWN THE WHOLE 16BIT BINARY TO D7
    
    LSL.W   #8,D7
    LSR.W   #8,D7
    
    MOVE.B #'$',(A3)+ 
    CMP.B #$0,D7 * Does the branch specify a 16 bit offset?
    BEQ branchw 
    CMP.B #$FF,D7 * Does the branch specify a 32 bit offset?
    BEQ branchl 
    JSR getByte * Branch must be default 8 bit offset
    RTS
    
branchw 
    JSR getword * Get the 16 bit offset word
    RTS
branchl 
    JSR getlong * Get the 32 bit offset long
    RTS
    
JSR
    LEA     addressing_mode,A4  *load the jump table for addressing_mode
    
    CLR.L   D6          *ZERO OUT D6
    CLR.L   D7          *ZERO OUT D7
    MOVE.L  D3,D6       *COPY DOWN THE WHOLE 16BIT BINARY TO D6
    MOVE.L  D3,D7       *COPY DOWN THE WHOLE 16BIT BINARY TO D7
    *getting the destination mode and register
    LSL.W   #8,D6       *SHIFT TO THE LEFT 8
    LSL.W   #2,D6       *SHIFT TO THE LEFT 2
    LSR.W   #8,D6       *SHIFT TO THE RIGHT 8
    LSR.W   #5,D6       *SHIFT TO THE RIGHT 5
    
    LSL.W   #8,D7       *SHIFT TO THE LEFT 8
    LSL.W   #5,D7       *SHIFT TO THE LEFT 5
    LSR.W   #8,D7       *SHIFT TO THE RIGHT 8
    LSR.W   #5,D7       *SHIFT TO THE RIGHT 5
    
    *error checking
    CMP.B   #%000,D6    
    BEQ     FLAGINVALID
    CMP.B   #%001,D6    
    BEQ     FLAGINVALID
    CMP.B   #%011,D6    
    BEQ     FLAGINVALID
    CMP.B   #%100,D6    
    BEQ     FLAGINVALID
    CMP.B   #%111,D6
    BNE     continue19
    CMP.B   #%100,D7
    BEQ     FLAGINVALID
    
continue19
    MULU    #6,D6       *FORM OFFSET - SEE ADDENDUM
    JSR     0(A4,D6)    *JUMP INDIRECT WITH INDEX
    RTS
    
RTS
    RTS
 
addressing_mode 
    JMP addresing_mode000 * Register is Dn
    JMP addresing_mode001 * Register is An
    JMP addresing_mode010 * Register is (An)
    JMP addresing_mode011 * Register is (An)+
    JMP addresing_mode100 * Register is -(An)
    JMP addresing_mode101 * Register is (d16,An)
    JMP addresing_mode110 * Register is (d8,An,Xn)
    JMP addresing_mode111 * Register is (XXX).W or (XXX).L
    
addresing_mode000
    LEA     register_mode,A2    *load the jump table for register_mode
    MOVE.B  #'D',(A3)+
    MULU    #6,D7
    JSR     0(A2,D7)    
    RTS
    
addresing_mode001
    LEA     register_mode,A2    *load the jump table for register_mode
    MOVE.B  #'A',(A3)+
    MULU    #6,D7
    JSR     0(A2,D7)
    RTS
    
addresing_mode010
    LEA     register_mode,A2    *load the jump table for register_mode
    MOVE.B  #'(',(A3)+
    MOVE.B  #'A',(A3)+
    MULU    #6,D7
    JSR     0(A2,D7)
    MOVE.B  #')',(A3)+
    RTS
    
addresing_mode011
    LEA     register_mode,A2    *load the jump table for register_mode
    MOVE.B  #'(',(A3)+
    MOVE.B  #'A',(A3)+
    MULU    #6,D7
    JSR     0(A2,D7)
    MOVE.B  #')',(A3)+
    MOVE.B  #'+',(A3)+
    RTS
    
addresing_mode100
    LEA     register_mode,A2    *load the jump table for register_mode
    MOVE.B  #'-',(A3)+
    MOVE.B  #'(',(A3)+
    MOVE.B  #'A',(A3)+
    MULU    #6,D7
    JSR     0(A2,D7)
    MOVE.B  #')',(A3)+
    RTS
    
addresing_mode101
    BRA     FLAGINVALID
    RTS            * Nothing to return!
    
addresing_mode110
    BRA     FLAGINVALID
    RTS            * Nothing to return!

addresing_mode111
    LEA     ab_mode,A2  * load in the absolute address table
    MULU    #6,D7
    JSR     0(A2,D7)
    RTS
    
register_mode 
    JMP register_mode000 * Register is 0
    JMP register_mode001 * Register is 1
    JMP register_mode010 * Register is 2
    JMP register_mode011 * Register is 3
    JMP register_mode100 * Register is 4
    JMP register_mode101 * Register is 5
    JMP register_mode110 * Register is 6
    JMP register_mode111 * Register is 7
    
register_mode000 
    MOVE.B #'0',(A3)+ * Prints 0 for the register number 
    RTS   
register_mode001 
    MOVE.B #'1',(A3)+ * Prints 1 for the register number
    RTS   
register_mode010 
    MOVE.B #'2',(A3)+ * Prints 2 for the register number
    RTS
register_mode011 
    MOVE.B #'3',(A3)+ * Prints 3 for the register number
    RTS
register_mode100 
    MOVE.B #'4',(A3)+ * Prints 4 for the register number
    RTS
register_mode101 
    MOVE.B #'5',(A3)+ * Prints 5 for the register number
    RTS
register_mode110 
    MOVE.B #'6',(A3)+ * Prints 6 for the register number
    RTS
register_mode111 
    MOVE.B #'7',(A3)+ * Prints 7 for the register number
    RTS
    
ab_mode 
    JMP ab_mode000 * Register mode is 000
    JMP ab_mode001 * Register mode is 001
    JMP ab_mode010 * Register mode is 010
    JMP ab_mode011 * Register mode is 011
    JMP ab_mode100 * Register mode is 100
    JMP ab_mode101 * Register mode is 101
    JMP ab_mode110 * Register mode is 110
    JMP ab_mode111 * Register mode is 111    

ab_mode000 
    CLR.L   D6
    MOVE.B  #'$',(A3)+
    MOVE.W  (A5),D6
    LSR.W   #8,D6
    LSR.W   #4,D6
    JSR     print_absoluteAdd 
    MOVE.W  (A5),D6
    LSL.W   #4,D6
    LSR.W   #8,D6
    LSR.W   #4,D6
    JSR     print_absoluteAdd
    MOVE.W  (A5),D6
    LSL.W   #8,D6
    LSR.W   #8,D6
    LSR.W   #4,D6
    JSR     print_absoluteAdd
    MOVE.W  (A5)+,D6
    LSL.W   #8,D6
    LSL.W   #4,D6
    LSR.W   #8,D6
    LSR.W   #4,D6
    JSR     print_absoluteAdd
    RTS
ab_mode001 
    CLR.L   D6
    MOVE.B  #'$',(A3)+
    MOVE.W  (A5),D6
    LSR.W   #8,D6
    LSR.W   #4,D6
    JSR     print_absoluteAdd 
    MOVE.W  (A5),D6
    LSL.W   #4,D6
    LSR.W   #8,D6
    LSR.W   #4,D6
    JSR     print_absoluteAdd
    MOVE.W  (A5),D6
    LSL.W   #8,D6
    LSR.W   #8,D6
    LSR.W   #4,D6
    JSR     print_absoluteAdd
    MOVE.W  (A5)+,D6
    LSL.W   #8,D6
    LSL.W   #4,D6
    LSR.W   #8,D6
    LSR.W   #4,D6
    JSR     print_absoluteAdd
    MOVE.W  (A5),D6
    LSR.W   #8,D6
    LSR.W   #4,D6
    JSR     print_absoluteAdd 
    MOVE.W  (A5),D6
    LSL.W   #4,D6
    LSR.W   #8,D6
    LSR.W   #4,D6
    JSR     print_absoluteAdd
    MOVE.W  (A5),D6
    LSL.W   #8,D6
    LSR.W   #8,D6
    LSR.W   #4,D6
    JSR     print_absoluteAdd
    MOVE.W  (A5)+,D6
    LSL.W   #4,D6
    LSL.W   #8,D6
    LSR.W   #8,D6
    LSR.W   #4,D6
    JSR     print_absoluteAdd
    RTS
ab_mode100 
    MOVE.B  #'#',(A3)+   
    CMP.B   #%1,D5
    BEQ     longhelper
    JSR     getWord
    RTS
longhelper
    JSR     getLong
    RTS    
    
ab_mode010 
    BRA     FLAGINVALID
    RTS            * Nothing to return!
ab_mode011 
    BRA     FLAGINVALID
    RTS            * Nothing to return!
ab_mode101 
    BRA     FLAGINVALID
    RTS            * Nothing to return!
ab_mode110 
    BRA     FLAGINVALID
    RTS            * Nothing to return!
ab_mode111 
    BRA     FLAGINVALID
    RTS            * Nothing to return!

print_absoluteAdd 
    CMP.B #$0A,D6 * Check to see if it's a number
    BLT num       * It's a number, print out in ASCII
    CMP.B #$9,D6  * Check to see if it's a letter
    BGT char      * It's a letter, print out in ASCII
num 
    ADDI.B #48,D6 * Add 48 to print in ASCII
    MOVE.B D6,(A3)+ 
    RTS
char
    ADDI.B #55,D6 * Add 55 to print in ASCII
    MOVE.B D6,(A3)+ 
    RTS
    
getByte
    MOVE.W  D7,D6
    ANDI.W  #$00FF,D6
    LSR.W   #4,D6
    JSR     print_absoluteAdd
    MOVE.W  D7,D6
    ANDI.W  #$000F,D6
    JSR     print_absoluteAdd
    RTS    

getWord
    CLR     D6
    MOVE.W  (A5),D6 * Load data from the next address
    LSR.W   #8,D6 
    LSR.W   #4,D6 
    JSR     print_absoluteAdd * Go encode and write the first character
    MOVE.W  (A5),D6 * Reload data from the next address
    ANDI.W  #$0FFF,D6 
    LSR.W   #8,D6 
    JSR     print_absoluteAdd * Go encode and write the second character
    MOVE.W  (A5),D6 * Reload data from the next address
    ANDI.W  #$00FF,D6 
    LSR.W   #4,D6 
    JSR     print_absoluteAdd * Go encode and write the second character
    MOVE.W  (A5)+,D6  * Reload data from the next address      
    ANDI.W  #$000F,D6 
    JSR     print_absoluteAdd * Go encode and write the second character
    RTS 
getLong
    CLR     D6
    MOVE.L  (A5),D6 * Load data from the next address
    MOVE.B  #28,D0
    LSR.L   D0,D6  
    JSR     print_absoluteAdd * Go encode and write the first character
    MOVE.L  (A5),D6 * Reload data from the next address
    ANDI.L  #$0FFFFFFF,D6 * Mask out the first character
    MOVE.B  #24,D0
    LSR.L   D0,D6 * Get the second character
    JSR     print_absoluteAdd * Go encode and write the third chracter
    MOVE.L  (A5),D6 * Reload data from the next address
    ANDI.L  #$00FFFFFF,D6 * Mask out the first two characters
    MOVE.B  #20,D0
    LSR.L   D0,D6  
    JSR     print_absoluteAdd * Go encode and write the third chracter
    MOVE.L  (A5),D6 * Reload data from the next address
    ANDI.L  #$000FFFFF,D6
    LSR.L   #8,D6 
    LSR.L   #8,D6 
    JSR     print_absoluteAdd * Go encode and write the fourth chracter
    MOVE.L  (A5),D6 * Reload data from the next address
    ANDI.L  #$0000FFFF,D6 
    LSR.L   #8,D6 
    LSR.L   #4,D6 
    JSR     print_absoluteAdd * Go encode and write the fifth chracter
    MOVE.L  (A5),D6 * Reload data from the next address
    ANDI.L  #$00000FFF,D6 
    LSR.L   #8,D6 
    JSR     print_absoluteAdd * Go encode and write the sixth chracter
    MOVE.L  (A5),D6 * Reload data from the next address
    ANDI.L  #$000000FF,D6 
    LSR.L   #4,D6 
    JSR     print_absoluteAdd * Go encode and write the seventh chracter
    MOVE.L  (A5)+,D6 * Reload data from the next address
    ANDI.L  #$0000000F,D6 
    JSR     print_absoluteAdd * Go encode and write the eigth chracter
    RTS 

data_mode 
    JMP data_mode000 * Register is 8
    JMP data_mode001 * Register is 1
    JMP data_mode010 * Register is 2
    JMP data_mode011 * Register is 3
    JMP data_mode100 * Register is 4
    JMP data_mode101 * Register is 5
    JMP data_mode110 * Register is 6
    JMP data_mode111 * Register is 7
    
data_mode000 
    MOVE.B #'8',(A3)+ * Prints 0 for the register number 
    RTS   
data_mode001 
    MOVE.B #'1',(A3)+ * Prints 1 for the register number
    RTS   
data_mode010 
    MOVE.B #'2',(A3)+ * Prints 2 for the register number
    RTS
data_mode011 
    MOVE.B #'3',(A3)+ * Prints 3 for the register number
    RTS
data_mode100 
    MOVE.B #'4',(A3)+ * Prints 4 for the register number
    RTS
data_mode101 
    MOVE.B #'5',(A3)+ * Prints 5 for the register number
    RTS
data_mode110 
    MOVE.B #'6',(A3)+ * Prints 6 for the register number
    RTS
data_mode111 
    MOVE.B #'7',(A3)+ * Prints 7 for the register number
    RTS
 
PRINT
        LEA     buffer,A1  
        MOVE.B  #14,D0
        TRAP    #15 
    SIMHALT             ; halt simulator

* Put variables and constants here
buffer      DS.B        80
EmptyStr    DC.B        '',0
INVALIDSTR  DC.B        '1000   DATA   $WXYZ',0
CR          EQU     $0D
LF          EQU     $0A
INTRO       DC.B   ' ',CR,LF
            DC.B   '  _     _ _   _   _        ___           _ _                            ',CR,LF
            DC.B   ' | |   (_) |_| |_| | ___  |_ _|_ __   __| (_) __ _ _ __                 ',CR,LF
            DC.B   ' | |   | | __| __| |/ _ \  | ||  _ \ / _` | |/ _` |  _ \                ',CR,LF
            DC.B   ' | |___| | |_| |_| |  __/  | || | | | (_| | | (_| | | | |               ',CR,LF
            DC.B   ' |_____|_|\__|\__|_|\___| |___|_| |_|\__,_|_|\__,_|_| |_|               ',CR,LF
            DC.B   '                  _   ____  _         _____     _                _      ',CR,LF
            DC.B   '   __ _ _ __   __| | | __ )(_) __ _  |  ___| __(_) ___ _ __   __| |___  ',CR,LF
            DC.B   '  / _` |  _ \ / _` | |  _ \| |/ _` | | |_ |  __| |/ _ \  _ \ / _` / __| ',CR,LF
            DC.B   ' | (_| | | | | (_| | | |_) | | (_| | |  _|| |  | |  __/ | | | (_| \__ \ ',CR,LF
            DC.B   '  \__,_|_| |_|\__,_| |____/|_|\__, | |_|  |_|  |_|\___|_| |_|\__,_|___/ ',CR,LF
            DC.B   '                              |___/                                     ',CR,LF
            DC.B   '  ____ ___ ____    _    ____ ____  _____ __  __ ____  _     _____ ____  ',CR,LF
            DC.B   ' |  _ \_ _/ ___|  / \  / ___/ ___|| ____|  \/  | __ )| |   | ____|  _ \ ',CR,LF
            DC.B   ' | | | | |\___ \ / _ \ \___ \___ \|  _| | |\/| |  _ \| |   |  _| | |_) |',CR,LF
            DC.B   ' | |_| | | ___) / ___ \ ___) |__) | |___| |  | | |_) | |___| |___|  _ < ',CR,LF
            DC.B   ' |____/___|____/_/   \_\____/____/|_____|_|  |_|____/|_____|_____|_| \_\',CR,LF
            DC.B   '                                                                        ',CR,LF,CR,LF,0
LINECOUNT   DS.B    1
STARTINPUT  DS.B    80                  
ENDINPUT    DS.B    80                  
MINSTART    EQU    $7000 MIN ADDRESS
MAXEND      EQU    $00FFFFFE MAX ADDRESS
ODDADDRMSG  DC.B    'You must enter an even address. Try again!',CR,LF,0
TOOLOWMSG   DC.B    'Too low! Please enter an address >= $7000',CR,LF,0
TOOHIGHMSG  DC.B    'Too High! Please enter an address <= $00FFFFFE',CR,LF,0    
HIGHLOWMSG  DC.B    'Ending address be lower than starting address!',CR,LF,0
STARTADDRMS DC.B    'Enter an even starting address between $7000 and $00FFFFE(MUST BE CAPS): ',0
ENDADDRMSG  DC.B    'Enter an even ending address $7000 and $00FFFFE(MUST BE CAPS): ',0
FAILMESSAGE DC.B    'Address entered is invalid. Please try again!',CR,LF,0
ENDMSG      DC.B   '    ____________________________________________________________    ',CR,LF
            DC.B   '   (                                               __           )   ',CR,LF
            DC.B   '   | _____  _              _      __ __           |  |  _    _  |   ',CR,LF
            DC.B   '   ||_   _|| |_  ___  ___ | |_   |  |  | ___  _ _ |  | (  \/ *) |   ',CR,LF
            DC.B   '   |  | |  |   || . ||   ||  _|  |_   _|| . || | ||__|  \   */  |   ',CR,LF
            DC.B   '   |  |_|  |_|_||__,||_|_||_,_|    |_|  |___||___||__|    \/    |   ',CR,LF
            DC.B   '   (_  _________________________________________________________)   ',CR,LF
            DC.B   '     \/                                                             ',CR,LF
            DC.B   '   (\__/)                                                           ',CR,LF
            DC.B   '   (=^_^)                                                           ',CR,LF
            DC.B   '   (")_(")                                                          ',CR,LF,CR,LF,0
ENDPROMPT 	DC.B	'Reach the end!!!!! Press [r] to restart, or [q] to quit', CR, LF, 0
KEYENTER    DC.B    'Press [Enter] to Continue, [r] to restart, or [q] to quit', CR, LF, 0
BADBUFFER   DC.L	1
END_LINE    DC.B    '  ', CR, LF, 0
    END    START        LAST LINE
























*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
