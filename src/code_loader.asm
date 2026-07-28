;Code loader for the Basic file
	di
	ld a,(PROG)		;check whether the program is running under TR-DOS
	cp #3b
	ld a,#01		;assume tape
	jr nz,.done
	inc a		;#02 - TR-DOS
.done:
	out (#fe),a
	halt