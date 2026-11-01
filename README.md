<!-- Propósito: presentación e instalación del kit equipo-herdr para personas. Las instrucciones para agentes están en SKILL.md. -->
# equipo-herdr

Un equipo de seis agentes de IA que trabajan juntos sobre herdr (`hc`). Funciona en cualquier workspace: se instala una vez por máquina y luego cada proyecto solo necesita un archivo de configuración.

| Grupo (espacio herdr) | Rol | Modelo por defecto | Función |
|---|---|---|---|
| Negocio | `plan` | Claude Opus 5.5 · high | Planifica y orquesta. Es crítico y juez de las decisiones. Accesible por Remote Control. |
| Negocio | `docs` | Codex GPT-6 Luna · low | Documenta y responde preguntas de negocio y código. |
| Desarrollo | `luna` | Codex GPT-6 Luna · high | Codifica con TDD. |
| Desarrollo | `sol` | Codex GPT-6.1 Sol · low | Ejecuta las pruebas y verifica la arquitectura. |
| Desarrollo | `revisor` | Claude Opus 5.5 · medium | Verifica los objetivos del plan, la arquitectura y SOLID. Si encuentra problemas, devuelve el trabajo a `luna`. |
| Diseño | `diseno` | Claude Opus 5.5 · high | Diseño UI/UX. Accesible por Remote Control. |

**Flujo:**

1. Le das un objetivo a `plan`. Él lo cuestiona y escribe el plan.
2. Cuando dices "implementa", `plan` lanza al resto:
   1. `diseno` (si hay UI).
   2. `luna`.
   3. `sol`.
   4. `revisor`, con rondas de corrección.
   5. `docs`.
   6. Al final, `plan` te entrega un resumen.

Si un agente no sabe cómo hacer algo, consulta a un superior. `plan` arbitra las discrepancias. Las decisiones de negocio siempre son tuyas.

## Requisitos

- Windows con PowerShell 5.1 o superior.
- herdr (`herdr-app` y `hc`).
- [Claude Code](https://claude.com/claude-code) (`claude`) y [Codex CLI](https://github.com/openai/codex) (`codex`), con sesión iniciada y acceso a los modelos configurados.
- Las skills que usan los roles por defecto, en `~/.agents/skills/` o `~/.claude/skills/`: `to-issues`, `grill-with-docs`, `zoom-out`, `tdd`, `diagnose` e `impeccable`.
- El plugin `engineering` de Claude Code (lo usa `revisor`).
- *(Opcional)* `C:\Program Files\Git\bin` en el PATH, para usar las plantillas nativas de `hc`.

## Instalación

```powershell
git clone <url-de-este-repo> "$HOME\.agents\skills\equipo-herdr"
# Para que Claude Code también lo vea como skill:
cmd /c mklink /J "$HOME\.claude\skills\equipo-herdr" "$HOME\.agents\skills\equipo-herdr"
```

Para actualizar: `git -C "$HOME\.agents\skills\equipo-herdr" pull`.

## Uso en un workspace

```powershell
& "$HOME\.agents\skills\equipo-herdr\equipo.ps1" instalar -Workspace C:\mi-proyecto -Nombre "Mi Proyecto" -Prefijo mp
cd C:\mi-proyecto
.\.agents\equipo\equipo.ps1 verificar   # lista lo que falta en esta máquina
.\.agents\equipo\equipo.ps1 iniciar     # abre herdr y deja vivos plan y docs
```

La primera vez, abre `claude` y `codex` en la carpeta del workspace y acepta confiar en ella. Después habla con `mp-plan` en el espacio **Mi Proyecto Negocio**.

| Comando | Para qué |
|---|---|
| `iniciar` | Abre herdr, crea los espacios de grupo y deja vivos `plan` y `docs`. Se puede repetir sin riesgo. |
| `plan "objetivo"` | Inicia `plan` con un objetivo (si ya vive, se lo envía). |
| `estado` / `cerrar [-Agentes a,b]` | Ver los agentes y cerrar los de trabajo. |
| `generar` | Regenerar los roles tras editar la configuración. |
| `plantillas` | Crear las plantillas `hc` `<prefijo>-<rol>`. |
| `acceso-directo` | Crear el acceso directo "Herdr <Nombre>" en el escritorio. |
| `verificar` | Comprobar los requisitos. |

Añade `-DryRun` a cualquier comando para ver lo que haría sin ejecutarlo.

## Configuración por workspace

`instalar` crea `.agents/equipo/` en el workspace:

- `equipo.json`: nombre, prefijo de terminales, contexto del proyecto y, por rol, los cambios sobre los valores por defecto (`modelo`, `esfuerzo`, `skills`, `grupo`, `remoto`, `persistente`, `cli`).
- `roles/<rol>.md`: reglas propias del proyecto, que se agregan al rol genérico.
- `equipo.ps1`: atajo al kit.
- `trabajo/` y `.generado/`: artefactos locales, ignorados por git.

```json
{
  "nombre": "Mi Proyecto",
  "prefijo": "mp",
  "contexto": ["Cómo localizar código y qué documentación leer en este proyecto."],
  "roles": {
    "luna": { "skills": ["`tdd`: obligatoria.", "`kotlin-specialist`: en el módulo móvil."] },
    "docs": { "esfuerzo": "medium" }
  }
}
```

## Estructura del kit

| Archivo | Contenido |
|---|---|
| `equipo.ps1` | Lanzador: instala, genera, lanza, administra y verifica. |
| `equipo.defaults.json` | Modelos, esfuerzos, grupos y skills por defecto de cada rol. |
| `PROTOCOLO.md` | Flujo, mensajes, consultas y reglas comunes. |
| `EQUIPO.md` | Plantilla de la composición del equipo. |
| `roles/*.md` | Roles genéricos. |
| `atajo.ps1` | Atajo que `instalar` copia a cada workspace. |
| `SKILL.md` | Instrucciones para agentes (Claude Code y Codex). |

Más detalle en [SKILL.md](SKILL.md).
