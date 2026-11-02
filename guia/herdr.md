<!-- Propósito: explicar qué papel cumple herdr en el equipo. Índice en README.md. -->
# Qué hace herdr en el equipo

herdr es el entorno donde corren los agentes. No forma parte del código del proyecto: los repositorios no dependen de él; es la herramienta con la que el equipo trabaja sobre ellos.

| Uso | Cómo |
|---|---|
| **Una terminal por agente** | Cada rol corre en su terminal con el prefijo del workspace: `<prefijo>-plan`, `<prefijo>-luna`, etc. |
| **Espacios por grupo** | Las terminales se agrupan en *Negocio* (`plan`, `docs`), *Desarrollo* (codificadores y revisores) y *Diseño*. |
| **Mensajes entre agentes** | `hc send <terminal> "PREFIJO: resumen -> ruta"` con `LISTO`, `HALLAZGOS`, `CONSULTA`, `RESPUESTA`, `APROBADO` o `BLOQUEADO`. El contenido largo va en archivos. |
| **Orquestación** | Solo `plan` lanza y cierra agentes, mediante `equipo.ps1`, que llama a `hc`. Espera con `hc wait`, nunca con sleep. |
| **Supervisión** | Si un agente queda bloqueado, `plan` lee su pantalla con `hc read <terminal> --lines 60`. |

## Dónde vive cada cosa en un workspace

| Ruta | Contenido |
|---|---|
| `.agents/equipo/equipo.json` | Nombre, prefijo, contexto del proyecto y cambios por rol. |
| `.agents/equipo/roles/` | Reglas propias del proyecto, que se agregan al rol genérico. |
| `.agents/equipo/trabajo/<tarea>/` | Artefactos de cada tarea: `plan.md`, `implementacion.md`, `verificacion-N.md`, `decisiones.md`… |
| `.agents/equipo/.generado/` | Lo que leen los agentes, generado a partir del kit y la configuración. |

Para arrancar: `.\.agents\equipo\equipo.ps1 iniciar` abre herdr, crea los espacios y deja vivos `plan` y `docs`. Después hablas con `<prefijo>-plan`.
