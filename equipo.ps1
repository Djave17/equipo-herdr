<#
Proposito: kit plug and play "equipo-herdr": equipo de agentes (plan, docs, luna, sol, revisor, diseno)
sobre herdr (hc) para cualquier workspace. Documentacion: SKILL.md junto a este archivo.

Uso (desde el workspace, via su atajo .agents\equipo\equipo.ps1, o con -Workspace):
  equipo.ps1 instalar [-Workspace C:\ruta] [-Nombre "Mi Proyecto"] [-Prefijo mp]   # prepara el workspace
  equipo.ps1 iniciar                     # abre herdr, crea espacios de grupo, deja vivos plan y docs
  equipo.ps1 plan "Objetivo..."          # orquestador con objetivo inicial
  equipo.ps1 luna -TareaId 20261101-x -Tarea "..."   # lo usa plan; si ya vive, le envia el encargo
  equipo.ps1 generar | plantillas | estado | acceso-directo | verificar
  equipo.ps1 cerrar [-Agentes luna,sol]  # sin -Agentes: todos los no permanentes
  -DryRun muestra los comandos sin ejecutarlos. -Oculto no abre pestanas en herdr.
Este archivo es ASCII a proposito (PowerShell 5.1 lee UTF-8 sin BOM como ANSI); los textos con
acentos viven en los .md y .json del kit, que se leen como UTF-8.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet('instalar', 'iniciar', 'plan', 'diseno', 'luna', 'sol', 'revisor', 'docs',
        'generar', 'plantillas', 'estado', 'cerrar', 'acceso-directo', 'verificar')]
    [string]$Accion,
    [Parameter(Position = 1)][string]$Tarea,
    [string]$TareaId,
    [string]$Workspace,
    [string]$Cwd,
    [string]$Nombre,
    [string]$Prefijo,
    [string[]]$Agentes,
    [switch]$Oculto,
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'
$Kit = $PSScriptRoot
$Utf8 = New-Object System.Text.UTF8Encoding($false)

function Read-Texto([string]$Ruta) { [System.IO.File]::ReadAllText($Ruta, [System.Text.Encoding]::UTF8) }
function Write-Texto([string]$Ruta, [string]$Texto) {
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $Ruta) | Out-Null
    [System.IO.File]::WriteAllText($Ruta, $Texto, $Utf8)
}
function Read-Json([string]$Ruta) { Read-Texto $Ruta | ConvertFrom-Json }

function Merge-Objeto($Base, $Encima) {
    $r = [ordered]@{}
    if ($Base) { foreach ($p in $Base.PSObject.Properties) { $r[$p.Name] = $p.Value } }
    if ($Encima) { foreach ($p in $Encima.PSObject.Properties) { $r[$p.Name] = $p.Value } }
    [pscustomobject]$r
}

function ConvertTo-Prefijo([string]$Texto) {
    $p = ($Texto.ToLowerInvariant() -replace '[^a-z0-9]+', '-').Trim('-')
    if ($p.Length -gt 20) { $p = $p.Substring(0, 20).Trim('-') }
    if (-not $p) { $p = 'equipo' }
    $p
}

