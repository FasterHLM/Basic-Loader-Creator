//basic loader creator v5.0 (tr-dos/tape editions) for sjasmplus 1.18.3 or newer.
//© 2010-2011, 2013, 2021, 2023 all rights reserved by Faster/HLM.

		device zxspectrum48                   

		include "./library/ctrl_codes.asm"	//управляющие коды для использования в бейсик-программе
		include "./library/sys_vars_48.asm"	//системные переменные Basic sys_vars_48
		include "./library/basic_line_v2.asm"	//1 - RUN USR X [LET X = Start_Address] (TR-DOS)
							//2 - RUN USR VAL "PEEK 23628*256+PEEK 23627" (TR-DOS/TAPE)
							//3 - пользовательский вариант

MergeProtect	equ 1					//0|1 - выкл/вкл защита от комадны MERGE
HiddenLine	equ 1					//0|1 - выкл/вкл отображения листинга бейсик-строки
CopyrightLine	equ 1					//0|1 - выкл/вкл текстового сообщения в бейсик-строке

NumberLine	equ 0					//номер бейсик-строки
StartLine	equ NumberLine				//номер строки автостарта
VarSymbol	equ "X"|#20				//символ для RUN USR приведенный к нижнему регистру

		macro CopyrightText			//текст сообщения в бейсик-строке
		db AT,0,0				//позиция вывода сообщения на экран
		db BRIGHT,0,PAPER,0,INK,4
		db "    Basic Loader Creator 5.0    "
		db INK,6
		db "  (c) 04.12.2023 by Faster/HLM  "
		endm

		org #5d3b				//начало бейсик-программы (#5d3b - для TR-DOS, #5ccb - для +3DOS/TAPE)

BasicFileStart	db high NumberLine,low NumberLine	//2 байта номера бейсик-строки

		if MergeProtect				//2 байта длины бейсик-строки
		dw #ffff				//фальшивая длина строки
		else
		dw BasicVariables-BasicProg		//реальная длина строки
		endif
BasicProg
		BasicLineCode

Code		include	"./sources/code_loader.asm"	//код загрузчика

BasicFileEnd
		display	' '
		display 'Basic loader address: ',/a,BasicFileStart
		display 'Start code: ',/a,Code
		display 'Length code: ',/a,(BasicFileEnd-BasicFileStart)-(BasicVariables-BasicFileStart)
		display	' '
		display	'Catalogue info: Start (basic file length): ',/d,BasicFileEnd-BasicFileStart
		display	'Catalogue info: Length (basic program length): ',/d,BasicVariables-BasicFileStart
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