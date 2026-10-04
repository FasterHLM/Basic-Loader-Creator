;for Basic Loader Creator
;IF USR <build date> (TR-DOS or TAPE)

	macro BasicLineCode
	display 'BASIC listing: IF USR ', BuildDate, ' [IF USR ', /d, CodeLoader, ']'
NoCopyrightSep	equ 0		;USR outranks any statement: the code is started before the ROM gets to the copyright text after the line
	HiddenText 2,0		;"0>" - the line number that LIST prints before its text. Each part of the listing is erased right
			;after itself, so the next one is printed over it, and at the end only the widest
			;part is blanked out with spaces, not the whole line
	dh "fa"		;IF
	HiddenText 3,0
	dh "c0"		;USR
	HiddenText 4,0
	db BuildDate		;build date DD.MM.YYYY (a define from lua/build_date.asm) or any text, but it must start with a digit:
			;on seeing a digit the ROM assumes a number follows, and when executing skips everything up to the 0E marker.
			;Only this text is visible in the listing, but the hidden number below is what works
	dh "0e"		;marker "a 5-byte number follows" - LIST does not print it, so the real value does not
			;appear in the listing at all
	dh "00"		;exponent: zero means the short form for integers
	dh "00"		;sign: 00 plus, FF minus
	dw CodeLoader		;the value itself, low byte first
	dh "00"		;fifth byte, the ROM does not read it for integers
	HiddenText 10,10
	endm