# Plans — backlog de mejoras del kit

Cada archivo es un plan independiente y ejecutable para una mejora o arreglo
encontrado en la evaluación del workflow (2026-05-30). Implementalos de a uno;
respetá las dependencias indicadas en cada plan.

> Estos son **planes de mejora del kit**, no handoffs activos. Si querés
> ejecutar uno con el propio flujo del kit, pasalo por `/plan` (opcionalmente
> `/plan <slug> <ruta-al-plan>` para ingerir el draft) y convertilo en un slug
> bajo `docs/handoff/<slug>/`.

## Orden sugerido

Foundational primero (desbloquean al resto), luego features, luego fixes menores.

| Prioridad | Plan | Qué resuelve | Depende de |
|---|---|---|---|
| P0 | [05-structured-index.md](05-structured-index.md) | INDEX parseable con `status` + `depends-on` | — |
| P0 | [03-autogenerate-verify-file.md](03-autogenerate-verify-file.md) | `/handoff` genera `.verify` desde el bloque Verification | — |
| P1 | [01-plan-command.md](01-plan-command.md) | Comando `/plan` (rama + planning + auto-crítica) | — |
| P1 | [04-slug-aware-stop-hook.md](04-slug-aware-stop-hook.md) | Stop-hook slug-aware (desbloquea slugs paralelos) | 03 |
| P1 | [06-commit-attribution.md](06-commit-attribution.md) | Atribución de commit parametrizada por implementador | — |
| P2 | [02-dispatch-parallel-agents.md](02-dispatch-parallel-agents.md) | `/dispatch`: fan-out de subagentes en worktrees por oleadas | 05, 04 |
| P2 | [07-progress-sync-refinement.md](07-progress-sync-refinement.md) | Afinar el guard de pre-commit (`progress-sync.sh`) | — |
| P2 | [11-early-branch-creation.md](11-early-branch-creation.md) | Crear la rama de tarea al arranque, no en `/implement` | 01 (parcial) |
| P3 | [08-tool-agnostic-plan-source.md](08-tool-agnostic-plan-source.md) | Desacoplar el source-plan de `~/.claude/plans/` | — |
| P3 | [09-handoff-lifecycle-archival.md](09-handoff-lifecycle-archival.md) | Ciclo de archivado de slugs terminados | — |
| P3 | [10-fresh-context-review-hardening.md](10-fresh-context-review-hardening.md) | Endurecer la garantía de "fresh context" del review gate | — |

## Aciertos del kit (no tocar — preservar al modificar)

- Contrato en disco (no resumen en memoria) — la tesis central.
- Modelo de 4 archivos (CONTEXT/PLAN/PROGRESS/DECISIONS).
- Separación de roles estricta: **solo Opus reescribe PLAN**.
- Banner de provenance con SHA.
- Bloque **Verification** ejecutable y obligatorio.
- Core tool-agnostic + hooks Claude-only opt-in.
- Un commit atómico por paso verificado.
- Back-channel como loop (DECISIONS → Opus → PLAN).

Cualquier cambio debe mantener estas propiedades. En particular: **no metas
maquinaria Claude-only en el core** y **no rompas la portabilidad a Codex**.
