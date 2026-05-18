---
title: General Starter Kit
permalink: /docs/starter-kit/
nav_order: 3
---

# General Starter Kit — v1.2

> Especificación canónica, agnóstica de plataforma, del starter_kit que
> sirve de cimiento a todos los starter_kits específicos por stack
> (Python, Dart con Flutter, Node, Go, Rust, mixtos). Define qué debe
> incluir un kit, por qué, y los gates de calidad que no son
> negociables.
>
> **Versión:** 1.2 · **Fecha:** 18 de mayo de 2026
> **Reemplaza:** v1.1
> **Estado:** vivo. Las versiones específicas por plataforma derivan de
> este documento y no pueden contradecirlo; pueden extenderlo.

---

## 0. Cambios desde v1.1

Esta versión integra dos fuentes de aprendizaje: (a) los patrones
observados en operación real del primer proyecto del enjambre,
identificados por análisis comparativo entre el kit canónico y la
implementación real; (b) el diseño de **tests rojos pre-cargados**
validado en operación y que reemplaza el modelo anterior de
inmutabilidad por hash determinístico per-épica.

### Cambios estructurales

1. **Tests rojos pre-cargados.** El modelo de `tests/contract/<epic>/`
   + manifiesto de hashes per-épica del v1.1 se reemplaza por:
   - Sección `### Tests rojos pre-cargados` en el body del Issue
     (fuente de verdad).
   - Workflow `prepare-issue-branch.yml` que parsea el body y
     materializa los tests como primer commit de la rama.
   - Check `check_test_immutability.sh` que verifica blob SHA
     per-archivo del commit scaffold contra HEAD del PR.
   - Auto-desactivación del check cuando el primer commit no es
     scaffold (Issues sin tests, ramas legacy).

2. **G no audita PR.** Clarificación de roles: G (Gemini) actúa como
   ejecutor (Jules) y como co-auditor de documentación en chat con D.
   **No audita PR**. La auditoría de PR la hace exclusivamente D vía
   API en `audit-pr.yml`.

3. **Label `requires-architect-review` se renombra a
   `requires-human-review`.** Para alinearse con la operación real.
   La label `architect-approved` (aplicada manualmente por el
   arquitecto sobre N1/N2) se mantiene.

4. **N2 como par `.md` + script bash.** El N2 de un bloque es un
   documento markdown legible (fuente de verdad) **acompañado** por un
   script bash que sube los Issues a GitHub. D+G auditan ambos.

5. **Patrón "la última operación es la señal".** La etiqueta `jules`
   (o equivalente del ejecutor) se aplica como paso final atómico tras
   verificar éxito completo del workflow de preparación. Si algo falla
   antes, la señal no se emite y el sistema queda en estado limpio.

6. **Regla: el ejecutor nunca edita el Issue.** La etiqueta `jules`
   nunca se retira. La única "edición" del Issue por la máquina es la
   aplicación inicial automática de la etiqueta. Toda otra
   modificación del Issue la hace el arquitecto humano.

### Patrones operacionales rescatados del proyecto real

7. **Mensajes-instrucción embebidos al agente** en errores de CI:
   cuando el CI detecta un error recuperable sin commit (título de PR
   mal formado, label faltante, body sin `Closes #N`), el error debe
   devolver la receta exacta de recuperación al agente.

8. **Auto-aplicación de `requires-human-review` por complejidad
   declarada.** El formulario de Issue tiene dropdown de complejidad
   estimada; "large" dispara `requires-human-review` automático.

9. **Lista exhaustiva de `PROTECTED_PATTERNS`** multi-stack como
   apéndice (ver Apéndice A).

10. **"Nunca re-aplicar `auto-merge` en sync".** Si un humano removió
    la label intencionalmente, no se la pongas otra vez en el siguiente
    push.

11. **`skip_validators` como input del orquestador** en runs manuales,
    para saltar validadores nombrados durante diagnóstico.

12. **Concurrencia diferenciada**: el orquestador cancela superseded
    runs del mismo PR; el auto-merge **nunca** cancela in-flight.

13. **Flags `--only=<scope>` y `--continue`** en scripts CI para
    monorepos heterogéneos y diagnóstico.

14. **Helper functions inline con fallback** a `lib/_common.sh` en
    scripts CI, para que cada script ejecute aislado.

15. **Bootstrap y codegen como pasos explícitos del CI** cuando el
    stack tiene código generado.

16. **`sleep` antes de buscar siguiente Issue** tras un merge
    (eventual consistency de GitHub).

17. **Token PAT del arquitecto como "marca de procedencia".** El
    secret `JULES_PAT` (nombre genérico: `OPERATOR_PAT` o equivalente
    según el proyecto) no es solo permisos elevados; es una firma:
    cuando un workflow opera con este PAT, el ejecutor reconoce que la
    acción viene del jefe y obedece. Si operara con `GITHUB_TOKEN`,
    podría desconfiar.

18. **Fallback en cascada para detectar Issue cerrado** por un PR:
    primero parse de `Closes/Fixes/Resolves #N`, luego último Issue
    con label de ejecutor cerrado recientemente.

19. **`project_manifest.json`** como artefacto canónico con IDs de
    GitHub Project y de sus campos. Script generador idempotente para
    producirlo.

20. **Script `branch_protections_rules.sh`** para configurar branch
    protection declarativamente vía `gh api`.

21. **Un script de creación de Issues por bloque** (no un script
    monolítico con flag); cada bloque es replayable idempotente.

22. **DoD como checkboxes editables** en el formulario del Issue;
    convierte el DoD en máquina de estado visible en GitHub UI.

23. **Campo "Rutas afectadas"** y **"Comandos extra de validación"** en
    el formulario del Issue.

24. **`Issue link required` como gate de governance**, con instrucción
    al agente embebida en el error.

25. **CHANGELOG validation como gate**, con exempción automática para
    PRs puramente de docs/scripts (detección por extensión).

26. **Tests sobre las herramientas de governance del propio kit.**
    Toda herramienta del kit que decida el destino de un PR
    (validador de CHANGELOG, check de inmutabilidad, futuros
    validadores) debe tener su propia suite de tests que corra en CI.

### Cambios de redacción y eliminaciones

- **`requires-architect-review` → `requires-human-review`** en todo el
  documento.
- **§9 directorios canónicos**: `docs/orchestrator/contract-hashes/`
  eliminado. `tests/contract/<epic>/` eliminado como prescripción
  rígida.
- **`auditor-prompts/`**: lista actualizada (solo
  `pr-auditor-system.md`; los prompts manuales viven fuera).
- **PR size budget default**: subido de 400 a 2000 líneas con nota
  explicativa sobre stacks con codegen.

**Nota sobre versionado**: estrictamente, varios de estos cambios
calificarían como breaking (renombrar label, eliminar directorios
canónicos, cambiar modelo de inmutabilidad). Se mantiene en v1.2 (no
v2.0) porque no existen aún kits derivados completos que el bump pueda
romper, y porque los proyectos en operación migran fácil
(`requires-architect-review → requires-human-review` es buscar y
reemplazar; el modelo de tests pre-cargados convive con el viejo
durante la transición). Si emerge un segundo kit derivado a partir de
aquí, el próximo cambio estructural sí ameritará major bump.

---

## 1. Propósito de este documento

Este documento es el **contrato base** que toda implementación de
starter_kit debe honrar, sin importar el lenguaje o framework objetivo.
Su propósito es triple:

1. **Aislar las decisiones estructurales de las decisiones de stack.**
   Las decisiones que aquí se definen valen igual para Python que para
   Dart o para cualquier combinación. Cuando se deriva un kit
   específico, solo se especializa la capa más superficial (comandos
   concretos, manifiestos, herramientas de lint). El resto se hereda.
2. **Servir de referencia única para auditorías arquitectónicas.**
   Cuando se audita un proyecto, se verifica conformidad contra este
   documento, no contra los kits derivados. Los kits derivados solo
   añaden requisitos, nunca relajan los de aquí.
3. **Documentar el "por qué" detrás de cada decisión.** Las reglas sin
   justificación se erosionan. Cada regla aquí tiene fundamento, y el
   fundamento es lo que justifica mantenerla cuando el equipo (o el
   propio arquitecto solopreneur) tenga la tentación de hacer
   excepciones.

Lo que este documento **no es**: una implementación. No contiene
código, no incluye archivos ejecutables, no prescribe herramientas
específicas. Las herramientas son elecciones del kit por plataforma.

---

## 2. Definición de starter_kit

Un **starter_kit** es el conjunto mínimo de archivos, convenciones,
workflows y gates que se aplica el día 1 de un repositorio nuevo para
que el desarrollo asistido por un enjambre de LLMs sea defendible y
auditable de extremo a extremo.

Un starter_kit no es:

- Una plantilla de proyecto (esas resuelven "cómo arranco el código").
- Un boilerplate de framework (esos resuelven "qué stack uso").
- Un conjunto de buenas prácticas opcionales (esas no se hacen
  cumplir).

Un starter_kit **sí** es:

- Una infraestructura de control que materializa físicamente las
  decisiones arquitectónicas mediante CI/CD, labels, hooks y
  validadores.
