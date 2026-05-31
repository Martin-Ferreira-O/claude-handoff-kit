# Plan 05 — INDEX estructurado (status + depends-on)

**Prioridad:** P0 · **Depende de:** — · **Hallazgo:** #7

## Context

`docs/handoff/INDEX.md` es "una línea por handoff" en prosa libre. Sirve para un
humano, pero **no es parseable** para orquestación ni para detectar dependencias.

## Problema

- Sin estado por slug (`todo`/`in-progress`/`blocked`/`done`) machine-readable,
  ningún comando puede decidir qué slug está listo para ejecutarse.
- Sin `depends-on`, no se puede construir el DAG que necesita `/dispatch` (Plan 02).

## Approach

Adoptar un formato **legible por humano y parseable** en `INDEX.md`. Opción
recomendada: una tabla markdown con columnas fijas, o un bloque YAML front-matter
por slug. Recomendación: **tabla markdown** (sigue siendo lindo de leer y es
parseable con un grep/awk simple).

```
| slug | status | depends-on | updated | nota |
|---|---|---|---|---|
| harden-handoff-kit | done | — | 2026-05-29 | 6/6 pasos |
| plan-command | todo | — | 2026-05-30 | Q1 |
| dispatch | todo | structured-index, slug-aware-hook | 2026-05-30 | Q2 |
```

- `status` ∈ {`todo`, `in-progress`, `blocked`, `done`}.
- `depends-on` = lista de slugs separados por coma, o `—`.
- Migrar la línea existente de `harden-handoff-kit` al nuevo formato.

Actualizar los comandos que escriben/leen INDEX:
- `/handoff` y `/implement`: escribir/actualizar la fila del slug (no duplicar).
- `/resume`: leer el status del slug desde la fila.

## Files

- **Editar:** `docs/handoff/INDEX.md` (migrar al formato tabla).
- **Editar:** `.claude/commands/handoff.md`, `implement.md`, `resume.md` — pasos
  de actualización/lectura del registry.
- **Editar:** `AGENTS.md` — documentar el esquema del INDEX como parte del contrato.

## Verification

1. Tras `/handoff nuevo-slug`, confirmar que aparece una fila válida con
   `status: todo`.
2. Tras `/implement nuevo-slug`, confirmar que la fila pasa a `in-progress`/`done`.
3. Confirmar que `awk -F'|'`/grep extrae status y depends-on sin ambigüedad
   (test de parseabilidad — base para Plan 02).

## Guardrails

- Mantener legibilidad humana (el INDEX se sigue leyendo a mano).
- Una fila por slug; **actualizar**, no duplicar (regla ya existente).
