;for Basic Loader Creator
;RUN USR X [LET X = Start_Address] (TR-DOS or TAPE)

	macro BasicLineCode
	display 'BASIC listing: RUN USR x [RUN USR ', /d, CodeLoader, ']'
VarSymbol	equ "X"|#20		;lowercase character for RUN USR
	dh f7c0		;RUN USR
	db VarSymbol		;"X"
	HiddenText 11,11	;number of characters that hide the BASIC line listing (BACKSPACE, SPACE)
	endm