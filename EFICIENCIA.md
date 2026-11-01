<!-- Propósito: criterios del kit para obtener el mejor resultado con el menor costo de tokens. Los aplican las plantillas de roles y PROTOCOLO.md. -->
# Eficiencia del equipo

El objetivo no es el agente más barato, sino **el mejor resultado con el menor gasto necesario**. Se gasta donde mejora la calidad (planificar, arbitrar, revisar riesgo real) y se ahorra donde no aporta (contexto acumulado, logs, exploración, pasadas redundantes).

## Medidas

| # | Medida | Dónde se aplica | Por qué |
|---|---|---|---|
| 1 | **Contexto limpio entre tareas.** Al cerrar, `plan` guarda lo necesario en `decisiones.md` y limpia su conversación (`/clear`). | `roles/plan.md` (Cierre) | `plan` es permanente: sin limpiar, cada turno repaga todo el historial. |
| 2 | **Esfuerzo por fase.** `plan` piensa a fondo al planificar y arbitrar; en el ruteo (recibir `LISTO`, lanzar, esperar) actúa breve y sin re-análisis. | `roles/plan.md` | El ruteo no mejora con razonamiento profundo. |
| 3 | **Revisión según riesgo.** Mecánico (`haiku`): solo `sol`. Lógica normal: `sol` + `revisor`. Arquitectura, persistencia, seguridad o concurrencia: ambos completos. | `PROTOCOLO.md`, `roles/plan.md` | Evita una pasada de Opus donde no detectaría nada. `sol` sube a **medium** para que esa única revisión sea fiable. |
| 4 | **Salida de pruebas recortada.** Modo silencioso y solo resumen + fallos; nunca logs completos en artefactos ni mensajes. | `PROTOCOLO.md`, `luna`, `haiku`, `sol` | Un log se lee hasta tres veces (codificador, `sol`, `plan`). |
| 5 | **Encargos cerrados.** Rutas exactas, patrón a seguir y comando de prueba; el índice de código antes que explorar. | `roles/plan.md` | La exploración es el mayor gasto de los codificadores. |
| 6 | **Mensajes y artefactos breves.** Formato fijo, sin repetir lo que ya está en otro artefacto. | `PROTOCOLO.md` | La salida es el token más caro. |
| 7 | **`docs` solo si hay documentación que tocar.** `plan.md` lo indica. | `PROTOCOLO.md`, `roles/plan.md` | No todas las tareas cambian documentación. |
| 8 | **`diseno` solo con UI nueva o rediseño.** Ajustes menores sobre un diseño existente los hace el codificador con `impeccable`. | `roles/plan.md` | Opus high solo donde decide el diseño. |
| 9 | **Máximo 2 rondas de corrección.** Solo los hallazgos bloqueantes reabren ronda; después se escala al usuario. | `PROTOCOLO.md` | Con umbrales y severidad, una tercera ronda rara vez converge. |
| 10 | **Costo medido por tarea.** El cierre incluye tokens/costo por agente (`/cost` en Claude, uso reportado en Codex) en `decisiones.md`. | `roles/plan.md` (Cierre) | Sin datos no se puede ajustar modelo ni esfuerzo con criterio. |
| 11 | **Prefijo estable para la caché.** Protocolo, `EQUIPO.md` y rol se leen primero y solo cambian al regenerar. | `equipo.ps1 generar` | La caché de prompts cobra mucho menos lo que se repite idéntico. |

## Asignación de modelos

| Rol | Modelo · esfuerzo | Cuándo se usa |
|---|---|---|
| `plan` | Opus · high | Siempre (permanente); profundidad solo al planificar y arbitrar. |
| `haiku` | Haiku · high | Cortes acotados o mecánicos. |
| `luna` | Luna · high | Lógica, arquitectura, bugs sin causa conocida. |
| `sol` | Sol · medium | Todos los cortes. |
| `revisor` | Opus · medium | Cortes con lógica o riesgo. |
| `diseno` | Opus · high | UI nueva o rediseño. |
| `docs` | Luna · low | Solo si hay documentación que tocar. |

Revisa estos valores con los costos medidos (medida 10) antes de cambiarlos.
