;for Basic Loader Creator
;POKE 0,0:POKE 0,0 [ERR_SP] (TR-DOS or TAPE)

	macro HiddenNumber n	;the listing shows the digit "0", the real value is in the hidden 5-byte number
	db '0'		;visible placeholder digit
	dh "0e"		;marker "a 5-byte number follows" - LIST does not print it
	dh "00"		;exponent: zero means the short form for integers
	dh "00"		;sign: 00 plus, FF minus
	dw n		;the value itself, low byte first
	dh "00"		;fifth byte, the ROM does not read it for integers
	endm

	macro HiddenPokeLast addr,val,width
			;POKE addr,val with both operands hidden from LIST. It is the last one in the
			;line, with no colon after it: the ROM checks the end of a statement in STMT-NEXT ($1BF4) and
			;sends everything except ":" and #0D to REPORT-C - so a trap byte after the POKE is enough, and
			;a colon before it would only take up space
	dh "f4"		;width is the width of "POKE " in the listing: 5 at the start of the line and 6 after
	HiddenText width,0	;":" - LIST prints a space before the statement
	HiddenNumber addr
	db ','
	HiddenText 2,0
	HiddenNumber val
	HiddenText 1,0		;"0" - back one column: there is no colon after the number any more
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

	macro BasicLineCode
	display 'BASIC listing: POKE ', /d, sys48.ERR_SP, ',', /d, low ErrStack, ':POKE ', /d, sys48.ERR_SP+1, ',', /d, high ErrStack, ' [ERR_SP -> ', /a, ErrStack, ' -> ', /a, CodeLoader, ']'
	HiddenText 2,0		;"0>" - the line number that LIST prints before its text. Each part of the listing is erased right
			;after itself, so the next one is printed over it, and at the end only the widest
			;part is blanked out with spaces, not the whole line. These BACKSPACEs go before ErrStack: it counts its offset from $
ErrStack	equ $+6		;low bytes of the mantissa of the hidden address below - here, right inside the BASIC line, lie the two bytes of
			;CodeLoader. On an error the ROM does LD SP,(ERR_SP) and RET, which takes this address from there
	HiddenPokeStash sys48.ERR_SP,low ErrStack,CodeLoader,5
	HiddenPokeLast sys48.ERR_SP+1,high ErrStack,6
	assert {ErrStack} = CodeLoader, ErrStack must point at the word HiddenPokeStash hides in the mantissa
			;no variable is needed, the code address is hidden in the POKE itself - so the first byte of the code
			;must be #40 or higher (as in all variants without a variable), otherwise LIST will decide the program is over
NoCopyrightSep	equ 0		;the error falls on the trap byte below, the copyright text after the line is never reached
	dh "80"		;trap byte: error C, "Nonsense in BASIC". What follows the POKE is neither ":" nor the end of the line, and
			;the end-of-statement check raises the error right on this byte - and the error is the start of the code.
			;Any byte from #21 will do except ":"; a smaller one the ROM skips as a space or a control
			;code, and without the copyright it would get to #0D, that is the normal end of the line. #80 is taken because
			;it is the first of the block graphics - all four of its quarters are empty, and in the listing it
			;is indistinguishable from a space. A token (also a single byte) will not do: the ROM prints it together with
			;a companion space, and a stray "?" is left next to it in the listing
	HiddenText 2,6		;erase after yourself: two BACKSPACEs to the first occupied column and six spaces over the
			;widest part of the listing - "POKE 0". Needed even with the copyright on: it prints AT 0,0 and
			;covers only the top rows, while LIST (unlike auto-list) does not clear the screen, and
			;the listing may start lower - then without the erasing a tail of "POKE" would remain there
	endm