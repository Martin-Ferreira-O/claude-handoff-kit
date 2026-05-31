# CLAUDE.md merge guide para otros proyectos

Este archivo no es un `CLAUDE.md` completo para reemplazar el de otro proyecto.
Es una guia para mezclar el Harness Engineering de este repo en un proyecto que
ya tiene sus propias instrucciones.

La regla practica:

- Si tu proyecto personal ya tiene `CLAUDE.md`, conserva primero sus reglas de
  dominio, arquitectura, comandos, estilo y testing.
- Agrega de este archivo solo las secciones que mejoren el flujo con agentes.
- Si copiaste los slash commands de handoff (`/plan`, `/clarify`, `/handoff`,
  `/resume`, `/implement`, `/code-review`), agrega tambien la seccion "Handoff".
  (`/dispatch` y `/archive` son extras avanzados —paralelizacion y archivado—:
  copialos solo si los vas a usar, ver seccion 4.)
- No copies texto que describa a `claude-handoff-kit` como producto; eso solo
  pertenece a este repo.

## 1. Bloque recomendado para casi cualquier proyecto

Este bloque suele valer la pena incluso si no usas handoffs.

```md
## Trabajo con agentes

- Lee primero la documentacion local relevante antes de cambiar codigo:
  `README.md`, `AGENTS.md`, docs de arquitectura, guias de testing y archivos
  mencionados por la tarea.
- Re-deriva el estado actual desde el codigo y los tests; no confies solo en
  summaries, memoria de sesiones anteriores o comentarios que puedan estar
  desactualizados.
- Mantene los cambios acotados al pedido. No hagas refactors, cambios de estilo,
  upgrades de dependencias o reorganizaciones que no sean necesarios para cerrar
  la tarea.
- Si encontras cambios no hechos por vos, tratalos como trabajo del usuario:
  no los reviertas ni los mezcles innecesariamente con tu cambio.
- Antes de editar, entende el patron existente y seguilo salvo que haya una razon
  concreta para desviarte.

## Verificacion

- No marques una tarea como terminada sin ejecutar la verificacion relevante:
  tests, typecheck, lint, build o el comando especifico del proyecto.
- Reporta el comando real que corriste y el resultado observable. Si no pudiste
  correrlo, explica por que y que riesgo queda.
- No afirmes que algo "pasa" sin haberlo verificado en esta sesion.

## Git

- No uses comandos destructivos como `git reset --hard`, `git checkout -- <file>`
  o borrados amplios sin pedido explicito del usuario.
- Si el usuario pide commits, hacelos atomicos y con mensajes descriptivos.
- No pushees ni abras PRs salvo que el usuario lo pida.
- Si estas en `main` o `master` y el cambio no es trivial, crea una branch de
  tarea antes de implementar.

## Decisiones y bloqueos

- Si un requisito es ambiguo, imposible o contradice el codigo actual, detenete
  y deja clara la pregunta o el bloqueo antes de inventar una arquitectura nueva.
- Registra cualquier decision importante: que se decidio, por que, y que tradeoff
  implica.
- Si te desvias de una instruccion o plan existente, explicalo explicitamente
  antes de continuar.

## Documentacion de librerias y APIs

- Cuando la tarea dependa de una libreria, framework, SDK, API, CLI o servicio
  cloud, consulta documentacion actual antes de responder o implementar.
- Preferi fuentes oficiales o herramientas de docs del entorno. No asumas que la
  sintaxis o configuracion que recordas sigue vigente.
```

## 2. Bloque si copiaste los comandos de Harness Engineering

Agrega este bloque solo si tu proyecto personal va a usar handoffs en
`docs/handoff/<slug>/`.

