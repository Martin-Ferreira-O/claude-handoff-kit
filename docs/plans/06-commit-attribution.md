# Plan 06 — Atribución de commit parametrizada por implementador

**Prioridad:** P1 · **Depende de:** — · **Hallazgo:** #6

## Context

El template de mensaje de commit en `.claude/commands/implement.md` hardcodea:

```
Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>
```

## Problema

El implementador puede ser **Codex u otro modelo/sesión de Claude**, no Opus 4.8.
Firmar todos los commits como "Claude Opus 4.8" es una atribución incorrecta y
contradice el espíritu tool-agnostic del kit (Opus es el *autor del spec*, no el
implementador).

## Approach

Parametrizar la línea de atribución por el **agente que realmente implementa**:

1. En `implement.md`, cambiar el template para que el `Co-Authored-By` refleje al
   implementador real (el modelo/agente que corre `/implement`), no un valor fijo.
   Texto del comando: "firmá el commit con tu propia identidad de implementador;
   no copies un `Co-Authored-By` fijo".
2. Para Claude: usar el modelo de la sesión actual.
3. Para Codex u otros: su propia atribución (o ninguna co-autoría si no aplica).
4. Mantener el resto del template (`<slug>: <step summary>` / `PLAN step <n>. …`).

## Files

- **Editar:** `.claude/commands/implement.md` (bloque del template de commit).

## Verification

1. Correr `/implement` en una sesión Claude no-Opus → confirmar que el
   `Co-Authored-By` refleja ese modelo, no "Opus 4.8".
2. Revisar que el resto del formato de commit sigue intacto.

## Guardrails

- No romper el formato `<slug>: <summary>` que mantiene la historia legible.
- Coherente con el rol: el spec lo firmó Opus (autor); el código lo firma quien
  implementa.