- Un contrato entre el arquitecto humano, los agentes LLM ejecutores y
  los agentes LLM auditores.
- Una membrana de seguridad: lo que pasa los gates es defendible; lo
  que no pasa, no entra a `main`.

---

## 3. Principios rectores

Toda decisión incluida en este documento se justifica contra uno o
varios de estos diez principios. Una regla que no remita a ninguno
está fuera de lugar y debe revisarse.

**P1. Segregación de funciones entre familias LLM.** Ningún modelo
diseña, ejecuta y audita el mismo artefacto. El diseñador, el ejecutor
y el auditor pertenecen siempre a familias distintas para un mismo
artefacto. Una misma familia puede ocupar roles distintos sobre
artefactos distintos.

**P2. El script local es el contrato; CI lo invoca.** La validación
remota nunca diverge de la validación local porque ejecuta exactamente
el mismo script. Esto se cumple por construcción, no por documentación.

**P3. Compuerta única hacia `main`.** Branch protection apunta a un
solo nombre de check estable. Los validadores convergen en ese gate.
Esto desacopla "qué validadores existen" de "qué se exige para
fusionar".

**P4. Composición sobre configuración.** Las decisiones del orquestador
se expresan en labels componibles, no en motores de reglas custom.
Dos labels (`auto-merge` y `requires-human-review`) bastan para
expresar la política de fusión.

**P5. Radio de daño acotado.** Cualquier mecanismo automatizado tiene
límites explícitos (frecuencia, tamaño, scope). Cuando los excede, se
detiene y reclama intervención humana, no continúa "esperando lo
mejor".

**P6. Self-healing por defecto, no por excepción.** Cuando `main` se
rompe, el sistema pausa al agente automáticamente. El humano no tiene
que recordar pausarlo.

**P7. Path-based protection sobre confianza implícita.** Las zonas
sensibles (CI, manifiestos, migraciones, infraestructura, contratos
arquitectónicos) se protegen mecánicamente por path, no se espera que
el agente o el humano recuerden tener cuidado allí.

**P8. Inmutabilidad de los contratos por el ejecutor.** Los tests
pre-cargados (scaffold) y los ADRs los escribe el arquitecto (o el
diseñador LLM bajo supervisión); el ejecutor no puede modificarlos.
Esto se hace cumplir por guards mecánicos (blob SHA per-archivo
contra el commit scaffold), no por convención.

**P9. Telemetría como prerequisito de mejora.** Lo que no se mide, no
se mejora. Cada Issue procesado genera datos: iteraciones, tokens
consumidos, tiempo de ciclo, falsos positivos del auditor. Sin esto,
no hay forma de detectar la patología.

**P10. La auditoría LLM no anula la auditoría humana.** Los gates
automáticos pasan o fallan; los gates humanos se reservan para
decisiones donde el costo de equivocarse es asimétrico (revisión de
épica, arquitectura, contratos públicos, modificación del scaffold).

---

## 4. Componentes del kit

Todo starter_kit debe proveer, organizadas en seis capas, las
siguientes categorías de artefactos. La granularidad concreta y el
formato lo define cada kit específico; las categorías son inviolables.

### 4.1 Capa de orquestación

Workflows reusables que coordinan el ciclo de vida de un PR desde
apertura hasta merge (o rechazo). Componen:

- **Punto de entrada único** disparado por eventos de PR y push a
  `main`. Acepta `workflow_dispatch` con input `skip_validators`
  (CSV) para saltar validadores nombrados en runs manuales.
- **Validadores enchufables en paralelo** (CI funcional, governance,
  auditoría LLM, otros).
- **Gate de convergencia único** que todos los validadores alimentan.
- **Mecanismo de auto-merge** condicionado a labels y al gate.
- **Concurrencia diferenciada**: el orquestador cancela superseded
  runs del mismo PR (`cancel-in-progress: true`); el auto-merge
  **nunca** cancela in-flight (`cancel-in-progress: false`).
- **Preparación de rama para el siguiente Issue** que respeta
  exclusiones y salud de `main`. La etiqueta del ejecutor se aplica
  como **paso final atómico** tras éxito de la preparación (incluida
  la materialización del scaffold de tests pre-cargados, si aplica).
  Toma siempre el Issue elegible más viejo con label de tarea
  estructurada y sin label de ejecutor; FIFO con `sleep` previo para
  acomodar eventual consistency de GitHub.
- **Auto-apertura de incidente** cuando `main` se rompe, con pausa
  automática del agente hasta resolución manual.

### 4.2 Capa de validación

Scripts ejecutables que materializan el contrato de calidad,
invocables tanto local como remotamente. Mínimo:

- **Script ligero** (~30 segundos) para validación pre-commit:
  formato, lint, tipos.
- **Script completo** (sin tope de tiempo razonable) que ejecuta la
  suite completa: el ligero + tests + cobertura + auditorías de
  seguridad + build de documentación + cualquier extra del proyecto.
- **Flags canónicos `--only=<scope>` y `--continue`** en ambos
  scripts:
  - `--only=<scope>`: limita la ejecución a un subconjunto del
    monorepo (útil para stacks heterogéneos).
  - `--continue`: acumula fallos sin cortar, para diagnóstico.
- **Helper functions** (`ci_log`, `ci_step`, `ci_summary`, `ci_fail`)
  cargadas desde `lib/_common.sh` con **fallback inline**: si la lib
  común no se encuentra (script ejecutado aislado o copia-pega), el
  script define versiones locales y sigue funcionando.
- **Bootstrap y codegen como pasos explícitos** cuando el stack tiene
  código generado: el script completo ejecuta primero el bootstrap y
  el codegen (sobre checkout limpio) y luego el resto. **No asumir
  que el código generado está commiteado.**
- **Hooks Git** que invocan el script ligero en pre-commit y el script
  completo en pre-push.
- **Hooks de extensión por proyecto** para añadir validaciones
  específicas sin modificar el kit base.

### 4.3 Capa de convención

Documentos y configuraciones que codifican las reglas inviolables del
repositorio en un formato que tanto humanos como agentes leen:

- **AGENTS.md raíz** con las reglas para todo agente que escriba
  código en el repositorio.
- **AGENTS.md por scope** (sub-monorepos, paquetes, módulos) cuando el
  proyecto tiene divisiones internas con reglas propias.
- **CONTRIBUTING.md** dirigido a humanos.
- **CHANGELOG.md** mantenido bajo "Keep a Changelog" + SemVer (o
  variante explícitamente justificada).
- **Configuración de hooks de commit** que rechaza commits que no
  sigan Conventional Commits.
- **Scopes Conventional Commits enumerados explícitamente** en el
  AGENTS.md (por feature, por paquete) para que el ejecutor no
  invente scopes.

### 4.4 Capa de documentación viva

Cuatro directorios con propósito y reglas de actualización claras:

- **`docs/backlog/`**: N1 (épicas) y N2 (bloques de Issues por épica)
  generados por el arquitecto LLM, auditados manualmente por el
  arquitecto humano con D+G en chat antes de subirse al repo por push
  manual. El N2 vive como **par** (`.md` + script bash); ambos se
  commitean al repo. La fuente de verdad es el `.md`; el script es
  consecuencia.
- **`docs/adr/`**: Architecture Decision Records, versionados, con
  formato estándar (variante de Nygard u otro explícitamente
  justificado). Su actualización es obligatoria para PRs que tocan
  superficie arquitectónica.
- **`docs/orchestrator/`**: documentación del propio kit dentro del
  proyecto, para que cualquier humano (o agente nuevo) entienda el
  pipeline sin depender de conocimiento tribal. Aquí también vive
  `project_manifest.json` (ver §8.3) con los IDs del GitHub Project.
- **`docs/reviews/`** (opcional, se llena en operación): reportes de
  revisión de épica producidos por O o D, nombrados
  `epic-NNN-review-YYYYMMDD.md`. Más de una revisión por épica es
  esperable (las épicas no se cierran).

### 4.5 Capa de auditoría externa (enjambre LLM)

Workflows que invocan auditores LLM externos como validadores
adicionales del orquestador. Mínimo:

- **Auditor de PR (único):** invocado por el orquestador en cada PR.
  Recibe diff + AGENTS.md + ADRs relevantes + N2 de la épica. Devuelve
  veredicto estructurado contra checklist fijo. Aplica label
  `audit/pass` o `audit/fail`. El gate único exige `audit/pass`. Ver
  `DeepSeek_Auditor_Integration_v1_2.md` para implementación.
  **Implementado exclusivamente por D (DeepSeek V4 Flash); G no
  audita PR.**

**No incluido como workflow del kit** (son procesos manuales en chat,
no automatizados):

- **Auditoría dual de documentos iniciales**: la hace el arquitecto
  humano en chat con D y G como co-auditores, usando
  `Prompt_Auditoria_Documentos_D_y_G.md`. Cuando el N2 viene como par
  `.md` + script, la auditoría confirma tres cosas a la vez:
  coherencia interna del `.md`, fidelidad del script al `.md`, y
  consistencia de rutas y nombres.
- **Revisión de épica**: la hace el arquitecto humano en chat con O
  (vía `.zip`), o opcionalmente con D (vía `.md` concatenado),
  usando `Prompt_Revision_de_Epica_con_O.md`. Produce un reporte con
  hallazgos por Issue + Issues sugeridos.

