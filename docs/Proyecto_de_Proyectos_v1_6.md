---
title: Proyecto de Proyectos
permalink: /docs/proyecto/
nav_order: 2
---

# Proyecto de Proyectos — v1.6

> Plan estratégico para desarrollar proyectos en cartera como
> solopreneur, mediante orquestación de un enjambre de LLMs.
> Equipo bueno, no perfecto. Starter Kit completo desde el día 1.
>
> **Versión:** 1.6 · **Fecha:** 18 de mayo de 2026
> **Reemplaza:** v1.5 (incorpora aprendizajes del primer proyecto real
> en operación + el modelo de tests rojos pre-cargados validado).
> **Documentos hermanos:** `General_Starter_Kit_v1_2.md`,
> `DeepSeek_Auditor_Integration_v1_2.md`,
> `Prompt_Auditoria_Documentos_D_y_G.md`,
> `Prompt_Revision_de_Epica_con_O.md`

---

## 0. Cambios desde v1.5

Esta versión integra dos fuentes de aprendizaje:

- **El primer proyecto real del enjambre** en operación (Épica 4 en
  curso al cierre del documento), del que se rescatan patrones
  operacionales no documentados en v1.5.
- **El modelo de tests rojos pre-cargados** diseñado y validado por
  separado, que reemplaza al modelo de v1.5 basado en
  `tests/contract/<epic>/` + hash determinístico per-épica.

**Cambios principales:**

1. **Tests rojos pre-cargados** reemplazan al modelo de hashes
   per-épica. Los tests viven en el body del Issue (fuente de verdad);
   un workflow los materializa como primer commit de la rama
   (subject: `test(EXX-NNN): scaffold red tests`); un check verifica
   blob SHA per-archivo en cada PR; degradación graciosa por convención
   de commit cuando un Issue no lleva tests. Ver §3 Fase 4 y `General_Starter_Kit_v1_2.md §11.6`.
2. **G no audita PR.** Clarificación de roles: G actúa como ejecutor
   (J) y como co-auditor de documentación en chat con D. **No audita
   PR**, punto. La auditoría de PR es exclusiva de D.
3. **Label `requires-architect-review` → `requires-human-review`.**
   Alineamiento con la nomenclatura del proyecto real en operación.
   `architect-approved` (aplicada manualmente por el arquitecto sobre
   N1/N2) se mantiene.
4. **N2 como par `.md` + script bash.** El N2 de un bloque es ahora
   explícitamente un par de archivos: un documento markdown legible
   (fuente de verdad) acompañado por un script bash que sube los
   Issues a GitHub. D+G auditan ambos a ojo y verifican consistencia.
5. **Regla inviolable: el ejecutor nunca edita el Issue.** La etiqueta
   `jules` (o equivalente del ejecutor) **nunca se retira**. La única
   "edición" del Issue por la máquina es la aplicación inicial
   automática de la etiqueta tras éxito completo del workflow de
   preparación. Toda otra modificación del Issue la hace el arquitecto
   humano.
6. **JULES_PAT como "firma del jefe".** El PAT del arquitecto no es
   solo permisos elevados; es **marca de procedencia**: cuando un
   workflow opera con este PAT, el ejecutor reconoce que la acción
   viene del jefe y obedece (incluso a comentarios automáticos del
   workflow que incluyen `@jules`). El nombre `JULES_PAT` se mantiene
   por convención operacional.
7. **Revisor de épica: O obligatorio, D opcional.** O recibe `.zip`
   del repo y produce reporte profundo. D puede recibir un `.md`
   concatenado equivalente (un script del arquitecto recorre el repo
   y concatena los archivos de texto en un solo markdown). El
   arquitecto compara ambas auditorías cuando invoca a las dos. Sin
   apuros: una épica puede revisarse mientras J trabaja en otra.
8. **Patrones operacionales rescatados del proyecto real:**
   mensajes-instrucción al agente embebidos en errores de CI,
   auto-aplicación de `requires-human-review` por complejidad
   declarada, lista exhaustiva de `PROTECTED_PATTERNS` multi-stack,
   `skip_validators` como input del orquestador, concurrencia
   diferenciada entre orquestador y auto-merge, `sleep` antes de
   asignar siguiente tarea, helpers de CI con fallback inline,
   bootstrap y codegen como pasos previos del CI, fallback en cascada
   para detectar Issue cerrado, `project_manifest.json` y
   `branch_protections_rules.sh` como artefactos canónicos, scripts
   de creación de Issues por bloque, DoD como checkboxes editables,
   campos "Rutas afectadas" y "Comandos extra" en el formulario,
   `Issue link required` y CHANGELOG validation como gates de
   governance. Detalle completo en `General_Starter_Kit_v1_2.md §0`.
9. **Tests sobre las herramientas del kit como regla**, no
   recomendación. Toda herramienta del kit que decida el destino de
   un PR debe tener su propia suite de tests que corra en CI.
