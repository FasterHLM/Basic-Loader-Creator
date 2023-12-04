//Code loader для Basic загрузчика
		ei
		ld a,(PROG)				//проверяем запущена ли программа в TR-DOS
		cp #3b
		jr z,TRDOS				//запущена в TR-DOS
Tape		ld a,#01			
		out (#fe),a
		ret

TRDOS		ld a,#02
		out (#fe),a
		ret