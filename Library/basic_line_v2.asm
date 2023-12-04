//вариант формата бейсик-строки в бейсик-программе
//RUN USR VAL "PEEK 23628*256+PEEK 23627" (TR-DOS/TAPE)

        	macro BasicLineCode		
		dh f7c0					//RUN USR
		dh B022BE32333632382A			//VAL "PEEK 23628*
		if HiddenLine
		dup 26
		db BACKSPACE
		edup
		dup 26+3				//+3 байта, для переноса числа 256 на другую строку
		db " "
		edup
		endif
		dh 3235362BBE323336323722		//256+PEEK 23627"
		if HiddenLine
		dup 15					//длина 256+PEEK 23627"
		db BACKSPACE
		edup
		dup 15
		db " "
		edup
		endif

		if CopyrightLine			//отображение текстового сообщения в бейсик-строке
		db ":",BACKSPACE," "			//отделяем команду символом ":" и скрываем символ
		CopyrightText
		endif

//		dh 10ff					//вводим ошибочное значение INK, чтобы скрыть дальнейшее отображение листинга
		dh 0d					//конец бейсик-строки
BasicVariables
		endm