10. **"Te informo que serás auditado" como recurso operacional
    documentado.** Nota explícita en el v1.6 sobre cómo se opera con
    O en sesiones de diseño cuando se quiere mejorar la calidad del
    output: anteceder con esa frase activa cuidado adicional. Ver
    `General_Starter_Kit_v1_2.md §11.3`.

**Eliminaciones:**

- `tests/contract/<epic>/` como prescripción rígida de ubicación de
  tests.
- `docs/orchestrator/contract-hashes/` y archivos `epic-NNN.txt`.
- Cálculo de hash con `shasum -a 256` o script Python equivalente.
- Comentario del workflow `prepare-issue-branch.yml` al Issue tras
  preparación exitosa (redundante con el body imperativo del Issue).
- "Cierre" en lugar de "revisión" donde quedaba alguna referencia
  residual.

---

## 1. Propósito

El operador es un arquitecto con cuarenta años de experiencia en
desarrollo de software. Ese expertise valida la metodología: lo que
funciona manualmente —dividir en piezas pequeñas, escribir contratos
inmutables, auditar al cierre— se escala con tres familias de LLMs
apoyando.

El objetivo es operar varios proyectos delegando la mayor parte del
ciclo de vida al enjambre. La cartera distribuye la latencia humana:
si un proyecto está esperando una decisión, los demás avanzan. La
cola del humano se gestiona desde un panel consolidado, no abriendo
seis repos.

**Sin cronograma.** El sistema se opera al ritmo del arquitecto
humano. La unidad de progreso es la **épica** y el **Issue**, no el
mes ni el día. Esa decisión es deliberada: el arquitecto no rinde
cuentas a nadie y prefiere romper el paradigma del sprint board.

**Equipo bueno, no perfecto.** Esa es la consigna operativa. El
sistema no busca atrapar todos los errores; busca atraparlos
suficientemente rápido para que las sesiones del arquitecto rindan,
y que los errores que pasan sean detectables (no silenciosos) y
corregibles a bajo costo. Los LLMs se equivocarán. El humano también.
El sistema acomoda eso por construcción.

**Lo que el sistema sí promete**:

- Detectar errores graves antes de que contaminen `main`.
- Mantener al humano informado sin atraparlo en cada decisión.
- Acumular evidencia legible (no agregada en una BD) de qué funciona.
- Ser una herramienta sincera: el auditor aprueba lo razonable y
  comenta lo dudoso, sin bloquear por pedantería.

**Lo que el sistema no promete**:

- Ser infalible. La IA se equivoca; los humanos también.
- Ser perfecto desde el día 1. Se calibra operando.
- Eliminar al humano. Es juez de último recurso por diseño.
- Operar contra reloj. La cadencia es la del arquitecto.

Principios del `General_Starter_Kit_v1_2.md §3` (P1-P10) vigentes.

---

## 2. El enjambre: tres familias, roles distintos

| Rol | Modelo | Acceso | Modalidad |
|---|---|---|---|
| **Arquitecto (O)** | Claude Opus 4.7 | Claude Max 20x ($200/mes) | Manual, chat |
| **Co-auditor docs A (G)** | Gemini 3.1 Pro vía chat | Google AI Pro ($20/mes) | Manual, chat |
| **Co-auditor docs B + auditor PR (D)** | DeepSeek V4 Pro (chat) y V4 Flash (API) | API directa + chat | Mixto |
| **Ejecutor (J)** | Gemini 3.1 Pro (Jules) | Incluido en Google AI Pro | Automático, VM Google Cloud |
| **Revisor de épica (O obligatorio, D opcional)** | Opus 4.7 y DeepSeek V4 Pro | Chat manual | Bajo invocación del arquitecto |
| **QA humano (opcional, reservado)** | "Usuario bruto" | Post-merge manual | A definir cuando se incorpore |

**Cambios respecto a v1.5:**

- G **no audita PR** (clarificación). G es ejecutor (J) y co-auditor
  de docs en chat. D V4 Flash es el único auditor de PR vía API en
  `audit-pr.yml`.
- D puede actuar como revisor opcional de épica en chat, recibiendo
  un `.md` concatenado del repo (no `.zip`, que D V4 Pro no acepta).
- El comentario tabular incluye al revisor de épica como rol nombrado
  (antes implícito en la descripción de O).

Defensas mecánicas contra manipulación del ejecutor: **blob SHA
per-archivo del commit scaffold + diff contra rama base + CI contra
checkout limpio**. Detalle en `DeepSeek_Auditor_Integration_v1_2.md §9`.

**Riesgo residual aceptado (R1)**: Gemini ocupa dos roles distintos
(co-auditor de docs en chat + Jules ejecutor en VM), compartiendo
sesgos. Mitigación: revisión de épica con O cuando el arquitecto la
invoque, opción de revisión paralela con D, y telemetría que detecta
patrones de aprobación coordinada sospechosa cross-proyecto.

---

## 3. Flujo end-to-end

### Fase 1 — Conceptual (manual, con O)

Conversación con O en chat. Documentos: Inception, Visión, Glosario,
UI/UX (si aplica), Arquitectura, Stack, Modelo de datos, CI/CD,
Backlog N1.

El N1 declara:

