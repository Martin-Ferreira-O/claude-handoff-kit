# CLAUDE.md

Este repo **es** un kit de "Harness Engineering": un conjunto de comandos que
coordinan un agente planificador (Opus) y un agente implementador (Codex o un
Claude fresco) a través de handoffs basados en archivos bajo `docs/handoff/<slug>/`.

El contrato compartido — cómo se estructura un handoff y cómo se actualiza — vive
en `AGENTS.md` y lo lee cualquier herramienta. Este archivo agrega la guía
específica para Claude/Opus como autor del spec.

@AGENTS.md

## El ciclo

```
/plan → /clarify → /resume → /implement → /code-review
```

- **/plan** — Opus arranca el ciclo y lo materializa de una: crea la rama de tarea
  (para no trabajar en `main`), conduce el planning, lo pasa por una
  **auto-crítica**, y **escribe el paquete de handoff** en `docs/handoff/<slug>/`
  (CONTEXT, PLAN, PROGRESS, DECISIONS) con bloque **Verification**, deriva `.verify`
  y siembra la fila en `INDEX.md`. **Absorbió a `/handoff`**: ya no hay un segundo
  comando que re-derive contexto. Es **opcional**: corre **fuera** del plan mode
  nativo (que es read-only y no puede ramificar ni escribir el paquete) y no duplica
  `/clarify` — ante ambigüedad real, deriva a él. Otro agente puede saltárselo y
  traer su propio draft, pasándolo como segundo argumento (`/plan <slug> <path>`)
  para que `/plan` lo empaquete, o materializando el paquete a mano según `AGENTS.md`.
- **/clarify** — Opus entrevista al usuario (`AskUserQuestion`) sobre las partes
  difíciles (bordes, límites de alcance, tradeoffs) y vuelca las respuestas
  **directo en el `PLAN.md` del paquete** (Goal/Non-goals + sección *Clarifications*).
  Corre **después** de `/plan`, sobre el paquete ya creado. Es **opcional**: si el
  cambio cabe en una sola frase, saltá `/clarify` y hacelo directo.
- **/resume** — reconstruye contexto y hace el briefing; **no implementa**.
- **/implement** — ejecuta `PLAN.md` paso a paso, con un commit atómico por
  paso verificado (código + actualizaciones de PROGRESS/DECISIONS juntos). Antes
  del reporte final corre un **gate de review contra `PLAN.md`** en **contexto
  realmente fresco** — el revisor ve **solo el diff + `PLAN.md`**, no la sesión
  del implementador, para no heredar sus supuestos: "¿está implementado cada
  requisito y pasa el comando de **Verification**? Reportá gaps, no preferencias
  de estilo." El mecanismo es por-herramienta: **preferí un subagente / sesión
  limpia** (la garantía real); correr `/code-review` en la misma sesión es el
  **fallback de menor garantía**, solo si no hay subagente disponible. El
  resultado queda en una línea de PROGRESS que distingue `review (fresh)` de
  `review (in-session)` según el mecanismo usado.

## Roles (no cruzar las líneas)

- **Opus = autor del spec.** Planifica, decide arquitectura y escribe `PLAN.md`.
  No implementa salvo que se lo pidan explícitamente.
- **Implementador = ejecutor.** Sigue `PLAN.md` sin rediseñar. Ante un paso
  ambiguo, erróneo o imposible, **para** y lo registra en `DECISIONS.md` en lugar
  de improvisar otro diseño.
- **Solo Opus reescribe `PLAN.md`.** El implementador propone cambios al spec vía
  `DECISIONS.md` (sección *Open questions for the spec author*); nunca edita el
  plan en silencio. Esta es la regla que evita que el harness derive.

## Cuándo materializar (o actualizar) el paquete

El paquete lo crea `/plan` desde el arranque del ciclo. Que exista (y mantenerlo al
día) importa sobre todo cuando:

- Te estás quedando sin contexto/tokens en una tarea larga y otra sesión la continúa.
- Vas a delegar la ejecución a Codex u otro agente.
- Querés paralelizar varios slugs en paralelo.

## Gate de verificación

- Ningún paso se marca `- [x]` en `PROGRESS.md` ni se commitea sin correr los
  comandos de **Setup / run / test** de `CONTEXT.md` y ver que pasan.
- Reportá los fallos con el output real — nunca afirmes que un paso pasó sin
  verificarlo.
- No commitees un paso `🚧` (en progreso) o `⛔` (bloqueado).

## Git

- **Una rama por slug, creada lo antes posible.** La rama de tarea nace al
  **arranque** del ciclo (`/plan` la crea desde `main`/`master`), no recién en
  `/implement`. Es pre-requisito de los slugs paralelos (el Stop-hook resuelve el
  slug por la rama y los worktrees de `/dispatch` necesitan una rama por slug). Se
  permiten prefijos del proyecto host (p.ej. `feat/<slug>`) siempre que el slug se
  derive del sufijo.
- `/implement` hace **un commit por paso verificado** y **no pushea**.
- El branch-step de `/implement` es una **red de seguridad idempotente**: si ya
  estás en la rama del slug no hace nada; si seguís en `main`/`master`, la crea.
- Pushear y abrir PR queda manual, salvo que el usuario lo pida.

## Convenciones de los comandos (este repo se auto-dogfoodea)

- Cada comando en `.claude/commands/` lleva frontmatter: `description`,
  `argument-hint`, `allowed-tools`.
- `allowed-tools` mínimo necesario: read-mostly para `handoff`/`resume`,
  `Write`/`Edit`/`Bash` para `implement`. El `Bash` sin restringir de
  `implement.md` es **la única concesión amplia intencional**: implementar de
  verdad necesita bash arbitrario; el resto de los comandos van acotados.
- Slugs en kebab-case; un handoff por slug — se **actualiza**, no se duplica.
- **Tamaño del slug:** acotá cada slug a lo que entra en una sola ventana de
  contexto del implementador. Si el plan es grande, partilo en varios slugs en
  paralelo (el kit ya soporta slugs paralelos) en lugar de un slug gigante que
  pudre el contexto del implementador a mitad de camino.
- Los cuatro archivos del handoff abren con el banner de cabecera.