# ---------------------------------------------------------------- instalar
if ($Accion -eq 'instalar') {
    $ws = if ($Workspace) { (Resolve-Path -LiteralPath $Workspace).Path } else { (Get-Location).Path }
    $dir = Join-Path $ws '.agents\equipo'
    $cfgRuta = Join-Path $dir 'equipo.json'
    if (Test-Path -LiteralPath $cfgRuta) {
        Write-Output "Ya existe $cfgRuta; se conserva. Se actualizan atajo y generados."
    } else {
        $hoja = Split-Path -Leaf $ws
        $n = if ($Nombre) { $Nombre } else { $hoja }
        $px = if ($Prefijo) { ConvertTo-Prefijo $Prefijo } else { ConvertTo-Prefijo $hoja }
        $cfg = [ordered]@{
            nombre   = $n
            prefijo  = $px
            contexto = @('Respeta el AGENTS.md/CLAUDE.md del workspace y de cada repositorio.')
            grupos   = [ordered]@{}
            roles    = [ordered]@{}
        }
        if (-not $DryRun) { Write-Texto $cfgRuta (($cfg | ConvertTo-Json -Depth 6) + "`n") }
        Write-Output "Creado $cfgRuta (nombre=$n, prefijo=$px)."
    }
    if (-not $DryRun) {
        Write-Texto (Join-Path $dir 'equipo.ps1') (Read-Texto (Join-Path $Kit 'atajo.ps1'))
        $leeme = Join-Path $dir 'roles\LEEME.md'
        if (-not (Test-Path -LiteralPath $leeme)) { Write-Texto $leeme (Read-Texto (Join-Path $Kit 'roles-locales-LEEME.md')) }
        Write-Texto (Join-Path $dir '.gitignore') "trabajo/`n.generado/`n"
        New-Item -ItemType Directory -Force -Path (Join-Path $dir 'trabajo') | Out-Null
    }
    $codexCfg = Join-Path $HOME '.codex\config.toml'
    if ((Test-Path -LiteralPath $codexCfg) -and -not ((Read-Texto $codexCfg).ToLowerInvariant().Contains("[projects.'$($ws.ToLowerInvariant())']"))) {
        Write-Warning "Codex aun no confia en $ws. Abre 'codex' una vez en esa carpeta y acepta, o los agentes Codex quedaran 'blocked' al arrancar."
    }
    Write-Output 'Claude tambien pide confiar en la carpeta la primera vez: abre "claude" una vez en el workspace y acepta.'
    if ($DryRun) { return }
    $Workspace = $ws
    $Accion = 'generar'
}

# ---------------------------------------------------------------- configuracion
function Resolve-Workspace {
    if ($Workspace) { return (Resolve-Path -LiteralPath $Workspace).Path }
    $d = (Get-Location).Path
    while ($d) {
        if (Test-Path -LiteralPath (Join-Path $d '.agents\equipo\equipo.json')) { return $d }
        $padre = Split-Path -Parent $d
        if ($padre -eq $d) { break }
        $d = $padre
    }
    throw 'No encuentro .agents\equipo\equipo.json subiendo desde la carpeta actual. Ejecuta "equipo.ps1 instalar" en el workspace o usa -Workspace.'
}

$Ws = Resolve-Workspace
$DirEq = Join-Path $Ws '.agents\equipo'
$DirGen = Join-Path $DirEq '.generado'
$Trabajo = Join-Path $DirEq 'trabajo'
$Lanzador = Join-Path $DirEq 'equipo.ps1'
$SkillsDir = Join-Path $HOME '.agents\skills'
if (-not $Cwd) { $Cwd = $Ws }

$Def = Read-Json (Join-Path $Kit 'equipo.defaults.json')
$Cfg = Read-Json (Join-Path $DirEq 'equipo.json')
$NombreEq = [string]$Cfg.nombre
$Px = ConvertTo-Prefijo ([string]$Cfg.prefijo)
if (-not $NombreEq) { throw 'equipo.json: falta "nombre".' }

$Grupos = [ordered]@{}
foreach ($p in (Merge-Objeto $Def.grupos $Cfg.grupos).PSObject.Properties) { $Grupos[$p.Name] = ([string]$p.Value).Replace('{{NOMBRE}}', $NombreEq) }
$Roles = [ordered]@{}
foreach ($p in $Def.roles.PSObject.Properties) {
    $over = if ($Cfg.roles) { $Cfg.roles.PSObject.Properties[$p.Name] } else { $null }
    $Roles[$p.Name] = Merge-Objeto $p.Value $(if ($over) { $over.Value } else { $null })
}
function Get-Terminal([string]$Rol) { "$Px-$Rol" }

# ---------------------------------------------------------------- generados
function Get-Reemplazos {
    $r = [ordered]@{
        '{{NOMBRE}}'     = $NombreEq
        '{{WORKSPACE}}'  = $Ws
        '{{TRABAJO}}'    = $Trabajo
        '{{LANZADOR}}'   = $Lanzador
        '{{PROTOCOLO}}'  = (Join-Path $DirGen 'PROTOCOLO.md')
        '{{EQUIPO}}'     = (Join-Path $DirGen 'EQUIPO.md')
        '{{SKILLS_DIR}}' = $SkillsDir
    }
    foreach ($rol in $Roles.Keys) { $r["{{$rol}}"] = Get-Terminal $rol }
    $r
}
function Expand-Plantilla([string]$Texto, $Reemplazos) {
    foreach ($k in $Reemplazos.Keys) { $Texto = $Texto.Replace($k, [string]$Reemplazos[$k]) }
    $Texto
}

