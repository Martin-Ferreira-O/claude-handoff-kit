> Handoff doc for task `atomic-tasks-and-routing`. Author: Claude Opus 4.8. Updated: 2026-06-14 16:35.
> IMPLEMENTING AGENT: read CONTEXT.md → PLAN.md → PROGRESS.md → DECISIONS.md before starting.
> Update PROGRESS.md after every meaningful change, and record any deviation from PLAN.md in DECISIONS.md.
> Spec written by Claude Opus 4.8 against commit `1ec8eb7` on branch `atomic-tasks-and-routing`; source plan: `~/.claude/plans/act-a-como-arquitecto-senior-harmonic-wall.md`. If HEAD has moved far past this, reconcile before trusting the spec.

# DECISIONS — atomic-tasks-and-routing

## Decisiones tomadas
- **Unidad atómica = slug**, no subagente-por-paso. Los pasos de un slug suelen depender entre
  sí; un subagente fresco por paso recarga contexto creciente → más tokens, no menos. (Decisión
  del usuario, confirmada en plan mode.)
- **Routing Opus-heavy** (elección del usuario): 1-3 Sonnet · 4-7 Opus 4.8 medium · 8-10 Opus
  4.8 max. La frontera puede moverse a 5-6 si el costo molesta, sin tocar la mecánica.
- **Este meta-task se materializa como UN slug acoplado**, no como 5 slugs paralelos, aplicando
  la propia regla de partición del diseño (acoplado por el contrato compartido + cabe en una
  ventana). Los 5 TASK cards van como pasos ordenados — dogfoodean el formato sin front-loadear
  5 paquetes.
- **`--delegate` es opt-in**; el modo por defecto de `/implement` queda intacto. `Agent` se suma
  a `allowed-tools` pero es Claude-only y solo se usa en `--delegate` (igual que `/dispatch`).
- **`effort` se transmite por prompt**, no es un parámetro del harness. El routing de **modelo**
  sí es exacto (`Agent` acepta `model`).
- **Esquema del INDEX intacto.** El modelo/effort vive en el Task card del PLAN, parseable con
  `grep`, no en columnas nuevas — para no romper consumidores `awk` existentes.
- **Rama desde `1ec8eb7`** (no desde `main`): `plan-absorbs-handoff` no está mergeado y trae los
  archivos de comando actuales que este spec referencia. Si se mergea a `main` antes que este
  slug, rebasar es trivial.

## Notas del implementador (no bloquean)
- **TASK-01 — label canónico del card = `Modelo recomendado:` / `Effort recomendado:`**
  (siguiendo §6 del source plan, que el PLAN marca normativo). Observación: los Task
  cards de **este** PLAN.md abrevian a `**Modelo:**` / `**Effort:**`, que **no** matchean
  `grep 'Modelo recomendado'`. No lo edito (solo Opus reescribe PLAN.md). Lo resuelvo del
  lado del parser: en TASK-03 `/dispatch` matchea `Modelo recomendado` **o** un `Modelo`
  pelado, con default Sonnet — así el dogfooding rutea igual. Si Opus prefiere
  estandarizar las etiquetas del PLAN, es un cambio de prosa trivial.
- **Baseline commit del paquete.** El paquete de handoff estaba sin commitear (lo
  materializó `/plan` pero quedó untracked). Lo committeé como baseline (`CONTEXT`/`PLAN`/
  `DECISIONS`) antes de TASK-01 para que los commits de paso referencien un PLAN en
  historia. Sin impacto en el spec.

## Open questions for the spec author
*(Resueltas por Opus únicamente; el implementador no las adivina ni edita el PLAN.)*

**Ninguna pendiente** — las dos abiertas se resolvieron en `/clarify` (2026-06-14 16:35) y se
foldearon al PLAN (§Clarifications):
- **Reviewer del gate bajo routing → RESUELTO:** se **rutea por dificultad** (misma tabla que el
  implementador), no Sonnet fijo. Un slug 8-10 lo revisa Opus max. (Afecta TASK-04.)
- **Ubicación de la rúbrica → RESUELTO:** `docs/routing.md` nuevo (rúbrica de 5 ejes + tabla) +
  resumen corto con link en `AGENTS.md`. (Confirma TASK-01.)
