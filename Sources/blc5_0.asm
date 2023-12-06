;Basic Loader Creator v5.0 (tr-dos/tape editions) for sjasmplus 1.18.3 or newer.
;© 2010-2011, 2013, 2021, 2023 all rights reserved by Faster/HLM.

		device zxspectrum48                   

		include "./library/ctrl_codes.asm"	;control codes for BASIC-program
		include "./library/sys_vars_48.asm"	;BASIC 48 system variables
		include "./library/basic_line_v2.asm"	;1 - RUN USR X [LET X = Start_Address] (TR-DOS)
							;2 - RUN USR VAL "PEEK 23628*256+PEEK 23627" (TR-DOS/TAPE)
							;3 - user version

MergeProtect	equ 1					;0|1 - off/on protection from "MERGE"
HiddenLine	equ 1					;0|1 - off/on hiding a text of BASIC-line
CopyrightLine	equ 1					;0|1 - off/on copyright message

NumberLine	equ 0					;BASIC-line number
StartLine	equ NumberLine				;autostart line number
;-
		macro CopyrightText			;copyright message
		db AT,0,0				;message output position on the screen
		db BRIGHT,0,PAPER,0,INK,4
		db "    Basic Loader Creator 5.0    "
		db INK,6
		db "  (c) 07.12.2023 by Faster/HLM  "
		endm
;-
		org #5d3b				;beginning of a BASIC-program (#5d3b for TR-DOS, #5ccb for +3DOS/TAPE)

BasicFileStart	db high NumberLine,low NumberLine	;2 bytes of BASIC-line number

		if MergeProtect				;protection from "MERGE"
		dh ffff					;false length of BASIC-line
		else
		dw BasicVariables-BasicProg		;true length of BASIC-line
		endif
BasicProg
;-
		macro HiddenText n_bs, n_s		;hiding a text of BASIC-line
		if HiddenLine
        	dup n_bs
		db BACKSPACE
		edup
		dup n_s
		db " "
		edup
		endif
		endm
;-
		BasicLineCode
;-
		if CopyrightLine			;copyright message
		db ":",BACKSPACE," "
		CopyrightText
		endif
;-
;		dh 10ff					;an invalid INK value to hide the listing
		dh 0d					;the end of BASIC line
BasicVariables	ifused VarSymbol
		db VarSymbol				;BASIC variables area
		dw 0,CodeLoader				;numeric value of the variable (4 bytes instead of 5 are sufficient, 5th byte = 1st byte of code)
		endif
;-
CodeLoader	include	"./sources/code_loader.asm"	;code loader

BasicFileEnd
		display	' '
		display 'Basic loader address: ',/a,BasicFileStart
		display 'Start code: ',/a,CodeLoader
		display 'Length code: ',/a,(BasicFileEnd-BasicFileStart)-(BasicVariables-BasicFileStart)
		display	' '
		display	'Catalogue info: Start (BASIC file length): ',/d,BasicFileEnd-BasicFileStart
		display	'Catalogue info: Length (BASIC program length): ',/d,BasicVariables-BasicFileStart
		display 'Length in sectors: ',/d,low (BasicFileEnd-BasicFileStart)/#100+1
		display 'Free space for a hidden message: ',/a,#100*(low (BasicFileEnd-BasicFileStart)/#100+1)-(BasicFileEnd-BasicFileStart+2)
		display	' '

		if (_ERRORS = 0 && _WARNINGS = 0)
		labelslist 'c:\Users\Faster\Documents\Unreal\user.l'

		emptytrd 'BLC5_0.trd'
		savetrd 'BLC5_0.trd',|'boot.B',BasicFileStart,BasicFileEnd-BasicFileStart,NumberLine,BasicVariables-BasicFileStart

		emptytap "BLC5_0.tap"
		savetap "BLC5_0.tap",BASIC,'boot',BasicFileStart,BasicFileEnd-BasicFileStart,NumberLine,BasicVariables-BasicFileStart

		shellexec 'c:\Users\Faster\Documents\Unreal\unreal.exe ./BLC5_0.trd'
		endif