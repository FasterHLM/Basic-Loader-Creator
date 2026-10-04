# build.ps1 - sjasmplus build + emulator launch driven by define emul "..." in the source file
#   .\build.ps1                          - build src\main.asm
#   .\build.ps1 -Run                     - build + launch the emulator (unreal / cspect)
#   .\build.ps1 -DebugEmu                - build + CSpect in DeZog mode (-remote), used by F5 in VS Code
#   .\build.ps1 -ActiveFile <path.asm>   - build that file instead of src\main.asm (must live under src\);
#                                           ignored (falls back to src\main.asm) if outside src\, not .asm, or missing
param(
    [switch]$Run,
    [switch]$DebugEmu,
    [string]$ActiveFile = ''
)
$ErrorActionPreference = 'Stop'
$ProjectDir = $PSScriptRoot
$SrcDir     = Join-Path $ProjectDir 'src'
$Src        = Join-Path $SrcDir 'main.asm'
if ($ActiveFile) {
    $resolved = $ActiveFile
    if (-not [System.IO.Path]::IsPathRooted($resolved)) { $resolved = Join-Path $ProjectDir $resolved }
    $resolved = [System.IO.Path]::GetFullPath($resolved)
    $srcDirFull = [System.IO.Path]::GetFullPath($SrcDir)
    if ($resolved.ToLower().EndsWith('.asm') -and $resolved.StartsWith($srcDirFull + [System.IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase) -and (Test-Path -LiteralPath $resolved)) {
        $Src = $resolved
    }
}
$BaseName   = [System.IO.Path]::GetFileNameWithoutExtension($Src)
$SrcRel     = ($Src.Substring($ProjectDir.Length).TrimStart('\', '/')).Replace('\', '/')
$BuildDir   = Join-Path $ProjectDir 'build'

# --- locate sjasmplus: tools folder (ZXDEV_TOOLS or upward search), PATH otherwise ---
function Find-Tools {
    if ($env:ZXDEV_TOOLS -and (Test-Path (Join-Path $env:ZXDEV_TOOLS 'sjasmplus\sjasmplus.exe'))) {
        return $env:ZXDEV_TOOLS
    }
    $d = $ProjectDir
    while ($true) {
        $t = Join-Path $d 'tools'
        if (Test-Path (Join-Path $t 'sjasmplus\sjasmplus.exe')) { return $t }
        $p = Split-Path $d -Parent
        if (-not $p -or $p -eq $d) { break }
        $d = $p
    }
    return $null
}
$Tools = Find-Tools
if ($Tools) {
    $Sjasm = Join-Path $Tools 'sjasmplus\sjasmplus.exe'
} elseif (Get-Command sjasmplus -ErrorAction SilentlyContinue) {
    $Sjasm = 'sjasmplus'   # from PATH (building outside the zxdev environment)
} else {
    throw 'sjasmplus not found: no tools folder (or ZXDEV_TOOLS) and nothing in PATH. Get it at https://github.com/z00m128/sjasmplus'
}

New-Item -ItemType Directory -Force $BuildDir | Out-Null

# breakpoint list for the Unreal debugger: sjasmplus writes it only while the bplist/setbp lines are
# in the source, so drop a stale one first - otherwise it would be deployed again after they are
# commented out
$BpxFile = Join-Path $BuildDir 'bpx.ini'
Remove-Item -LiteralPath $BpxFile -ErrorAction SilentlyContinue

# --- build ---
$BuildStart = Get-Date
Push-Location -LiteralPath $ProjectDir
try {
    & $Sjasm --nologo --fullpath `
        "--sld=build/$BaseName.sld" "--lst=build/$BaseName.lst" "--sym=build/$BaseName.sym" `
        $SrcRel
    $SjasmExit = $LASTEXITCODE
} finally {
    Pop-Location
}
# BPLIST creates the file on pass 1, before any error is known, and SETBP fills it only in a clean
# build: after a failed build, or an empty list (errors or warnings), there is nothing to deploy -
# an empty file would wipe the breakpoints Unreal keeps in its own bpx.ini
if ($SjasmExit -ne 0 -or ((Test-Path -LiteralPath $BpxFile) -and (Get-Item -LiteralPath $BpxFile).Length -eq 0)) {
    Remove-Item -LiteralPath $BpxFile -ErrorAction SilentlyContinue
}
if ($SjasmExit -ne 0) {
    Write-Host 'BUILD FAILED' -ForegroundColor Red
    exit 1
}
# --- export debugger label files from the sjasmplus .sym table ---
$symFile = Join-Path $BuildDir "$BaseName.sym"
if (Test-Path -LiteralPath $symFile) {
    $labels = Select-String -LiteralPath $symFile -Pattern '^(\S+):\s+EQU\s+0x([0-9A-Fa-f]{8})$' | ForEach-Object {
        [pscustomobject]@{ Name = $_.Matches[0].Groups[1].Value; Addr = [Convert]::ToInt32($_.Matches[0].Groups[2].Value, 16) }
    } | Where-Object { $_.Addr -ge 0x4000 -and $_.Addr -le 0xFFFF } | Sort-Object Addr
    # Unreal Speccy debugger: 'AAAA name' lines (deployed as user.l on launch, auto-reloaded)
    $labels | ForEach-Object { '{0:X4} {1}' -f $_.Addr, $_.Name } | Set-Content -LiteralPath (Join-Path $BuildDir "$BaseName.l") -Encoding Ascii
    # CSpect built-in debugger: SNasm-style map, passed via -map=
    @('[SYMBOLS]') + ($labels | ForEach-Object { '{0:X8} 00000000 01 {1}' -f $_.Addr, $_.Name }) + @('[FILES]', '[LINES]', '[END]') | Set-Content -LiteralPath (Join-Path $BuildDir "$BaseName.map") -Encoding Ascii
}

# output file base name: <DEFINE PROJECT> <DEFINE VERSION> joined with a space, as OutputName in main.asm does,
# or the source's own base name if unset
$m = Select-String -LiteralPath $Src -Pattern '^\s*DEFINE\s+PROJECT\s+"([^"]*)"' | Select-Object -First 1
$ProjName = if ($m) { $m.Matches[0].Groups[1].Value } else { $BaseName }
$m = Select-String -LiteralPath $Src -Pattern '^\s*DEFINE\s+VERSION\s+"([^"]*)"' | Select-Object -First 1
if ($m) { $ProjName += ' ' + $m.Matches[0].Groups[1].Value }

# only files THIS build wrote: build\ can hold leftovers from other source files, and a source that
# gates its save block on __WARNINGS__ writes nothing at all, leaving the previous build's files in place;
# -Filter combined with -Exclude unreliably returns 0 items on Windows PowerShell 5.1, so filter manually.
# -LiteralPath everywhere a computed path is passed: -Path would read [ ] in a name as a wildcard
$debugExt = '.sld', '.lst', '.sym', '.l', '.map'
$outFiles = @(Get-ChildItem -LiteralPath $BuildDir -Filter "$ProjName.*" |
    Where-Object { $debugExt -notcontains $_.Extension -and $_.LastWriteTime -ge $BuildStart })
if (-not $outFiles) {
    # a variant, a lib table or a lua step saves nothing by design - that is not a failure;
    # main.asm writing nothing means its save block was skipped, and that is one
    if ($Src -eq (Join-Path $SrcDir 'main.asm')) {
        Write-Host 'No output file written - the save block was skipped (warnings?). Files in build\ are from an earlier build.' -ForegroundColor Yellow
        exit 1
    }
    Write-Host "Assembled $SrcRel - it saves no output file of its own (it only gets included)." -ForegroundColor Yellow
    exit 0
}
Write-Host 'Build OK:' -ForegroundColor Green
$outFiles | ForEach-Object { Write-Host ("  {0}  {1} bytes" -f $_.Name, $_.Length) }

if (-not ($Run -or $DebugEmu)) { exit 0 }

# --- emulator selection: DEFINE EMUL "..." in the source ---
$emu = ''
$m = Select-String -LiteralPath $Src -Pattern '^\s*DEFINE\s+EMUL\s+"([^"]+)"' | Select-Object -First 1
if ($m) { $emu = $m.Matches[0].Groups[1].Value.ToLower() }

$runExt = $null
$m = Select-String -LiteralPath $Src -Pattern '^\s*DEFINE\s+RUN\s+"([^"]+)"' | Select-Object -First 1
if ($m) { $runExt = $m.Matches[0].Groups[1].Value.TrimStart('.') }

if ($DebugEmu) { $emu = 'cspect-debug' }

if (-not $emu) {
    Write-Host 'No DEFINE EMUL "..." found in the source - nothing to launch.' -ForegroundColor Yellow
    exit 0
}

if (-not $Tools) {
    Write-Host 'zxdev emulators not found - run the file from build\ in your own emulator.' -ForegroundColor Yellow
    exit 0
}

# run file: <DEFINE RUN, if set, otherwise first matching extension> of build\<ProjName>.*
function Resolve-RunFile([string[]]$Extensions) {
    $projName = $script:ProjName

    if ($script:runExt) {
        if ($Extensions -notcontains ".$($script:runExt)") {
            throw "DEFINE RUN '$($script:runExt)' is not loadable by this emulator (expected $($Extensions -join ' / ')) - change DEFINE RUN or DEFINE EMUL."
        }
        $img = Join-Path $script:BuildDir "$projName.$($script:runExt)"
        if (-not (Test-Path -LiteralPath $img)) { throw "Run file (from DEFINE RUN) not found: $img" }
        return $img
    }
    foreach ($ext in $Extensions) {
        $img = Join-Path $script:BuildDir "$projName$ext"
        if (Test-Path -LiteralPath $img) { return $img }
    }
    throw "No runnable file in build\ for '$projName' ($($Extensions -join ' / '))"
}

switch ($emu) {
    'unreal' {
        $exe = Join-Path $Tools 'emuls\Unreal\unreal.exe'
        if (-not (Test-Path $exe)) {
            Write-Host "Unreal Speccy not found at $exe - see tools\emuls\Unreal\DOWNLOAD.txt (or run the file from build\ in your own emulator)." -ForegroundColor Yellow
            exit 0
        }
        $img = Resolve-RunFile @('.sna', '.trd', '.tap')
        # deploy labels: Unreal auto-(re)loads user.l from its own folder
        $lbl = Join-Path $BuildDir "$BaseName.l"
        if (Test-Path -LiteralPath $lbl) {
            $userL = Join-Path (Split-Path $exe) 'user.l'
            if ((Test-Path -LiteralPath $userL) -and -not (Test-Path -LiteralPath "$userL.orig")) { Copy-Item -LiteralPath $userL -Destination "$userL.orig" }
            Copy-Item -LiteralPath $lbl -Destination $userL -Force
        }
        # deploy breakpoints: Unreal loads bpx.ini from its own folder on start (and saves it back on exit)
        if (Test-Path -LiteralPath $BpxFile) {
            $userBpx = Join-Path (Split-Path $exe) 'bpx.ini'
            if ((Test-Path -LiteralPath $userBpx) -and -not (Test-Path -LiteralPath "$userBpx.orig")) { Copy-Item -LiteralPath $userBpx -Destination "$userBpx.orig" }
            Copy-Item -LiteralPath $BpxFile -Destination $userBpx -Force
        }
        Write-Host "Launching Unreal: $(Split-Path $img -Leaf)" -ForegroundColor Cyan
        Start-Process $exe -ArgumentList "`"$img`"" -WorkingDirectory (Split-Path $exe)
    }
    'cspect' {
        $exe = Join-Path $Tools 'emuls\Cspect\CSpect.exe'
        if (-not (Test-Path $exe)) {
            Write-Host "CSpect not found at $exe - see tools\emuls\Cspect\DOWNLOAD.txt (or run the file from build\ in your own emulator)." -ForegroundColor Yellow
            exit 0
        }
        $img = Resolve-RunFile @('.sna', '.nex')
        $mmc = ($ProjectDir -replace '\\', '/') + '/'
        $cargs = @('-w3', '-zxnext', '-vsync', '-60', ('-mmc="{0}"' -f $mmc))
        $map = Join-Path $BuildDir "$BaseName.map"
        if (Test-Path -LiteralPath $map) { $cargs += ('-map="{0}"' -f $map) }
        Write-Host "Launching CSpect: $(Split-Path $img -Leaf)" -ForegroundColor Cyan
        Start-Process $exe -ArgumentList ($cargs + "`"$img`"") -WorkingDirectory (Split-Path $exe)
    }
    'cspect-debug' {
        $exe = Join-Path $Tools 'emuls\Cspect\CSpect.exe'
        if (-not (Test-Path $exe)) {
            Write-Host "CSpect not found at $exe - see tools\emuls\Cspect\DOWNLOAD.txt. DeZog can't attach without it." -ForegroundColor Yellow
            exit 0
        }
        $img = Resolve-RunFile @('.sna', '.nex')
        $mmc = ($ProjectDir -replace '\\', '/') + '/'
        $cargs = @('-w3', '-zxnext', '-vsync', '-60', '-remote', ('-mmc="{0}"' -f $mmc))
        $map = Join-Path $BuildDir "$BaseName.map"
        if (Test-Path -LiteralPath $map) { $cargs += ('-map="{0}"' -f $map) }
        # DeZog needs port 11000: a stray CSpect from a previous run keeps it bound.
        # Close our own leftover emulator; refuse to touch any unrelated process.
        $port = 11000
        $held = Get-NetTCPConnection -LocalPort $port -State Listen -ErrorAction SilentlyContinue
        if ($held) {
            $owner = Get-Process -Id ($held.OwningProcess | Select-Object -First 1) -ErrorAction SilentlyContinue
            if ($owner -and $owner.ProcessName -eq 'CSpect') {
                Write-Host "Port $port held by a stray CSpect (PID $($owner.Id)) - closing it." -ForegroundColor Yellow
                Stop-Process -Id $owner.Id -Force
                for ($i = 0; $i -lt 20 -and (Get-NetTCPConnection -LocalPort $port -State Listen -ErrorAction SilentlyContinue); $i++) { Start-Sleep -Milliseconds 100 }
            } else {
                $who = if ($owner) { "$($owner.ProcessName) (PID $($owner.Id))" } else { "PID $($held.OwningProcess | Select-Object -First 1)" }
                throw "Port $port (DeZog) is in use by $who - close it or change the DeZog port, then retry."
            }
        }
        Write-Host "Launching CSpect (DeZog, port 11000): $(Split-Path $img -Leaf)" -ForegroundColor Cyan
        Start-Process $exe -ArgumentList ($cargs + "`"$img`"") -WorkingDirectory (Split-Path $exe)
        Start-Sleep -Seconds 3   # give CSpect time to start before DeZog connects
    }
    default {
        Write-Host "Unknown emulator '$emu' (expected unreal | cspect)" -ForegroundColor Yellow
    }
}