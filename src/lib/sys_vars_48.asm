KSTATE	equ #5C00	;#5C00...#5C07 Eight bytes forming two blocks used by the keyboard-handling routine. These variables are practically never used by external programs
LAST_K	equ #5C08	;code of the last key pressed
REPDEL	equ #5C09	;delay (in 1/50s) between a key press and the start of automatic key-repeat
REPPER	equ #5C0A	;repeat period (in 1/50s) while a key is held down. Changing REPDEL and REPPER lets you tune the keyboard for a particular user
DEFADD	equ #5C0B	;address of the first parameter of a user-defined function (DEF FN) while it is being evaluated
K_DATA	equ #5C0D	;colour code entered via a digit key in 'E' cursor mode
TVDATA	equ #5C0E	;first byte: control code entered via a digit key in 'E' cursor mode. Second byte: first parameter of AT or TAB
STRMS	equ #5C10	;#5C10...#5C35 storage area for stream information
CHARS	equ #5C36	;address of the current character set. After start-up this is the address of the standard font, #3C00
		;since character codes #00 to #1F are control codes and are not defined in the font, the actual address of the current character set is #100 (32x8) higher
		;than the value stored in CHARS. for example, to make the font located at #FD00 current, CHARS must be set to #FC00 (#FD00-#100)
RASP	equ #5C38	;value proportional to the length of the beep warning that the editor buffer is full
PIP	equ #5C39	;value proportional to the length of the beep sounded on a key press
ERR_NR	equ #5C3A	;error report code minus one (including report 0, OK, for normal program completion)
FLAGS	equ #5C3B	;individual bits of this variable are used by the operating system (see also the FLAGS2 variable):
		;bit 0 is set if no leading space is needed before a BASIC statement. (Most BASIC statements print a leading space when listed or printed)
		;bit 1 is set when output goes to stream #3 (normally the printer)
		;bit 2 is set while entering a character in 'L' cursor mode, reset while entering in 'K' mode
		;bit 3 is set while waiting for a character in 'L' cursor mode, reset while waiting in 'K' mode
		;bit 4 is set while the extended BASIC interpreter is running on a ZX Spectrum 128; reset in standard configuration
		;bit 5 is set when any character key is pressed. The key code can be read from LAST_K
		;bit 6 is set while evaluating a numeric expression, reset for a string expression
		;bit 7 is set while a program is running, reset while checking the syntax of an entered line
TV_FLAG	equ #5C3C	;individual bits of this variable are used to control screen output:
		;bit 0 is set when writing to the lower (status) screen, reset when writing to the main screen
		;bit 3 is set if the screen output mode may have changed and needs re-checking
		;bit 4 is set while listing a program
		;bit 5 is set when the lower screen needs to be cleared (e.g. before printing a message)
ERR_SP	equ #5C3D	;address the stack pointer is set to when the error-handling routine starts. Changing this value lets you install your own error-handling routines
LIST_SP	equ #5C3F	;saves the top-of-stack address while a program listing is being output
MODE	equ #5C41	;value determining the keyboard input mode:
		;0 - the next character is entered in K, L or C cursor mode
		;1 - the next character is entered in E cursor mode
		;2 and above - the next and following characters are entered in G cursor mode
		;at values above 2 the appearance of the cursor changes
NEWPPC	equ #5C42	;line number of the BASIC program containing the next statement to execute
NSPPC	equ #5C44	;number of the next statement to execute within that program line
		;NEWPPC and NSPPC can be used to jump to an arbitrary statement in the BASIC program
PPC	equ #5C45	;line number of the BASIC program line currently being executed
		;set to #FFFE when a statement is executed in immediate (command) mode
SUBPPC	equ #5C47	;number of the statement currently being executed within its program line
BORDCR	equ #5C48	;lower-screen attributes. The border colour is taken from the lower screen's paper colour
E_PPC	equ #5C49	;line number of the BASIC program line marked by the cursor
VARS	equ #5C4B	;address of the start of the BASIC program's variables area
DEST	equ #5C4D	;address of the first character of the name of the variable currently being processed
CHANS	equ #5C4F	;address of the start of the channel information area
CURCHL	equ #5C51	;address of the first byte of the current channel's descriptor within the channel information area
PROG	equ #5C53	;address of the start of the BASIC program. Subtracting the value of the VARS system variable from PROG gives the length of the BASIC program
NXTLIN	equ #5C55	;address of the start of the next BASIC program line
DATADD	equ #5C57	;address of the last data item read by a READ statement from a DATA statement
E_LINE	equ #5C59	;address of the start of the line being edited
K_CUR	equ #5C5B	;address of the character of the edited line the cursor is positioned on
CH_ADD	equ #5C5D	;address of the next character to be processed in the BASIC program. This variable can be useful when writing external syntax-processing routines
X_PTR	equ #5C5F	;address of the character in the BASIC line after which a '?' is placed when a syntax error is detected. In operations unrelated to syntax checking,
		;the variable may be used by the computer to temporarily store other system information
