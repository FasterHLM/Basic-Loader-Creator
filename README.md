Basic Loader Creator (tr-dos/tape editions) for sjasmplus v1.22.0 and newer. Compiles a Basic Loader with code in a BASIC line for TR-DOS/TAPE.

Modular system for selecting different variants of the BASIC line:
- RUN USR X [LET X = START_ADDRESS] (TR-DOS or TAPE);
- RUN USR VAL "PEEK 23628*256+PEEK 23627" (TR-DOS and TAPE);
- RUN USR "DATE" (TR-DOS or TAPE);
- POKE 0,0:POKE 0,0:IN [ERR_SP] (TR-DOS or TAPE);
- POKE 0,0:POKE 0,0:PRINT [S-channel PR-OUT] (TR-DOS or TAPE);
- user-defined variant.

Miscellaneous options:
- protection against MERGE;
- hiding the BASIC line from LIST;
- copyright message;
- hidden message in the unused sectors of the .trd. (needs the next sjasmplus release - does not work on the current version)

## Building

```
powershell -executionpolicy bypass -file build.ps1
```

The BASIC line variants live in `src/basic_line/`: `var.asm`, `peek.asm`,
`string.asm`, `errsp.asm` and `chans.asm` (named after how each one reaches
`CodeLoader` — a BASIC variable, PEEK of system variables, a string literal, an
`ERR_SP` redirect, or a channel-vector redirect). `src/main.asm` includes one of
them (see the `include "basic_line/*.asm"` lines near the top of the file) —
comment/uncomment to switch; write your own `basic_line/custom.asm` for a sixth,
custom variant. Shared reference tables are in `src/lib/`: `ctrl_codes.asm` and the
system variable address tables `sys_vars_48.asm`, `sys_vars_128.asm`,
`sys_vars_2a_3.asm` and `sys_vars_trdos.asm` (include either the 128 or the +2A/+3
one, never both). Output in `build/`: `<PROJECT><VERSION>.tap` and
`<PROJECT><VERSION>.trd` (a single hidden BASIC file with the embedded machine code
loader).