### 4.6 Capa de telemetría

Mecanismos que capturan métricas operacionales por Issue:

- **Tokens consumidos** por el auditor LLM en el ciclo del Issue.
- **Iteraciones del ejecutor** (cuántos pushes hasta pasar CI).
- **Tiempo de ciclo** entre asignación del Issue y merge.
- **Tasa de falsos positivos del auditor** (PRs rechazados por
  `audit/fail` que luego pasan tras intervención mínima del humano).
- **Frecuencia de gates humanos disparados** y por qué.

Estos datos se publican como comentario estructurado en el PR al
cierre. Buscable con `gh pr list --search "[telemetry]"`. **No hay
base de datos a mantener.**

---

## 5. Topología de workflows

El kit organiza la lógica de orquestación en tres capas de workflows,
con responsabilidades disjuntas. Esta topología no depende del stack.

### 5.1 Punto de entrada (eventos)

Exactamente dos workflows reaccionan a eventos del repositorio:

- **Orquestador principal:** dispara en eventos de PR (apertura,
  sincronización, etiquetado) y en push a `main`. Es el único que
  invoca validadores. Acepta `workflow_dispatch` con input
  `skip_validators` (CSV) para saltar validadores nombrados en runs
  manuales. Mantiene una concurrencia tal que runs obsoletos del
  mismo PR se cancelan, pero un merge en vuelo nunca se cancela.
- **Etiquetador de formularios:** dispara en apertura/edición de
  Issues. Traduce las selecciones del formulario estructurado en
  labels que el orquestador entiende (`type/*`, `priority/*`,
  `requires-human-review` cuando la complejidad declarada es "large").

Cualquier otro workflow del kit es **reusable** (`workflow_call`) y se
invoca desde el orquestador. Esta separación impide que validadores
disparen entre sí o se ejecuten fuera del flujo controlado.

### 5.2 Validadores reusables

Cada validador es un workflow autónomo invocable. El kit base incluye,
como mínimo:

- **CI funcional:** invoca el script completo de validación. Es el
  único que sabe del stack (en cada kit derivado).
- **Governance:** validadores agnósticos de stack:
  - Secret scanning (gitleaks o equivalente).
  - Dependency review.
  - Título de PR contra Conventional Commits, con instrucción de
    recuperación embebida en el error (ver §10 C11).
  - Presupuesto de tamaño de PR (default: 2000 líneas, ver §10 C4).
  - **Issue link required**: el body del PR debe contener
    `Closes/Fixes/Resolves #N`. Sin esto, fail con instrucción
    embebida.
  - **CHANGELOG validation**: si el PR toca código fuente (detectado
    por extensión), exige que `CHANGELOG.md` tenga al menos una línea
    nueva bajo `## [Unreleased]`. PRs puramente de docs o scripts
    están exentos.
  - **Test scaffold immutability** (`check_test_immutability.sh`):
    blob SHA per-archivo contra el commit scaffold de tests
    pre-cargados. Auto-desactivado si el primer commit de la rama no
    es scaffold.
- **Auditoría LLM de PR:** invoca al auditor único de PR. Implementado
  por D vía API (ver `DeepSeek_Auditor_Integration_v1_2.md`).

Añadir validadores adicionales es trivial: nuevo workflow reusable,
nuevo job en el orquestador, nuevo `needs` en el gate de convergencia.

### 5.3 Workflows post-gate

Después del gate de convergencia, tres workflows reaccionan según el
contexto:

- **Auto-merge + asignación de siguiente Issue:** en eventos de PR.
  Verifica condiciones de fusión, aplica circuit breaker, ejecuta el
  merge (squash a `main`), determina qué Issue cerró el PR (parsing
  `Closes #N` primero, fallback al último Issue con label de ejecutor
  cerrado recientemente), verifica salud de `main`, selecciona el
  siguiente Issue **FIFO** (el más viejo elegible con label de tarea
  estructurada y sin label de ejecutor) tras un `sleep` previo, y
  delega al workflow de preparación de rama.
- **Preparación de rama del siguiente Issue** (workflow reusable
  `prepare-issue-branch.yml`): lee el body del Issue, resuelve el
  nombre de la rama (declarado en body o computado), parsea la
  sección `### Tests rojos pre-cargados`, crea la rama desde `main`,
  escribe los archivos del scaffold y commit
  `test(EXX-NNN): scaffold red tests`. Si no hay tests, commit vacío
  `chore(EXX-NNN): initialize branch for #N`. Push de la rama.
  **Aplica la etiqueta del ejecutor como paso final atómico.** Si
  cualquier paso anterior falla, la etiqueta no se aplica y el
  ejecutor no toma la tarea. Detalle del modelo en §11.6.
- **Salud post-merge:** en push a `main`. Registra el resultado de los
  validadores. Si `main` quedó rota, abre (o actualiza) issue de
  incidente con labels que el asignador de tareas excluye, pausando al
  ejecutor automáticamente.

---

## 6. Sistema de labels

El vocabulario de labels es **parte del contrato**. No es decoración
(con la excepción explícita de las labels de prioridad — ver §6.3).
Cada label canónica tiene semántica activa: workflows leen, escriben y
discriminan según labels. Renombrar una label sin actualizar workflows
rompe el sistema.

### 6.1 Labels de flujo de trabajo

- **`<agent>-task`** (nombre genérico; en el primer proyecto:
  `jules-task`): Issue estructurado vía formulario, elegible para ser
  asignado a un agente ejecutor. Aplicada automáticamente por el
  formulario.
- **`<agent>`** (nombre genérico; en el primer proyecto: `jules`):
  Issue actualmente asignado al ejecutor. **Aplicada por
  `prepare-issue-branch.yml` como paso final atómico tras éxito
  completo del workflow.** El asignador excluye Issues con esta label
  para evitar doble asignación. **Esta label nunca se retira.** Si
  un Issue mal especificado debe descartarse, se cierra el Issue (la
  label se queda con él como parte de la historia) y se crea uno
  nuevo. La única "edición" del Issue por la máquina es la aplicación
  inicial de esta label.
- **`auto-merge`**: PR elegible para fusión automática si todos los
  gates pasan. Aplicada por el etiquetador de PR cuando el Issue
  enlazado es `<agent>-task` y el PR no toca paths protegidos.
- **`requires-human-review`**: bloquea auto-merge incondicionalmente.
  Aplicada automáticamente por path-based protection, por incidente en
  `main`, por complejidad declarada como "large" en el formulario, o
  manualmente por el arquitecto.
- **`audit/pass`** y **`audit/fail`**: veredicto del auditor LLM
  externo (D) sobre el PR. El gate único exige `audit/pass`.
- **`architect-approved`**: aplicada manualmente por el arquitecto
  humano sobre N1 y N2 (par `.md` + script) en `docs/backlog/` tras
  la auditoría manual D+G en chat. Prerequisito para que el script
  bash de creación de Issues pueda ejecutarse.

**Nota sobre `auto-merge` en sync:** la label se aplica en el evento
`opened`. En eventos `synchronize` posteriores, **nunca se re-aplica**
si un humano la retiró intencionalmente. El workflow respeta la
decisión humana.

### 6.2 Labels de exclusión

- **`blocked`**: Issue no puede proceder; depende de algo externo.
- **`needs-design`**: Issue requiere decisión arquitectónica antes de
  ejecutarse.
- **`needs-triage`**: Issue no evaluado aún para priorización.
- **`incident`** y **`main-broken`**: Issues de incidente
  auto-generados. Pausan al agente mientras estén abiertas.

### 6.3 Labels de prioridad (decorativas)

Cuatro niveles, mutuamente excluyentes:

- **`priority/p0`**: drop everything.
- **`priority/p1`**: próximo.
- **`priority/p2`**: pronto.
- **`priority/p3`**: backlog.

**Estas labels son anotación humana para visualización en el Kanban.
El asignador NO las usa.** El asignador es FIFO estricto: toma el
Issue elegible más viejo. La priorización real está encodificada en el
**orden de creación** de los Issues, que el arquitecto controla al
diseñarlos secuencialmente con O. Romper este modelo de prioridad
calendarizada es deliberado: la cadena se diseña para el ritmo del
arquitecto humano, no para un sprint board.

### 6.4 Labels de tipo

Reflejan el tipo de Conventional Commit del PR resultante. El conjunto
mínimo: `type/feat`, `type/fix`, `type/chore`, `type/docs`,
`type/refactor`, `type/test`, `type/perf`.

### 6.5 Labels de excepción explícita

- **`size-override`**: PR excede el presupuesto de tamaño pero está
  aprobado con justificación en la descripción.
- Otras excepciones se documentan con su propia label y workflow de
  enforcement.

---

## 7. Gates de calidad

Un gate de calidad es un punto del pipeline donde el avance se
condiciona al cumplimiento de una propiedad verificable. El kit define
ocho gates, todos obligatorios. Cualquier excepción se documenta en un
ADR que justifica el bypass.

