;for Basic Loader Creator
;POKE 0,0:POKE 0,0:PRINT (TR-DOS or TAPE)

VarSymbol	equ "X"|#20		;lowercase letter - a valid numeric-variable marker, so LIST stops here
	ASSERT VarSymbol=VarSymbol	;only to trip main.asm's "ifused VarSymbol" check
	
SChanOut	equ BasicFileStart-16

	macro BasicLineCode
	display 'BASIC listing: POKE ', /d, SChanOut, ',', /d, low CodeLoader, ':POKE ', /d, SChanOut+1, ',', /d, high CodeLoader, ':PRINT  [S-channel PR-OUT -> ', /a, CodeLoader, ']'

	dh f4		;POKE
	db "0"		;placeholder digit - the real value is the hidden number below (S-channel PR-OUT vector, low byte)
	dh 0e0000
	dw SChanOut
	db 0
	db ","
	db "0"		;placeholder digit - the real value is the hidden number below
	dh 0e0000
	db low CodeLoader,0,0
	db ":"

	dh f4		;POKE
	db "0"		;placeholder digit - the real value is the hidden number below (S-channel PR-OUT vector, high byte)
	dh 0e0000
	dw SChanOut+1
	db 0
	db ","
	db "0"		;placeholder digit - the real value is the hidden number below
	dh 0e0000
	db high CodeLoader,0,0
	db ":"

	dh f5		;PRINT - forces one call through the now-patched S-channel output
			;vector immediately; the "0 OK" report does NOT do this on its
			;own - see the note at the top of this file
	HiddenText 28,28	;number of characters that hide the BASIC line listing (BACKSPACE, SPACE)
	endm