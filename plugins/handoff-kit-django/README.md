# Handoff Kit — Django layer

An **optional** Django layer for [`claude-handoff-kit`](../../README.md). The
core kit is deliberately language-agnostic; this layer adds Django domain
knowledge and specialized code-review subagents **without** touching the core.
Install it only in Django repos.

It imports a small, curated subset of [Everything Claude Code (ECC)][ecc] —
**not** the whole 248-skill / 63-agent plugin. See [`ATTRIBUTION.md`](./ATTRIBUTION.md)
for the exact files, source commit, and MIT notice.

## What's inside

**Skills** (domain knowledge, imported verbatim from ECC):

| Skill | Covers |
|---|---|
| `django-patterns`     | ORM/QuerySets/managers, DRF, service layer, caching, signals, middleware, N+1 |
| `django-security`     | auth, CSRF, SQL injection, XSS, secure deploy settings |
| `django-tdd`          | `pytest-django`, `factory_boy`, mocking, coverage, testing DRF |
| `django-verification` | migrations → lint → tests+coverage → security scan, pre-PR readiness |

**Reviewer subagents** (imported verbatim from ECC, run in their own context):

| Agent | Model | Role |
|---|---|---|
| `python-reviewer`   | sonnet | PEP 8, type hints, Pythonic idioms, complexity |
| `security-reviewer` | sonnet | secrets, injection, SSRF, OWASP Top 10 |
| `database-reviewer` | sonnet | query optimization, schema/migrations, indexes |

**Command** (original to this kit):

- `/django-review [--staged | <ref>]` — routes the current diff to the right
  reviewer above, in a clean context window. Thin wiring, not a new orchestrator.

## How it saves tokens

This is the point of the layer — three independent mechanisms:

1. **Progressive disclosure.** A skill only loads its `name` + `description`
   until a task matches it. `django-patterns` is ~600 lines of guidance; that
   body enters context *only when activated*, never in the planner's prompt.
2. **Subagent isolation.** The reviewers run as subagents — their own context
   window. The diff plus the heavy review rubric never flow back into the
   implementer's session.
3. **Model routing.** The reviewers are pinned to **`model: sonnet`**. Mechanical
   review (lint, typing, injection scan) doesn't need Opus. Reserve Opus for
   `/plan`. Don't bump these to Opus.

Together with the core kit's `/dispatch` (INDEX-driven, worktree-isolated
parallel slugs), you get ECC's orchestration story **plus** Django depth, at a
fraction of ECC's footprint.

## Install

**As a plugin (Claude Code):** this layer is registered as a second plugin in
the repo's `.claude-plugin/marketplace.json`:

```
/plugin install handoff-kit-django
```

**Tool-agnostic (any agent):** copy the skills + agents into the target repo's
`.claude/` with the installer flag:

```sh
./install.sh --target /path/to/your-django-repo --with-django
```

This drops `skills/` and `agents/` under the target's `.claude/`. It's
idempotent — re-running skips files that already exist (use `--force` to
overwrite).

## Wiring into the cycle

Once installed in a Django repo, `/implement`'s step-9 **fresh-context review
gate** prefers these reviewers over a generic subagent: a diff touching
migrations goes to `database-reviewer`, one touching auth/settings to
`security-reviewer`, the rest to `python-reviewer`. Run `/django-review` to do
this on demand outside `/implement`.

[ecc]: https://github.com/affaan-m/ECC
