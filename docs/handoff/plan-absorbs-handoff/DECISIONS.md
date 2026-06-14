> Handoff doc for task `plan-absorbs-handoff`. Author: Claude Opus 4.8. Updated: 2026-06-14 15:45.
> IMPLEMENTING AGENT: read CONTEXT.md → PLAN.md → PROGRESS.md → DECISIONS.md before starting.
> Update PROGRESS.md after every meaningful change, and record any deviation from PLAN.md in DECISIONS.md.
> Spec written by Claude Opus 4.8 against commit `e460331` on branch `plan-absorbs-handoff`; source plan: `~/.claude/plans/este-repositorio-es-una-declarative-babbage.md`. If HEAD has moved far past this, reconcile before trusting the spec.

# DECISIONS — plan-absorbs-handoff

## Decisiones tomadas
- **Eliminar `/handoff` por completo** (no como side-entry). El caso "otro agente
  trae su propio plan" lo cubre `/plan <slug> <path>` (ingiere el draft) o
  materializar el paquete a mano según `AGENTS.md`. Decidido con el usuario.
- **Autoría directa en el paquete**: `/plan` escribe `PLAN.md` sin draft intermedio.
  `~/.claude/plans/` sobrevive solo para el camino plan-mode-nativo.
- **`/clarify` refina el paquete in situ**: edita `docs/handoff/<slug>/PLAN.md`
  directo (Opus es dueño del PLAN), no un draft aparte.
- **Plantillas movidas a `plan.md`** (no centralizadas en `AGENTS.md`): un solo
  hogar, mínimo scope, sin duplicación (handoff.md era su hogar previo).
- **Paquete creado retroactivamente**: el cambio se implementó directo tras aprobar
  el plan, pero el hook `progress-sync.sh` del propio repo exige PROGRESS.md junto
  al "code". Se creó el paquete (lo que el nuevo `/plan` produciría) para commitear
  en regla — dogfooding.

## Open questions for the spec author
- **Stop-gate pre-implementación** (fuera de alcance): tras `/plan`, el árbol queda
  sucio con `.verify` presente, así que el Stop-gate opcional podría correr la
  Verification antes de implementar y fallar. No se agrava respecto de `/handoff`.
  Mitigación posible (no hecha): que `/plan` commitee el scaffold inicial → requiere
  `git add`/`git commit` en `allowed-tools`. ¿Vale la pena en un próximo slug?
