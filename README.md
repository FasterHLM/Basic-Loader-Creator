# Basic Loader Creator

Basic Loader Creator (tr-dos/tape editions) for sjasmplus v1.24.0 and newer. Compiles a Basic Loader for TR-DOS/TAPE with the machine code hidden right after its single BASIC line.

## How it works

The output is one BASIC file: a program of a single line, with the machine code right behind it.

## Variants

Modular system for selecting different variants of the BASIC line:
- `var` — IF USR x [x = START_ADDRESS] (TR-DOS or TAPE);
- `peek` — IF USR VAL "PEEK 23628*256+PEEK 23627" (TR-DOS and TAPE);
- `string` — IF USR \<build date\> (TR-DOS or TAPE);
- `errsp` — POKE 0,0:POKE 0,0 [ERR_SP] (TR-DOS or TAPE);
- `udg` — POKE 0,0:POKE 0,0:IF USR USR "a" [UDG] (TR-DOS or TAPE);
- `strms` — POKE 0,0:LIST [stream table] (TR-DOS or TAPE);
- user-defined variant.

*or* — the code address is hard-coded for one `org`, so the file is built either for disk or for
tape; *and* — one file works for both.

## Options

Miscellaneous options:
- protection against MERGE;
- hiding the BASIC line from LIST;
- copyright message;
- hidden message in the free space of the last sector: it is not counted in the file length in the catalogue, so TR-DOS never loads it and file viewers do not show it (TR-DOS only, not written to the .tap).

## Building

You need [sjasmplus](https://github.com/z00m128/sjasmplus/releases) v1.24.0 or newer, built with Lua
support (the official binaries are; `src/lua/` relies on it), and Windows PowerShell 5.1, the
`powershell` that ships with Windows. `build.ps1` looks for `sjasmplus.exe` in this order: in the
folder named by the `ZXDEV_TOOLS` environment variable; in a `tools` folder inside the project
folder or in any folder above it; on `PATH`. The first two expect the layout of zxdev, the
author's development environment (the name of the top folder does not matter, and the project
may sit at any depth below the folder that holds `tools`):

```
zxdev\
├─ tools\
│  ├─ sjasmplus\
│  │  └─ sjasmplus.exe
│  └─ emuls\
│     └─ Unreal\
│        └─ unreal.exe	// only for build.ps1 -Run
└─ zx_spectrum\projects\Basic-Loader-Creator\
   ├─ build.ps1
   └─ src\main.asm
```

```
powershell -executionpolicy bypass -file build.ps1
```

The script creates `build/` itself, assembles `src/main.asm` and writes the `.trd` / `.tap` file(s) there. Without
PowerShell, call the assembler directly — but `build/` is not in the repository and has to exist first:

```
mkdir build
sjasmplus --nologo src/main.asm
```

`build.ps1 -Run` also launches Unreal Speccy, but only when the `tools` folder it found holds
`emuls\Unreal\unreal.exe` (see the layout above); with `sjasmplus` taken from `PATH`, or with no
emulator there, it just prints a message, and you open the file from `build/` in your own
emulator.

## Project layout

- `src/main.asm` — the only file to edit per project. It holds:
  - the choices: which BASIC line variant, the option flags, the output names, the output
    format and the disk label, the copyright and hidden-message text;
  - the `Loader` macro with the machine code the BASIC line runs (replace its body with your
    own) and the `Breakpoints` macro next to it;
  - the `savetrd`/`savetap` calls that write the output, each inside its own
    `if OutputFormat` block.
- `src/make_loader.asm` — the engine: it assembles the loader from those choices and normally
  needs no changes. The autostart marker is written by `SAVETRD` itself, right after the end
  of the file (the program and the variables area with the code), in the free space of the
  same sector.
