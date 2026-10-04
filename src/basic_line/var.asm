;for Basic Loader Creator
;IF USR x [x = Start_Address] (TR-DOS or TAPE)

	macro BasicLineCode
	display 'BASIC listing: IF USR x [IF USR ', /d, CodeLoader, ']'
VarSymbol	equ 'x'		;lower-case letter - marks a numeric variable
	HiddenText 2,0		;"0>" - the line number that LIST prints before its text. Each part of the listing is erased right
			;after itself, so the next one is printed over it, and at the end only the widest
			;part is blanked out with spaces, not the whole line
	dh "fa"		;IF - the ROM evaluates the numeric expression of IF before looking for THEN, so a missing THEN does not matter
	HiddenText 3,0
	dh "c0"		;USR
	HiddenText 4,0
	db VarSymbol		;"x"
	HiddenText 1,3
	endm