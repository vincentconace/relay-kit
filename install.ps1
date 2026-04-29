# relay-kit installer (Windows / PowerShell mirror of install.sh)
# Implements MASD (Multi-Agent Spec Development) for Claude across Antigravity,
# Claude Code, and Cowork. Installs slash commands, agents, and templates into
# the host directory and bootstraps .relay/{current,archive,memory}/ in the
# project so the 6 MASD phases can run end-to-end.
#
# Usage:
#   powershell -ExecutionPolicy Bypass -File .\install.ps1 [target_project_dir] [-Yes]

[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$TargetDir = (Get-Location).Path,

    [Alias('y')]
    [switch]$Yes
)

$ErrorActionPreference = 'Stop'

# Resolve script source dir.
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Validate target.
if (-not (Test-Path -LiteralPath $TargetDir -PathType Container)) {
    Write-Error "target_project_dir no existe: $TargetDir"
    exit 2
}
$TargetDir = (Resolve-Path -LiteralPath $TargetDir).Path

# Detect host: Antigravity -> Claude Code -> Cowork -> generic fallback.
$HostName = ''
$HostDir = ''
$HomeDir = $env:USERPROFILE

if ((Test-Path "$TargetDir\.agents") -or (Test-Path "$HomeDir\.agents")) {
    $HostName = 'Antigravity'
    if (Test-Path "$TargetDir\.agents") { $HostDir = "$TargetDir\.agents" } else { $HostDir = "$HomeDir\.agents" }
}
elseif ((Test-Path "$HomeDir\.claude") -or (Test-Path "$TargetDir\.claude")) {
    $HostName = 'Claude Code'
    if (Test-Path "$TargetDir\.claude") { $HostDir = "$TargetDir\.claude" } else { $HostDir = "$HomeDir\.claude" }
}
elseif (Test-Path "$HomeDir\.config\cowork") {
    $HostName = 'Cowork'
    $HostDir = "$HomeDir\.config\cowork"
}
else {
    $HostName = 'generic-fallback (Claude Code-compatible)'
    $HostDir = "$TargetDir\.claude"
}

Write-Host "========================================"
Write-Host "relay-kit · MASD installer"
Write-Host "========================================"
Write-Host "Host detectado : $HostName"
Write-Host "Host dir       : $HostDir"
Write-Host "Proyecto       : $TargetDir"
Write-Host "Archivos a copiar:"
Write-Host "  · commands\relay\   <- commands\*.md"
Write-Host "  · agents\relay\     <- agents\*.md + agents\sub\*.md"
Write-Host "  · templates\relay\  <- templates\*.md"
Write-Host "Bootstrap del proyecto:"
Write-Host "  · $TargetDir\.relay\{current,archive,memory}\"
Write-Host "  · memory\*.md (sólo si no existen)"
Write-Host "========================================"

if (-not $Yes) {
    Write-Host "Continúo en 3 segundos. Cancelá con Ctrl-C si querés revisar."
    Start-Sleep -Seconds 3
}

function Copy-FileSafe {
    param([string]$Src, [string]$Dst)
    if (Test-Path -LiteralPath $Dst) {
        $srcHash = (Get-FileHash -LiteralPath $Src).Hash
        $dstHash = (Get-FileHash -LiteralPath $Dst).Hash
        if ($srcHash -eq $dstHash) { return }
        if ($Yes) {
            Copy-Item -LiteralPath $Src -Destination $Dst -Force
            Write-Host "  overwrite (-Yes): $Dst"
        }
        else {
            $ans = Read-Host "  ? $Dst ya existe y difiere. Sobrescribir? [y/N]"
            if ($ans -match '^(y|Y|yes|YES)$') {
                Copy-Item -LiteralPath $Src -Destination $Dst -Force
                Write-Host "  overwrite: $Dst"
            }
            else {
                Write-Host "  skip: $Dst"
            }
        }
    }
    else {
        Copy-Item -LiteralPath $Src -Destination $Dst
        Write-Host "  + $Dst"
    }
}

function Copy-FileNoOverwrite {
    param([string]$Src, [string]$Dst)
    if (Test-Path -LiteralPath $Dst) {
        Write-Host "  skip (preserve existing memory): $Dst"
    }
    else {
        Copy-Item -LiteralPath $Src -Destination $Dst
        Write-Host "  + $Dst"
    }
}

# Install host artifacts.
New-Item -ItemType Directory -Force -Path "$HostDir\commands\relay"   | Out-Null
New-Item -ItemType Directory -Force -Path "$HostDir\agents\relay"     | Out-Null
New-Item -ItemType Directory -Force -Path "$HostDir\templates\relay"  | Out-Null

Write-Host "-> commands/"
Get-ChildItem -LiteralPath "$ScriptDir\commands" -Filter '*.md' -File | ForEach-Object {
    Copy-FileSafe -Src $_.FullName -Dst "$HostDir\commands\relay\$($_.Name)"
}

Write-Host "-> agents/"
Get-ChildItem -LiteralPath "$ScriptDir\agents" -Filter '*.md' -File | ForEach-Object {
    Copy-FileSafe -Src $_.FullName -Dst "$HostDir\agents\relay\$($_.Name)"
}
if (Test-Path -LiteralPath "$ScriptDir\agents\sub") {
    Get-ChildItem -LiteralPath "$ScriptDir\agents\sub" -Filter '*.md' -File | ForEach-Object {
        Copy-FileSafe -Src $_.FullName -Dst "$HostDir\agents\relay\$($_.Name)"
    }
}

Write-Host "-> templates/"
Get-ChildItem -LiteralPath "$ScriptDir\templates" -Filter '*.md' -File | ForEach-Object {
    Copy-FileSafe -Src $_.FullName -Dst "$HostDir\templates\relay\$($_.Name)"
}

# Bootstrap the project's .relay/ tree.
New-Item -ItemType Directory -Force -Path "$TargetDir\.relay\current" | Out-Null
New-Item -ItemType Directory -Force -Path "$TargetDir\.relay\archive" | Out-Null
New-Item -ItemType Directory -Force -Path "$TargetDir\.relay\memory"  | Out-Null

Write-Host "-> memory bootstrap (preserve existing files)"
Get-ChildItem -LiteralPath "$ScriptDir\memory" -Filter '*.md' -File | ForEach-Object {
    Copy-FileNoOverwrite -Src $_.FullName -Dst "$TargetDir\.relay\memory\$($_.Name)"
}

# Note: .relay\project.md is NOT created here — /onboard produces it.

Write-Host ""
Write-Host "========================================"
Write-Host "relay-kit instalado"
Write-Host "========================================"
Write-Host "Host  : $HostName ($HostDir)"
Write-Host "Proy. : $TargetDir\.relay\"
Write-Host ""
Write-Host "Si este proyecto YA tiene código, corré /onboard ahora para sembrar el"
Write-Host "contexto (escribe .relay\project.md y siembra la memoria) antes de tu"
Write-Host "primera tarea. En proyectos greenfield podés saltar /onboard."
Write-Host ""
Write-Host "Quick start (flujo MASD):"
Write-Host "  1. /onboard                         (recomendado en proyectos existentes)"
Write-Host "  2. /analyze ""<tu pedido>"""
Write-Host "  3. /plan"
Write-Host "  4. /tasks"
Write-Host "  5. /implement                       (o /implement T-001 para una sola)"
Write-Host "  6. /review                          (cierra el loop y actualiza la memoria)"
Write-Host ""
Write-Host "Documentación: README.md · INSTALL.md · DISTRIBUTION.md (en español)."
Write-Host "========================================"

exit 0
