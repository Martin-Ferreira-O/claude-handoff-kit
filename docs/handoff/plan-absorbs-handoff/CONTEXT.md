> Handoff doc for task `plan-absorbs-handoff`. Author: Claude Opus 4.8. Updated: 2026-06-14 15:45.
> IMPLEMENTING AGENT: read CONTEXT.md → PLAN.md → PROGRESS.md → DECISIONS.md before starting.
> Update PROGRESS.md after every meaningful change, and record any deviation from PLAN.md in DECISIONS.md.
> Spec written by Claude Opus 4.8 against commit `e460331` on branch `plan-absorbs-handoff`; source plan: `~/.claude/plans/este-repositorio-es-una-declarative-babbage.md`. If HEAD has moved far past this, reconcile before trusting the spec.

# CONTEXT — plan-absorbs-handoff

- **Task**: Eliminar el dos-pasos `/plan` → `/handoff`. El usuario sentía que el
  segundo comando re-derivaba contexto y desperdiciaba tokens. Ahora `/plan` hace
  todo en una pasada: ramifica, planifica, auto-critica y **materializa el paquete
  de handoff** (los 4 archivos + `.verify` + fila en `INDEX.md`). `/handoff` se
  elimina; `/clarify` refina el `PLAN.md` del paquete in situ.

- **Project area**: el propio kit — `.claude/commands/`, `.claude-plugin/`,
  `templates/`, y la doctrina en `CLAUDE.md` / `AGENTS.md` / `README.md` / `docs/`.

- **Read first** (abrí estos archivos y confirmá que todavía coinciden con este
  spec antes de confiar en cualquier resumen):
  - `.claude/commands/plan.md` — el comando reescrito (absorbió handoff).
  - `.claude/commands/clarify.md` — reposicionado al paquete.
  - `AGENTS.md:6`, `AGENTS.md:12` — contrato compartido (seeds-the-row, source plan).
  - `hooks/progress-sync.sh`, `hooks/verify-gate.sh` — qué cuenta como "code" y
    cuándo se dispara el Stop-gate (relevante para el slug-window).

- **Setup / run / test**: repo de markdown, sin suite de tests. La verificación es
  estructural (ver el bloque Verification de PLAN.md). Comando ancla:
  `grep -rn -e '/handoff ' -e '/handoff`' -e 'handoff\.md' --include='*.md' --include='*.json' . | grep -vE 'docs/handoff/|_archive|/handoff-init|handoff-kit-django'`

- **Conventions that matter here**: comandos en `.claude/commands/` con frontmatter
  (`description`, `argument-hint`, `allowed-tools` mínimo); un handoff por slug
  (actualizar, no duplicar); solo Opus reescribe `PLAN.md`; un commit atómico por
  paso verificado (código + PROGRESS juntos — el hook `progress-sync.sh` lo exige).