**G1. Documentación inicial auditada antes de generar Issues.** Ningún
script bash de creación de Issues hijos puede ejecutarse contra un
repositorio cuyo N2 (par `.md` + script) no tenga label
`architect-approved`. La auditoría ocurre en **chat manual** del
arquitecto humano con D y G como co-auditores; la aplicación de la
label es acto manual del arquitecto. La auditoría confirma además
que el script bash refleja fielmente el `.md`.

**G2. Auditoría LLM antes de merge.** Todo PR debe tener `audit/pass`
del auditor D de PR. `audit/fail` bloquea aunque el resto del CI esté
verde. **Solo D audita PR**; G no participa en este gate.

**G3. Path-based protection.** Todo PR que toque paths protegidos
(workflows, manifiestos, migraciones, Docker, ADRs, contratos
públicos, archivos del scaffold de tests pre-cargados) recibe
automáticamente `requires-human-review`. La label no se puede remover
sin intervención del arquitecto. La lista exacta de patrones está en
el **Apéndice A**.

**G4. Inmutabilidad del scaffold de tests pre-cargados.** El ejecutor
no puede modificar ni eliminar archivos del primer commit
`test(EXX-NNN): scaffold red tests` de la rama del Issue. El guard se
implementa con `check_test_immutability.sh`: blob SHA per-archivo
entre el commit scaffold y HEAD. El check se auto-desactiva cuando el
primer commit no es scaffold (Issues sin tests, ramas legacy). Ver
`DeepSeek_Auditor_Integration_v1_2.md §9` para mecánica completa.

**G5. Aprobación de CODEOWNERS.** Branch protection exige aprobación
de Code Owners en paths configurados. Esta es la última red de
seguridad humana.

**G6. Circuit breaker de auto-merge.** Máximo N fusiones automáticas
en ventana móvil de 2 horas (default: 10). Al disparar, pausa
auto-merge hasta que la ventana se vacíe naturalmente o el arquitecto
ajuste el umbral con justificación.

**G7. Salud de `main`.** Si la última corrida del orquestador en
`main` no es exitosa, el asignador rehusa asignar la siguiente tarea
hasta que se cierre el issue de incidente.

**G8. Revisión de épica con O (cuando se decida).** Las épicas no se
cierran. La revisión de épica es opcional y la decide el arquitecto.
Existen dos modos:

- **Cierre rápido por confianza** (default): el arquitecto observa
  que los Issues de un bloque o de la épica están completos y sigue
  con la siguiente sesión de diseño. Sin auditoría adicional.
- **Revisión profunda con O** (y opcionalmente también D): el
  arquitecto produce un `.zip` del repo (para O) o un `.md`
  concatenado equivalente (para D), entrega a una o ambas LLMs en
  chat usando `Prompt_Revision_de_Epica_con_O.md`, y recibe un
  reporte con hallazgos por Issue + Issues sugeridos. Si invoca a
  ambas, compara las dos auditorías. Indicado para: primera épica del
  proyecto, épica que toca arquitectura, épica con alta tasa de
  retrabajo observable, o cualquier épica donde el arquitecto
  sospeche que conviene mirar dos veces.

Ninguno de los dos modos sella la épica. La épica permanece "abierta"
en el sentido de que el arquitecto puede añadirle Issues nuevos en
cualquier momento (Issues de corrección, ampliaciones).

---

## 8. Archivos canónicos del kit

Todo kit derivado debe incluir los siguientes archivos, con los
nombres exactos o equivalentes documentados:

### 8.1 Documentos raíz

- **`README.md`**: introducción al kit y al proyecto resultante.
  Bootstrap del día 1, comandos canónicos, estructura del repositorio,
  decisiones de diseño explicadas.
- **`AGENTS.md`** (raíz): reglas inviolables para todo agente IA que
  escriba código. Estructura: propósito, arquitectura, prohibiciones,
  Definition of Done, lectura obligatoria al empezar.
  **Incluye explícitamente la regla**: "Si no se provee una rama de
  trabajo en el Issue, debes crear una rama desde `main` siguiendo la
  convención `<type>/<E##-###>-<slug>`."
- **`CONTRIBUTING.md`**: equivalente humano de AGENTS.md.
- **`CHANGELOG.md`**: bajo "Keep a Changelog" + SemVer.
- **`PR_JUSTIFICATION.md.template`**: plantilla para PRs que tocan
  paths protegidos. Por-PR, se borra al fusionar.

### 8.2 Configuración de hooks Git

- **Manifiesto de hooks** (formato según la herramienta elegida en
  cada kit derivado: lefthook, pre-commit, husky, etc.) que
  materializa:
  - `pre-commit`: script ligero de validación.
  - `commit-msg`: enforcement de Conventional Commits.
  - `pre-push`: script completo de validación.
  - `post-merge`: recordatorio de re-sincronización de dependencias si
    cambiaron manifiestos.

### 8.3 Plantillas y configuración de GitHub

- **`.github/CODEOWNERS`**: define quién aprueba cada path. Las
  entradas combinadas con branch protection son la red humana final.
- **`.github/labels.yml`** (o equivalente): manifiesto declarativo del
  conjunto de labels canónicas con colores y descripciones.
- **`.github/PULL_REQUEST_TEMPLATE.md`**: descripción de PR por
  defecto con checklist de Definition of Done.
- **`.github/ISSUE_TEMPLATE/agent_task.yml`** (o nombre equivalente,
  por ejemplo `jules_task.yml` en el primer proyecto): formulario
  estructurado para tareas de agente. Estructura prescrita:
  - **Bloque WARNING en el primer markdown** (no editable por el
    agente), instruyendo al ejecutor que: (a) la validación local con
    el script completo es obligatoria antes de crear el PR; (b) si
    el body declara una rama (`## 🌿 Rama asignada: ...`), debe usar
    esa rama y no crear otra; **si no la declara, debe crear una
    rama desde `main`** siguiendo la convención
    `<type>/<E##-###>-<slug>`; (c) el título del PR sigue Conventional
    Commits; (d) si el PR excede el tamaño, debe aplicar
    `size-override` con justificación.
  - Campos estructurados de texto libre: contexto, criterios de
    aceptación, notas técnicas, comandos extra de validación.
  - Dropdowns: tipo (`type/*`), prioridad (`priority/*` decorativa,
    opcional), **complejidad estimada** (`small`/`medium`/`large`;
    "large" dispara `requires-human-review` automático).
  - Campo de texto: **rutas afectadas** (estimadas, para que
    CODEOWNERS y otros agentes detecten colisiones).
  - **Checklist de Definition of Done editable** que el agente marca
    al avanzar. Convierte el DoD en máquina de estado visible en
    GitHub UI.
  - Sección `### Tests rojos pre-cargados` (rellenable por el
    diseñador LLM, no por el formulario en sí; el formulario es para
    Issues humanos; los Issues estructurados generados por el script
    de N2 ya traen esta sección poblada).
- **`.github/ISSUE_TEMPLATE/bug_report.yml`** y
  **`.github/ISSUE_TEMPLATE/feature_request.yml`**: formularios para
  humanos.
- **`.github/ISSUE_TEMPLATE/config.yml`**: deshabilita issues en
  blanco.
- **`.github/project_manifest.json`** (o `docs/orchestrator/`):
  manifiesto declarativo con IDs del GitHub Project asociado, sus
  campos custom (Epic, Priority, etc.) y los IDs de cada opción. Los
  scripts de creación de Issues consumen este manifiesto en lugar de
  hardcodear UUIDs. Generado por un script idempotente
  (`generate_project_manifest.sh`).

### 8.4 Workflows

Los workflows base, descritos por su propósito (no por su contenido):

- **Orquestador principal**: punto de entrada, validadores en
  paralelo, gate de convergencia, input `skip_validators`.
- **CI por stack**: invoca el script completo. Único workflow
  específico de plataforma.
- **Governance**: validadores universales (secret scan, dep review,
  Conventional Commits, PR size, Issue link, CHANGELOG, test
  scaffold immutability).
- **Auto-merge + selección FIFO de siguiente Issue**: post-gate,
  evento de PR.
- **Preparación de rama** (`prepare-issue-branch.yml`): reusable,
  invocado por el de auto-merge cuando hay siguiente Issue elegible.
  Materializa el scaffold de tests pre-cargados y aplica la etiqueta
  del ejecutor como paso final atómico.
- **Salud post-merge**: post-gate, evento de push a `main`.
- **Etiquetador de formularios**: traduce campos de formulario a
  labels (incluyendo `requires-human-review` por complejidad "large").
- **Etiquetador de PR**: aplica `auto-merge` o
  `requires-human-review` según el Issue enlazado y los paths
  tocados. **Nunca re-aplica `auto-merge` en sync**.
- **Auditor LLM de PR (`audit-pr.yml`)**: invoca a D y publica
  veredicto. Único workflow LLM del kit.

### 8.5 Scripts del kit

En `tools/ci/`:

- **Script ligero** (`light.sh`): validación rápida pre-commit, con
  flags `--only=<scope>` y `--continue`.
- **Script completo** (`full.sh`): la fuente única de verdad de "qué
  ejecuta CI", con mismos flags. El workflow de CI lo invoca
  literalmente. Incluye bootstrap y codegen como pasos previos
  cuando aplique.