- **Épicas** explícitas (sin tope de tamaño).
- **Grafo de dependencias** entre épicas (`depends-on: [epic-NN, ...]`
  o `depends-on: none`).
- **Épicas raíz** que se pueden trabajar en paralelo (si la cartera
  está activa con varios proyectos).

### Fase 2 — Planificación por bloque (manual, con O)

O genera el **N2 del bloque como par de archivos**:

- **`N2-epic-EE-bloque-NN.md`** (fuente de verdad). Describe el
  bloque en prosa: contexto, alcance, lista de Issues con criterios
  de aceptación, **tests rojos pre-cargados por Issue**, ADRs si
  aplica.
- **`N2-epic-EE-bloque-NN.sh`** (consecuencia). Script bash idempotente
  que sube los Issues a GitHub poblando el body de cada Issue con la
  sección `### Tests rojos pre-cargados` extraída del `.md`.

Ambos archivos se versionan en `docs/backlog/` o equivalente. Nada se
borra; el script queda como historia.

**Definición de bloque**: agrupación de Issues que O diseña en una
sola sesión coherente. **El tamaño del bloque lo decide O**, según su
análisis de capacidad por sesión para producir tests robustos sin
saturación. No hay tope numérico. En el análisis preliminar de cada
épica, O propone cómo dividirla en bloques.

**Recurso operacional honesto** (`General_Starter_Kit_v1_2.md §11.3`):
anteceder cada sesión de diseño con O con una frase tipo *"Vamos con
el Bloque N. Te informo que será auditado, así que haz tu mejor
esfuerzo"* mejora la calidad observable del output.

### Fase 3 — Auditoría dual de documentos (manual, en chat)

El arquitecto humano lleva el par N2 (`.md` + script) a sesión manual
en chat con D y G como co-auditores, usando
`Prompt_Auditoria_Documentos_D_y_G.md`.

Checklist estructurado (ver el prompt para detalle):

- ¿El `.md` es internamente coherente? (Cobertura del N1, criterios
  de aceptación, tests bien especificados.)
- ¿El script bash refleja fielmente lo decretado en el `.md`? (No
  introduce ni omite Issues, no edita textos del body más allá del
  formato.)
- ¿Las rutas y nombres del scaffold (rama, archivos de test) son
  consistentes entre `.md` y script?
- ¿Los tests pre-cargados de cada Issue son falsables, no
  tautológicos?
- ¿Los ADRs requeridos están presentes y bien formados?
- ¿Las dependencias entre Issues (referencias `E##-###`) son
  acíclicas?

**Mentalidad de los auditores**: razonable, no perfecto. Aprueban si
los documentos son defendibles. Bloquean solo en categorías graves.
Las dudas menores van como comentarios.

**Ciclos de iteración**: 2-3 rondas en chat, dependiendo de la
complejidad. No hay número fijo: cuando el arquitecto siente que el
par está defendible, lo aprueba.

**Aprobación final**: el arquitecto humano aplica la label
`architect-approved` al documento (o al PR si los docs vienen vía PR
posterior). Esta aprobación es el gate G1 — sin ella no se ejecuta el
script bash de creación de Issues.

**Función red-team**: integrada en la misma sesión D+G. La auditoría
adversarial de tests (¿son falsables? ¿hay tautologías?) es parte del
checklist arriba, no un paso separado.

### Fase 4 — Creación de Issues y preparación de ramas

El arquitecto ejecuta el script bash aprobado. Los Issues quedan
creados en GitHub con:

- Cuerpo estructurado con criterios de aceptación.
- Sección `### Tests rojos pre-cargados` con bloques fenced del tipo:

  ````
  ```dart:packages/core_kit/test/models/foo_test.dart
  ...
  ```
  ````

- Rama declarada explícitamente:
  `## 🌿 Rama asignada: feat/EE-NNN-slug-descriptivo`
- Referencias a Issues previos (`E##-###`) cuando hay dependencia
  explícita.
- Labels: `jules-task`, `status/ready`, `epic/eEE`, `type/*`,
  `component/*` según corresponda.

**Cuando el orquestador asigna el Issue** (o el arquitecto lo asigna
manualmente con `workflow_dispatch`), el workflow
`prepare-issue-branch.yml` se ejecuta:

1. Lee el body del Issue y los labels.
2. Determina el nombre de la rama (desde el body, o computado como
   fallback).
3. Parsea la sección `### Tests rojos pre-cargados`.
4. Crea la rama desde `main`.
5. Si hay tests, los escribe a disco y hace commit
   `test(EXX-NNN): scaffold red tests`.
6. Si no hay tests (Issue de docs, chore puro), hace commit vacío
   `chore(EXX-NNN): initialize branch for #N`.
7. Push de la rama.
8. **Aplica el label `jules` como paso final atómico.** Si algo en
   los pasos 1-7 falla, el label nunca se aplica y J no toma la tarea.

El workflow **no comenta el Issue** (el body ya tiene las
instrucciones imperativas). El audit trail vive en el log de Actions.

Detalle del modelo en `General_Starter_Kit_v1_2.md §11.6`.
Detalle del check de inmutabilidad en
`DeepSeek_Auditor_Integration_v1_2.md §9`.

