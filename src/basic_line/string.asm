;for Basic Loader Creator
;RUN USR "10.12.2023" (TR-DOS or TAPE)

	macro BasicLineCode
	display 'BASIC listing: RUN USR "10.12.2023" [RUN USR ', /d, CodeLoader, ']'
	dh f7c0		;RUN USR
	db "10.12.2023"		;program release date or other text (must start with a digit!)
	dh 0e0000
	dw CodeLoader
	db 0
	HiddenText 20,20	;number of characters that hide the BASIC line listing (BACKSPACE, SPACE)
	endm