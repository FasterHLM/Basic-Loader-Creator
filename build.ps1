# build.ps1 - sjasmplus build + emulator launch driven by define emul "..." in src\main.asm
#   .\build.ps1           - build only
#   .\build.ps1 -Run      - build + launch the emulator (unreal / cspect)
#   .\build.ps1 -DebugEmu - build + CSpect in DeZog mode (-remote), used by F5 in VS Code
param(
    [switch]$Run,
    [switch]$DebugEmu
)
$ErrorActionPreference = 'Stop'
$ProjectDir = $PSScriptRoot
$Src        = Join-Path $ProjectDir 'src\main.asm'
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

# --- build ---
Push-Location $ProjectDir
try {
    & $Sjasm --nologo --fullpath `
        "--sld=build/main.sld" "--lst=build/main.lst" "--sym=build/main.sym" `
        'src/main.asm'
    if ($LASTEXITCODE -ne 0) {
        Write-Host 'BUILD FAILED' -ForegroundColor Red
        exit 1
    }
} finally {
    Pop-Location
}
# --- export debugger label files from the sjasmplus .sym table ---
$symFile = Join-Path $BuildDir 'main.sym'
if (Test-Path $symFile) {
    $labels = Select-String -Path $symFile -Pattern '^(\S+):\s+EQU\s+0x([0-9A-Fa-f]{8})$' | ForEach-Object {
        [pscustomobject]@{ Name = $_.Matches[0].Groups[1].Value; Addr = [Convert]::ToInt32($_.Matches[0].Groups[2].Value, 16) }
    } | Where-Object { $_.Addr -ge 0x4000 -and $_.Addr -le 0xFFFF } | Sort-Object Addr
    # Unreal Speccy debugger: 'AAAA name' lines (deployed as user.l on launch, auto-reloaded)
    $labels | ForEach-Object { '{0:X4} {1}' -f $_.Addr, $_.Name } | Set-Content (Join-Path $BuildDir 'main.l') -Encoding Ascii
    # CSpect built-in debugger: SNasm-style map, passed via -map=
    @('[SYMBOLS]') + ($labels | ForEach-Object { '{0:X8} 00000000 01 {1}' -f $_.Addr, $_.Name }) + @('[FILES]', '[LINES]', '[END]') | Set-Content (Join-Path $BuildDir 'main.map') -Encoding Ascii
}

Write-Host 'Build OK:' -ForegroundColor Green
Get-ChildItem $BuildDir -Exclude *.sld, *.lst, *.sym, *.l, *.map | ForEach-Object { Write-Host ("  {0}  {1} bytes" -f $_.Name, $_.Length) }

if (-not ($Run -or $DebugEmu)) { exit 0 }

# --- emulator selection: DEFINE EMUL "..." in the source ---
$emu = ''
$m = Select-String -Path $Src -Pattern '^\s*DEFINE\s+EMUL\s+"([^"]+)"' | Select-Object -First 1
if ($m) { $emu = $m.Matches[0].Groups[1].Value.ToLower() }

$runExt = $null
$m = Select-String -Path $Src -Pattern '^\s*DEFINE\s+RUN\s+"([^"]+)"' | Select-Object -First 1
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

# run file: <PROJECT define><VERSION define, if set>.<DEFINE RUN, if set, otherwise first matching extension>
function Resolve-RunFile([string[]]$Extensions) {
    $projName = 'main'
    $mm = Select-String -Path $script:Src -Pattern '^\s*DEFINE\s+PROJECT\s+"([^"]+)"' | Select-Object -First 1
    if ($mm) { $projName = $mm.Matches[0].Groups[1].Value }
    $mv = Select-String -Path $script:Src -Pattern '^\s*DEFINE\s+VERSION\s+"([^"]+)"' | Select-Object -First 1
    if ($mv) { $projName += $mv.Matches[0].Groups[1].Value }

    if ($script:runExt) {
        $img = Join-Path $script:BuildDir "$projName.$($script:runExt)"
        if (-not (Test-Path $img)) { throw "Run file (from DEFINE RUN) not found: $img" }
        return $img
    }
    foreach ($ext in $Extensions) {
        $img = Join-Path $script:BuildDir "$projName$ext"
        if (Test-Path $img) { return $img }
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
        $lbl = Join-Path $BuildDir 'main.l'
        if (Test-Path $lbl) {
            $userL = Join-Path (Split-Path $exe) 'user.l'
            if ((Test-Path $userL) -and -not (Test-Path "$userL.orig")) { Copy-Item $userL "$userL.orig" }
            Copy-Item $lbl $userL -Force
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
        $cargs = @('-w3', '-zxnext', '-vsync', '-60', "-mmc=$mmc")
        $map = Join-Path $BuildDir 'main.map'
        if (Test-Path $map) { $cargs += "-map=$map" }
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
        $cargs = @('-w3', '-zxnext', '-vsync', '-60', '-remote', "-mmc=$mmc")
        $map = Join-Path $BuildDir 'main.map'
        if (Test-Path $map) { $cargs += "-map=$map" }
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