### Fase 5 — Ejecución (J)

J detecta el Issue con label `jules`. Lee el body imperativo, hace
`git fetch && git checkout feat/EE-NNN-...`. La rama está roja: los
tests existen pero el código de producción no.

J implementa el código de producción que haga pasar los tests.
**No modifica el scaffold de tests.** Si necesita tests adicionales,
los agrega en archivos nuevos.

J ejecuta `bash tools/ci/light.sh` (o equivalente) durante el
desarrollo, y `bash tools/ci/full.sh` antes de abrir PR. **Abre PR
contra `main`** con título Conventional Commits y cuerpo que
incluye `Closes #N`.

**Reintentos**: máximo 3 corridas fallidas del script completo. Tras
la tercera, el orquestador aplica `requires-human-review` al PR,
`blocked` al Issue, y abre Issue de incidente.

**Apelación del ejecutor**: si J falla el mismo test pre-cargado 3
veces con el mismo error, aplica label `suspect-contract`. Esto
dispara revisión humana inmediata del test, no del código. Si el test
estaba mal especificado, el arquitecto sigue una de las dos vías de
modificación legítima descritas en
`DeepSeek_Auditor_Integration_v1_2.md §9.5`.

**Regla inviolable**: J nunca edita el Issue (excepto marcar
checkboxes del DoD). La etiqueta `jules` nunca se retira por J.

### Fase 6 — Validación en CI

Validadores en paralelo del orquestador:

- **CI funcional**: script completo (`full.sh`) contra checkout
  limpio. Incluye bootstrap + codegen + format + analyze + tests +
  cobertura + docs build.
- **Governance**: secret scan, dep review, título Conventional
  Commits, tamaño de PR, `Issue link required`, **check de
  inmutabilidad del scaffold** (`check_test_immutability.sh`),
  CHANGELOG validation.
- **Auditor LLM de PR**: D V4 Flash con cache de prefijos sobre
  system prompt + ADRs + AGENTS.md. Ver
  `DeepSeek_Auditor_Integration_v1_2.md`.

**Estructura del prompt del auditor de PR** (consigna operativa):

> "Audita este PR contra el Issue enlazado y los ADRs vigentes.
> Aprueba (`audit/pass`) si el cambio es razonable, ejecuta el
> contrato del Issue, y no introduce regresiones evidentes. Bloquea
> (`audit/fail`) solo si hay categorías graves: violación del scaffold
> de tests, contrato público roto, riesgo de seguridad, dependencia
> no autorizada, cambio fuera del scope del Issue. Las dudas menores
> (estilo, optimizaciones, alternativas) van como comentarios, no
> bloquean.
>
> Tu objetivo es velocidad con calidad defendible, no pureza
> académica."

Veredicto: `audit/pass` o `audit/fail`. El gate `all_green` exige
`audit/pass`.

**Telemetría como comentario estructurado**: al cerrar cada PR, el
orquestador publica un comentario fijado en formato:

```
[telemetry]
auditor: pr-auditor
model: deepseek-v4-flash
iteraciones: 4
tokens_executor: 12,400
prompt_tokens: 8,200
completion_tokens: 3,200
reasoning_tokens: 0
cache_hit_inferred: true
result: pass
duración_seg: 23
trigger: synchronize
falso_positivo: false
```

Buscable con `gh pr list --search "[telemetry]"`. **No hay BD que
mantener.**

### Fase 7 — Gates humanos

Label `requires-human-review` detiene auto-merge. Se aplica:

- Paths protegidos (workflows, manifiestos, migraciones, ADRs,
  archivos del scaffold).
- Superficie arquitectónica.
- `main` rota.
- `audit/fail` sin resolver.
- `suspect-contract` aplicada por J.
- Complejidad declarada como `large` en el formulario del Issue
  (auto-aplicada por el workflow `issue-form-labels.yml`).
- Manualmente por el arquitecto.

**Concurrencia per-repo**: el orquestador mantiene
`docs/orchestrator/state.json` con estado del repo. **Dentro del
mismo repo**, no se asigna Issue nuevo si:

- Hay PR pendiente del ejecutor.
- Hay PR con `audit/fail` no resuelto.
- Hay incidente abierto (`main-broken`).

**Selección del siguiente Issue (FIFO con filtros)**: el asignador
toma el Issue elegible más viejo, donde "elegible" significa:

- Tiene label `jules-task` (estructurado por el flujo).
- No tiene label `jules` (no asignado actualmente).
- No tiene labels de exclusión (`blocked`, `needs-design`,
  `needs-triage`, `incident`, `main-broken`).

Las labels de prioridad (`priority/p0..p3`) son **decorativas**. La
priorización real está encodificada en el orden de creación de los
Issues por el arquitecto.

**Tras seleccionar**: el orquestador llama a `prepare-issue-branch.yml`
con el número del Issue. El workflow prepara la rama y aplica el
label `jules` como paso final atómico.

