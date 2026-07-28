;for Basic Loader Creator
;RUN USR VAL POKE 0,0:POKE 0,0:IN (TR-DOS and TAPE)

VarSymbol	equ "X"|#20		;lowercase letter - a valid numeric-variable marker, so LIST stops here
	ASSERT VarSymbol=VarSymbol;only to trip main.asm's "ifused VarSymbol" check

	macro BasicLineCode
	display 'BASIC listing: POKE ', /d, 23613, ',', /d, low (BasicVariables+3), ':POKE ', /d, 23614, ',', /d, high (BasicVariables+3), ':IN  [ERR_SP -> ', /a, BasicVariables+3, ']'
	dh f4		;POKE
	db "0"		;placeholder digit - the real value is the hidden number below (#5C3D low byte of ERR_SP)
	dh 0e0000
	dh 3d5c00
	db ","
	db "0"		;placeholder digit - the real value is the hidden number below
	dh 0e0000
	db low (BasicVariables+3),0,0
	db ":"

	dh f4		;POKE
	db "0"		;placeholder digit - the real value is the hidden number below (#5C3E high byte of ERR_SP, address 23614)
	dh 0e0000
	dh 3e5c00
	db ","
	db "0"		;placeholder digit - the real value is the hidden number below
	dh 0e0000
	db high (BasicVariables+3),0,0
	db ":"

	dh bf		;IN (Report C, "Nonsense in BASIC" - a function token where a
			;statement is expected isn't in the statement dispatch table,
			;guaranteed error, no operand)
			;NOTE: the normal "0 OK" report does not reach ERR_SP the same
			;way, even though ROM #1BB0 reports it via the same RST 08
			;path - an explicit error trigger is required here
	HiddenText 24,24	;number of characters that hide the BASIC line listing (BACKSPACE, SPACE)
	endm