- **Biblioteca compartida** (`lib/_common.sh`): utilidades de
  logging, timing, detección de stack. Cargada por light y full con
  **fallback inline** si no se encuentra.
- **Script de sincronización de labels** (`bootstrap-labels.sh`):
  bootstrap idempotente del conjunto de labels canónicas al
  repositorio de GitHub, leyendo `.github/labels.yml` y aplicando
  vía `gh label`.
- **Script de configuración de branch protection**
  (`branch_protections_rules.sh`): aplica declarativamente las reglas
  de branch protection vía `gh api`. Reemplaza la configuración
  clic-a-clic en la UI.
- **Script generador del project_manifest**
  (`generate_project_manifest.sh`): produce `project_manifest.json` a
  partir de la inspección del GitHub Project vía `gh api graphql`.
- **Script de empaquetado de revisión de épica** (opcional): produce
  el `.zip` para O y/o el `.md` concatenado para D, con exclusiones
  razonables (`node_modules/`, `build/`, `dist/`, `.venv/`, etc.).
- **Directorio de hooks de extensión** para que cada proyecto añada
  validaciones adicionales sin tocar el kit base.
- **Validador de inmutabilidad del scaffold**
  (`check_test_immutability.sh`): comparación blob SHA per-archivo
  entre el commit scaffold (primer commit tras `merge-base`) y HEAD
  del PR. Auto-desactivación cuando el subject del primer commit no
  matchea `^test\([eE][0-9]+-[0-9]+\): scaffold red tests$`.

En `.github/scripts/`:

- **Script preparador de rama** (`prepare_issue_branch.py` o
  equivalente): leído por el workflow `prepare-issue-branch.yml`. Lee
  el body del Issue, resuelve el nombre de la rama, parsea la sección
  `### Tests rojos pre-cargados`, materializa los archivos, hace
  commit y push. **Aplica la etiqueta del ejecutor como paso final
  atómico.**

### 8.6 Scripts de creación de Issues

- **Un script por bloque de N2** (no un script monolítico con flag).
  Cada bloque es replayable idempotente. Convención de nombre:
  `scripts/create_issues_E##_bNN.sh` (o equivalente). El script lee
  el N2 `.md` correspondiente (fuente de verdad) y sube los Issues
  con sus bodies poblados (incluyendo la sección
  `### Tests rojos pre-cargados`).

### 8.7 Tests del propio kit

- **Tests de las herramientas de governance** (carpeta `tools/` del
  proyecto): toda herramienta que decida el destino de un PR
  (validador de CHANGELOG, `check_test_immutability.sh`, futuros
  validadores) debe tener su propia suite de tests que corra en CI.
  Razón: estas herramientas son **código que decide qué se mergea**;
  un bug aquí es un agujero estructural del pipeline. **Esta regla
  es inviolable.** No hay validador en el kit sin tests que prueben
  sus casos de éxito y de fallo conocidos.

---

## 9. Directorios canónicos

Estructura mínima compartida por todos los kits derivados (los nombres
exactos pueden adaptarse si se documenta la traducción):

- **`.github/`** — configuración de GitHub (workflows, scripts,
  plantillas, CODEOWNERS, project_manifest).
- **`.github/scripts/`** — scripts ejecutados por workflows
  (`prepare_issue_branch.py`, etc.).
- **`tools/ci/`** — scripts de validación, biblioteca compartida,
  hooks de extensión, scripts de bootstrap.
- **`tools/auditor-prompts/`** — system prompts del auditor LLM
  automatizado (solo `pr-auditor-system.md`; los prompts manuales
  viven fuera del repo del proyecto, en el kit conceptual).
- **`docs/backlog/`** — N1 y N2 versionados, aprobados manualmente
  por el arquitecto tras auditoría manual D+G en chat. **El N2 vive
  como par `.md` + script bash.**
- **`docs/adr/`** — Architecture Decision Records.
- **`docs/orchestrator/`** — documentación del kit dentro del
  proyecto. Aquí también puede vivir `project_manifest.json`.
- **`docs/reviews/`** — reportes de revisión de épica producidos por
  O o D (opcional, se llena en operación).
- **`scripts/`** — scripts de creación de Issues por bloque,
  utilidades operacionales del proyecto.

**Eliminados respecto a v1.1**:

- `docs/orchestrator/contract-hashes/` (manifiesto de hashes
  per-épica). Ya no existe; la inmutabilidad se verifica contra el
  commit scaffold de cada rama.
- `tests/contract/<epic>/<issue>-*` como prescripción rígida. Cada
  proyecto decide dónde viven sus tests; el scaffold declara las
  rutas explícitamente en el body del Issue.

---

## 10. Convenciones inviolables

Las siguientes convenciones se aplican a todo proyecto basado en este
kit, independientemente del stack:

**C1. CI ejecuta el script local, nada más.** El workflow de CI no
contiene lógica de validación; invoca el script completo. Esto
mantiene paridad estricta entre validación local y remota.

**C2. Conventional Commits a tres capas.** Hook `commit-msg` local,
validador de governance en CI, regla explícita en AGENTS.md. Las tres
capas se refuerzan mutuamente; ninguna es redundante. Los **scopes
válidos están enumerados explícitamente** en el AGENTS.md del proyecto
(por feature, por paquete), no se inventan en el momento.

**C3. Un PR cierra un Issue.** El cuerpo del PR incluye `Closes #N`,
`Fixes #N` o `Resolves #N`. Sin esto, el orquestador no puede cerrar
correctamente ni seleccionar la siguiente tarea. Es un gate de
governance: PR sin Issue link enlazado → fail con instrucción
embebida.

**Patrón de Issue de corrección**: cuando un Issue post-merge necesita
arreglo, se crea un nuevo Issue y su PR referencia ambos:
`Closes #45, Corrects #32`. Esto da trazabilidad sin reabrir el Issue
original.

**C4. Tope de tamaño de PR.** Default: **2000 líneas** (sumadas
adiciones y borrados). Justificación del cambio respecto al v1.1
(que prescribía 400): en operación con stacks que generan código
(Flutter con codegen, Prisma, gRPC, etc.), el límite de 400 produce
PRs artificialmente troceados o saturación constante de
`size-override`. 2000 es un equilibrio observado entre legibilidad y
realidad. Cada kit derivado puede reducirlo si el stack lo permite.
Override explícito con label `size-override` y justificación en la
descripción.

**C5. No bypass de hooks locales.** `--no-verify` está explícitamente
prohibido por AGENTS.md. La variable de entorno equivalente solo se
usa en emergencias documentadas.

**C6. Branches por convención.** Patrones: `feat/<slug>`,
`fix/<slug>`, `chore/<slug>`. Nunca trabajar directo en `main`.
**Cuando el Issue declara una rama** (`## 🌿 Rama asignada: <nombre>`),
el ejecutor usa esa rama y no crea otra. **Cuando el Issue no la
declara**, el ejecutor crea una desde `main` siguiendo la convención
`<type>/<E##-###>-<slug>`.

**C7. Bloque de diseño de tamaño decidido por O; épica sin tope.** El
**bloque** es la unidad de diseño: el arquitecto y O producen un
conjunto de Issues con sus tests rojos pre-cargados en una sola
sesión coherente, que D+G auditan en chat antes de subir a GitHub. **El
tamaño del bloque lo decide O según su análisis de capacidad por
sesión**, no es un parámetro fijo. La justificación es la capacidad
de contexto del LLM diseñador (que produzca tests robustos), no la
deuda de integración. **La épica no tiene tope de tamaño** y es una
organización lógica (carpeta, label, columna del Kanban), no una
unidad de control de versiones.

**C8. Todos los PRs van directo a `main` con squash-merge.** No
existen ramas intermedias (`epic/N`, `develop`, etc.). La épica como
rama de git se descartó en v1.1 por fricción observada. El squash-merge
mantiene `main` legible (un commit por feature, fácil de revertir).

**C9. Squash-merge por defecto.** Refuerza C8.

**C10. Las decisiones arquitectónicas viven en ADRs.** Cambios que
toquen contratos públicos, capas de arquitectura, manifiestos del
stack o reglas de seguridad exigen ADR en el mismo PR. Sin ADR, el
guard mecánico falla.

**C11. Mensajes-instrucción al agente embebidos en errores del CI.**
Cuando un validador detecta un error que el agente puede resolver
**sin commit nuevo** (título de PR mal formado, body sin `Closes #N`,
label faltante), el mensaje de error debe incluir la receta exacta de
recuperación, prefijada por `::error::🤖 JULES/AGENT INSTRUCTION:`. La
receta es un comando ejecutable (típicamente `gh pr edit ...` o
`gh issue edit ...`). El propósito es self-healing de costo cero:
el agente recibe la instrucción exacta de cómo arreglar lo que rompió
sin contaminar la historia con commits cosméticos.

**C12. El ejecutor nunca edita el Issue.** La única modificación del
Issue por la máquina es la aplicación inicial automática de la
etiqueta del ejecutor por el workflow `prepare-issue-branch.yml`.
Toda otra modificación del Issue (cambiar body, retirar labels,
cerrar, reasignar) la hace el arquitecto humano. **La etiqueta del
ejecutor nunca se retira**: si un Issue mal especificado debe
descartarse, se cierra el Issue (la label se queda con él) y se crea
uno nuevo.

