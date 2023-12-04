//вариант формата бейсик-строки в бейсик-программе
//RUN USR X [LET X = Start_Address] (TR-DOS)

		macro BasicLineCode
		dh f7c0					//RUN USR
    		db VarSymbol				//"X"
		if HiddenLine				//скрытие листинга
        	dup 11
		db BACKSPACE
		edup
		dup 11
		db " "
		edup
		endif

		if CopyrightLine			//отображение текстового сообщения в бейсик-строке
		db ":",BACKSPACE," "			//отделяем команду символом ":" и скрываем символ
		CopyrightText
		endif

//		dh 10ff					//вводим ошибочное значение INK, чтобы скрыть дальнейшее отображение листинга
		dh 0d					//конец бейсик-строки
BasicVariables	db VarSymbol				//область бейсик-переменных
		dw 0,Code				//числовое значение переменной (достаточно 4 байта вместо 5, 5-й байт = 1-му байту кода)
		endm