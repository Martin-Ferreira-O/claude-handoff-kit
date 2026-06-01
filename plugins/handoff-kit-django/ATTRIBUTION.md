# Attribution

The Django domain knowledge and the specialized reviewer subagents in this layer
are **imported verbatim** from **Everything Claude Code (ECC)** by Affaan Mustafa:

- Repository: https://github.com/affaan-m/ECC
- Imported from `main` at commit `64cd1ba248e77e377e76f70fc4e6434bfdddd511`
- Imported on: 2026-06-01

## Files imported verbatim from ECC

| This layer | ECC source |
|---|---|
| `skills/django-patterns/SKILL.md`     | `skills/django-patterns/SKILL.md` |
| `skills/django-security/SKILL.md`     | `skills/django-security/SKILL.md` |
| `skills/django-tdd/SKILL.md`          | `skills/django-tdd/SKILL.md` |
| `skills/django-verification/SKILL.md` | `skills/django-verification/SKILL.md` |
| `agents/python-reviewer.md`           | `agents/python-reviewer.md` |
| `agents/security-reviewer.md`         | `agents/security-reviewer.md` |
| `agents/database-reviewer.md`         | `agents/database-reviewer.md` |

`commands/django-review.md` is **original to this kit** — it is thin wiring that
routes the imported reviewers into this kit's existing `/implement` and
`/dispatch` flow. ECC's own `chief-of-staff` agent was intentionally **not**
imported: it is a personal communication-triage agent (email/Slack/calendar),
not a code orchestrator, and this kit's `/dispatch` already provides the
INDEX-driven, worktree-isolated orchestration ECC is known for.

## License

ECC is distributed under the MIT License. The MIT License requires that the
copyright notice below be retained in all copies or substantial portions of the
software. The imported files above are such portions.

```
MIT License

Copyright (c) 2026 Affaan Mustafa

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