WORKSP	equ #5C61	;address of the start of the BASIC program's workspace
STKBOT	equ #5C63	;address of the bottom of the calculator stack
STKEND	equ #5C65	;address of the top of the calculator stack
BREG	equ #5C67	;calculator's B register
MEM	equ #5C68	;address of the memory area used by the calculator. Normally the MEMBOT system area is used for this purpose
FLAGS2	equ #5C6A	;individual bits of this variable are used by the operating system (see also the FLAGS variable)
		;bit 0 is set when the main screen needs to be cleared after a line is entered
		;bit 1 is set once the printer buffer has already been used
		;bit 2 is set when the main screen has been cleared
		;bit 3 is set while using C cursor mode, reset while using L cursor mode. Changing this bit lets you switch the keyboard's C/L register modes in software
		;bit 4 is set while using K cursor mode
		;bits 5, 6, 7 are used by the ZX-LPRINT III interface (if fitted)
DF_SZ	equ #5C6B	;number of lines in the lower screen. The number of lines in the main screen can be increased up to the maximum (24 lines) by executing POKE 23659,0
		;however, if the lower screen has fewer than 2 lines, then attempting to print any message to it, e.g. OK or BREAK-CONT repeats,
		;will make the system behave very badly. Writing zero to DF_SZ is one way of protecting a BASIC program against being stopped
S_TOP	equ #5C6C	;line number of the BASIC program from which an automatic listing starts (on pressing Enter)
OLDPPC	equ #5C6E	;line number of the BASIC program from which execution will resume after a CONTINUE statement
OSPCC	equ #5C70	;number of the statement within the BASIC program line from which execution will resume after a CONTINUE statement
FLAGX	equ #5C71	;used while processing an INPUT statement
		;bit 1 is set if a new variable is being entered by the INPUT statement
		;bit 5 is set while working in INPUT entry mode, reset while editing a BASIC line
		;bit 6 is set while processing a line entered via the INPUT statement
		;bit 7 is set if an INPUT LINE statement is being executed
STRLEN	equ #5C72	;length of the string variable currently being processed (if already defined), or the identifier of a numeric or new string variable (low byte)
T_ADDR	equ #5C74	;address of the next entry in the syntax tables held in ROM
SEED	equ #5C76	;value used to compute the pseudo-random number. After a RANDOMIZE statement, the SEED variable is changed according to the given parameter
		;if RANDOMIZE was used without a parameter, the two low bytes of the FRAMES variable are copied into SEED
FRAMES	equ #5C78	;#5C78/79/7A system counter. Reset to zero on start-up (reset)
		;while the standard interrupt-handling routine is running, the counter is incremented by one every 1/50 second
UDG	equ #5C7B	;address of the start of the area used to hold user-defined graphics
COORDS	equ #5C7D	;X and Y coordinates of the last point plotted on screen
P_POSN	equ #5C7F	;holds the value 33-n, where n is the number of the next print position in the printer buffer
PR_CC	equ #5C80	;low byte of the address of the area currently used as the printer buffer
NOT_USED	equ #5C81	;most descriptions describe this variable as unused (hence its name),
		;but it actually holds the high byte of the address of the area currently used as the printer buffer
		;when printing to the ZX Printer, the operating system prepares the line to print in the buffer addressed by the PR_CC and NOT_USED variables
ECHO_E	equ #5C82	;position (line number and column) of the next character of the BASIC line being entered
DF_CC	equ #5C84	;address of the byte corresponding to the top row of pixels of the main-screen character cell where the next character will be printed
DFCCL	equ #5C86	;address of the byte corresponding to the top row of pixels of the lower-screen character cell where the next character will be printed
S_POSN	equ #5C88	;coordinates of the next print position on the main screen. Stored as 24-nr, 33-nc, where nr is the line number and nc the column number
SPOSNL	equ #5C8A	;coordinates of the next print position on the lower screen
SCR_CT	equ #5C8C	;value one greater than the number of lines the screen can scroll up without a scroll? prompt
		;changing the contents of this cell can be used to achieve non-stop scrolling of text on screen
ATTR_P	equ #5C8D	;permanent screen attributes, set by the PAPER, INK, FLASH and BRIGHT statements
MASK_P	equ #5C8E	;mask used to separate the permanent (ATTR_P) and current attributes when printing to the screen. If a bit is set in MASK_P, the corresponding attribute bit is left unchanged when printing to the screen
ATTR_T	equ #5C8F	;temporary attributes used when printing to the screen, e.g. by the statement PRINT INK 7; PAPER 1;"..."
MASK_T	equ #5C90	;mask used to separate the temporary (ATTR_T) and current attributes when printing to the screen
P_FLAG	equ #5C91	;screen output parameters. Even-numbered bits are used for permanent parameters, odd-numbered bits for temporary ones:
		;bit 0/1 is set when OVER 1 is used
		;bit 2/3 is set when INVERSE 1 is used
		;bit 4/5 is set when INK 9 is used
		;bit 6/7 is set when PAPER 9 is used
MEMBOT	equ #5C92	;#5C92...#5CAF area used by the calculator to hold values that are inconvenient to process via the calculator stack
NMIADD	equ #5CB0	;not used. The authors of the system evidently intended this system variable to service non-maskable interrupts,
		;but due to an oversight the variable ended up genuinely unused. Some external device interfaces make use of this variable;
		;for example, the ZX Lprint III printer interface stores its serial link baud rate here
RAMTOP	equ #5CB2	;last RAM address the BASIC interpreter is allowed to use. Set by the CLEAR statement
P_RAMT	equ #5CB4	;address of the last byte of physical RAM. Set during computer initialisation after testing available memory
		;on a working computer with 48K of RAM this variable should hold the value #FFFF