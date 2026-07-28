;TR-DOS has no canonical variable names; these are ours, wrapped in MODULE trd (use trd.NAME)
	MODULE trd
IF1CHK	equ #5CB6	;used when an Interface 1 is present: if 244, the variables area is
		;not relocated, otherwise the byte at 23832 (IF1) is checked
		;#5CB7...#5CC1 (11 bytes) - not used
RET	equ #5CC2	;holds a RET instruction, used to call subroutines in the BASIC ROM
		;(switching the ROM back to BASIC)
		;#5CC3...#5CC7 (5 bytes) - not used
TYPE_A	equ #5CC8	;type of drive A: bit 7 = 0 for a 40-track drive, 1 for 80-track;
		;bit 1 = 0 single-sided, 1 double-sided;
		;bit 0 = 0 to use an 80-track drive as a 40-track one
TYPE_B	equ #5CC9	;type of drive B
TYPE_C	equ #5CCA	;type of drive C
TYPE_D	equ #5CCB	;type of drive D
CATSEC	equ #5CCC	;current sector while working with the catalogue
DELAY	equ #5CCD	;if not 0, delay after positioning. Also holds the VG93 status register
		;before a track check, and bit 7 of that status before reading an address marker
RWFLAG	equ #5CCE	;sector operation: 0 = read a sector, 255 = write a sector
WORKSP	equ #5CCF	;2 bytes - address of the working area for MOVE, COPY and LIST, while
		;processing a record number, and when writing to a direct-access data file
MVLEN	equ #5CD1	;length of the file being moved by MOVE
AUTOLINE	equ #5CD1	;2 bytes - autostart line number when saving a BASIC program
ARRNAME	equ #5CD2	;array name when saving/loading an array: bits 0-4 = name ("A" = 1 to
		;"Z" = 26), bit 5 = 0 for a numeric array, bit 6 = 1 for a string array, bit 7 always 1
MVSECCNT	equ #5CD3	;2 bytes - sector counter of the file being moved by MOVE
MVFILE	equ #5CD4	;number of the file being erased by MOVE
MVSEC	equ #5CD5	;current sector of the file being moved by MOVE
MVTRK	equ #5CD6	;current track of the file being moved by MOVE. Number of defective
		;sectors when formatting and verifying a disk
ERSEC	equ #5CD7	;current sector of the file being erased by MOVE. Number of tracks when
		;determining the drive type and when formatting
ERTRK	equ #5CD8	;current track of the file being erased by MOVE. If 0, a formatted
		;track is not verified
CHADD	equ #5CD7	;2 bytes - saves CH_ADD while processing a record number in a
		;sequential-access file. Address of a variable string length for the string-compression
		;subroutine. Address of the old array when loading an array. Sector address for PEEK and POKE
RECADDR	equ #5CD9	;relative address of a record while processing a record number in a
		;sequential-access file
BLOCK	equ #5CDA	;number of the opened block of a random-access file while processing a
		;record number. If 128, both sides are formatted, otherwise only one
FREESEC	equ #5CD9	;2 bytes - counter of sectors freed by MOVE. File load address for LOAD,
		;sector number for PEEK and POKE. Keyword address for the string-compression
		;subroutine. File length for SAVE
MVFSEC	equ #5CDB	;number of the loaded sector of a random-access file block while
		;processing a record number. Number of the first sector of the file being moved by MOVE
MVFTRK	equ #5CDC	;number of the first track of the file being moved by MOVE
LDLEN	equ #5CDB	;2 bytes - file length for LOAD. File length written to the catalogue
		;by SAVE. Stream number for CAT and LIST
		;#5CDD...#5CEC together form the 16-byte catalogue entry of the file
NAME	equ #5CDD	;8 bytes - file name, or disk name when formatting
EXT	equ #5CE5	;file extension (B, C, D or #)
FSTART	equ #5CE6	;2 bytes - file load address. Address of the sector table when formatting
FLENGTH	equ #5CE8	;2 bytes - file length. Address of the sector table when verifying a track
FSECTORS	equ #5CEA	;file size in sectors
FSEC	equ #5CEB	;number of the first sector of the file
FTRK	equ #5CEC	;number of the first track of the file
OLDSTART	equ #5CED	;2 bytes - load address of the old file for COPY
OLDLEN	equ #5CEF	;2 bytes - length of the old file in bytes for COPY
OLDSECS	equ #5CF1	;length of the old file in sectors for COPY
OLDSEC	equ #5CF2	;number of the first sector of the old file for COPY
OLDTRK	equ #5CF3	;number of the first track of the old file for COPY
CURSEC	equ #5CF4	;current sector number for the sector load/save subroutine
CURTRK	equ #5CF5	;current track number for the sector load/save subroutine
DRIVE	equ #5CF6	;2 bytes - drive number for the operation (0-3)
SRCDRV	equ #5CF8	;source drive for COPY. If 255, the file is not deleted when written
		;to the buffer
DSTDRV	equ #5CF9	;destination drive for COPY. Drive number when listing the catalogue.
		;File operation flag: 0 = load, 255 = verify
