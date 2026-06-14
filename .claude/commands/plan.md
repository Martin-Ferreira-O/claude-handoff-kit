---
description: Entrada única del ciclo — crea la rama de tarea, planifica, auto-critica y materializa el paquete de handoff (los 4 archivos + .verify + fila en INDEX)
argument-hint: <task-description> [plan-path]
allowed-tools: Read, Write, Edit, Bash(git status:*), Bash(git log:*), Bash(git diff:*), Bash(git checkout:*), Bash(git branch:*), Bash(ls:*), Bash(date:*), AskUserQuestion
---

# /plan — autor del spec, entrada única del ciclo

Sos **Opus, autor del spec**. `/plan` es la entrada formal y única al ciclo
`/plan → /clarify → /resume → /implement → /code-review`. Tu trabajo es
**planificar y empaquetar**, no implementar: producís un draft de plan
disciplinado, creás la rama de tarea para no trabajar en `main`, y **materializás
el paquete de handoff** en `docs/handoff/<slug>/` en una sola pasada. La
implementación es de otro agente.

> **Por qué `/plan` no es plan mode nativo:** el plan mode de Claude Code es
> read-only — no puede crear una rama ni escribir el paquete. `/plan` corre
> **fuera** de plan mode para poder ramificar y escribir los archivos. No duplica
> la entrevista de `/clarify`: si hay ambigüedad real, derivá a `/clarify`.

> **`/plan` absorbió a `/handoff`.** Antes el ciclo separaba planificar (`/plan`)
> de empaquetar (`/handoff`); ese segundo comando re-derivaba contexto y gastaba
> tokens. Ahora `/plan` hace ambas cosas en una pasada. El caso "otro agente trae
> su propio plan" se cubre pasando la ruta del draft como segundo argumento
> (ver paso 1): `/plan <slug> <plan-path>` ingiere ese draft en vez de empezar
> de cero.

Tarea a planificar (y, opcionalmente, ruta a un draft existente): **$ARGUMENTS**

## Pasos

1. **Orientar y juntar el estado real.** Corré `git status`, `git log --oneline -10`
   y `git diff --stat`. Leé `CLAUDE.md` y `AGENTS.md` para las convenciones del repo
   (estructura de handoff, banner, reglas de roles). Corré `date "+%Y-%m-%d %H:%M"`
   para timestamps reales. No asumas: re-derivá del estado real.
   - **Source plan (opcional).** Si ya existe un draft de plan acordado, ingerilo en
     vez de empezar de cero. Resolvé en orden: (a) una ruta pasada como argumento,
     (b) `~/.claude/plans/<slug>.md` (lo que escribe el plan mode nativo de Claude
     Code), (c) un draft en el repo como `docs/plans/<slug>.md`; usá el primero que
     exista y anotá cuál. Si no hay ninguno, el source plan es el `PLAN.md` que vas
     a autorar acá (autoría in situ).

2. **Crear la rama de tarea.** Derivá un `<slug>` en kebab-case de la tarea.
   - Si estás en `main`/`master`, creá y cambiá a la rama: `git checkout -b <slug>`.
   - Si la rama ya existe, **reusala** (`git checkout <slug>`) — no la dupliques.
   - Si ya estás en una rama de tarea no-`main`, quedate en ella.
   Registrá la rama elegida en el banner del paquete.

3. **Resolver el slug del paquete.** `ls docs/handoff/` — si ya existe una carpeta
   que claramente corresponde a esta tarea, **reusala y actualizá** en vez de crear
   un duplicado. Un handoff por slug — se actualiza, no se duplica.

4. **Escribir los cuatro archivos** en `docs/handoff/<slug>/` (plantillas abajo).
   Cada uno arranca con el banner de cabecera. Llenalos con contenido real — nunca
   dejes una sección como placeholder vacío; si algo se desconoce, decilo explícito.
   El `PLAN.md` lleva:
   - **Goal** — qué se logra, en una o dos frases.
   - **Non-goals / scope** — qué queda explícitamente afuera.
   - **Ordered steps** — pasos en orden, cada uno **committeable por sí solo**.
   - **Verification** — un bloque **ejecutable**: el/los comando(s) exactos más la
     **señal observable de pass**. Nada de "verificar que anda": comando + qué se
     ve cuando pasa. Cerrá con un chequeo end-to-end que pruebe la feature, no solo
     que pasan los units.

5. **Auto-crítica del plan** (la parte "mejorar planes"). Pasá el `PLAN.md` por este
   checklist y **aplicá las correcciones in situ** antes de cerrar:
   - ¿El bloque **Verification** es realmente ejecutable y observable?
   - ¿Hay **non-goals** explícitos que acoten el alcance?
   - ¿El slug entra en **una sola ventana de contexto** del implementador? Si no,
     proponé partirlo en **slugs paralelos** (el kit ya soporta slugs en paralelo)
     en vez de un slug gigante.
   - ¿Cada paso es **committeable solo** (código + actualizaciones de estado juntos)?
   Reportá al usuario el resultado del checklist con las correcciones aplicadas.

6. **Derivar `.verify` del bloque Verification** (alimenta el Stop hook opcional —
   ver `docs/hooks.md`). `.verify` es una *proyección* del PLAN; el PLAN sigue siendo
   la única fuente de verdad.
   - Si Verification es **un solo comando runnable**, escribí exactamente ese comando
     en `docs/handoff/<slug>/.verify` (una línea, solo el comando — sin prosa ni
     anotación de pass-signal).
   - Si son **varios comandos** (o no se expresa como uno), **no inventes un formato
     multi-comando**: dejá `.verify` sin crear y anotá en el reporte que el Stop gate
     queda inactivo hasta que el autor envuelva los comandos en un script y apunte
     `.verify` ahí (consistente con `docs/hooks.md`).
   - `.verify` es versionado (auditable) — queda junto a los cuatro archivos.