**Entre repos** (across portfolio): paralelismo automático. Cada repo
tiene su propio orquestador y su propio `state.json`. J en proyecto A
puede estar trabajando mientras J en proyecto B también lo está.

### Fase 8 — Revisión de épica (opcional)

**Las épicas no se cierran.** La revisión es opcional y la decide el
arquitecto. Existen dos modos:

**Modo 1: cierre rápido por confianza** (default)

El arquitecto observa que los Issues de un bloque o de la épica están
completos, mira los PRs mergeados a `main`, y sigue con la siguiente
sesión de diseño. Sin auditoría adicional. La mayoría de las épicas
caben aquí.

**Modo 2: revisión profunda con O (y opcionalmente D)**

El arquitecto produce material para auditoría:

- Para O: un `.zip` del repositorio (sin `.git`, preferiblemente sin
  `node_modules/`, `build/`, etc.).
- Para D (opcional): un `.md` concatenado equivalente (un script del
  arquitecto recorre el repo y concatena los archivos de texto en un
  solo markdown bien identificado por ruta). D V4 Pro chat no acepta
  `.zip` pero sí acepta `.md` largos.

Ambos usan `Prompt_Revision_de_Epica_con_O.md` (el prompt está
escrito para O pero D puede usarlo con la entrada alternativa).
El arquitecto compara ambas auditorías si invoca a las dos. La
comparación es manual; el arquitecto la hace sin apuros mientras J
trabaja en otra épica (si no es bloqueante).

Indicado para:

- Primera épica del proyecto.
- Épicas que tocaron arquitectura significativa.
- Épicas con alta tasa de retrabajo observable.
- Cualquier épica donde el arquitecto sospeche que conviene mirar dos
  veces.

**Salida**: el reporte se commitea como
`docs/reviews/epic-NNN-review-YYYYMMDD.md`. Más de una revisión por
épica es esperable a lo largo del tiempo.

**Issues sugeridos por O/D**: el arquitecto decide cuáles crea, en
qué épica (la actual, una anterior, o una nueva), y cuándo.

**Pausar a J entre épicas**: si el arquitecto quiere revisar una
épica con cuidado mientras J avanza, deja a J trabajando en la
siguiente épica si las correcciones potenciales **no son
bloqueantes**. Si lo son, pausa a J desde el sitio web del proveedor
del ejecutor (no vía label de GitHub).

---

## 4. AGENTS.md: cómo se escribe

Es el prompt que todo agente lee. Su calidad determina la del
ejecutor. Estructura prescrita:

1. **Propósito del repositorio** en 2-3 frases.
2. **Stack y arquitectura** de alto nivel.
3. **WARNING crítico de validación local** con consecuencia explícita.
4. **Regla: el ejecutor nunca edita el Issue** (la etiqueta de
   ejecutor nunca se retira).
5. **Regla: si no se provee una rama de trabajo, se debe crear una
   rama desde `main`** siguiendo la convención del título.
6. **Definition of Done**: criterios verificables, no genéricos.
7. **Prohibiciones absolutas**: concretas, no aspiracionales.
8. **Arquitectura por capas** con referencia a sus enforcers
   mecánicos.
9. **Gestión de dependencias**: gestor único, lock obligatorio.
10. **Commits y branching**: Conventional Commits, todos los PRs a
    `main`, patrón de ramas de trabajo (`feat/`, `fix/`, `chore/`),
    regla `Closes #N`.
11. **Trabajo en rama precargada con scaffold de tests**: sección
    breve sobre el modelo de tests rojos pre-cargados y la
    inmutabilidad del scaffold.
12. **Checklist pre-PR**.
13. **Lectura obligatoria al empezar**: otros AGENTS.md,
    `docs/orchestrator/README.md`, el Issue asignado, los tests
    pre-cargados de la rama.

**Anti-patrones**: reglas genéricas sin enforcer, contexto teórico
innecesario, contradicciones entre AGENTS.md raíz y los de scope.

**Nota práctica**: el WARNING del template de Issue (formulario
`agent_task.yml`) es **el producto de la vida real** donde J es
olvidadizo, terco o desobediente. Repite reglas críticas que ya están
en AGENTS.md, porque la disciplina opera en cada Issue concreto, no
solo en la constitución. No es duplicación gratuita; es defensa en
profundidad.

---

## 5. Vulnerabilidades y mitigaciones

