Basic Loader Creator (tr-dos/tape editions) для sjasm v1.18.3 и новее. Компилирует Basic Loader с кодом в бейсик-строке для TR-DOS/TAPE.

Модульная система подключения различных вариантов бейсик-строки:
- RUN USR X [LET X = Start_Address] (TR-DOS);
- RUN USR VAL "PEEK 23628*256+PEEK 23627" (TR-DOS/TAPE);
- пользовательский вариант бейсик-строки.

Различные опции:
- защита от команды MERGE;
- скрытие листинга бейсик-строки;
- текстовое сообщение-copyright в бейсик строке.