7. **Sembrar el registro** `docs/handoff/INDEX.md` — una **fila de tabla por slug**
   bajo la tabla `## Handoffs`: `| <slug> | <status> | <depends-on> | <fecha> | <nota> |`.
   - `status` ∈ {`todo`, `in-progress`, `blocked`, `done`} — un handoff fresco es
     normalmente `todo`.
   - `depends-on` = slugs separados por coma que deben estar `done` antes, o `—`.
   - `fecha` = hoy (`%Y-%m-%d`); `nota` = estado corto legible.
   Creá el archivo con el header de schema si falta (ver el INDEX existente para el
   formato). **Actualizá la fila existente** para este slug en vez de duplicarla.

8. **Pasar el baton.** Imprimí la ruta del paquete y el siguiente paso:
   - `/clarify <slug>` si todavía hay ambigüedad real que entrevistar, o
   - `/implement <slug>` directo si el plan ya está cerrado (o `/resume <slug>` para
     que una sesión fresca reconstruya contexto primero).

## Plantillas de los archivos

Banner de cabecera arriba de los cuatro archivos (sustituí valores reales):

```
> Handoff doc for task `<slug>`. Author: <tu modelo, p.ej. Claude Opus 4.8>. Updated: <YYYY-MM-DD HH:MM>.
> IMPLEMENTING AGENT: read CONTEXT.md → PLAN.md → PROGRESS.md → DECISIONS.md before starting.
> Update PROGRESS.md after every meaningful change, and record any deviation from PLAN.md in DECISIONS.md.
> Spec written by <planner model> against commit `<sha>` on branch `<branch>`; source plan: `<ruta-resuelta o "authored in place by /plan">`. If HEAD has moved far past this, reconcile before trusting the spec.
```

La 4ta línea es **procedencia/frescura**: fija el modelo planner, el commit exacto
contra el que se escribió el spec y la ruta del source plan (o "authored in place"
si lo autoraste acá mismo). Un resumen recordado refleja un único momento; hacer ese
momento explícito deja que el implementador (y `/resume`) detecten drift "spec
escrito hace N commits" en vez de confiar en un mapa viejo.

### CONTEXT.md — orientación
- **Task**: un párrafo de qué + por qué.
- **Project area**: qué apps/módulos/dirs toca.
- **Read first**: el puñado de archivos (`path:line`) que el implementador debe abrir
  antes de codear. Agregá la instrucción permanente: *abrí estos archivos y confirmá
  que todavía coinciden con este spec antes de confiar en cualquier resumen de abajo*
  — re-derivar del código gana a recordar de un handoff (quizá viejo).
- **Setup / run / test**: los comandos exactos, usando `.venv/bin/python ...` si la
  regla del repo lo pide (p.ej. `.venv/bin/python manage.py test <app>`).
- **Conventions that matter here**: reglas relevantes de CLAUDE.md/AGENTS.md (service
  layer, UUID PKs, texto en español al usuario, enteros CLP, etc.).

### PLAN.md — el spec (autor → implementador)
- **Goal** y **non-goals / scope**.
- **Source plan**: la ruta resuelta en el paso 1 (puede ser `~/.claude/plans/`, un
  draft del repo, una ruta pasada, o "authored in place by /plan").
- **Ordered steps**, cada uno concreto como para ejecutar.
- **Verification** (obligatorio, no prosa): el/los comando(s) copy-pasteables que el
  implementador corre para probar que el trabajo está hecho, más la **señal
  observable de pass** de cada uno (p.ej. `` `.venv/bin/python manage.py test billing` → `OK`, 0
  failures ``). Cerrá con un chequeo end-to-end que pruebe que la feature anda, no
  solo que pasan los units. Este bloque es load-bearing — `/implement` verifica
  contra él y el Stop hook opcional (ver `docs/hooks.md`) se basa en él. Si un paso
  genuinamente no se puede verificar por comando, decilo explícito y dá el chequeo
  manual.
- Tratalo como read-mostly; el implementador no debe divergir en silencio.

### PROGRESS.md — estado vivo (lo actualiza el implementador)
- **Checklist** espejando los pasos del PLAN: `- [ ]` todo, `- [x]` done, `🚧` en
  progreso, `⛔` bloqueado.
- **Work log** (cronología inversa): `YYYY-MM-DD HH:MM — <agente> — qué cambió`.
- Sembralo con el estado actual (qué ya está hecho vs. pendiente ahora mismo).

### DECISIONS.md — decisiones + preguntas abiertas
- **Decisiones tomadas** con breve racional.
- **Open questions for the spec author** — bloqueos o ambigüedades que el
  implementador debe devolver a Opus antes de seguir.

## Guardrails

- **No implementás código** en `/plan` — sos autor de spec. Si te piden implementar,
  ese es trabajo de `/implement`.
- **No dupliques la entrevista de `/clarify`.** Ante ambigüedad, derivá a él.
- **Tool-agnostic:** `/plan` es una conveniencia, no un requisito del core. Lo
  load-bearing es el **contrato del paquete** (`AGENTS.md`), no este comando: otro
  agente (Codex, etc.) puede materializar el paquete a mano siguiendo ese contrato,
  o escribir un draft y pasarlo como segundo argumento (`/plan <slug> <plan-path>`)
  para que `/plan` lo empaquete. Nada en el contrato de handoff debe *exigir* `/plan`.