**C13. La última operación es la señal.** Cuando un workflow prepara
un Issue para ser tomado por el ejecutor, **aplica la etiqueta del
ejecutor como paso final atómico** tras verificar éxito completo
(rama creada, scaffold materializado, push exitoso). Si cualquier
paso anterior falla, la etiqueta nunca se aplica y el sistema queda
en estado limpio para intervención humana. Generalizable a cualquier
patrón "preparar X, señalar al consumidor": la señal es lo último.

**C14. Auto-desactivación por convención de mensaje de commit.** El
comportamiento "este validador no aplica a este PR" se codifica en el
subject del primer commit de la rama, no en archivos de configuración
externos. Ejemplo: `check_test_immutability.sh` solo aplica cuando el
primer commit es `test(EXX-NNN): scaffold red tests`; cualquier otro
subject (incluyendo `chore(EXX-NNN): initialize branch for #N` para
Issues sin tests) auto-desactiva el check. Esta convención evita
flags externos que pueden desincronizarse.

**C15. Tests sobre las herramientas del kit.** Toda herramienta del
kit que decida el destino de un PR debe tener su propia suite de
tests que corra en CI (ver §8.7).

**C16. Cero divergencia entre fuente de verdad y artefacto
materializado.** Lo que el humano lee en GitHub UI (el body del
Issue, el contenido de un N2 `.md`) es bit-a-bit lo que la máquina
materializa al ejecutar (los archivos del scaffold en disco, los
Issues que el script bash sube). Las herramientas del kit son
parsers, no transformadores creativos.

**C17. PAT del arquitecto como firma de procedencia.** Los workflows
operan con un PAT del arquitecto (`JULES_PAT` en el primer proyecto,
nombre genérico `OPERATOR_PAT` o equivalente). Este PAT tiene
propósito doble: (a) permisos elevados sobre `GITHUB_TOKEN` (crear
commits, abrir PRs, enviar menciones `@<agent>` que el ejecutor
honra), (b) **firma de procedencia**: cuando el ejecutor recibe una
acción firmada con este PAT, reconoce que viene del jefe y obedece.
Si la misma acción viniera con `GITHUB_TOKEN` genérico, podría
desconfiar. La elección no es puramente técnica.

---

## 11. Integración con el enjambre LLM

Esta sección describe los puntos de integración entre el kit y el
ecosistema de modelos de lenguaje. Las identidades concretas de los
modelos (Opus, Gemini, DeepSeek, etc.) se definen en el documento de
arquitectura del proyecto, no en el kit. Aquí se definen los **roles**.

### 11.1 Roles del enjambre

- **Arquitecto LLM (O)**: genera el N1, los N2 por bloque (par `.md`
  + script bash), los tests rojos pre-cargados en cada Issue del N2,
  los ADRs base. Audita la revisión de épica cuando el arquitecto
  humano lo invoca. Acceso manual (chat) en todos sus pasos.
- **Co-auditores de documentación inicial (D y G)**: auditan los N2
  generados en chat manual del arquitecto, usando
  `Prompt_Auditoria_Documentos_D_y_G.md`. La función adversarial
  (red-team) sobre tests está integrada en esta sesión. Familias
  distintas del arquitecto.
- **Ejecutor (G / Jules)**: implementa el código en respuesta a
  Issues, abre PRs contra `main`. Acceso vía integración nativa con
  GitHub. Familia que coincide con uno de los co-auditores de
  documentación (G es ejecutor y co-auditor de docs), pero no con el
  arquitecto (O) ni con el auditor de PR (D). **G no audita PR.**
- **Auditor de PR (D)**: revisa cada PR antes del merge. Vía API.
  Familia distinta del ejecutor. Ver
  `DeepSeek_Auditor_Integration_v1_2.md`.
- **Revisor de épica (O, y opcionalmente D)**: auditoría profunda
  post-épica cuando el arquitecto la invoca. O recibe `.zip`; D
  recibe `.md` concatenado equivalente. El arquitecto puede comparar
  ambas auditorías.
- **QA humano (Usuario bruto, opcional)**: rol reservado para una
  persona no técnica que valida los programas desde la perspectiva
  del cliente, post-merge. Su flujo se detalla cuando se incorpore.
  No es parte del ciclo automatizado.

### 11.2 Conmutación de roles entre artefactos

Una misma familia (e incluso un mismo modelo) puede ocupar roles
distintos sobre **artefactos distintos**, siempre que no audite su
propio trabajo. Ejemplos válidos:

- G como ejecutor de código + G como co-auditor de documentación
  (artefactos distintos: el código que escribe vs los documentos que
  audita).
- D como auditor de PR + D como co-auditor de documentación + D como
  revisor opcional de épica (todos sobre artefactos distintos del
  mismo proyecto).

Ejemplo inválido: G auditando un PR escrito por G. Por eso G no
audita PR.

Esta regla acepta como riesgo residual conocido que dos roles
distintos de la misma familia compartan sesgos de alignment y blind
spots de razonamiento. La mitigación es la auditoría dual manual D+G
en documentación inicial (familias distintas) y la revisión de épica
con O y opcionalmente D.

### 11.3 Reglas de la auditoría LLM

- **Veredicto estructurado, no review libre.** Cada auditor responde
  un checklist fijo con respuestas binarias o categóricas. El review
  libre se llena de "se ve bien" cosmético y no es accionable.
- **Reevaluación post-corrección no anula críticas previas.** Cuando
  un auditor LLM se corrige tras feedback (factual o de contexto), sus
  críticas técnicas independientes del error corregido permanecen
  válidas. El prompt del auditor debe forzar este principio
  explícitamente.
- **Cache de prefijos cuando aplique.** System prompts, ADRs base y
  documentos de arquitectura cambian poco. Las APIs que ofrecen cache
  de prefijos (con descuentos del 90% o más) deben usarse para reducir
  el costo efectivo de auditoría por orden de magnitud.
- **Presupuesto explícito por Issue.** El auditor opera contra un tope
  de tokens declarado. Excederlo es señal de patología (Issue
  demasiado grande, scope mal definido, o auditor en bucle).
- **Razonable, no perfecto.** Cada prompt de auditor codifica
  explícitamente la consigna: aprobar lo defendible, comentar las
  dudas, bloquear solo en categorías graves.

**Nota operacional (recurso del arquitecto humano).** En la práctica,
anteceder cada sesión de diseño con O con una frase como *"Vamos con
el Bloque N. Te informo que será auditado, así que haz tu mejor
esfuerzo."* mejora la calidad observable del output: el LLM produce
tests más robustos y N2 más completos cuando sabe que su trabajo será
revisado por otros LLMs y por el arquitecto humano. No es
solicitación; es un recordatorio que activa cuidado adicional. Va
acá como nota honesta sobre cómo se opera en la realidad, no como
regla mecánica.

### 11.4 Sandbox del ejecutor

El ejecutor opera dentro de su propio entorno (típicamente una VM o
contenedor controlado por su proveedor). Esto le da control total
sobre la ejecución local, lo que es una virtud para la productividad y
un riesgo para la integridad de los gates. Las defensas mecánicas
contra un ejecutor que intente optimizar la recompensa por encima de
la calidad:

- **CI corre contra checkout limpio desde Git**, no contra el
  filesystem del ejecutor. Cualquier modificación local del ejecutor
  no committeada es inocua.
- **Guards basados en diff contra la rama base**, no en contenido del
  archivo en el momento del commit. Esto detecta modificaciones a
  archivos inmutables aunque el ejecutor intente revertirlas
  parcialmente.
- **Blob SHA per-archivo** del scaffold de tests pre-cargados,
  verificado en cada PR. Discrepancia detiene la corrida.
- **Permisos de filesystem read-only** sobre directorios de scaffold
  cuando la plataforma del ejecutor lo permita. Defensa en
  profundidad. (En Jules no es garantía; los blob SHAs sí.)

### 11.5 Acciones manuales del arquitecto

El kit reconoce explícitamente que ciertas acciones son humanas, no
automatizables hoy. Documentarlas reduce fricción cognitiva:

- **Pausar al ejecutor**: vía botón en el sitio web del proveedor del
  ejecutor (no vía label de GitHub).
- **Aprobar documentación inicial**: aplicar `architect-approved` a
  mano sobre N1, N2 (par `.md` + script), ADRs base tras la
  auditoría manual con D+G.
- **Subir documentación inicial al repo**: push manual a `main` por el
  arquitecto.
- **Ejecutar el script bash** de creación de Issues hijos del bloque
  aprobado.
- **Crear el `.zip`** (para O) o el `.md` concatenado (para D) para
  revisión de épica, vía script de `tools/`.
- **Comparar las dos auditorías** (O y D) si invocó a ambas en la
  revisión de épica.
- **Añadir Issue de corrección** a épicas anteriores cuando aplique
  (las épicas no se cierran).
- **Aplicar `architect-approved`** manualmente cuando un PR de
  arquitecto modifique el scaffold de tests (Vía 1 de §9.5 del
  documento de DeepSeek).
