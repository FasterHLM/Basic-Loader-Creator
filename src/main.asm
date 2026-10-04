;Basic Loader Creator v6.0 (tr-dos/tape editions) for sjasmplus 1.24.0 or newer.
;(c) 2010-2011, 2013, 2021, 2023, 2026 by Faster/HLM.

	device zxspectrum48
	opt --syntax=s			;define is substituted for whole words only, otherwise define file, diskname, run,
				;project, version, emul would also replace parts of labels separated by "_"
	define emul "unreal"		;which emulator to launch. Only unreal fits here
;-
	define project "Basic Loader Creator"	;output file names: build/<project> <version>.trd or .tap
	define version "v6.0"		;appended to <project> with a space in the output file names

	define file "boot"		;file name INSIDE the .tap/.trd (no longer than 8 characters for TR-DOS)
	define diskname "BLC " .. version	;TR-DOS disk label: 8 characters (up to 11 with sjasmplus 1.24.1)
	define run "trd"		;build format and file to launch: "trd" - disk image only, "tap" - tape only
				;comment out to build both
;-
	include "lib/ctrl_codes.asm"		;BASIC control codes
	include "lib/sys_vars_48.asm"		;BASIC 48 system variables

;	include "basic_line/var.asm"		;var      - IF USR x [x = Start_Address] (TR-DOS or TAPE)
;	include "basic_line/peek.asm"		;peek     - IF USR VAL "PEEK 23628*256+PEEK 23627" (TR-DOS and TAPE)
;	include "basic_line/string.asm"		;string   - IF USR <build date> (TR-DOS or TAPE)
;	include "basic_line/errsp.asm"		;errsp    - POKE 0,0:POKE 0,0 [ERR_SP] (TR-DOS or TAPE)
;	include "basic_line/udg.asm"		;udg      - POKE 0,0:POKE 0,0:IF USR USR "a" [UDG] (TR-DOS or TAPE)
	include "basic_line/strms.asm"		;strms    - POKE 0,0:LIST [stream table] (TR-DOS or TAPE)
				;custom   - your own variant (write basic_line/custom.asm)
;-
	define MergeProtect		;protection against MERGE
	define HiddenLine		;hiding the BASIC line from LIST
	define CopyrightLine		;copyright message
	define HiddenMessage		;hidden message in the free space of the last sector, behind the autostart marker: it is
				;not part of the file length in the catalogue. TR-DOS only, not written to the .tap

StartOrg	equ #5d3b			;start of the BASIC program (#5d3b for TR-DOS, #5ccb for +3DOS/TAPE)
NumberLine	equ 0			;BASIC line number. For a disk autostart it must be at least 1: TR-DOS reads 0 in the
				;autostart marker as "no autostart", so LOAD "<file>" only loads the program without
				;starting it. From tape 0 starts too. The limit 0..9999 is checked by the assert in
				;make_loader.asm. NOTE: the HiddenText counts in basic_line/*.asm are computed for a
				;single-digit number. LIST prints the number in a fixed-width field, so the visible part
				;of the number grows from "0>" (2 columns) to "10>" (3) or "100>" (4), while the start
				;of the text stays in place. The variant's first HiddenText then falls short of the
				;start - the line is no longer overwritten completely, silently, with no errors or warnings.
				;Fix: for each extra digit add 1 to the first number of the FIRST HiddenText call of the
				;variant. Leave the other counts alone: each one measures its own part of the
				;listing, which does not depend on the line number
;-
	macro CopyrightText		;copyright message
	db AT,0,0			;screen position of the message
	db BRIGHT,0,PAPER,0,INK,4
	db "    Basic Loader Creator ", version, "   "	;width is 32 characters
	db INK,6
	db "  (c) ", BuildDate, " by Faster/HLM  "
	endm

	macro HiddenMessageText		;message text
	db "          hello world!          "
	endm
;-
	macro Loader			;the code the BASIC line starts. The example below shows with the border colour where
				;the program was loaded from, and stops. If the variant creates no variable (peek,
				;string, errsp, udg, strms), the first byte of the code must be #40 or higher: LIST
				;takes it as the end of the program (here it is di, #F3). The build checks this itself
				;and fails if it is violated
	di
	ld a,(sys48.PROG+1)		;high byte of PROG: #5D under TR-DOS (#5D3B), #5C from tape (#5CCB)
	sub #5b			;border: #02 red - TR-DOS, #01 blue - tape
	out (#fe),a
	halt			;just stop the program, otherwise some basic_line variants would reset
	endm
;-
	macro Breakpoints		;breakpoints for the Unreal debugger: setbp can be repeated to set a stop on
;	setbp CodeLoader		;any label
	endm
;-
	ifdef run			;define run sets not only the file to launch but also the build format: "trd" - only the
	define OutputFormat run		;disk image, "tap" - only the tape. Without define run both are written
	else
	define OutputFormat "both"
	endif
	assert OutputFormat = "trd" || OutputFormat = "tap" || OutputFormat = "both", DEFINE RUN must be "trd" or "tap" - this project builds no other format

	org StartOrg

	include "lua/build_date.asm"		;define BuildDate - the build date from __DATE__
	include "make_loader.asm"		;assembles the loader from the choices made above
;-
	if __ERRORS__ = 0 && __WARNINGS__ = 0	;files are written only by a clean build, without errors or warnings
	define OutputName "build/" .. project .. " " .. version	;common part of the output file names

	if OutputFormat = "trd" || OutputFormat = "both"
	emptytrd OutputName .. ".trd", diskname	;empty disk image with the diskname label
	savetrd OutputName .. ".trd", file .. ".B", BasicFileStart, TrdLength, NumberLine, BasicVariables-BasicFileStart
	ifdef HiddenMessage
	include "lua/hidden_message.asm"	;hidden message - onto the trd image, behind the autostart marker
	endif
	endif

	if OutputFormat = "tap" || OutputFormat = "both"
	emptytap OutputName .. ".tap"
	savetap OutputName .. ".tap", basic, file, BasicFileStart, BasicFileEnd-BasicFileStart, NumberLine, BasicVariables-BasicFileStart
	endif

	bplist "build/bpx.ini" unreal		;breakpoints for the Unreal debugger
	Breakpoints			;expands the list from the macro above, after bplist
	endif