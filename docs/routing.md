# Routing de modelo y effort por dificultad

> **Contrato compartido.** Esta rúbrica y esta tabla son la fuente de verdad que
> `/plan` usa para puntuar cada tarea atómica (Task card) y que `/dispatch` e
> `/implement --delegate` usan para rutear el modelo del subagente. El schema del
> Task card que las consume vive en `AGENTS.md`; este archivo tiene la rúbrica
> completa y la mecánica de routing.

## Rúbrica de dificultad (1-10)

Puntuá **5 ejes** de 0 a 2 y sumá (rango 0-10):

| Eje | 0 | 1 | 2 |
|---|---|---|---|
| **Blast radius** | 1 archivo | pocos archivos / 1 módulo | cross-cutting, varios módulos |
| **Acoplamiento** | aislado | usa 1-2 piezas existentes | muchas deps / efectos colaterales |
| **Novedad/ambigüedad** | patrón claro a copiar | algo de criterio | requiere decisión de diseño |
| **Verificación** | comando determinista | end-to-end simple | edge cases / difícil de checkear |
| **Riesgo/reversibilidad** | trivial de revertir | reversible con cuidado | difícil de revertir / alto impacto |

### Bandas
- **1-3 — mecánico:** un archivo o bien acotado, patrón claro, verificación
  determinista, bajo riesgo (renames, agregar un campo, docs, copiar un patrón).
- **4-7 — razonamiento / refactor:** varios archivos, algo de criterio, refactor de
  comportamiento existente, riesgo moderado, verificación end-to-end.
- **8-10 — crítico / arquitectónico:** transversal, alto acoplamiento / muchas deps,
  enfoque ambiguo con decisiones de arquitectura, alto riesgo o difícil de revertir.

`/plan` anota el desglose por ejes solo si ayuda; lo normal es el número final + el
**Motivo** en una frase.

## Tabla de routing

| Dificultad | Modelo | Effort | Tipo de tarea |
|---|---|---|---|
| **1-3** | Sonnet 4.6 | low / medium | simple, mecánica, bajo riesgo |
| **4-7** | Opus 4.8 | medium | razonamiento, refactor, decisiones de diseño |
| **8-10** | Opus 4.8 | max | crítica, compleja, alto riesgo o muchas deps |

El valor de la columna **Modelo** se copia al campo **Modelo recomendado** del Task
card; el de la columna **Effort**, al campo **Effort recomendado**.

### Cómo lo consume cada comando
- **`/plan`** puntúa cada Task card con la rúbrica y deriva `Modelo recomendado` /
  `Effort recomendado` de esta tabla.
- **`/dispatch`** traduce el `Modelo recomendado` del card al parámetro `model` del
  `Agent` (`sonnet` / `opus`), reemplazando cualquier modelo hardcodeado. **Default
  `sonnet`** si un slug viejo no tiene card legible.
- **`/implement --delegate`** rutea con la misma tabla tanto el subagente
  implementador como el **reviewer del gate de review**: un slug 8-10 lo revisa Opus
  4.8 max; uno 1-3, Sonnet.

### Effort: recomendación, no dial
El **modelo** se rutea exacto (`Agent` acepta `model`). El **effort** no es un
parámetro del harness: se transmite como **guía en el prompt** del subagente
("razonamiento máximo / exhaustivo" para `max`; "directo, sin sobre-análisis" para
`low`) y queda registrado en el Task card.

### Override
El routing es un **default informado, no una jaula**: el usuario puede forzar el
modelo o la concurrencia (`/dispatch --max N`). La frontera Opus/Sonnet puede moverse
a 5-6 si el costo molesta, sin tocar la mecánica.