STEP_A	equ #5CFA	;head step rate for drive A (8-11)
STEP_B	equ #5CFB	;head step rate for drive B
STEP_C	equ #5CFC	;head step rate for drive C
STEP_D	equ #5CFD	;head step rate for drive D
CMD	equ #5CFE	;controller command for the sector read/write subroutine
SECTOR	equ #5CFF	;sector number for the sector read/write subroutine
SECADDR	equ #5D00	;2 bytes - sector address for the sector read/write subroutine
OLDHL	equ #5D02	;2 bytes - saves HL for the subroutine that calls BASIC ROM routines and 15635
OLDDE	equ #5D04	;2 bytes - saves DE
NAMELEN	equ #5D06	;number of bytes of the file descriptor compared when searching for a
		;file (interpreter command #0A). The initial value is #09
ERCOUNT	equ #5D07	;number of erased files, for the file-erase subroutine
FIRSTCH	equ #5D08	;first character of the file name, for the file-erase subroutine
OPENTYPE	equ #5D09	;data file type for OPEN# ("R", "W" or "RND")
		;#5D0B...#5D0C (2 bytes) - not used
BUFFLAG	equ #5D0C	;buffer presence flag: 0 = present, anything else = absent
COPYFILE	equ #5D0D	;current file number when copying a whole disk with two drives
WORKFLAG	equ #5D0E	;state of the working memory area: 255 = the area has been used,
		;254 = subroutine 963 ignores errors
ERROR	equ #5D0F	;TR-DOS error code. When searching for a file with subroutine 15635:
		;255 = file not found, otherwise the file number
OPFLAG	equ #5D10	;operation flag for the load/verify subroutine: 0 = operation on the whole
		;file, 255 = load/verify one sector of the file, anything else = write one sector
CMDLINE	equ #5D11	;2 bytes - address of the command line
ERRSP	equ #5D13	;2 bytes - saves ERR_SP for the return-to-BASIC subroutines
QUIET	equ #5D15	;if 0, error messages are printed on the screen, otherwise they are not
SYSREG	equ #5D16	;copy of the system register (port #FF)
BOOTFLAG	equ #5D17	;if 170, a call to 15612 does not show the splash screen; otherwise it is
		;shown and the byte at 23296 is checked - if that is not 170, the file "boot" is run
IF1	equ #5D18	;used when an Interface 1 is present: if not 0, the two 45-byte memory
		;blocks at 23747 and 23859 are swapped
DEFDRIVE	equ #5D19	;default drive number
RETADDR	equ #5D1A	;2 bytes - return address of the termination subroutine
SP	equ #5D1C	;2 bytes - saves SP for the return-to-BASIC subroutines
CATENTRY	equ #5D1E	;file number found by a search
CALLFROM	equ #5D1F	;how TR-DOS was called: 0 = from machine code, otherwise from BASIC.
		;Also the number of the first sector of the file on the destination disk for COPY S
LASTCMD	equ #5D20	;3 bytes - saves the first three characters of the command line
FIRSTPASS	equ #5D21	;if not 0, this is the first copying pass, otherwise a continuation
FREEMEM	equ #5D23	;amount of memory available to MOVE and COPY, in sectors
CHANS	equ #5D26	;21 bytes - the channel area, relocated by TR-DOS: #5D26 K, #5D2B S,
		;#5D30 R, #5D35 P, #5D3A end marker. On a plain 48K it sits at #5CB6 instead
PROG	equ #5D3B	;start of the BASIC program under TR-DOS (#5CCB without it)
		;-
		;cells used only while the system is being initialised
IF1TEST	equ #5C92	;20 bytes from 23698 (the MEMBOT area) hold the Interface 1 detection routine
INITHL	equ #5F00	;2 bytes - saves HL for the subroutine that executes instructions in RAM
		;#5F02...#5F0F (14 bytes) - not used
LDIR	equ #5F10	;3 bytes - block move subroutine (LDIR or LDDR)
TSTACK	equ #5F13	;237 bytes - temporary stack
	ENDMODULE
;-
;cells where the two books disagree - Fedin (used above) vs Larchenko/Rodionov:
;#5CCD  delay after positioning / VG93 status   vs  #80 = drive ready
;#5CD6  current track of the moved file, and    vs  #FF = the command was accepted
;       the count of defective sectors              by the syntax analyser
;#5CD7  saves CH_ADD (2 bytes)                  vs  CH_ADD analogue is at #5CD9
;#5CEF  length of the old file for COPY         vs  holds 1 if an Interface 1 is present
;#5CF6  drive number, 2 bytes                   vs  1 byte, with a separate #5CF7
;                                                   that is zeroed on return from 15616
;#5D0E  state of the working area (255/254)     vs  #FE = BASIC owns the command,
;                                                   anything else = TR-DOS
;#5D10  load/verify operation flag              vs  high byte of the error code
;#5D15  0 = error messages are printed          vs  #AA = messages are printed
;Larchenko/Rodionov also list #5D14 (23828) as meaningful when it holds #AA; Fedin
;does not list that cell at all. Their table stops at #5D20 and does not cover
;#5D1F, #5D21, #5D23, the channel area or the initialisation cells