- **Crear, ejecutar, fusionar Issues a mano** en casos raros (Issue
  legacy, decisión puntual del arquitecto). En estos casos el flujo
  automatizado no aplica; el arquitecto opera como ejecutor humano.

### 11.6 Modelo de tests rojos pre-cargados

Este modelo es la materialización de P8 (inmutabilidad de los
contratos por el ejecutor) y de C16 (cero divergencia entre fuente de
verdad y artefacto). Sustituye al modelo de v1.1 basado en directorio
`tests/contract/<epic>/` + manifiesto de hashes per-épica.

**Concepto.** Cada Issue del backlog contiene en su body una sección
`### Tests rojos pre-cargados` con bloques de código fenced que
declaran lenguaje y ruta de destino. Esta sección es la **fuente de
verdad** de los tests del Issue. El workflow
`prepare-issue-branch.yml` parsea esta sección y materializa los
archivos en disco como **primer commit de la rama del Issue**
(subject: `test(EXX-NNN): scaffold red tests`).

**Inmutabilidad.** El check `check_test_immutability.sh` (en el job
governance del orquestador) verifica blob SHA per-archivo del commit
scaffold contra HEAD del PR. Modificar, eliminar o renombrar archivos
del scaffold falla el check. **El ejecutor puede**:

- Agregar tests adicionales en archivos nuevos (no parte del scaffold).
- Modificar cualquier archivo fuera del scaffold (código de
  producción, otros tests preexistentes en `main`).

**El ejecutor no puede modificar archivos del scaffold.** Si los
tests están mal especificados, ver §9.5 del documento de DeepSeek
para las dos vías legítimas de modificación.

**Auto-desactivación.** Si el primer commit de la rama no es scaffold
(subject distinto al regex), el check pasa con exit 0. Esto cubre:

- Issues sin tests pre-cargados (docs, chore puro). El workflow crea
  la rama con commit vacío `chore(EXX-NNN): initialize branch for #N`.
- Ramas creadas a mano por el arquitecto fuera del flujo automatizado.
- Issues legacy creados antes de adoptar el modelo.

**Sin manifiestos.** No hay archivos de hash que mantener
sincronizados. La inmutabilidad vive en la historia de git mismo
(blob SHA del commit scaffold).

Ver `DeepSeek_Auditor_Integration_v1_2.md §9` para mecánica completa
del check.

---

## 12. Lo que NO está en el kit base

Para mantener la separación entre estructura y plataforma, las
siguientes categorías se excluyen explícitamente del kit base. Cada
kit derivado las añade:

- **Manifiestos del stack** (pyproject.toml, pubspec.yaml,
  package.json, Cargo.toml, go.mod, etc.).
- **Herramientas de lint y formato** específicas.
- **Verificadores de tipos** específicos.
- **Frameworks de tests** específicos.
- **Reglas de arquitectura por capas** específicas.
- **Dockerfiles, docker-compose, manifiestos de Kubernetes,
  configuración de Terraform.**
- **Schemas de base de datos, migraciones, ORMs.**
- **Estrategias de autenticación, configuración de secrets en
  runtime.**
- **Pipelines de release.**

---

## 13. Adaptación a plataforma

Un kit por plataforma se deriva de este documento añadiendo,
exclusivamente:

1. **Manifiestos del stack** con versiones pineadas al momento del
   bootstrap del kit.
2. **Scripts de validación específicos** (light y full) que ejecuten
   las herramientas concretas del stack pero respeten la interfaz
   canónica (los nombres de los scripts, sus argumentos, sus códigos
   de salida).
3. **El workflow CI** del stack, que se reduce a invocar el script
   completo (cumpliendo P2 mecánicamente).
4. **AGENTS.md específico del stack** con prohibiciones y convenciones
   propias del lenguaje y los scopes Conventional Commits enumerados.
5. **Documentación de adaptación**: una sección en el README del kit
   derivado que explica qué se debe podar al adaptar el kit a un
   proyecto concreto (porque el kit derivado suele incluir más
   herramientas de las que un proyecto típico necesita; ver §14).

Lo que un kit por plataforma **no puede hacer**:

- Renombrar workflows del orquestador.
- Modificar el conjunto de labels canónicas (puede añadir, no quitar
  ni renombrar).
- Saltarse gates del §7.
- Mover archivos canónicos del §8 a otras ubicaciones sin documentar
  la traducción.
- Reducir el alcance de las convenciones inviolables del §10.

---

## 14. Filosofía de sobre-equipamiento adaptativo

Los kits derivados pueden (y suelen) ser deliberadamente más completos
que lo que un proyecto típico necesita. La razón es asimétrica:

- **Añadir herramientas más tarde** requiere decisiones de diseño,
  PRs, justificaciones, y suele postergarse hasta que el problema
  duele.
- **Quitar herramientas al adaptar** es trivial: el LLM que adapta el
  kit al proyecto real revisa el caso, identifica lo que no aplica, y
  hace un commit de bootstrap inicial podando lo innecesario.

Cada kit derivado debe incluir, en su AGENTS.md, una sección titulada
"Para la LLM que adapta este kit a un proyecto nuevo" con una lista
explícita de decisiones que el adaptador debe tomar antes de la
primera tarea de producto. Esto evita el doble extremo del "lienzo en
blanco" (decidir todo desde cero) y del "monolito rígido" (cargar con
herramientas innecesarias para siempre).

---

## 15. Mantenimiento y evolución del kit

### 15.1 Versionado

El kit base sigue SemVer. Los kits derivados versionan
independientemente pero declaran explícitamente la versión del kit
base de la que derivan.

### 15.2 Política de breaking changes

Un cambio en el kit base que requiera modificación de los kits
derivados se considera breaking change y exige bump de major.

Cambios aditivos (nuevas labels opcionales, nuevos workflows
opcionales, nuevas convenciones recomendadas pero no obligatorias) son
minor.

**Nota sobre v1.2**: estrictamente, algunos cambios listados en §0
calificarían como breaking (renombre de label, eliminación de
directorios canónicos, reemplazo del modelo de inmutabilidad). Se
mantiene en v1.2 (no v2.0) porque no existen aún kits derivados
completos que el bump pueda romper, y los proyectos en operación
migran fácil (buscar y reemplazar la label, eliminar el directorio de
hashes, adoptar el nuevo workflow). Si emerge un segundo kit derivado
a partir de aquí, el próximo cambio estructural sí ameritará major
bump.

### 15.3 Actualización en proyectos existentes

Al actualizar el kit en un proyecto vivo:

1. Reemplazar los workflows base.
2. **No** reemplazar el workflow CI específico de stack (es del
   proyecto).
3. Comparar el manifiesto de labels contra el actual; labels nuevas
   son aditivas, labels removidas o renombradas requieren migración.
4. Re-ejecutar el script de bootstrap de labels.
5. Para el cambio v1.1 → v1.2 específicamente:
   - Buscar y reemplazar `requires-architect-review` →
     `requires-human-review` en todo el repo.
   - Eliminar `docs/orchestrator/contract-hashes/` si existía.
   - Adoptar `prepare-issue-branch.yml` y
     `check_test_immutability.sh` para los Issues nuevos; los
     anteriores ya cerrados no requieren retrofit.
   - Actualizar el AGENTS.md del proyecto con la regla nueva sobre
     rama declarada en el Issue.
6. Revisar el CHANGELOG del kit para identificar otros breaking
   changes.

### 15.4 Quién mantiene el kit

El kit base es responsabilidad del arquitecto del enjambre, no de
ningún proyecto individual. Los hallazgos de un proyecto que ameriten
cambios al kit se proponen como issues contra el repositorio del kit
base, no se hackean en el proyecto y luego se "olvidan" propagar.

---

## 16. Riesgos residuales aceptados

El kit no pretende resolver todos los problemas posibles. Los
siguientes riesgos son conocidos y se aceptan conscientemente:

**R1. Sustrato compartido entre ejecutor y co-auditor de la misma
familia.** Mitigación: auditoría dual manual D+G en documentación
inicial (familias distintas), y revisión de épica con O (y
opcionalmente D) en chat cuando el arquitecto la invoque. **G no
audita PR** para no auditar su propio código. Telemetría debe
detectar si el riesgo se materializa en patrones consistentes.

**R2. Imposibilidad de garantizar mediante código que un agente LLM
nunca razone fuera de su scope.** Mitigación: gates mecánicos (path
protection, inmutabilidad de scaffold, presupuesto de tamaño de PR)
acotan el daño potencial. El kit es membrana, no jaula.

**R3. Costo de tokens variable por la naturaleza no determinista de
los modelos.** Mitigación: telemetría por Issue, presupuesto explícito
por auditor, y revisión cuando el patrón observado supere el rango
habitual.

**R4. Auditor LLM que se sobre-corrige tras feedback.** Mitigación:
prompt estructurado que fuerza distinguir críticas técnicas
independientes del contexto factual; auditoría dual manual en
documentación inicial para que un sobre-corregido no determine el
veredicto.

**R5. Drift entre el kit base y los kits derivados.** Mitigación:
versionado explícito, política de breaking changes, auditoría
periódica del conjunto de kits derivados contra el kit base.

