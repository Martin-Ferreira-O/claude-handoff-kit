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
plan (Opus) → /clarify → /handoff → /resume → /implement → /code-review
```

- **/clarify** — Opus entrevista al usuario (`AskUserQuestion`) sobre las partes
  difíciles (bordes, límites de alcance, tradeoffs) y vuelca las respuestas en el
  Goal/Non-goals del plan **antes** del handoff. Es **opcional**: si el cambio
  cabe en una sola frase, saltá `/clarify` y `/handoff` y hacelo directo.
- **/handoff** — Opus vuelca contexto + spec en `docs/handoff/<slug>/`
  (CONTEXT, PLAN, PROGRESS, DECISIONS) y registra el slug en `INDEX.md`.
- **/resume** — reconstruye contexto y hace el briefing; **no implementa**.
- **/implement** — ejecuta `PLAN.md` paso a paso, con un commit atómico por
  paso verificado (código + actualizaciones de PROGRESS/DECISIONS juntos). Antes
  del reporte final corre un **gate de review contra `PLAN.md`** (skill
  `/code-review` o subagente, en contexto fresco): "¿está implementado cada
  requisito y pasa el comando de **Verification**? Reportá gaps, no preferencias
  de estilo." El resultado queda en una línea de PROGRESS.

## Roles (no cruzar las líneas)

- **Opus = autor del spec.** Planifica, decide arquitectura y escribe `PLAN.md`.
  No implementa salvo que se lo pidan explícitamente.
- **Implementador = ejecutor.** Sigue `PLAN.md` sin rediseñar. Ante un paso
  ambiguo, erróneo o imposible, **para** y lo registra en `DECISIONS.md` en lugar
  de improvisar otro diseño.
- **Solo Opus reescribe `PLAN.md`.** El implementador propone cambios al spec vía
  `DECISIONS.md` (sección *Open questions for the spec author*); nunca edita el
  plan en silencio. Esta es la regla que evita que el harness derive.

## Cuándo hacer handoff

- Te estás quedando sin contexto/tokens en una tarea larga.
- Vas a delegar la ejecución a Codex u otro agente.
- Querés paralelizar varios slugs en paralelo.

## Gate de verificación

- Ningún paso se marca `- [x]` en `PROGRESS.md` ni se commitea sin correr los
  comandos de **Setup / run / test** de `CONTEXT.md` y ver que pasan.
- Reportá los fallos con el output real — nunca afirmes que un paso pasó sin
  verificarlo.
- No commitees un paso `🚧` (en progreso) o `⛔` (bloqueado).

## Git

- `/implement` hace **un commit por paso verificado** y **no pushea**.
- Si estás en `main`/`master`, primero creá una branch de tarea.
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