- `src/basic_line/` — the BASIC line variants, one per file: `var.asm`, `peek.asm`,
  `string.asm`, `errsp.asm`, `udg.asm` and `strms.asm`. They are named after how each one
  reaches `CodeLoader`: a BASIC variable, PEEK of system variables, a number hidden behind
  date-like text, an `ERR_SP` redirect, the `UDG` system variable behind `USR USR "a"`, an
  entry in the stream table. `src/main.asm` includes one of them (see the
  `include "basic_line/*.asm"` lines near the top of the file) — comment/uncomment to switch.
  Write your own `basic_line/custom.asm` for a seventh, custom variant.
- `src/lua/` — two pieces of embedded Lua:
  - `build_date.asm` turns `__DATE__` into the define `BuildDate` ("DD.MM.YYYY") used by the
    copyright message and the `string` variant; it is marked `lua allpass` because the define
    is needed on all three passes;
  - `hidden_message.asm` runs after `savetrd` and writes the hidden message straight into the
    disk image behind the autostart marker, so it lands in the file's sector without counting
    towards the file length or the sector count in the catalogue.
- `src/lib/` — shared reference tables: `ctrl_codes.asm` and the system variable address
  tables `sys_vars_48.asm`, `sys_vars_128.asm`, `sys_vars_2a_3.asm` and `sys_vars_trdos.asm`
  (include either the 128 or the +2A/+3 one, never both).

## Output

The files go to `build/` and are named `<PROJECT> <VERSION>` plus an extension. The extension
is chosen by `define run` in `src/main.asm`:

- `define run "trd"` — the disk image only;
- `define run "tap"` — the tape only;
- no `define run` — both files.

Besides that:

- the same define names the file `build.ps1 -Run` launches; without it the script picks one by
  extension priority;
- either way the output is a single BASIC file with the embedded machine code loader;
- the format does not move the code: the BASIC program address is set by `org` (`#5D3B` under
  TR-DOS, `#5CCB` from tape) and is changed by hand;
- a tape-only build skips everything that concerns the TR-DOS image alone: sectors and the
  hidden message are neither counted nor checked, and the summary shows the tape header
  lengths instead of the catalogue.

## Pitfalls

- The `HiddenText` counts in `src/basic_line/*.asm` are computed for a single-digit line
number. `LIST` prints the number in a fixed-width field, so with `NumberLine equ 10` or
`100` the visible line number grows by one column per extra digit and the line is no longer
fully hidden — silently, without errors or warnings. Add 1 per extra digit to the first
number of the variant's first `HiddenText` call; leave the other counts alone, since each
one measures its own piece of the listing, which does not depend on the line number (see
the comment next to `NumberLine` in `src/main.asm`).
- `NumberLine` ships as 0 on purpose: the ROM editor cannot retype, replace or erase line 0 (a
line typed with number 0 is executed as a direct command instead), which protects the loader
from editing. The price is the disk autostart: it needs 1..9999, because TR-DOS reads 0 in the autostart
marker as "no autostart", so `LOAD "<file>"` would load the program without starting it
(from tape 0 runs as well). The `assert` in `src/make_loader.asm` fails the build above
9999, because `SAVETRD` only warns about a larger number, writes no autostart marker and
leaves the image written anyway — the warning arrives after the clean-build check.
- Variants that create no BASIC variable (`peek`, `string`, `errsp`, `udg`, `strms`) put
the machine code right at `VARS`, so its first byte must be `#40` or higher: `LIST` takes
that byte as the end-of-program marker, and a lower one would be read as the next line's
number. The sample `Loader` starts with `di` (`#F3`); the variant
with a variable (`var`) is safe, since its variables area then starts with the name `x`
(`#78`). The build enforces this: it reads the first code byte and fails if the
rule is broken.
- The date in the copyright message and in the `string` variant is the build date, taken
from sjasmplus `__DATE__`. Rebuilding on another day changes the bytes of the output, so
build the release `.trd`/`.tap` on the release day.

## License

MIT, see [LICENSE](LICENSE).