function Update-Generado {
    # Compone lo que leen los agentes: kit generico + equipo.json + reglas locales del workspace.
    $rep = Get-Reemplazos
    $filas = @('| Grupo | Rol | Terminal | Descripcion | CLI / modelo | Esfuerzo | Remoto | Permanente |', '|---|---|---|---|---|---|---|---|')
    foreach ($rol in $Roles.Keys) {
        $c = $Roles[$rol]
        $si = { param($b) if ($b) { 'Si' } else { 'No' } }
        $filas += "| $($Grupos[[string]$c.grupo]) | $rol | ``$(Get-Terminal $rol)`` | $($c.descripcion) | $($c.cli) ``$($c.modelo)`` | $($c.esfuerzo) | $(& $si $c.remoto) | $(& $si $c.persistente) |"
    }
    $contexto = @($Cfg.contexto | Where-Object { $_ }) | ForEach-Object { "- $_" }
    $rep['{{TABLA}}'] = $filas -join "`n"
    $rep['{{CONTEXTO}}'] = if ($contexto) { $contexto -join "`n" } else { '- Respeta el AGENTS.md/CLAUDE.md del workspace y de cada repositorio.' }
    Write-Texto (Join-Path $DirGen 'EQUIPO.md') (Expand-Plantilla (Read-Texto (Join-Path $Kit 'EQUIPO.md')) $rep)
    Write-Texto (Join-Path $DirGen 'PROTOCOLO.md') (Expand-Plantilla (Read-Texto (Join-Path $Kit 'PROTOCOLO.md')) $rep)
    foreach ($rol in $Roles.Keys) {
        $c = $Roles[$rol]
        $rep['{{SKILLS}}'] = (@($c.skills) | ForEach-Object { "- $_" }) -join "`n"
        $texto = "<!-- Generado por equipo-herdr; no editar. Fuentes: $Kit\roles\$rol.md, equipo.json y .agents\equipo\roles\$rol.md -->`n"
        $texto += Expand-Plantilla (Read-Texto (Join-Path $Kit "roles\$rol.md")) $rep
        $local = Join-Path $DirEq "roles\$rol.md"
        if (Test-Path -LiteralPath $local) {
            $texto += "`n## Reglas de este workspace`n`n" + (Expand-Plantilla (Read-Texto $local) $rep)
        }
        Write-Texto (Join-Path $DirGen "roles\$rol.md") $texto
    }
}

# ---------------------------------------------------------------- hc / herdr
function Invoke-Hc {
    param([string[]]$Argumentos)
    if ($DryRun) { Write-Output ('hc ' + (($Argumentos | ForEach-Object { if ($_ -match '\s') { "'$_'" } else { $_ } }) -join ' ')); return }
    & hc @Argumentos
    if ($LASTEXITCODE -ne 0) { throw "hc termino con codigo $LASTEXITCODE" }
}

function Get-TerminalesEquipo {
    $json = & hc ls --json 2>$null | Out-String
    if ($LASTEXITCODE -ne 0 -or -not $json.Trim()) { return @() }
    $nombres = @($Roles.Keys | ForEach-Object { Get-Terminal $_ })
    @(($json | ConvertFrom-Json).terminals | Where-Object { $_.name -and $nombres -contains [string]$_.name })
}

function Test-AgenteSano($Terminal, $C) {
    # Tras un reinicio, hc recupera la terminal como shell con el mismo nombre: eso no es el agente.
    $Terminal.state -eq 'live' -and ([string]$Terminal.agent) -like "$($C.cli)*"
}

function Test-VentanaHerdr {
    try { & herdr-app ls 2>$null | Out-Null; return ($LASTEXITCODE -eq 0) } catch { return $false }
}

