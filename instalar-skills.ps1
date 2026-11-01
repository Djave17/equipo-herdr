# Propósito: instalar las skills que usa el equipo. Copia las incluidas en skills/ y descarga impeccable desde su repositorio.
# Uso: & "$HOME\.agents\skills\equipo-herdr\instalar-skills.ps1" [-Forzar] [-SinImpeccable] [-DryRun]
param(
    [switch]$Forzar,
    [switch]$SinImpeccable,
    [switch]$DryRun
)
$ErrorActionPreference = 'Stop'
$Kit = $PSScriptRoot
# Codex lee ~/.agents/skills; Claude Code lee ~/.claude/skills.
$Destinos = @((Join-Path $HOME '.agents\skills'), (Join-Path $HOME '.claude\skills'))

function Copy-Skill([string]$Origen, [string]$Nombre) {
    foreach ($d in $Destinos) {
        $dst = Join-Path $d $Nombre
        # Un enlace (junction/symlink) apunta a otra copia: no se toca para no borrar su destino.
        if ((Test-Path -LiteralPath $dst) -and ((Get-Item -LiteralPath $dst -Force).Attributes -band [IO.FileAttributes]::ReparsePoint)) { Write-Output "ENLACE  $dst (se respeta)"; continue }
        if ((Test-Path -LiteralPath $dst) -and -not $Forzar) { Write-Output "EXISTE  $dst (usa -Forzar para reemplazar)"; continue }
        if ($DryRun) { Write-Output "COPIAR  $Origen -> $dst"; continue }
        New-Item -ItemType Directory -Force $d | Out-Null
        if (Test-Path -LiteralPath $dst) { Remove-Item -Recurse -Force -LiteralPath $dst }
        Copy-Item -Recurse -LiteralPath $Origen -Destination $dst
        Write-Output "OK      $dst"
    }
}

foreach ($s in Get-ChildItem -Directory (Join-Path $Kit 'skills')) { Copy-Skill $s.FullName $s.Name }

if (-not $SinImpeccable) {
    $tmp = Join-Path ([IO.Path]::GetTempPath()) "impeccable-$PID"
    if ($DryRun) { Write-Output "CLONAR  https://github.com/pbakaus/impeccable -> $tmp" }
    else {
        git clone -q --depth 1 https://github.com/pbakaus/impeccable $tmp
        if ($LASTEXITCODE -ne 0) { throw 'No se pudo clonar impeccable.' }
    }
    Copy-Skill (Join-Path $tmp '.claude\skills\impeccable') 'impeccable'
    if (-not $DryRun) { Remove-Item -Recurse -Force -LiteralPath $tmp }
}

Write-Output 'Plugin de Claude Code requerido por revisor (engineering): instalalo desde el marketplace de plugins de Claude Code.'
