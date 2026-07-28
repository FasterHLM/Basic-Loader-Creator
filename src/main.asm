;Basic Loader Creator v5.2 (tr-dos/tape editions) for sjasmplus 1.22.0 or newer.
;(c) 2010-2011, 2013, 2021, 2023, 2026 by Faster/HLM. All rights reserved.

	define emul "unreal"		;emulator to launch: unreal | cspect

	define project "blc"		;output file names: build/<project><version>.tap/.trd
	define version "5.2"		;appended to <project> for output file names

	define file "boot"		;name of the file INSIDE .tap/.trd (max 8 characters for TR-DOS)
	define run "trd"		;force which build/<project><version>.<run> file to launch

	device zxspectrum48
	sldopt comment wpmem, logpoint, assertion

	include "lib/ctrl_codes.asm"		;control codes for a BASIC program
	include "lib/sys_vars_48.asm"		;BASIC 48 system variables
;	include "lib/sys_vars_trdos.asm"	;TR-DOS (#5CB6...#5D3A, plus init cells)	

	include "basic_line/var.asm"		;var    - RUN USR X [LET X = Start_Address] (TR-DOS or TAPE)
;	include "basic_line/peek.asm"		;peek   - RUN USR VAL "PEEK 23628*256+PEEK 23627" (TR-DOS and TAPE)
;	include "basic_line/string.asm"		;string - RUN USR "10.12.2023" (TR-DOS or TAPE)
;	include "basic_line/errsp.asm"		;errsp  - POKE 0,0 : POKE 0,0 : IN (TR-DOS or TAPE)
;	include "basic_line/chans.asm"		;chans  - POKE 0,0 : POKE 0,0 : PRINT (TR-DOS or TAPE)
				;custom - user-defined variant (write your own basic_line/custom.asm)

MergeProtect	equ 1			;0|1 - off/on protection against MERGE
HiddenLine	equ 1			;0|1 - off/on hiding the BASIC line from LIST
HiddenMessage 	equ 0			;0|1 - off/on a hidden message in the .trd's padding sectors
				;NOTE: needs the next sjasmplus release - does not work on the current version
CopyrightLine 	equ 1			;0|1 - off/on copyright message

NumberLine 	equ 0			;BASIC line number
StartLine 	equ NumberLine			;autostart line number
;-
	macro CopyrightText		;copyright message
	db AT,0,0			;message output position on the screen
	db BRIGHT,0,PAPER,0,INK,4
	db "    Basic Loader Creator 5.2    "
	db INK,6
	db "  (c) 28.07.2026 by Faster/HLM  "
	endm
;-
	org #5d3b			;beginning of a BASIC program (#5d3b for TR-DOS, #5ccb for +3DOS/TAPE)
;	org #5ccb

BasicFileStart
	db high NumberLine,low NumberLine	;2 bytes of the BASIC line number

	if MergeProtect			;protection against MERGE
	dh ffff			;false length of the BASIC line
	else
	dw BasicVariables-BasicProg		;true length of the BASIC line
	endif
BasicProg
;-
	macro HiddenText n_bs,n_s		;hiding the BASIC line from LIST
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
	if CopyrightLine		;copyright message
	db ":",BACKSPACE," "
	CopyrightText
	endif
;-
;	dh 10ff			;an invalid INK value to hide the listing
	dh 0d			;the end of the BASIC line
BasicVariables	ifused VarSymbol
	db VarSymbol			;BASIC variables area
	dw 0,CodeLoader			;numeric value of the variable (4 bytes instead of 5 suffice, 5th byte = 1st byte of the code)
	endif
;-
CodeLoader	include "code_loader.asm"

BasicFileEnd

	if HiddenMessage
HiddenStart
	db "(c) Faster/HLM 2026"		;hidden message text (any non-empty length)
HiddenEnd

HiddenLen	equ HiddenEnd-HiddenStart

;total data = BASIC + message; round up to the nearest 256-byte sector boundary
TotalLen	equ (BasicFileEnd-BasicFileStart)+HiddenLen
FullSize	equ ((TotalLen+#ff)/#100)*#100		;rounded up to multiple of 256
Slack	equ FullSize-(BasicFileEnd-BasicFileStart)	;total space for message + padding
Pad	equ Slack-HiddenLen		;zeroes after the message

	ds Pad,0			;pad up to the sector boundary with zeroes
BasicFileFull
	endif
;-
	display ' '
	display 'Basic loader address:                        ', /a, BasicFileStart
	display 'Code entry point:                            ', /a, CodeLoader
	display 'Code + variables length:                     ', /a, (BasicFileEnd-BasicFileStart)-(BasicVariables-BasicFileStart)
	display ' '
	display 'Catalogue info: Start - total file length:   ', /d, BasicFileEnd-BasicFileStart
	display 'Catalogue info: Length - BASIC only:         ', /d, BasicVariables-BasicFileStart
	display 'Logical size in sectors (BASIC):             ', /d, (BasicFileEnd-BasicFileStart+#ff)/#100

	if HiddenMessage
	display ' '
	display 'Hidden message length:                       ', /d, HiddenLen
	display 'Padding zeroes:                              ', /d, Pad
	display 'Physical .trd length (BASIC + message):      ', /d, BasicFileFull-BasicFileStart
	display 'Physical .trd size in sectors:               ', /d, FullSize/#100
	endif

	display ' '

	if (_ERRORS = 0 && _WARNINGS = 0)
	emptytrd "build/" .. project .. version .. ".trd"
	savetrd "build/" .. project .. version .. ".trd", file .. ".B", BasicFileStart, BasicFileEnd-BasicFileStart, NumberLine, BasicVariables-BasicFileStart

	emptytap "build/" .. project .. version .. ".tap"
	savetap "build/" .. project .. version .. ".tap", basic, file, BasicFileStart, BasicFileEnd-BasicFileStart, NumberLine, BasicVariables-BasicFileStart
	endif