function Get-EspacioGrupo {
    # Id del espacio local del grupo; lo crea si la ventana esta abierta y no existe. Sin ventana: $null.
    param([string]$Grupo, [switch]$Crear)
    $nombre = $Grupos[$Grupo]
    if (-not $nombre) { return $null }
    for ($intento = 0; $intento -lt 2; $intento++) {
        try {
            $json = & herdr-app ls 2>$null | Out-String
            if ($LASTEXITCODE -ne 0 -or -not $json.Trim()) { return $null }
            $espacio = ($json | ConvertFrom-Json).spaces | Where-Object { $_.name -eq $nombre -and -not $_.machine } | Select-Object -First 1
            if ($espacio) { return $espacio.id }
        } catch { return $null }
        if (-not $Crear -or $DryRun) { return $null }
        & herdr-app do space.new --name $nombre --folder $Ws | Out-Null
    }
    return $null
}

function Get-ComandoAgente([string]$Rol, [string]$RutaRol) {
    $c = $Roles[$Rol]
    $t = Get-Terminal $Rol
    if ($c.cli -eq 'claude') {
        $argv = @('claude', '--model', $c.modelo, '--effort', $c.esfuerzo, '--append-system-prompt-file', $RutaRol)
        if ($c.remoto) { $argv += @('--remote-control', $t) }
        return $argv + @('-n', $t)
    }
    if ($c.cli -eq 'codex') {
        # Codex debe correr con --no-daemon bajo hc. El remoto solo se habilita en roles Claude.
        return @('codex', '--no-daemon', '-m', $c.modelo, '-c', "model_reasoning_effort=$($c.esfuerzo)")
    }
    throw "cli no soportado en el rol ${Rol}: $($c.cli) (use claude o codex)."
}

function Start-Rol([string]$Rol, [string]$Texto, [string]$Id) {
    $c = $Roles[$Rol]
    $t = Get-Terminal $Rol
    $rolGen = Join-Path $DirGen "roles\$Rol.md"
    $protoGen = Join-Path $DirGen 'PROTOCOLO.md'
    $plan = Get-Terminal 'plan'

    $vivo = Get-TerminalesEquipo | Where-Object { $_.name -eq $t } | Select-Object -First 1
    if ($vivo -and -not (Test-AgenteSano $vivo $c)) {
        Write-Output "'$t' quedo como shell recuperada ($($vivo.agent)); se relanza."
        Invoke-Hc @('kill', $t)
        Invoke-Hc @('rm', $t)
        $vivo = $null
    }

    if ($Texto -and -not $Id) {
        if ($Rol -eq 'plan') { $Id = Get-Date -Format 'yyyyMMdd-HHmm' } else { throw 'Indica -TareaId (lo crea plan).' }
    }
    if ($Id -and $Id -notmatch '^[a-z0-9][a-z0-9-]{0,47}$') { throw 'TareaId: minusculas, numeros y guiones (max. 48).' }
    if (-not $c.persistente -and -not $Texto) { throw 'Indica -TareaId y -Tarea con el encargo concreto.' }

    # El encargo va a un archivo: la linea de arranque queda corta y sin comillas,
    # segura para codex.cmd (cmd.exe) y para el paso de argumentos de PowerShell 5.1.
    $prompt = $null
    if ($Texto) {
        $carpeta = Join-Path $Trabajo $Id
        $encargo = Join-Path $carpeta "encargo-$Rol.md"
        $contenido = if (Test-Path -LiteralPath $Texto -PathType Leaf) { Read-Texto $Texto } else { $Texto }
        if (-not $DryRun) {
            New-Item -ItemType Directory -Force -Path $carpeta | Out-Null
            [System.IO.File]::AppendAllText($encargo, "## Encargo $(Get-Date -Format 's')`n`n$contenido`n`n", $Utf8)
        }
        $prompt = "Eres $Rol del equipo $NombreEq. Antes de actuar lee $rolGen y $protoGen. " +
            "TareaId: $Id. Carpeta de trabajo: $carpeta. Tu encargo es el ultimo bloque de $encargo. " +
            "Reporta con hc send $plan al terminar, si consultas o si te bloqueas."
        if ($Rol -eq 'plan') {
            $prompt = "Eres plan, orquestador del equipo $NombreEq. Lee $protoGen. TareaId asignado: $Id. " +
                "Carpeta de trabajo: $carpeta. El objetivo del usuario esta en $encargo. Empieza por planificar."
        }
    } elseif ($c.cli -ne 'claude') {
        # Codex no admite prompt de sistema: el rol se carga con el primer mensaje.
        $prompt = "Eres $Rol del equipo $NombreEq. Lee $rolGen y $protoGen. " +
            "Luego espera instrucciones del usuario o encargos de $plan."
    }

    if ($vivo) {
        if (-not $Texto) { Write-Output "'$t' ya esta vivo ($($vivo.address))."; return }
        Invoke-Hc @('send', $t, $prompt)
        return
    }

    $hcArgs = @('run', '--bg', '--name', $t, '--cwd', $Cwd, '--label', "equipo=$Px", '--label', "rol=$Rol")
    if ($c.persistente) { $hcArgs += @('--no-parent', '--outlive-parent') }
    if (-not $Oculto) {
        $espacio = Get-EspacioGrupo -Grupo ([string]$c.grupo) -Crear
        if ($espacio) { $hcArgs += @('--label', "herdr.space=$espacio") }
    }
    $programa = Get-ComandoAgente $Rol $rolGen
    if ($prompt) { $programa += $prompt }
    Invoke-Hc ($hcArgs + $programa)
}

