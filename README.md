<!-- Propósito: presentación e instalación del kit equipo-herdr para personas. Las instrucciones para agentes están en SKILL.md. -->
# equipo-herdr

Un equipo de siete agentes de IA que trabajan juntos sobre herdr (`hc`). Funciona en cualquier workspace: se instala una vez por máquina y luego cada proyecto solo necesita un archivo de configuración.

| Grupo (espacio herdr) | Rol | Modelo por defecto | Función |
|---|---|---|---|
| Negocio | `plan` | Claude Opus 5.5 · high | Planifica y orquesta. Es crítico y juez de las decisiones. Accesible por Remote Control. |
| Negocio | `docs` | Codex GPT-6 Luna · low | Documenta funcionalidades y decisiones en `docs/` y responde preguntas de negocio y código. |
| Desarrollo | `luna` | Codex GPT-6 Luna · high | Codifica con TDD. |
| Desarrollo | `haiku` | Claude Haiku 5.5 · high | Codifica cortes acotados o mecánicos. `plan` elige entre `haiku` y `luna` por corte. |
| Desarrollo | `sol` | Codex GPT-6.1 Sol · medium | Ejecuta las pruebas y verifica la arquitectura. |
| Desarrollo | `revisor` | Claude Opus 5.5 · medium | Verifica los objetivos del plan, la arquitectura y SOLID. Interviene según el riesgo del corte. Si encuentra problemas, devuelve el trabajo al codificador. |
| Diseño | `diseno` | Claude Opus 5.5 · high | Diseño UI/UX. Accesible por Remote Control. |

## Guía

| Documento | Contenido |
|---|---|
| [Cómo trabaja el equipo](guia/flujo.md) | Flujo, revisión con umbrales, documentación en `docs/`, commits y ramas. |
| [Qué hace herdr](guia/herdr.md) | Terminales, espacios, mensajes y orquestación. |
| [Uso y configuración](guia/uso.md) | Comandos y `equipo.json` por workspace. |
| [Skills](guia/skills.md) | Incluidas, descargadas al instalar y recomendadas. |
| [Eficiencia](EFICIENCIA.md) | Mejor resultado con el menor gasto de tokens. |

## Requisitos

- Windows con PowerShell 5.1 o superior.
- herdr (`herdr-app` y `hc`).
- [Claude Code](https://claude.com/claude-code) (`claude`) y [Codex CLI](https://github.com/openai/codex) (`codex`), con sesión iniciada y acceso a los modelos configurados.
- Las skills de los roles ([Skills](guia/skills.md)); se instalan con `instalar-skills.ps1`.
- El plugin `engineering` de Claude Code (lo usa `revisor`).
- *(Opcional)* `C:\Program Files\Git\bin` en el PATH, para usar las plantillas nativas de `hc`.

## Instalación

```powershell
git clone https://github.com/Djave17/equipo-herdr "$HOME\.agents\skills\equipo-herdr"
# Para que Claude Code también lo vea como skill:
cmd /c mklink /J "$HOME\.claude\skills\equipo-herdr" "$HOME\.agents\skills\equipo-herdr"
```

Después instala las skills:

```powershell
& "$HOME\.agents\skills\equipo-herdr\instalar-skills.ps1"
```

Para actualizar: `git -C "$HOME\.agents\skills\equipo-herdr" pull`.

## Estructura del kit

| Archivo | Contenido |
|---|---|
| `equipo.ps1` | Lanzador: instala, genera, lanza, administra y verifica. |
| `equipo.defaults.json` | Modelos, esfuerzos, grupos y skills por defecto de cada rol. |
| `PROTOCOLO.md` | Flujo, mensajes, consultas y reglas comunes. |
| `EQUIPO.md` | Plantilla de la composición del equipo. |
| `roles/*.md` | Roles genéricos. |
| `instalar-skills.ps1` | Instala las skills de `skills/` y descarga `impeccable`. |
| `skills/` | Skills incluidas con su licencia de origen. |
| `guia/` | Documentación para personas, por tema. |
| `EFICIENCIA.md` | Criterios para el mejor resultado con el menor gasto. |
| `atajo.ps1` | Atajo que `instalar` copia a cada workspace. |
| `SKILL.md` | Instrucciones para agentes (Claude Code y Codex). |

Instrucciones para agentes en [SKILL.md](SKILL.md).

## Licencia

[MIT](LICENSE)
