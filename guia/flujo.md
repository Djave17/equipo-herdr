<!-- Propósito: flujo de trabajo, revisión, documentación y reglas de commits del equipo. Índice en README.md. -->
# Cómo trabaja

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

## Revisión: solo lo realizado y con umbrales

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

## Documentación en `docs/`

`docs` documenta siempre las funcionalidades nuevas y las decisiones de cada tarea, en la carpeta `docs/` de cada repositorio afectado:

| Carpeta | Contenido |
|---|---|
| `docs/features/` | Qué hace cada funcionalidad, para qué sirve, cómo se usa y qué pruebas la verifican. |
| `docs/decisiones/` | Decisiones de alcance, negocio o compromisos: alternativas, motivo, quién decidió y fecha. |
| `docs/adr/` | Decisiones de arquitectura en formato ADR. |

## Commits y ramas

Ningún agente hace commit, push ni PR salvo que lo pidas. Cuando lo pidas, se usa [Conventional Commits](https://www.conventionalcommits.org/) y el trabajo va en una rama propia.

Los commits, PR y merges **no incluyen a ningún agente de IA como autor o colaborador**: sin `Co-Authored-By: Claude`, sin "Generated with Claude Code" ni firmas de Codex. La autoría es siempre de la persona. Para reforzarlo en Claude Code, desactiva la firma automática en `~/.claude/settings.json`:

```json
{ "attribution": { "commit": "", "pr": "" }, "includeCoAuthoredBy": false }
```

## Eficiencia (resumen)

El objetivo es el mejor resultado con el menor gasto necesario, no el agente más barato. Se gasta donde mejora la calidad (planificar, arbitrar, revisar lo riesgoso) y se ahorra donde no aporta:

- Revisión según riesgo y elección de `haiku` o `luna` por corte.
- `plan` limpia su contexto entre tareas y anota el costo de cada una.
- Salidas de pruebas recortadas, encargos con rutas exactas y artefactos breves.
- `diseno` solo con UI nueva; máximo 2 rondas de corrección.

Detalle de las 11 medidas en [EFICIENCIA.md](../EFICIENCIA.md).

