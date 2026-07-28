SWAP	equ #5B00	;#5B00...#5B13 - switches the ROM pages in the CPU0 area. This and the
		;six areas that follow hold small routines used by the 128 interpreter extension
YOUNGER	equ #5B14	;#5B14...#5B1C - part of the routine linking the interpreter extension
		;to the main BASIC
ONERR	equ #5B1D	;#5B1D...#5B2E - error handling routine of the BASIC interpreter
PIN	equ #5B2F	;#5B2F...#5B33 - routine reading a byte from the RS-232 interface
POUT	equ #5B34	;#5B34...#5B49 - routine writing a byte to the RS-232 interface
POUT2	equ #5B4A	;#5B4A...#5B57 - used automatically at the end of RS-232 input or output
;-
;shared by the 128/+2 and the +2A/+3
TARGET	equ #5B58	;2 bytes - address of the subroutine called by the 128 extension from main BASIC
RETADDR	equ #5B5A	;2 bytes - return address into the 128 extension while a main BASIC
		;subroutine is running
BANKM	equ #5B5C	;copy of the machine's configuration register: whenever the system writes to
		;port 32765 (#7FFD) it stores the same value here. The port is write-only, so
		;this copy must be kept up to date - always write here as well as to the port:
		;bits 0-2 RAM page (0-7) paged into #C000
		;bit 3 screen select (0 = normal, page 5; 1 = shadow, page 7)
		;bit 4 ROM select (0 = 128K editor ROM, 1 = 48K BASIC ROM)
		;bit 5 disables further paging until the machine is reset
RAMRST	equ #5B5D	;holds #CF, the opcode of RST 8. On an error in the extended BASIC
		;interpreter control is passed here, so this and the next cell form the
		;entry point of the error handler
RAMERR	equ #5B5E	;error code of the extended BASIC interpreter
BAUD	equ #5B5F	;2 bytes - used to compute the transfer rate of the RS-232 printer interface
SERFL	equ #5B61	;2 bytes - the low byte is a flag saying that a second data byte was received
		;over RS-232; that byte is placed in the high byte of this variable
COL	equ #5B63	;position of the character being printed on the printer. On reaching WIDTH
		;the codes for starting a new line are output automatically
WIDTH	equ #5B64	;highest printing position when printing, that is the line width in characters
TVPARS	equ #5B65	;counter used when sending multi-byte control characters (AT, TAB) over RS-232
FLAGS3	equ #5B66	;bits controlling the 128 BASIC interpreter extension:
		;bit 0 reset while the BASIC screen editor runs, set in calculator mode
		;bit 1 set if the BASIC program has an autostart line number
		;bit 2 set when a file is opened on the RAM disk
		;bit 3 reset if tape is used, set when working with the RAM disk
		;bit 4 set for the BASIC command LOAD
		;bit 5 set for the BASIC command SAVE
		;bit 6 set for the BASIC command MERGE
		;bit 7 set for the BASIC command VERIFY
;-
;128/+2 only: RAM disk control, external keypad, renumbering
NSTR1	equ #5B67	;#5B67...#5B70 - 10-character file name used with the RAM disk. This and the
		;next five variables form the RAM disk file control block
HD_00	equ #5B71	;file type: 0 = BASIC program, 1 = numeric array, 2 = character array, 3 = code
HD_0B	equ #5B72	;2 bytes - length of the data block
HD_0D	equ #5B74	;2 bytes - address of the data block in memory
HD_0F	equ #5B76	;2 bytes - length of the BASIC program
HD_11	equ #5B78	;2 bytes - autostart line number of the BASIC program
SC_00	equ #5B7A	;file type (as HD_00). This and the next three variables form the second
		;RAM disk file control block
SC_0B	equ #5B7B	;2 bytes - length of the data block
SC_0D	equ #5B7D	;2 bytes - address of the data block in memory
SC_0F	equ #5B7F	;2 bytes - length of the BASIC program
OLDSP	equ #5B81	;2 bytes - saves the interpreter's stack pointer while auxiliary routines
		;(screen editor, menu) run on the temporary stack TSTACK
SFNEXT	equ #5B83	;2 bytes - first free entry in the RAM disk catalogue
SFSPACE	equ #5B85	;3 bytes - number of free bytes on the RAM disk
ROW01	equ #5B88	;bitmap of the first row of the external keypad; a set bit means the key is pressed
ROW23	equ #5B89	;bitmap of the second and third rows of the external keypad
ROW45	equ #5B8A	;bitmap of the fourth and fifth rows of the external keypad
SYNRET	equ #5B8B	;2 bytes - return address from the interpreter's error handling routine
LASTV	equ #5B8D	;#5B8D...#5B91 - last value printed by the calculator (5 bytes)
RNLINE	equ #5B92	;2 bytes - line currently being renumbered
RNFIRST	equ #5B94	;2 bytes - first line number for renumbering
RNSTEP	equ #5B96	;2 bytes - renumbering step
STRIP1	equ #5B98	;8 bytes - first half of the maker's logo (slanted colour stripes). 32 bytes
		;from this address are also used when working with the RAM disk
STRIP2	equ #5BA0	;8 bytes - second half of the maker's logo
TSTACK	equ #5BA8	;#5BA8...#5BFF - temporary stack of the extended interpreter, growing down
		;from #5BFF
