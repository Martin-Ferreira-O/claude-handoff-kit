# Plan 09 — Ciclo de archivado de slugs terminados

**Prioridad:** P3 · **Depende de:** — · **Hallazgo:** #9

## Context

No hay ciclo de vida para los handoffs. Los slugs terminados quedan para siempre
en `docs/handoff/`, INDEX crece sin límite, y el heurístico `ls -t … | head -1`
(usado por `/resume`, `/implement` y el Stop-hook) se ensucia con cada slug viejo.

## Problema

- `docs/handoff/` se llena de slugs `done` que compiten con los activos en la
  heurística "más reciente".
- INDEX se vuelve largo y ruidoso.

## Approach

Definir un paso de archivado explícito (no automático, para no sorprender):

1. Convención: slugs `done` se mueven a `docs/handoff/_archive/<slug>/` (o se
   marcan con un campo en el INDEX y se excluyen de la heurística `ls -t`).
   Recomendación: **mover a `_archive/`** — la heurística `ls -t docs/handoff/*/`
   ya los excluye sin tocar el glob.
2. Comando o paso opcional (`/handoff --archive <slug>` o una nota en `/implement`
   al cerrar el último paso) que: mueve la carpeta, actualiza la fila de INDEX a
   `done (archived)`.
3. Documentar la convención en `AGENTS.md`.

## Files

- **Nuevo (opcional):** lógica de archivado en `.claude/commands/handoff.md`
  o un comando dedicado.
- **Editar:** `AGENTS.md` (convención de archivado y exclusión de `_archive/`).
- **Editar:** hooks que usan `ls -t docs/handoff/*/PROGRESS.md` para confirmar que
  `_archive/` queda fuera del glob (lo está, pero documentarlo).

## Verification

1. Archivar `harden-handoff-kit` → confirmar que pasa a `docs/handoff/_archive/`.
2. Confirmar que `ls -t docs/handoff/*/PROGRESS.md` ya no lo lista (no compite con
   slugs activos en `/resume`/`/implement`/Stop-hook).
3. Confirmar que INDEX refleja `done (archived)`.

## Guardrails

- Archivado **manual/explícito**, nunca borrar (el historial es valioso).
- No romper los globs existentes de la heurística "más reciente".