**R6. Falsos negativos del auditor LLM (PRs malos que pasan).**
Mitigación: G5 (CODEOWNERS) como red humana, G8 (revisión de épica
con O y opcionalmente D) como recolección de casos, y telemetría para
entrenar mejores prompts del auditor sobre los falsos negativos
detectados.

**R7. Falsos positivos del auditor LLM (PRs buenos rechazados).**
Mitigación: telemetría explícita de tasa de falsos positivos; ajuste
del prompt si supera umbral; escalación a humano si el ejecutor no
puede resolver tras N intentos.

**R8. Acciones manuales que el arquitecto olvida.** Mitigación: §11.5
lista explícita; con el tiempo, automatizar las que tengan API
disponible.

**R9. Tests pre-cargados mal especificados por O.** El diseñador LLM
podría escribir tests que pasen trivialmente o que validen algo
distinto al requisito en prosa. Mitigación: auditoría manual D+G del
N2 (par `.md` + script) antes de subir Issues; el supervisor revisa
los tests propuestos contra los criterios de aceptación. Si el N2 ya
está validado por tres LLMs distintos (O lo crea, D y G lo auditan)
el riesgo es bajo pero no nulo; cuando se materializa, suele
detectarse en la revisión de épica con O.

---

## 17. Resumen ejecutivo

Un starter_kit es una infraestructura de control, no una plantilla. Su
trabajo es materializar mecánicamente las decisiones arquitectónicas y
los principios de SoD del enjambre LLM, de manera que las garantías de
calidad no dependan de que humanos o agentes recuerden seguirlas.

El kit base v1.2, agnóstico de plataforma, define:

- Una **topología de workflows** con punto de entrada único, gate de
  convergencia único, y validadores enchufables. Incluye
  `prepare-issue-branch.yml` que materializa los tests rojos
  pre-cargados como primer commit de la rama del Issue.
- Un **vocabulario de labels** con semántica activa que los workflows
  leen y escriben. Las labels de prioridad son decorativas (asignador
  FIFO). `requires-human-review` reemplaza a
  `requires-architect-review`.
- Ocho **gates de calidad** inviolables. G4 cambió de hash per-épica
  a blob SHA per-archivo del commit scaffold.
- Diecisiete **convenciones inviolables**, incluyendo: el ejecutor
  nunca edita el Issue (C12), la última operación es la señal (C13),
  auto-desactivación por convención de mensaje de commit (C14), tests
  sobre las herramientas del kit (C15), cero divergencia entre
  fuente de verdad y artefacto (C16), PAT del arquitecto como firma
  de procedencia (C17).
- Una **integración con el enjambre LLM** organizada por roles
  (arquitecto, co-auditores en chat manual, ejecutor, auditor de PR,
  revisor opcional de épica), con frontera explícita entre Diseño
  (manual en chat) y Ejecución (automatizado en GitHub Actions). **G
  no audita PR.**
- Un **modelo de tests rojos pre-cargados** donde la fuente de verdad
  es el body del Issue, materializada por workflow, verificada por
  blob SHA per-archivo. Reemplaza el modelo de manifiesto de hashes
  per-épica de v1.1.
- **Defensas mecánicas** contra los modos de fallo conocidos del
  ejecutor.
- **Patrones operacionales** rescatados del primer proyecto en
  operación real: mensajes-instrucción embebidos en errores de CI,
  complejidad declarada como gate, lista exhaustiva de paths
  protegidos (Apéndice A), `--only` y `--continue` en scripts,
  bootstrap y codegen explícitos, `project_manifest.json` canónico,
  un script por bloque, DoD como checkboxes editables, tests sobre
  las herramientas del kit.
- Una **filosofía de sobre-equipamiento adaptativo** que delega al LLM
  adaptador la poda de herramientas innecesarias.

Lo que el kit deja a cada plataforma: manifiestos, herramientas
concretas, configuración de tests por framework, infraestructura de
despliegue.

Este documento es el contrato. Las versiones específicas por
plataforma derivan de él. Cualquier ambigüedad se resuelve contra este
documento, no contra los kits derivados.

---

## Apéndice A — Lista de referencia de `PROTECTED_PATTERNS` multi-stack

Esta lista de patrones de path se usa en el workflow de etiquetado de
PR (`pr-labels.yml` o equivalente) para detectar automáticamente PRs
que tocan zonas sensibles y aplicarles `requires-human-review`.

Es **lista de referencia**: cada kit derivado conserva los patrones
relevantes a su stack y elimina los demás (o los marca como
comentario). La regla "añadir patrones es fácil; eliminarlos requiere
justificación" se aplica.

```regex
# --- Infraestructura del kit ---
^\.github/
^tools/ci/
^lefthook\.yml$
^\.pre-commit-config\.yaml$

# --- Manifiestos de stack (mantener los relevantes) ---
^pyproject\.toml$
^uv\.lock$
^requirements.*\.txt$
^pubspec\.yaml$
^pubspec\.lock$
^melos\.yaml$
^analysis_options\.yaml$
^package\.json$
^pnpm-lock\.yaml$
^yarn\.lock$
^package-lock\.json$
^Cargo\.toml$
^Cargo\.lock$
^go\.mod$
^go\.sum$

# --- Infraestructura y deployment ---
^Dockerfile.*$
^docker-compose
^infra/
^terraform/
^k8s/
^helm/

# --- Base de datos y migraciones ---
^alembic/versions/
^prisma/schema\.prisma$
^db/migrations/

# --- Reglas de seguridad de servicios cloud ---
^firestore\.rules$
^storage\.rules$

# --- Contratos arquitectónicos del proyecto ---
^docs/adr/
^docs/backlog/
```

**Notas de uso**:

- Para añadir o eliminar patrones, editar la lista en el workflow real
  del proyecto (`pr-labels.yml`). Esta lista vive aquí como
  referencia, no como configuración activa.
- El conjunto debe mantenerse **alineado con `.github/CODEOWNERS`**:
  todo path en CODEOWNERS debería estar reflejado aquí, y viceversa.
- Para stacks específicos (Flutter monorepo con Melos, Node monorepo
  con pnpm, Python monorepo con uv), añadir las rutas de manifiestos
  internos (`apps/*/pubspec.yaml`, `packages/*/package.json`, etc.).

---

## Apéndice B — Patrones operacionales destacables

Patrones observados en el primer proyecto real del enjambre que valen
la pena ser nombrados explícitamente y que no caben en otras
secciones:

**B1. Concurrencia diferenciada por workflow.** El orquestador del PR
cancela superseded runs del mismo PR (`cancel-in-progress: true`); el
workflow de auto-merge **nunca** cancela in-flight
(`cancel-in-progress: false`). Cancelar un merge en vuelo deja el
sistema en estado inconsistente; cancelar un orquestador no.

**B2. `sleep` deliberado antes de buscar siguiente Issue.** Tras
mergear un PR, GitHub puede no haber indexado el cierre del Issue
asociado todavía cuando preguntas por Issues abiertos. Un `sleep 10`
antes del `gh issue list` reduce drásticamente los race conditions
observados. Es "wait for eventual consistency".

**B3. Fallback en cascada para detectar Issue cerrado por un PR.**
Estrategia 1: parse `Closes/Fixes/Resolves #N` del body del PR.
Estrategia 2 (fallback): último Issue con label de ejecutor cerrado
recientemente. Estrategia 3 (warning): no se pudo determinar; pasa al
asignador FIFO sin Issue específico.

**B4. Idempotencia de comentarios via marca HTML.** Cuando un
workflow comenta al PR (auditor LLM, recordatorios), usa marca HTML
identificable (`<!-- workflow-id-comment -->`). En cada ejecución,
busca el comentario por marca y lo actualiza si existe; lo crea si
no. Evita acumulación de comentarios en PRs con muchas iteraciones.

**B5. Workflow de preparación de rama via PAT, no `GITHUB_TOKEN`.**
El push de la rama del workflow `prepare-issue-branch.yml` necesita
disparar workflows downstream cuando el ejecutor abra PR. El
`GITHUB_TOKEN` por defecto **no dispara workflows desde sus propios
pushes**; un PAT sí. Combinado con C17, el PAT del arquitecto
resuelve esto.

**B6. Cero comentarios redundantes al Issue.** Si el body del Issue
ya declara la rama imperativamente (`## 🌿 Rama asignada: ...`), el
workflow no debe comentar al Issue "tu rama está lista". Es
redundante para el ejecutor. La señal operacional para el supervisor
queda en el log de Actions; el ejecutor lee el body.

**B7. Helpers de CI con fallback inline.** Los scripts `light.sh` y
`full.sh` cargan `lib/_common.sh` si existe, y si no, definen las
mismas funciones localmente. Esto permite ejecutar el script en
aislamiento (debugging, copia-pega a otro repo) sin dependencias
implícitas.

**B8. Bootstrap y codegen como pasos previos del CI.** El CI corre
contra checkout limpio. Si el stack tiene código generado
(`build_runner`, Prisma generate, gRPC stubs), el script completo
ejecuta primero el bootstrap y luego el codegen antes de
format/analyze/test. **Nunca asumir que el código generado está
commiteado.** Si el proyecto commite el código generado por
conveniencia, el CI igual lo regenera y compara (otro modo de detectar
drift).
