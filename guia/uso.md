<!-- Propósito: comandos y configuración del equipo en un workspace. Índice en README.md. -->
# Uso en un workspace

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
