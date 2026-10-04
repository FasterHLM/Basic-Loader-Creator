;for Basic Loader Creator

	macro HiddenText backspaces,spaces	;hiding the BASIC line from LIST: backspaces times BACKSPACE back over what is
	ifdef HiddenLine		;already printed, then spaces blanks on top of it. Either of the
	ds backspaces,BACKSPACE		;counts may be zero - ds 0 is allowed (shortblock-ok)
	ds spaces,' '			;(shortblock-ok)
	endif
	endm
;-
	struct NumVar			;BASIC numeric variable with a one-letter name
Letter	byte			;name letter, lower case
Exponent	byte 0			;exponent: zero - the short form for integers
Sign	byte 0			;sign: 0 is plus
Value	word			;the value itself. There is no fifth byte in the structure: its place
	ends			;is taken by the first byte of the code

BasicFileStart	db high NumberLine,low NumberLine	;2 bytes of the BASIC line number, 0..9999
	assert NumberLine >= 0 && NumberLine <= 9999, BASIC line number must be 0..9999 - SAVETRD writes no autostart marker for a larger one

	ifdef MergeProtect		;protection against MERGE
	dh "ffff"			;false BASIC line length
	else
	dw sizeof BasicProg		;real BASIC line length - from BasicProg to the next label, BasicVariables
	endif
BasicProg	BasicLineCode
	ifdef CopyrightLine		;copyright message
	if !exist NoCopyrightSep
	db ':'			;the colon separates the copyright from the statements of the line
	HiddenText 1,1
	endif
	CopyrightText
	endif
	dh "0d"			;end of the BASIC line
BasicVariables	if exist VarSymbol		;a variant that declares VarSymbol gets a numeric variable
	NumVar VarSymbol,,,CodeLoader		;holding the code address at the start of the BASIC variables area
	endif
CodeLoader	Loader
	if !exist VarSymbol		;without a variable the variables area starts right with the code, and by its first byte
				;LIST decides that the program is over: it would take a smaller one for the next line number.
				;{b address} reads an already assembled byte
	assert {b CodeLoader} >= #40, first code byte must be #40 or higher when the variant has no BASIC variable
	endif
BasicFileEnd	equ $			;end of the program and code - all that counts towards the file length. SAVETRD itself
				;appends the autostart marker (#80, #AA and the line number) right after this length,
				;in the free space of the same sector
TrdLength	equ BasicFileEnd-BasicFileStart		;file length: the program and variables, that is the code. The same length
				;goes into the tape header too
	if OutputFormat = "trd" || OutputFormat = "both"
				;from here on - only what concerns the TR-DOS image
	ifdef HiddenMessage
HiddenStart	HiddenMessageText		;hidden message: lua/hidden_message.asm takes it from here and
HiddenLen	equ $-HiddenStart		;writes it onto the image behind the autostart marker, so it is not
	endif			;counted in the file length or in the sector count in the catalogue
TrdSectors	equ (TrdLength+4+#ff)/#100		;number of sectors the file takes together with the 4 marker bytes
	ifdef HiddenMessage
	assert TrdLength+4+HiddenLen <= TrdSectors*#100, hidden message must fit the free space of the last sector
	endif
	endif
;-
	display ' '
	ifdef BuildDate
	display 'Build date:                                  ', BuildDate
	endif
	display 'Basic loader address:                        ', /a, BasicFileStart
	display 'Code entry point:                            ', /a, CodeLoader
	display 'Code + variables length:                     ', /a, BasicFileEnd-BasicVariables
	display ' '
	if OutputFormat = "tap"
	display 'Tape header: data length:                    ', /d, TrdLength
	display 'Tape header: program length (BASIC only):    ', /d, BasicVariables-BasicFileStart
	else
	display 'Catalogue info: Start - total file length:   ', /d, TrdLength
	display 'Catalogue info: Length - BASIC only:         ', /d, BasicVariables-BasicFileStart
	display 'File size in sectors:                        ', /d, TrdSectors
	ifdef HiddenMessage
	display ' '
	display 'Hidden message length:                       ', /d, HiddenLen
	if TrdLength+4+HiddenLen <= TrdSectors*#100
	display 'Free space to end of sector:                 ', /d, TrdSectors*#100-TrdLength-4-HiddenLen
	endif
	endif
	endif
	display ' '