;for Basic Loader Creator
;IF USR VAL "PEEK 23628*256+PEEK 23627" (TR-DOS and TAPE)

	macro BasicLineCode
	display 'BASIC listing: IF USR VAL "PEEK 23628*256+PEEK 23627" [IF USR ', /d, CodeLoader, ']'
NoCopyrightSep	equ 0		;USR outranks any statement: the code is started before the ROM gets to the copyright text after the line.
			;The expression ends with a closing quote, so CopyrightText must not start with a parenthesis: the
			;ROM would take it for a string slice, and the code would not start
	HiddenText 2,0		;"0>" - the line number that LIST prints before its text. Each part of the listing is erased right
			;after itself, so the next one is printed over it, and at the end only the widest
			;part is blanked out with spaces, not the whole line
	dh "fa"		;IF
	HiddenText 3,0
	dh "c0"		;USR
	HiddenText 4,0
	dh "b0"		;VAL - evaluates the expression written as a string, so the digits inside it stay plain characters and
			;produce no hidden 5-byte numbers. BACKSPACEs inside the string do not disturb the evaluation - the ROM
			;skips them
	HiddenText 4,0
	db '"'		;opening quote of the string
	HiddenText 1,0
	dh "be"		;PEEK
	HiddenText 5,0
	db "23628*"		;VARS+1, the high byte of the pointer, multiplied by 256
	HiddenText 6,0
	db "256+"
	HiddenText 4,0
	dh "be"		;PEEK
	HiddenText 5,0
	db "23627"		;VARS (#5C4B), the low byte - together they give the address the ROM put there on load:
			;the border of the variables area, and our code starts right there
	HiddenText 5,0
	db '"'		;closing quote of the string
	HiddenText 1,6
	endm