| Vulnerabilidad | Mitigación | Referencia |
|---|---|---|
| Build verde ilusorio | Tests pre-cargados como contrato + blob SHA per-archivo + CI limpio. | G4, `DS §9` |
| Fallos en cascada | Bloques que O decide según capacidad + revisión de épica opcional. | C7, G8 |
| Bucles infinitos de CI | Circuit breaker 10/2h + límite 3 reintentos por Issue. | G6 |
| Auditor capturado | Tres familias distintas, dual audit manual en chat D+G en G1, G no audita PR. | P1 |
| Drift docs vs código | Revisión de épica detecta drift acumulado. | G8 |
| Drift `.md` ↔ script bash | D+G auditan ambos en chat manual. Fuente de verdad es el `.md`. | §3 Fase 3 |
| Drift Issue body ↔ rama | El parser de `prepare-issue-branch.yml` materializa byte-a-byte el body. | `DS §9.1` |
| NIAH en revisión de épica | El `.zip` o `.md` se prepara con exclusiones razonables. | G8 |
| Auditor sobre-corregido | Prompt estructurado que separa hechos de críticas. | §3 Fase 3 |
| Manipulación del entorno del ejecutor | Blob SHA del scaffold + diff contra rama base + CI limpio. | §2 |
| Race conditions GHA | `state.json` versionado per-repo, `sleep` antes de asignar siguiente. | §3 Fase 7 |
| Tests adversariales débiles | Red-team integrado en sesión manual D+G + apelación del ejecutor (`suspect-contract`). | §3 Fases 3 y 5 |
| Livelock de revisión documental | 2-3 rondas según complejidad; tras eso, decisión del arquitecto. | §3 Fase 3 |
| Ejecutor bloqueado | Máximo 3 reintentos, escalación automática. | §3 Fase 5 |
| Ejecutor edita el Issue | Regla inviolable + workflow es el único que aplica label. | §3 Fase 4 |
| Indisponibilidad del arquitecto | El portafolio sigue para los proyectos no bloqueados. | §1 |
| Auditor pedante (falsos positivos) | Prompt explícito: aprobar razonable, no perfecto; dudas como comentarios. | §3 Fase 6 |
| Test mal especificado por O | Auditoría D+G previa + apelación de J + dos vías de modificación legítima. | `DS §9.5` |
| Workflow falso éxito | La etiqueta `jules` es la última operación atómica; si algo falla antes, no se aplica. | §3 Fase 4 |
| Tool del kit con bug | Toda herramienta del kit que decide destino de PR debe tener tests propios en CI. | `SK §8.7` |

---

## 6. Economía y telemetría

| Concepto | Costo (mensual indicativo) |
|---|---|
| Claude Max 20x | $200 |
| Google AI Pro (incluye Jules) | $20 |
| DeepSeek API | $5-15 estimado |
| **Total máquina** | **~$225-235** |

Los costos están en términos mensuales porque así los facturan los
proveedores, no porque el flujo se mida así. La unidad operacional
sigue siendo el Issue y la épica.

**Optimizaciones activadas**:

- Cache de prefijos de D (90-98% descuento sobre system prompts +
  ADRs base).
- D V4 Pro con 75% descuento hasta el 31 de mayo de 2026 (decisión
  pendiente sobre suscripción vs pay-per-token, basada en consumo
  medido durante calibración).
- V4 Flash para auditoría de PR (volumen alto, sin thinking).

**Telemetría operacional**: comentario estructurado en cada PR
(formato en §3 Fase 6). Buscable vía `gh`. Si en algún momento se
quiere análisis agregado cross-proyecto, un script parsea los
comentarios y produce CSV o markdown. **No hay base de datos que
mantener**.

**Revisión periódica** (cuando el arquitecto lo decida en su
rotación, sin cronograma): leer los comentarios `[telemetry]` de los
últimos PRs cerrados. Si algo se sale del rango habitual, se calibra
el prompt afectado.

---

## 7. Starter Kit

Especificación canónica: `General_Starter_Kit_v1_2.md`. Los kits
específicos por plataforma (Python, Dart con Flutter) se producen
después de validar el flujo en una segunda épica de un segundo
proyecto.

El kit completo se diseña **desde el día 1 del primer proyecto**.
La automatización de cada componente sigue su propio rolling
deployment (prototipo manual → workflows automatizados). Lo que sí
evoluciona en operación es la calibración de los prompts; lo que no
cambia es el conjunto de gates ni la estructura de workflows.

---

## 8. Gates de calidad

Los ocho del `General_Starter_Kit_v1_2.md §7` (G1-G8). Todos activos
desde el primer proyecto. Cambios en v1.6 respecto a v1.5:

- **G4 (inmutabilidad de scaffold)** cambió implementación: ahora
  blob SHA per-archivo verificado por
  `check_test_immutability.sh` en governance. Ver
  `DeepSeek_Auditor_Integration_v1_2.md §9`.
- **G7 (salud de `main`)**: el kit lo prescribe como obligatorio.
  Si el proyecto real lo tiene comentado, debe rehabilitarse.
- **G8 (revisión de épica)**: opcional, dos modos. Ahora explícito
  que D puede revisar también, en chat con `.md` concatenado.

Si un gate genera fricción excesiva (típicamente G1 por
discrepancias falsas de auditores), se calibra el prompt para
aprobar más lo razonable y comentar menos lo subjetivo; no se
desactiva el gate.

Cualquier bypass se documenta en ADR.

---

## 9. Operación en cartera

### 9.1 Distribución de atención

El sistema admite operación en cartera de varios proyectos. La
cadencia exacta depende del ritmo del arquitecto y del estado de los
proyectos; sin cronograma fijo.

- Cuando un proyecto está bloqueado (espera de decisión, incidente,
  revisión humana), el portafolio avanza con los demás.
- El humano rota entre proyectos según le convenga, no según
  calendario.
