<!-- Propósito: explicar las reglas locales por rol del kit equipo-herdr. -->
# Reglas locales por rol

Coloca aquí `<rol>.md` (`plan`, `docs`, `luna`, `sol`, `revisor`, `diseno`) con las reglas propias de este workspace. Se agregan al final del rol genérico del kit, en la sección «Reglas de este workspace».

- Escribe solo lo específico de este workspace: comandos de prueba, reglas de arquitectura, fuentes de negocio y repositorios.
- Puedes usar los mismos marcadores que el kit: `{{plan}}`, `{{luna}}`, `{{TRABAJO}}`, `{{WORKSPACE}}`, etc.
- Los modelos, el esfuerzo, el grupo, el acceso remoto y las skills de cada rol se cambian en `../equipo.json`.
- Después de editar, ejecuta `.agents/equipo/equipo.ps1 generar` (los lanzamientos también regeneran).
