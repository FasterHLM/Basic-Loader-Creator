;for Basic Loader Creator
;RUN USR VAL "PEEK 23628*256+PEEK 23627" (TR-DOS and TAPE)

	macro BasicLineCode
	display 'BASIC listing: RUN USR VAL "PEEK 23628*256+PEEK 23627" [RUN USR ', /d, CodeLoader, ']'
	dh f7c0		;RUN USR
	dh B022BE32333632382A	;VAL "PEEK 23628*
	HiddenText 26,26+3	;number of characters that hide the BASIC line listing (BACKSPACE, SPACE)
	dh 3235362BBE323336323722	;256+PEEK 23627"
	HiddenText 15,15	;number of characters that hide the BASIC line listing (BACKSPACE, SPACE)
	endm