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

## Cómo trabaja

1. Le das un objetivo a `plan`. Lo cuestiona, propone alternativas si ve problemas y escribe `plan.md`, donde decide por cada corte quién lo codifica y cuánto riesgo tiene.
2. Cuando dices "implementa", `plan` coordina al resto sin que tengas que lanzar nada:
   1. `diseno`, si hay UI nueva o rediseño.
   2. `haiku` (cambios acotados o mecánicos) o `luna` (lógica, arquitectura, bugs complejos), según el corte.
   3. `sol` ejecuta las pruebas y mide los umbrales.
   4. `revisor`, solo si el riesgo del corte lo requiere.
   5. Hasta 2 rondas de corrección; si no basta, `plan` te consulta.
   6. `docs` documenta las funcionalidades y decisiones.
   7. `plan` te entrega un resumen con la evidencia y el costo de la tarea.

Si un agente no sabe cómo hacer algo, consulta a un superior. `plan` arbitra las discrepancias. Las decisiones de negocio siempre son tuyas.

### Revisión: solo lo realizado y con umbrales

`sol` y `revisor` revisan únicamente el cambio de la ronda. Lo que vean fuera del cambio lo anotan como observación, sin bloquear.

Cada hallazgo debe citar una regla o un umbral con su valor medido (por ejemplo, `complejidad 14 > 10`):

| Umbral | Valor |
|---|---|
| Complejidad ciclomática por función | ≤ 10 |
| Líneas por archivo | ≤ 400 |
| Parámetros por función | ≤ 4 |
| Anidamiento | ≤ 3 |
| Líneas duplicadas | < 8 |
| Consultas por operación | ≤ 1 (sin N+1) |
| Cobertura del cambio | ≥ 80 % |

- **Bloqueante** (reabre ronda): violar la arquitectura o el `AGENTS.md`, consultas en bucle, comportamiento nuevo sin prueba o un umbral superado en más de un 20 %.
- **Sugerencia** (no reabre ronda): umbral superado dentro del 20 %, nombres, estilo.

La revisión depende del riesgo del corte: los mecánicos los revisa solo `sol`; los normales y de alto riesgo, `sol` y `revisor`. Los umbrales son globales (`revision` en `equipo.defaults.json`) y un workspace puede ajustarlos en su `equipo.json`.

### Documentación en `docs/`

`docs` documenta siempre las funcionalidades nuevas y las decisiones de cada tarea, en la carpeta `docs/` de cada repositorio afectado:

| Carpeta | Contenido |
|---|---|
| `docs/features/` | Qué hace cada funcionalidad, para qué sirve, cómo se usa y qué pruebas la verifican. |
| `docs/decisiones/` | Decisiones de alcance, negocio o compromisos: alternativas, motivo, quién decidió y fecha. |
| `docs/adr/` | Decisiones de arquitectura en formato ADR. |

### Eficiencia

El objetivo es el mejor resultado con el menor gasto necesario, no el agente más barato. Se gasta donde mejora la calidad (planificar, arbitrar, revisar lo riesgoso) y se ahorra donde no aporta:

- Revisión según riesgo y elección de `haiku` o `luna` por corte.
- `plan` limpia su contexto entre tareas y anota el costo de cada una.
- Salidas de pruebas recortadas, encargos con rutas exactas y artefactos breves.
- `diseno` solo con UI nueva; máximo 2 rondas de corrección.

Detalle de las 11 medidas en [EFICIENCIA.md](EFICIENCIA.md).

### Commits y ramas

Ningún agente hace commit, push ni PR salvo que lo pidas. Cuando lo pidas, se usa [Conventional Commits](https://www.conventionalcommits.org/) y el trabajo va en una rama propia.

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

## Skills

### Incluidas en el kit (carpeta `skills/`)

Se distribuyen con el repositorio porque los roles dependen de su versión exacta y algunas ya no existen en su repositorio original. `instalar-skills.ps1` las copia a `~/.agents/skills` (Codex) y `~/.claude/skills` (Claude Code); no reemplaza las que ya tengas salvo con `-Forzar`.

| Skill | Rol que la usa | Para qué |
|---|---|---|
| `tdd` | `luna`, `haiku`, `sol` | Ciclo rojo → verde → refactor y criterio para juzgar pruebas. |
| `diagnose` | `luna`, `haiku` | Diagnóstico de bugs. |
| `to-issues` | `plan` | Cortes verticales y criterios de aceptación. |
| `grill-with-docs` | `plan`, `docs` | Entrevista ante objetivos ambiguos; formatos de `CONTEXT.md` y ADR. |
| `zoom-out` | `plan`, `docs` | Entender cómo encaja una pieza en el sistema. |
| `caveman` | todos (opcional) | Respuestas escuetas para ahorrar tokens de salida. |

Origen: [mattpocock/skills](https://github.com/mattpocock/skills), licencia MIT (`skills/LICENSE-mattpocock-skills`).

### Descargadas al instalar

| Skill | Rol | Origen |
|---|---|---|
| `impeccable` | `diseno` | [pbakaus/impeccable](https://github.com/pbakaus/impeccable) (Apache 2.0). Pesa unos 20 MB, por eso se descarga en lugar de incluirse. Omítela con `-SinImpeccable`. |
| Plugin `engineering` | `revisor` | Marketplace de plugins de Claude Code. |

### Recomendadas según el stack

Se activan añadiéndolas a `skills` del rol en `equipo.json`:

| Skill | Rol sugerido | Cuándo |
|---|---|---|
| `kotlin-specialist`, `android-development` | `luna`, `haiku` | Apps Android/Kotlin. |
| `android-jetpack-compose` | `diseno` | UI con Jetpack Compose. |
| `design-taste-frontend` | `diseno` | Frontend web. |
| `improve-codebase-architecture` | `revisor`, `plan` | Refactors de arquitectura. |
| Skills propias del proyecto (p. ej. reglas de arquitectura) | según el caso | Reglas no negociables del repositorio. |

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

- `equipo.json`: nombre, prefijo de terminales, contexto del proyecto, `revision` opcional (alcance, umbrales y severidad de las revisiones; por defecto los globales del kit) y, por rol, los cambios sobre los valores por defecto (`modelo`, `esfuerzo`, `skills`, `grupo`, `remoto`, `persistente`, `cli`).
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
| `instalar-skills.ps1` | Instala las skills de `skills/` y descarga `impeccable`. |
| `skills/` | Skills incluidas con su licencia de origen. |
| `EFICIENCIA.md` | Criterios para el mejor resultado con el menor gasto. |
| `atajo.ps1` | Atajo que `instalar` copia a cada workspace. |
| `SKILL.md` | Instrucciones para agentes (Claude Code y Codex). |

Más detalle en [SKILL.md](SKILL.md).

## Licencia

[MIT](LICENSE)