```md
## Harness Engineering / Handoffs

Este proyecto puede coordinar un agente planificador y un implementador mediante
handoffs versionados en `docs/handoff/<slug>/`.

Cada handoff contiene:

- `CONTEXT.md`: orientacion, objetivo, archivos a leer primero, comandos de
  setup/run/test y convenciones relevantes.
- `PLAN.md`: el spec. Incluye goal, non-goals, pasos ordenados y un bloque
  runnable de `Verification`.
- `PROGRESS.md`: checklist que refleja los pasos del plan y un work log.
- `DECISIONS.md`: decisiones, desviaciones, bloqueos y preguntas abiertas.

`docs/handoff/INDEX.md` registra los slugs activos.

### Reglas del handoff

- Antes de empezar un handoff, lee en orden:
  `CONTEXT.md` -> `PLAN.md` -> `PROGRESS.md` -> `DECISIONS.md`.
- `PLAN.md` es la fuente de verdad. Implementa contra el plan y no lo cambies en
  silencio.
- Abri los archivos listados en `CONTEXT.md` y confirma que el codigo actual
  todavia coincide con el plan antes de confiar en el resumen.
- Actualiza `PROGRESS.md` despues de cada cambio significativo.
- Registra desviaciones, decisiones y bloqueos en `DECISIONS.md`.
- Si hay un autor del spec separado del implementador, solo el autor reescribe
  `PLAN.md`; el implementador propone cambios mediante `DECISIONS.md`.
- No marques `- [x]` en `PROGRESS.md` hasta que el comando de verificacion del
  paso haya pasado.

### Flujo recomendado

```text
planificar -> aclarar dudas -> escribir handoff -> resumir contexto ->
implementar -> verificar -> revisar contra el plan
```

Para cambios chicos de una frase, no uses handoff: implementa directo y verifica.
```

## 3. Bloque opcional si usas roles separados

Esto sirve si realmente queres separar un agente planificador de un agente
implementador. Si trabajas siempre con un solo agente, puede ser demasiado rigido.

```md
## Roles

- Planificador: decide arquitectura, define alcance y escribe `PLAN.md`.
- Implementador: ejecuta `PLAN.md` sin redisenar. Si un paso es ambiguo, erroneo
  o imposible, se detiene y lo registra en `DECISIONS.md`.
- Solo el planificador reescribe `PLAN.md`. El implementador propone cambios al
  spec mediante `DECISIONS.md`.
```

## 4. Que no copiaria a tu proyecto personal

No copiaria estas partes del `CLAUDE.md` de este repo salvo que tu proyecto sea
tambien una herramienta de Harness Engineering:

- La descripcion inicial de `claude-handoff-kit` como producto.
- Frases como "este repo es un kit de Harness Engineering".
- La explicacion de que el repo "se auto-dogfoodea".
- Reglas sobre `.claude/commands/` frontmatter, `allowed-tools` y convenciones de
  comandos, salvo que estes editando esos comandos.
- La obligacion de "un commit por paso verificado" si tu proyecto personal no
  necesita ese nivel de auditoria.
- Referencias fijas a Opus/Codex si en tu proyecto queres que funcione con
  cualquier agente.
- Hooks como `hooks/progress-sync.sh` o `hooks/verify-gate.sh` si no instalaste
  esa capa de enforcement.

## 5. Recomendacion concreta para tu caso

Como ya tenes un `CLAUDE.md` en tu proyecto personal y copiaste los comandos, yo
haria esto:

1. Deja intacto el `CLAUDE.md` existente del proyecto.
2. Agrega el bloque "Trabajo con agentes" si no tenes reglas equivalentes.
3. Agrega el bloque "Harness Engineering / Handoffs" porque los comandos dependen
   de ese contrato mental.
4. Agrega "Roles" solo si vas a usar de verdad un planner separado del
   implementador.
5. No agregues las secciones especificas de este repo ni hooks hasta que los
   necesites.

El resultado ideal no es copiar todo: es que tu `CLAUDE.md` personal diga como
se trabaja en tu proyecto, y que el Harness sea solo una capa de coordinacion
cuando una tarea es grande.