# ---------------------------------------------------------------- acciones
if (-not $DryRun) { Update-Generado }

switch ($Accion) {
    'generar' {
        Write-Output "Generado en $DirGen"
        Write-Output "Equipo $NombreEq (prefijo $Px). Siguiente paso: & '$Lanzador' iniciar"
    }
    'verificar' {
        # Requisitos para que el equipo funcione en esta maquina (util al recibir el kit de otra persona).
        $faltas = 0
        foreach ($cmd in @('hc', 'herdr-app', 'claude', 'codex')) {
            if (Get-Command $cmd -ErrorAction SilentlyContinue) { Write-Output "OK     comando $cmd" } else { Write-Output "FALTA  comando $cmd"; $faltas++ }
        }
        $dirs = @((Join-Path $HOME '.agents\skills'), (Join-Path $HOME '.claude\skills'))
        $skills = @($Roles.Values | ForEach-Object { @($_.skills) } | ForEach-Object { if ($_ -match '`([^`]+)`') { $Matches[1] } } |
            ForEach-Object { $_ -split '\s*/\s*' } | Sort-Object -Unique)
        foreach ($s in $skills) {
            if ($s -like '*:*') { Write-Output "PLUGIN skill $s (plugin de Claude Code; comprobar con /plugin)"; continue }
            if ($dirs | Where-Object { Test-Path -LiteralPath (Join-Path $_ "$s\SKILL.md") }) { Write-Output "OK     skill $s" } else { Write-Output "FALTA  skill $s"; $faltas++ }
        }
        $codexCfg = Join-Path $HOME '.codex\config.toml'
        if (-not ((Test-Path -LiteralPath $codexCfg) -and (Read-Texto $codexCfg).ToLowerInvariant().Contains("[projects.'$($Ws.ToLowerInvariant())']"))) {
            Write-Output "AVISO  Codex no confia aun en $Ws (abre codex ahi una vez y acepta)"
        }
        $rutas = ([Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [Environment]::GetEnvironmentVariable('Path', 'User')) -split ';'
        if (-not ($rutas | Where-Object { $_ -and (Test-Path -LiteralPath (Join-Path $_ 'sh.exe')) } | Select-Object -First 1)) {
            Write-Output 'AVISO  sh.exe no esta en el PATH: las plantillas hc no funcionaran (el lanzador si).'
        }
        Write-Output "Modelos usados: $((@($Roles.Values | ForEach-Object { "$($_.cli)/$($_.modelo)" }) | Sort-Object -Unique) -join ', ') (la cuenta debe tener acceso)."
        if ($faltas) { Write-Output "$faltas requisito(s) faltante(s)." } else { Write-Output 'Todo listo.' }
    }
    'estado' {
        $vivos = Get-TerminalesEquipo
        if (-not $vivos) { Write-Output "No hay agentes vivos del equipo $NombreEq."; return }
        $vivos | Select-Object @{ n = 'grupo'; e = { $Grupos[[string]$Roles[([string]$_.name).Substring($Px.Length + 1)].grupo] } },
            name, address, agent, status, where | Sort-Object grupo, name | Format-Table -AutoSize
    }
    'cerrar' {
        $objetivo = if ($Agentes) { $Agentes } else { @($Roles.Keys | Where-Object { -not $Roles[$_].persistente }) }
        foreach ($rol in $objetivo) { if (-not $Roles.Contains($rol)) { throw "'$rol' no es un rol del equipo." } }
        $vivos = @(Get-TerminalesEquipo | ForEach-Object { [string]$_.name })
        foreach ($rol in $objetivo) {
            $t = Get-Terminal $rol
            if ($vivos -notcontains $t) { continue }
            Invoke-Hc @('kill', $t)
            Invoke-Hc @('rm', $t)
        }
    }
    'plantillas' {
        $dir = Join-Path $env:APPDATA 'herdr-core\templates'
        foreach ($rol in $Roles.Keys) {
            $c = $Roles[$rol]
            $rolGen = Join-Path $DirGen "roles\$rol.md"
            $comando = (Get-ComandoAgente $rol ($rolGen -replace '\\', '/')) -join ' '
            $cuerpo = "Eres $rol del equipo $NombreEq. Antes de actuar lee $rolGen y $(Join-Path $DirGen 'PROTOCOLO.md'). " +
                "Trabaja en la carpeta $Trabajo\<tarea-id> que indique el encargo. " +
                "Reporta con hc send $(Get-Terminal 'plan') al terminar, si consultas o si te bloqueas."
            $texto = "---`nname: $(Get-Terminal $rol)`ndescription: Equipo $NombreEq - $rol, $($c.descripcion) ($($c.modelo) $($c.esfuerzo))`ncommand: $comando`n---`n$cuerpo`n"
            $ruta = Join-Path $dir "$(Get-Terminal $rol).md"
            if ($DryRun) { Write-Output "== $ruta"; Write-Output $texto; continue }
            Write-Texto $ruta $texto
        }
        $rutas = ([Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [Environment]::GetEnvironmentVariable('Path', 'User')) -split ';'
        if (-not ($rutas | Where-Object { $_ -and (Test-Path -LiteralPath (Join-Path $_ 'sh.exe')) } | Select-Object -First 1)) {
            Write-Warning 'hc ejecuta las plantillas con sh y sh.exe no esta en el PATH de Windows. Agrega C:\Program Files\Git\bin al PATH de usuario.'
        }
        if (-not $DryRun) { & hc templates }
    }
    'acceso-directo' {
        $lnk = Join-Path ([Environment]::GetFolderPath('Desktop')) "Herdr $NombreEq.lnk"
        $argumentos = "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$(Join-Path $Kit 'equipo.ps1')`" iniciar -Workspace `"$Ws`""
        if ($DryRun) { Write-Output "$lnk -> powershell.exe $argumentos"; return }
        $w = New-Object -ComObject WScript.Shell
        $l = $w.CreateShortcut($lnk)
        $l.TargetPath = 'powershell.exe'
        $l.Arguments = $argumentos
        $l.WorkingDirectory = $Ws
        $icono = Join-Path $env:LOCALAPPDATA 'Programs\herdr-app\herdr-app.exe'
        if (Test-Path -LiteralPath $icono) { $l.IconLocation = "$icono,0" }
        $l.Save()
        Write-Output "Creado $lnk. Para arrancar al iniciar sesion, copialo a la carpeta shell:startup."
    }
    'iniciar' {
        if (-not $DryRun -and -not (Test-VentanaHerdr)) {
            Start-Process -FilePath 'herdr-app'
            for ($i = 0; $i -lt 60 -and -not (Test-VentanaHerdr); $i++) { Start-Sleep -Milliseconds 500 }
        }
        if (-not $Oculto) { foreach ($g in $Grupos.Keys) { Get-EspacioGrupo -Grupo $g -Crear | Out-Null } }
        foreach ($rol in @($Roles.Keys | Where-Object { $Roles[$_].persistente })) { Start-Rol $rol }
    }
    default { Start-Rol $Accion $Tarea $TareaId }
}
