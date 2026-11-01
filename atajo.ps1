# Proposito: atajo del kit equipo-herdr para este workspace (lo escribe "equipo.ps1 instalar"; no editar).
# Portable: busca el kit en $env:EQUIPO_HERDR_KIT o en ~/.agents/skills/equipo-herdr de quien lo ejecute.
$kit = if ($env:EQUIPO_HERDR_KIT) { Join-Path $env:EQUIPO_HERDR_KIT 'equipo.ps1' } else { Join-Path $HOME '.agents\skills\equipo-herdr\equipo.ps1' }
if (-not (Test-Path -LiteralPath $kit)) { throw "No se encuentra el kit equipo-herdr en $kit. Instalalo en ~/.agents/skills/equipo-herdr o define EQUIPO_HERDR_KIT." }
& $kit @args -Workspace (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))
