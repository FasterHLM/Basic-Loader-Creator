SWAP	equ #5B00	;paging subroutine
STOO	equ #5B10	;paging subroutine. Entered with interrupts already disabled and AF, BC
		;on the stack
YOUNGER	equ #5B21	;paging subroutine
REGNUOY	equ #5B2A	;paging subroutine
ONERR	equ #5B3A	;paging subroutine
OLDHL	equ #5B52	;2 bytes - temporary store for HL while switching ROMs
OLDBC	equ #5B54	;2 bytes - temporary store for BC while switching ROMs
OLDAF	equ #5B56	;2 bytes - temporary store for AF while switching ROMs
;-
;#5B58...#5B66 - the only block shared with the original 128/+2
TARGET	equ #5B58	;2 bytes - subroutine address in ROM 3
RETADDR	equ #5B5A	;2 bytes - return address in ROM 1
BANKM	equ #5B5C	;copy of the last byte written to port #7FFD. The port is write-only, so
		;this copy must be kept up to date - always write here as well as to the port:
		;bits 0-2 RAM page (0-7) paged into #C000
		;bit 3 screen select (0 = normal, page 5; 1 = shadow, page 7)
		;bit 4 ROM select (0 = 128K editor ROM, 1 = 48K BASIC ROM)
		;bit 5 disables further paging until the machine is reset
RAMRST	equ #5B5D	;an RST 8 instruction. Used by ROM 1 to report old errors to ROM 3
RAMERR	equ #5B5E	;error number passed from ROM 1 to ROM 3. Also used by SAVE and LOAD as a
		;temporary drive store
BAUD	equ #5B5F	;2 bytes - RS232 bit period in T states/26. Set by FORMAT LINE
SERFL	equ #5B61	;2 bytes - second-character-received flag, and the data itself
COL	equ #5B63	;current column, from 1 to WIDTH
WIDTH	equ #5B64	;paper column width. Defaults to 80
TVPARS	equ #5B65	;number of inline parameters expected by RS232
FLAGS3	equ #5B66	;flags controlling token expansion, RS232/Centronics output, the disk
		;interface and the presence of drive B
;-
;+2A/+3 only - on the original 128/+2 this range holds the RAM disk control block,
;the external keypad bitmaps and the renumbering variables instead
BANK678	equ #5B67	;copy of the last byte written to port #1FFD, controlling RAM/ROM switching,
		;the disk motor and the Centronics strobe. Like BANKM, keep this copy up to date
XLOC	equ #5B68	;X location used by the unexpanded COPY command
YLOC	equ #5B69	;Y location used by the unexpanded COPY command
OLDSP	equ #5B6A	;2 bytes - old stack pointer, saved while TSTACK is in use
SYNRET	equ #5B6C	;2 bytes - return address for ONERR
LASTV	equ #5B6E	;#5B6E...#5B72 - last value printed by the calculator (5 bytes)
RCLINE	equ #5B73	;2 bytes - line currently being renumbered
RCSTART	equ #5B75	;2 bytes - first line number for renumbering. Defaults to 10
RCSTEP	equ #5B77	;2 bytes - renumbering step. Defaults to 10
LODDRV	equ #5B79	;holds 'T' if LOAD, VERIFY and MERGE read from tape, otherwise 'A', 'B' or 'M'
SAVDRV	equ #5B7A	;holds 'T' if SAVE writes to tape, otherwise 'A', 'B' or 'M'
DUMPLF	equ #5B7B	;line feed count for COPY EXP. Normally 9; adjust it to fit A4 paper
STRIP1	equ #5B7C	;8 bytes - stripe one bitmap
STRIP2	equ #5B84	;#5B84...#5B8B - stripe two bitmap (8 bytes)
TSTACK	equ #5BFF	;temporary stack, growing down from here (up to 115 bytes). Used when RAM
		;page 7 is paged in at the top of memory