;for Basic Loader Creator
;RUN USR X [LET X = Start_Address] (TR-DOS or TAPE)

		macro BasicLineCode
VarSymbol	equ "X"|#20				;lowercase character for RUN USR
		dh f7c0					;RUN USR
    		db VarSymbol				;"X"
		HiddenText 11,11			;number of characters to hide the listing of BASIC-line (BACKSPACE, SPACE)
		endm