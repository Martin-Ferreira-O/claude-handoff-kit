# Plan 03 — `/handoff` genera `.verify` desde el bloque Verification

**Prioridad:** P0 · **Depende de:** — · **Hallazgo:** #2

## Context

El Stop-hook (`hooks/verify-gate.sh`) lee el comando de verificación de
`docs/handoff/<slug>/.verify`. Pero **ningún comando genera ese archivo**: hoy
hay que crearlo a mano (`docs/hooks.md` lo muestra con un `echo`). El PLAN tiene
su bloque **Verification**, así que existe una **fuente de verdad duplicada** que
puede divergir: el PLAN dice una cosa y `.verify` otra (o no existe).

## Problema

- El "gate determinista" depende de un paso manual no documentado en ningún comando.
- `.verify` y el bloque Verification del PLAN pueden quedar desincronizados.

## Approach

Hacer que `/handoff` (y `/implement` al actualizar) **derive `.verify` del bloque
Verification del PLAN** automáticamente:

1. En `.claude/commands/handoff.md`, agregar al paso de escritura: si el bloque
   Verification del PLAN es **un solo comando ejecutable**, escribirlo en
   `docs/handoff/<slug>/.verify`. Si son varios, **no inventar formato**: dejar
   `.verify` sin crear y anotar en el reporte que el gate Stop queda inactivo
   hasta que el autor envuelva los comandos en un script (consistente con la guía
   actual de `docs/hooks.md`).
2. Mantener `.verify` como **artefacto derivado**: el PLAN sigue siendo la fuente
   de verdad; `.verify` es una proyección de su bloque Verification.
3. Documentar en `docs/hooks.md` que `.verify` ahora lo genera `/handoff` (y que
   editar el PLAN Verification → regenerar `.verify`).

Alternativa considerada (no elegida ahora): que el hook parsee `PLAN.md`
directamente. Se descarta por fragilidad de parseo de markdown en bash; el
artefacto derivado explícito es más robusto y dependency-light.

## Files

- **Editar:** `.claude/commands/handoff.md` (paso de escritura de archivos).
- **Editar:** `.claude/commands/implement.md` (si edita Verification, regenerar `.verify`).
- **Editar:** `docs/hooks.md` (documentar la generación automática).
- **Considerar:** `.gitignore` para `.verify` o dejarlo versionado (decisión:
  versionarlo lo hace auditable; preferible versionar).

## Verification

1. Correr `/handoff test-slug` con un PLAN cuyo bloque Verification sea un único
   comando → confirmar que se crea `docs/handoff/test-slug/.verify` con ese comando.
2. Con un PLAN multi-comando → confirmar que `.verify` **no** se crea y que el
   reporte lo explica.
3. Con el Stop-hook activo, confirmar que usa el `.verify` generado (no uno manual).

## Guardrails

- No inventar un formato multi-comando en `.verify` (regla ya establecida en DECISIONS).
- `.verify` es derivado: nunca debe contradecir el bloque Verification del PLAN.
