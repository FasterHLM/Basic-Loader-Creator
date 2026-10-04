;for Basic Loader Creator
;POKE 0,0:LIST [stream table] (TR-DOS or TAPE)

	macro HiddenNumber n	;the listing shows the digit "0", the real value is in the hidden 5-byte number
	db '0'		;visible placeholder digit
	dh "0e"		;marker "a 5-byte number follows" - LIST does not print it
	dh "00"		;exponent: zero means the short form for integers
	dh "00"		;sign: 00 plus, FF minus
	dw n		;the value itself, low byte first
	dh "00"		;fifth byte, the ROM does not read it for integers
	endm

	macro HiddenPokeStash addr,val,stash,width
			;POKE addr,val, but addr is stored not in the integer form but in the full one, where the mantissa is a fraction:
			;the exponent fixes the order 2^15, and the fraction stash/2^17 (below 0.5, which
			;FIND-INT2 drops when rounding) is added to the mantissa of addr. So the two low bytes of the mantissa are free for stash
			;(addr must fit in 16384..32767)
	assert addr >= #4000 && addr <= #7fff, HiddenPokeStash address must be #4000-#7FFF - the 2^15 exponent encodes nothing else
	dh "f4"		;POKE
	db '0'		;visible placeholder digit instead of the address
	dh "0e","8f"		;hidden-number marker and the order #8F, that is 2^15: the full form, not the short integer one
	db (addr>>7)&#7f,(addr<<1)&#ff	;high bytes of the mantissa - addr<<17. Its top bit is always 1 and so is taken by the sign: 0 is plus
	dw stash		;low bytes of the mantissa - the address of the code: a fraction below 0.5. Offset +6 from "f4"
	HiddenText width+1,0	;"POKE 0" - the count goes after the mantissa, not right after dh "f4": otherwise the BACKSPACEs would move stash off
			;the +6 offset the variant counts on
	db ','
	HiddenNumber val
	db ':'
	HiddenText 3,0
	endm

	struct ChanRec		;channel record
VectorOut	word		;output vector
VectorIn	word		;input vector
Letter	byte		;channel letter
	ends

	struct ChanArea		;channel area, CHANS points to it
K	ChanRec		;keyboard and the lower part of the screen
S	ChanRec		;main screen
R	ChanRec		;workspace, needed by the ROM itself
P	ChanRec		;printer
Term	byte		;#80 - end of the area
	ends

	macro BasicLineCode
	display 'BASIC listing: POKE ', /d, Stream2, ',', /d, low ChanOffset, ':LIST  [stream 2 -> ', /a, FakeChan, ' -> ', /a, CodeLoader, ']'
Stream2	equ sys48.STRMS+10	;stream 2 (the one PRINT and LIST print through) in the table: -3,-2,-1,0,1,2...
Chans	ChanArea = BasicFileStart-sizeof ChanArea
			;the channel area lies right under the BASIC program
	HiddenText 2,0		;"0>" - the line number that LIST prints before its text. Each part of the listing is erased right
			;after itself, so the next one is printed over it, and at the end only the widest
			;part is blanked out with spaces, not the whole line. These BACKSPACEs go before FakeChan: it counts its offset from $
FakeChan	equ $+6		;low bytes of the mantissa of the hidden address below - here, right inside the BASIC line, lie the two bytes of
			;CodeLoader
ChanOffset	equ FakeChan-Chans+1	;the stream table holds offsets from CHANS, shifted by one
	assert pair(0, low ChanOffset) = ChanOffset, stream 2 offset must fit the low byte - its high byte stays 0
			;POKE writes one byte, so the offset must fit in it: otherwise the assembler stays silent and
			;BASIC stops with the error "B Integer out of range"
	HiddenPokeStash Stream2,ChanOffset,CodeLoader,5
	assert {FakeChan} = CodeLoader, FakeChan must point at the word HiddenPokeStash hides in the mantissa
			;no variable is needed: the code address is hidden in the POKE itself, so the first byte of the code must itself be
			;#40 or higher (as in all variants without a variable), otherwise LIST will decide the program is over. The high
			;byte of the stream 2 offset (Stream2+1) is left alone - for stream 2 it is 0 by default anyway (offset 6
			;fits in the low byte)
	dh "f0"		;LIST - prints through stream 2, the very record substituted above, so the lookup leads to
			;FakeChan and calls the address that lies there
	HiddenText 5,4
	endm