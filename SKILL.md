---
name: equipo-herdr
description: Equipo de agentes plug and play sobre herdr (hc) para cualquier workspace. Siete roles con modelo, esfuerzo y skills por defecto, organizados en tres grupos (Negocio, Desarrollo, Diseño). Usar para instalar el equipo en un workspace nuevo, lanzarlo o arrancarlo con herdr, cambiar modelos/skills por rol, o cuando el usuario mencione herdr, hc, equipo de agentes, orquestador, plan/luna/sol/revisor/diseno/docs.
---

# equipo-herdr

Kit global, con una única copia en `~/.agents/skills/equipo-herdr/`. Cada workspace solo guarda su configuración en `.agents/equipo/`.

## Equipo por defecto

| Grupo (espacio herdr) | Rol | Modelo | Esfuerzo | Remoto | Permanente |
|---|---|---|---|---|---|
| Negocio | `plan`: planifica y orquesta | Claude `claude-opus-5-5` | high | Sí | Sí |
| Negocio | `docs`: documenta y responde al usuario sobre negocio y código | Codex `gpt-6-luna` | low | No | Sí |
| Desarrollo | `luna`: codifica | Codex `gpt-6-luna` | high | No | No |
| Desarrollo | `haiku`: codifica cortes acotados o mecánicos | Claude `claude-haiku-5-5` | high | No | No |
| Desarrollo | `sol`: verifica tests y arquitectura | Codex `gpt-6.1-sol` | medium | No | No |
| Desarrollo | `revisor`: objetivos del plan, arquitectura y SOLID | Claude `claude-opus-5-5` | medium | No | No |
| Diseño | `diseno`: UI/UX | Claude `claude-opus-5-5` | high | Sí | No |

**Flujo:**

1. `plan` escribe el plan.
2. `diseno` interviene si hay UI.
3. `luna` implementa.
4. `sol` verifica.
5. `revisor` revisa; si hay hallazgos, vuelve a `luna`.
6. `docs` documenta.
7. `plan` cierra y entrega el resumen.

Si `luna`, `sol` o `docs` no saben cómo hacer algo, consultan a `plan` (o a `diseno` si es de UI) y aplican la respuesta. El detalle está en `PROTOCOLO.md`.

## Instalar en un workspace

```powershell
& "$HOME\.agents\skills\equipo-herdr\equipo.ps1" instalar -Workspace C:\ruta\ws -Nombre "Mi Proyecto" -Prefijo mp
```

Esto crea, en `C:\ruta\ws\.agents\equipo\`:

- `equipo.json`: la configuración. Si ya existe, no se sobrescribe.
- `equipo.ps1`: un atajo al kit.
- `roles/LEEME.md`: cómo agregar reglas locales por rol.
- `.gitignore`: excluye `trabajo/` y `.generado/`.
- `.generado/`: lo que leen los agentes.

`-Nombre` y `-Prefijo` son opcionales y por defecto toman el nombre de la carpeta. El prefijo nombra las terminales (`mp-plan`, `mp-luna`…), así que dos workspaces pueden correr a la vez.

**Primera vez en una carpeta nueva:** abre `claude` y `codex` una vez en el workspace y acepta confiar en la carpeta. Si no, los agentes quedan `blocked` al arrancar.

## Uso diario (desde el workspace)

```powershell
.\.agents\equipo\equipo.ps1 iniciar          # abre herdr, crea los 3 espacios y deja vivos plan y docs (idempotente)
.\.agents\equipo\equipo.ps1 plan "Objetivo"  # o habla con plan en su pestaña o por Remote Control
.\.agents\equipo\equipo.ps1 estado
.\.agents\equipo\equipo.ps1 cerrar           # cierra los no permanentes
.\.agents\equipo\equipo.ps1 acceso-directo   # crea "Herdr <Nombre>" en el escritorio, que ejecuta iniciar
.\.agents\equipo\equipo.ps1 plantillas       # plantillas hc <prefijo>-<rol> (requieren sh.exe en el PATH de Windows)
```

`plan` lanza a los demás con `equipo.ps1 <rol> -TareaId <id> -Tarea "..."`. Si el agente ya está vivo, le envía el encargo en lugar de relanzarlo. Usa `-DryRun` para ver los comandos sin ejecutar.

## Configuración por workspace (`.agents/equipo/equipo.json`)

```json
{
  "nombre": "Mi Proyecto",
  "prefijo": "mp",
  "contexto": ["Cómo localizar código aquí (índice, scripts, docs de entrada)."],
  "grupos": { "diseno": "Mi Proyecto UI" },
  "roles": {
    "luna": { "esfuerzo": "medium", "skills": ["`tdd`: obligatoria.", "`kotlin-specialist`: en el módulo móvil."] },
    "docs": { "esfuerzo": "medium" }
  }
}
```

- Cada rol admite `grupo`, `cli` (`claude`|`codex`), `modelo`, `esfuerzo`, `remoto`, `persistente`, `descripcion` y `skills`.
- Lo que pongas reemplaza el valor por defecto de `equipo.defaults.json`. En el caso de `skills`, reemplaza la lista completa.
- Las reglas propias del workspace van en `.agents/equipo/roles/<rol>.md` y se agregan al rol genérico.
- Después de editar, ejecuta `equipo.ps1 generar`. Cada lanzamiento también regenera.

## Compartir

Son dos piezas independientes:

1. **El kit** (esta carpeta). No contiene rutas personales ni secretos. Quien lo recibe lo coloca en `~/.agents/skills/equipo-herdr/`. Para que Claude Code lo vea como skill, además lo enlaza en `~/.claude/skills/equipo-herdr/` (por ejemplo, con `mklink /J`). Otra opción es dejarlo en otra ruta y definir `EQUIPO_HERDR_KIT`.
2. **La configuración de un workspace**: `.agents/equipo/equipo.json`, `.agents/equipo/roles/` y `.agents/equipo/equipo.ps1`. No incluyas `trabajo/` ni `.generado/`, porque se regeneran con rutas locales.

**Requisitos de quien lo recibe:**

- Windows con PowerShell.
- herdr (`herdr-app` y `hc`), `claude` y `codex` instalados y con sesión iniciada.
- Acceso a los modelos configurados.
- Las skills que referencian los roles.

`equipo.ps1 verificar` lista lo que falta.

## Notas de herdr en Windows

- hc ejecuta las plantillas con `sh -c`. Necesitan `C:\Program Files\Git\bin` en el PATH de usuario. El lanzador no depende de ellas.
- Codex corre con `--no-daemon` bajo hc. Los encargos van a archivo, porque `codex.cmd` (cmd.exe) rompe los argumentos multilínea o con comillas.
- Si solo cierras la ventana, las terminales siguen vivas. Tras un reinicio quedan como shells; `iniciar` lo detecta y relanza los agentes permanentes.
