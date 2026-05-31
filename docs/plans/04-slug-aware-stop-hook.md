# Plan 04 — Stop-hook slug-aware (desbloquea slugs paralelos)

**Prioridad:** P1 · **Depende de:** [03-autogenerate-verify-file.md](03-autogenerate-verify-file.md) · **Hallazgos:** #3, #4

## Context

`hooks/verify-gate.sh` define el slug activo como "el `PROGRESS.md` tocado más
recientemente" (`ls -t docs/handoff/*/PROGRESS.md | head -1`) y corre su `.verify`
en **cada** fin de turno.

## Problema

1. **Se rompe con slugs paralelos** — justo lo que el kit recomienda. Con varios
   slugs activos solo valida uno, y `mtime` es frágil (leer/escribir un archivo o
   una operación git reordena el `ls -t`).
2. **Corre en cada fin de turno**, aun cuando solo respondés una pregunta. Con una
   suite completa es lento y puede atrapar al usuario en un loop donde no puede
   cerrar turno por fallos ajenos al turno actual.

## Approach

Hacer el hook **slug-aware por rama** y **scoped a trabajo en curso**:

1. **Resolver el slug por la rama actual**, no por mtime: si la rama es
   `<slug>` o `*/<slug>`, usar ese slug. Esto alinea con el modelo de "una rama
   por slug" (ver Plan 11) y funciona con worktrees paralelos (cada worktree está
   en su propia rama → cada uno valida su propio slug).
2. **Fallback** al heurístico `ls -t` solo si la rama no matchea ningún slug.
3. **Gate solo si hubo cambios relevantes en el turno:** chequear que haya cambios
   sin commitear o staged bajo el área del slug antes de correr la verificación;
   si el working tree está limpio para ese slug, salir 0 (no bloquear turnos de
   solo-lectura/preguntas).
4. Mantener la salida de error actual (últimas 20 líneas del log) y `exit 2`.

## Files

- **Editar:** `hooks/verify-gate.sh`
- **Editar:** `docs/hooks.md` — documentar la resolución por rama y el scoping.
- **Sinergia:** depende del `.verify` generado por el Plan 03 y de la disciplina
  de "una rama por slug" del Plan 11.

## Verification

1. Dos worktrees en ramas `slug-a` y `slug-b`, cada uno con su `.verify`. Romper
   la verificación de `slug-a`. Confirmar que el turno en el worktree de `slug-b`
   **no** se bloquea por el fallo de `slug-a`.
2. En una rama de slug con working tree limpio (sin cambios del turno), confirmar
   que un turno de solo preguntas **no** dispara la verificación.
3. Con un cambio sin commitear que rompe la verificación, confirmar que el turno
   **sí** se bloquea con el output real.

## Guardrails

- Sigue siendo opt-in y Claude-only.
- No asumir formato multi-comando en `.verify` (mantener la regla del Plan 03).
