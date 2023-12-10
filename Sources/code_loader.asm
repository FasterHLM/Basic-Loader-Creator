;Code loader for Basic file
		ei
		ld a,(PROG)				;check if the program is running in TR-DOS
		cp #3b
		jr z,TRDOS				;running in TR-DOS
Tape		ld a,#01			
		out (#fe),a
		ret

TRDOS		ld a,#02
		out (#fe),a
		ret