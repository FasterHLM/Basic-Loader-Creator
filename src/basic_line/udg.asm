;for Basic Loader Creator
;POKE 0,0:POKE 0,0:IF USR USR "a" [UDG] (TR-DOS or TAPE)

	macro HiddenNumber n	;the listing shows the digit "0", the real value is in the hidden 5-byte number
	db '0'		;visible placeholder digit
	dh "0e"		;marker "a 5-byte number follows" - LIST does not print it
	dh "00"		;exponent: zero means the short form for integers
	dh "00"		;sign: 00 plus, FF minus
	dw n		;the value itself, low byte first
	dh "00"		;fifth byte, the ROM does not read it for integers
	endm

	macro HiddenPoke addr,val,width	;POKE addr,val with both operands hidden from LIST.
	dh "f4"		;width is the width of "POKE " in the listing: 5 at the start of the line and 6 after
	HiddenText width,0	;":" - LIST prints a space before the statement
	HiddenNumber addr
	db ','
	HiddenText 2,0
	HiddenNumber val
	db ':'
	HiddenText 2,0
	endm

	macro BasicLineCode
	display 'BASIC listing: POKE ', /d, sys48.UDG, ',', /d, low CodeLoader, ':POKE ', /d, sys48.UDG+1, ',', /d, high CodeLoader, ':IF USR USR "a"  [UDG -> ', /a, CodeLoader, ']'
NoCopyrightSep	equ 0		;USR outranks any statement: the code is started before the ROM gets to the copyright text after the line.
			;The expression ends with a closing quote, so CopyrightText must not start with a parenthesis: the
			;ROM would take it for a string slice, and the code would not start
	HiddenText 2,0		;"0>" - the line number that LIST prints before its text. Each part of the listing is erased right
			;after itself, so the next one is printed over it, and at the end only the widest
			;part is blanked out with spaces, not the whole line
	HiddenPoke sys48.UDG,low CodeLoader,5
	HiddenPoke sys48.UDG+1,high CodeLoader,6
	dh "fa"		;IF
	HiddenText 4,0
	dh "c0"		;USR - the outer one: calls what the inner one returned
	HiddenText 4,0
	dh "c0"		;USR - the inner one: for a one-character string returns (UDG)+(letter-"a")*8, that is for "a" - the
			;value of UDG itself. The string form only returns the address, calling it is left to the outer USR - the
			;line has no address in any form, it lives in a system variable
	HiddenText 4,0
	db '"'
	db 'a'
	db '"'
	HiddenText 3,5
	endm