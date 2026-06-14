> Handoff doc for task `plan-absorbs-handoff`. Author: Claude Opus 4.8. Updated: 2026-06-14 15:45.
> IMPLEMENTING AGENT: read CONTEXT.md → PLAN.md → PROGRESS.md → DECISIONS.md before starting.
> Update PROGRESS.md after every meaningful change, and record any deviation from PLAN.md in DECISIONS.md.
> Spec written by Claude Opus 4.8 against commit `e460331` on branch `plan-absorbs-handoff`; source plan: `~/.claude/plans/este-repositorio-es-una-declarative-babbage.md`. If HEAD has moved far past this, reconcile before trusting the spec.

# PLAN — plan-absorbs-handoff

## Goal
`/plan` se vuelve la entrada única del ciclo: ramifica, planifica, auto-critica y
**materializa el paquete de handoff** (CONTEXT/PLAN/PROGRESS/DECISIONS + `.verify` +
fila en `INDEX.md`) en una sola pasada, absorbiendo lo que hacía `/handoff`.

## Non-goals / scope
- No tocar `/resume`, `/implement`, `/dispatch`, `/archive` salvo refs al comando.
- No reescribir los registros históricos `docs/plans/01–11` (solo guía viva).
- No agregar commit del scaffold en `/plan` (se mantiene el comportamiento de
  `/handoff`: escribe sin commitear). Nota: el Stop-gate opcional podría dispararse
  pre-implementación si `.verify` existe sobre árbol sucio — no se agrava.
- No centralizar plantillas en `AGENTS.md`: se mueven a `plan.md` (un solo hogar).

## Source plan
`~/.claude/plans/este-repositorio-es-una-declarative-babbage.md` (plan mode de
Claude Code), aprobado por el usuario tras una entrevista `AskUserQuestion`.

## Ordered steps
1. Reescribir `plan.md`: pasos 1–8 (orientar+estado, rama, resolver slug, escribir
   4 archivos con banner+plantillas movidas de handoff.md, auto-crítica, derivar
   `.verify`, sembrar INDEX, pasar baton); `allowed-tools` += `Bash(date:*)`.
2. Eliminar `handoff.md` (`git rm`).
3. Reposicionar `clarify.md` para refinar el `PLAN.md` del paquete in situ.
4. Config: `plugin.json` (quitar handoff.md), `marketplace.json` (lista), e
   `handoff-init.md` ("first `/plan` seeds a row").
5. Doctrina: `CLAUDE.md` (ciclo + bullets + sección), `AGENTS.md` (líneas 6 y 12),
   `CLAUDE.copy.md`, `templates/AGENTS.handoff.md`.
6. `README.md`: ciclo, tabla de comandos (reescribir /plan, borrar /handoff), lista
   de comandos, sección "Using it".
7. `docs/`: `orchestration.md`, `hooks.md` (`.verify` lo genera `/plan`),
   `plans/README.md` (guía viva).

## Clarifications (resolved)
- **`/handoff`**: eliminar por completo (no quedó como side-entry).
- **Draft `~/.claude/plans/`**: `/plan` autora directo en el paquete; el draft sigue
  existiendo solo para el camino plan-mode-nativo, ingerible por `/plan <slug> <path>`.
- **`/clarify`**: refina el paquete in situ (después de `/plan`).

## Verification
Repo de markdown sin tests; verificación estructural:

```sh
# 1. Sin refs al comando /handoff (excluyendo notas intencionales y docs/plans).
grep -rn -e '/handoff ' -e '/handoff`' -e '/handoff <' -e '/handoff →' -e 'handoff\.md' \
  --include='*.md' --include='*.json' . \
  | grep -vE 'docs/handoff/|_archive|/handoff-init|handoff-kit-django'
#   → pass: solo CLAUDE.md/plan.md ("absorbió a /handoff") y docs/plans/* (histórico).

# 2. Comando eliminado.
test ! -f .claude/commands/handoff.md && echo OK

# 3. Diagrama viejo ausente de docs vivos.
grep -rn '/clarify → /handoff' --include='*.md' . | grep -v docs/plans   # → vacío

# 4. JSON válido.
python3 -m json.tool .claude-plugin/plugin.json >/dev/null && \
python3 -m json.tool .claude-plugin/marketplace.json >/dev/null && echo OK

# 5. plan.md declara las capacidades nuevas.
grep -q 'Bash(date' .claude/commands/plan.md && \
  grep -q 'docs/handoff/<slug>/' .claude/commands/plan.md && \
  grep -q '\.verify' .claude/commands/plan.md && echo OK
```

**End-to-end (manual):** en un repo de prueba, `/plan <tarea>` crea
`docs/handoff/<slug>/{CONTEXT,PLAN,PROGRESS,DECISIONS}.md` + `.verify` + fila en
`INDEX.md`, sin requerir `/handoff`.
