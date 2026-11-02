<!-- Propósito: skills que usa el equipo: incluidas, descargadas y recomendadas. Índice en README.md. -->
# Skills

## Incluidas en el kit (carpeta `skills/`)

Se distribuyen con el repositorio porque los roles dependen de su versión exacta y algunas ya no existen en su repositorio original. `instalar-skills.ps1` las copia a `~/.agents/skills` (Codex) y `~/.claude/skills` (Claude Code); no reemplaza las que ya tengas salvo con `-Forzar`.

| Skill | Rol que la usa | Para qué |
|---|---|---|
| `tdd` | `luna`, `haiku`, `sol` | Ciclo rojo → verde → refactor y criterio para juzgar pruebas. |
| `diagnose` | `luna`, `haiku` | Diagnóstico de bugs. |
| `to-issues` | `plan` | Cortes verticales y criterios de aceptación. |
| `grill-with-docs` | `plan`, `docs` | Entrevista ante objetivos ambiguos; formatos de `CONTEXT.md` y ADR. |
| `zoom-out` | `plan`, `docs` | Entender cómo encaja una pieza en el sistema. |
| `caveman` | todos (opcional) | Respuestas escuetas para ahorrar tokens de salida. |

Origen: [mattpocock/skills](https://github.com/mattpocock/skills), licencia MIT (`../skills/LICENSE-mattpocock-skills`).

## Descargadas al instalar

| Skill | Rol | Origen |
|---|---|---|
| `impeccable` | `diseno` | [pbakaus/impeccable](https://github.com/pbakaus/impeccable) (Apache 2.0). Pesa unos 20 MB, por eso se descarga en lugar de incluirse. Omítela con `-SinImpeccable`. |
| Plugin `engineering` | `revisor` | Marketplace de plugins de Claude Code. |

## Recomendadas según el stack

Se activan añadiéndolas a `skills` del rol en `equipo.json`:

| Skill | Rol sugerido | Cuándo |
|---|---|---|
| `kotlin-specialist`, `android-development` | `luna`, `haiku` | Apps Android/Kotlin. |
| `android-jetpack-compose` | `diseno` | UI con Jetpack Compose. |
| `design-taste-frontend` | `diseno` | Frontend web. |
| `improve-codebase-architecture` | `revisor`, `plan` | Refactors de arquitectura. |
| Skills propias del proyecto (p. ej. reglas de arquitectura) | según el caso | Reglas no negociables del repositorio. |