- Costo por Issue (máquina): <$3. Costo por Issue (tiempo humano):
  variable, distribuido en la rotación.

### 9.2 Panel de control: GitHub Project Kanban

Un único GitHub Project a nivel de organización consolida los repos
activos en una sola vista. Columnas:

- **"Jules trabajando"**: Issues con label `jules`. Se ignora; el
  ejecutor trabaja, el humano no interviene aquí.
- **"Revisión automática"**: PRs en CI o auditoría LLM. Se ignora;
  los workflows resuelven.
- **"Requiere tu intervención"**: PRs e Issues con label
  `requires-human-review`, `audit/fail` no resuelto,
  `suspect-contract`, o `blocked`. **Esta es la columna donde el
  humano pasa la mayor parte de su tiempo activo.**
- **"Revisión de épica pendiente"**: épicas donde el arquitecto ha
  decidido invocar el modo 2 de revisión (con O y opcionalmente D).

Cuando el humano se sienta a operar, abre el Kanban, no varios repos.
Lee el resumen que dejó el auditor en cada PR de la columna de
intervención, decide, comenta, sigue.

### 9.3 Calibración cross-proyecto

Los aprendizajes de un proyecto alimentan el kit base. Si en proyecto
A se descubre que el auditor tiene tasa alta de falsos positivos en
cierto tipo de PR, el ajuste del prompt se propaga al kit base, y los
proyectos B-F se benefician en la próxima sesión. La cartera es un
banco de pruebas distribuido.

---

## 10. Decisiones tomadas

Lista consolidada de las decisiones de la arquitectura. Para
contexto histórico, ver §0 de este documento y los `§0` de los
documentos hermanos.

- **Tres familias de LLMs**: Anthropic (O), Google (G + J), DeepSeek
  (D).
- **Roles asignados** según §2.
- **G no audita PR.** Punto. Solo D vía API.
- **Auditoría dual de documentación inicial**: manual en chat con
  D+G (incluye red-team de tests). No es workflow automatizado.
- **Auditoría de PRs**: D V4 Flash vía API en `audit-pr.yml`.
- **Revisión de épica**: opcional, dos modos. O obligatorio cuando
  se invoca modo 2; D opcional con `.md` concatenado.
- **Tests rojos pre-cargados** como modelo de inmutabilidad, con
  blob SHA per-archivo verificado por
  `check_test_immutability.sh`.
- **N2 como par `.md` + script bash**, ambos versionados, fuente de
  verdad es el `.md`.
- **Tamaño del bloque lo decide O** según capacidad por sesión.
- **Todos los PRs a `main`** con squash-merge. Sin ramas `epic/N`.
- **Asignador FIFO** con filtros mínimos (`jules-task` requerido,
  exclusiones). Labels de prioridad decorativas.
- **Estado de concurrencia per-repo en `state.json`**; paralelismo
  cross-repo automático.
- **Telemetría como comentario estructurado en PR**, no BD.
- **Panel de control Kanban a nivel de organización**.
- **Operación en cartera** como modo nominal cuando varios proyectos
  estén activos.
- **Sin cronograma**: la cadencia es la del arquitecto humano.
- **Starter Kit completo diseñado desde el día 1**, con rolling
  deployment de automatizaciones.
- **Mentalidad del auditor**: aprobar razonable, comentar dudas, no
  bloquear por pedantería.
- **Frontera Diseño/Ejecución explícita**: Diseño es chat manual,
  Ejecución es GHA automatizado.
- **Gate `architect-approved` manual** para documentación inicial.
- **Label `requires-human-review`** (no `requires-architect-review`)
  para bloqueo humano.
- **El ejecutor nunca edita el Issue.** La etiqueta del ejecutor
  nunca se retira.
- **JULES_PAT como firma del jefe**: marca de procedencia, no solo
  permisos elevados.
- **Tests sobre las herramientas del kit como regla**, no
  recomendación.
- **Rol opcional de QA humano** ("Usuario bruto") reservado para
  cuando se incorpore.
- **El starter_kit base es `General_Starter_Kit_v1_2.md`** y los kits
  específicos por plataforma se producen tras la primera épica
  exitosa de un segundo proyecto.

---

## 11. Acciones manuales del arquitecto

El v1.6 reconoce explícitamente las acciones que hoy son humanas, no
automatizables, y las documenta como parte legítima del flujo (no
como deuda). Algunas serán automatizables en el futuro (ej: API de
Jules para pausar al ejecutor); las que no lo sean permanecerán
manuales por diseño.

- **Producir N1 con O** en chat.
- **Producir N2 por bloque con O** (par `.md` + script bash), con
  tests pre-cargados en cada Issue.
- **Auditar el par N2 con D y G** en chat usando
  `Prompt_Auditoria_Documentos_D_y_G.md`.
- **Iterar 2-3 rondas** sobre el par hasta que esté defendible.
- **Aplicar `architect-approved`** a mano al par N2 aprobado.
- **Push manual** del par N2 (y ADRs) a `main`.
- **Ejecutar el script bash** de creación de Issues hijos del bloque.
- **(Caso raro) Asignar el Issue a J manualmente** mediante
  `workflow_dispatch` de `prepare-issue-branch.yml` cuando se quiere
  saltar el flujo FIFO automático.
