# Plan 07 — Afinar `progress-sync.sh` (guard de pre-commit)

**Prioridad:** P2 · **Depende de:** — · **Hallazgo:** #5

## Context

`hooks/progress-sync.sh` bloquea un `git commit` que stagea código pero no
`docs/handoff/<slug>/PROGRESS.md`. Define **"código = todo path que no esté bajo
`docs/handoff/`"**.

## Problema

1. **Falsos positivos en commits solo-docs:** editar `README.md`, `CLAUDE.md` o
   `docs/hooks.md` (que no están bajo `docs/handoff/`) cuenta como "código" y
   exige tocar un PROGRESS, aunque el commit no tenga nada de implementación. El
   propio bookkeeping de este repo cae en esto.
2. **No liga PROGRESS al mismo slug del código:** un commit que toca código del
   slug A pero actualiza el PROGRESS del slug B pasa el guard, aunque sean cosas
   no relacionadas.

## Approach

Afinar la heurística sin perder simpleza:

1. **Excluir docs no-handoff conocidos** del set "código": tratar como docs los
   paths de documentación pura (`*.md` en la raíz, `docs/` fuera de `handoff/`,
   `docs/plans/`). Tunear los patrones `grep` del script (el propio `docs/hooks.md`
   ya invita a hacerlo).
2. **(Opcional, más estricto)** Resolver el slug por la rama actual y exigir que
   el PROGRESS staged sea **el del slug de la rama**, no cualquiera. Alinea con el
   Plan 04 (resolución por rama).
3. Documentar la nueva heurística en `docs/hooks.md`.

## Files

- **Editar:** `hooks/progress-sync.sh` (patrones de clasificación code vs docs).
- **Editar:** `docs/hooks.md` (documentar el refinamiento).

## Verification

1. Commit que toca solo `README.md` → **no** se bloquea.
2. Commit que toca código real sin PROGRESS → **sí** se bloquea (comportamiento
   actual preservado).
3. (Si se hace el paso 2) Commit en rama `slug-a` que stagea el PROGRESS de
   `slug-b` → se bloquea pidiendo el PROGRESS de `slug-a`.

## Guardrails

- Mantener dependency-light (python3 solo para parsear el JSON de stdin).
- No volverlo tan estricto que moleste en el flujo normal; el objetivo es reducir
  falsos positivos, no agregar fricción.