- **Pausar a J** vía botón en el sitio web del proveedor (no vía
  label).
- **Crear el `.zip`** (para O) o el `.md` concatenado (para D) para
  revisión de épica.
- **Comparar las dos auditorías** (O y D) cuando se invoca a ambas.
- **Decidir qué Issues sugeridos** se crean, en qué épica.
- **Añadir Issues de corrección** a épicas anteriores cuando aplique
  (las épicas no se cierran).
- **Corregir scaffold mal especificado** vía una de las dos vías
  legítimas (`DS §9.5`): PR del arquitecto modificando el scaffold,
  o cerrar el Issue y crear uno nuevo.
- **Crear, ejecutar, fusionar Issues a mano** en casos raros (Issue
  legacy, decisión puntual del arquitecto). En estos casos el flujo
  automatizado no aplica; el arquitecto opera como ejecutor humano.

---

## 12. Próximos pasos

(Sin cronograma estricto; los pasos están en orden lógico de
prerequisitos, no calendarizados.)

1. **Migración del primer proyecto a v1.6.** El proyecto real (en
   Épica 4) opera con un subconjunto del kit. Migrar lo accionable:
   adoptar `requires-human-review` como nombre canónico, ajustar
   labels eliminadas, verificar que los workflows del paquete de
   tests pre-cargados están integrados, rehabilitar health-check de
   `main`, agregar tests al `tools/changelog.py` y al
   `check_test_immutability.sh`.
2. **Decisión DeepSeek pre-31-mayo**. Decidir suscripción V4 Pro con
   75% descuento vs pay-per-token, basado en consumo medido durante
   calibración.
3. **Primera revisión de épica con O**. Cuando el primer proyecto
   complete una épica significativa, ejercitar el modo 2 con O y
   opcionalmente D. Validar el formato del `.md` concatenado que
   produce el script del arquitecto para D.
4. **Kanban consolidado**. Si todavía no está, crear el GitHub
   Project a nivel de organización con las cuatro columnas del §9.2.
   Configurar reglas automáticas que muevan Issues y PRs entre
   columnas según labels.
5. **Workflow propio para auditor de PR**. Si el primer proyecto
   sigue usando `hustcer/deepseek-review`, reemplazar por workflow
   propio sin dependencia de tercero.
6. **Segundo proyecto al portafolio**. Cuando el arquitecto sienta
   que el primer proyecto está estable, añadir el segundo. Validar
   que la operación cross-proyecto funciona desde el Kanban.
7. **Más proyectos según aparezcan**. Sin cuota fija. Conforme entren
   más, aplicar al kit los aprendizajes acumulados. Generar los kits
   específicos por plataforma (Python, Dart/Flutter) cuando un
   segundo proyecto en ese stack lo justifique.

---

## 13. Resumen ejecutivo

Tres familias, roles distintos, cartera de proyectos sin cronograma.
O diseña en chat. D+G auditan documentación inicial en chat. J
ejecuta en su VM. D V4 Flash audita PRs vía API. O (y opcionalmente
D) revisa épicas cuando el arquitecto lo invoque. El humano abre un
Kanban consolidado, no varios repos.

El v1.6 mantiene el espíritu de v1.5 e integra los aprendizajes del
primer proyecto real en operación + el modelo de tests rojos
pre-cargados validado:

- **Los tests son contrato ejecutable pre-cargado en el body del
  Issue**. El workflow `prepare-issue-branch.yml` los materializa
  como primer commit de la rama; `check_test_immutability.sh`
  verifica blob SHA per-archivo en cada PR.
- **El N2 es un par**: `.md` (fuente de verdad) + script bash
  (consecuencia). D+G auditan ambos.
- **El tamaño del bloque lo decide O** según capacidad por sesión.
- **El ejecutor nunca edita el Issue**, la etiqueta del ejecutor
  nunca se retira, la última operación es la señal.
- **G no audita PR**; solo D vía API.
- **El PAT del arquitecto es firma del jefe**, no solo permisos.
- **Mensajes-instrucción al agente embebidos en errores de CI**,
  helpers de CI con fallback inline, `skip_validators` en el
  orquestador, concurrencia diferenciada, y demás patrones
  rescatados del proyecto real.

Equipo bueno, no perfecto. La IA se equivoca; el humano también. El
sistema acomoda eso por construcción: railes que detectan los
errores graves, comentarios que documentan las dudas, y la revisión
de épica cuando el arquitecto sospeche que conviene mirar dos veces.
Los errores restantes se corrigen en la siguiente iteración. Eso es
suficiente.

Costo: ~$225/mes en máquina + tiempo del arquitecto distribuido al
ritmo que prefiera. Sin presión calendárica.

Siguiente paso operacional: **migrar el primer proyecto a v1.6**.
Operar desde el día 1 con kit completo en diseño, automatizando los
componentes en rolling. La fábrica se construye operándola.
