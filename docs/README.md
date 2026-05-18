---
published: false
---

# Paquete v1.6 — Documentos del Enjambre de LLMs

> Versión consolidada de los documentos de arquitectura tras dos
> rondas de aprendizaje operacional: (a) análisis del primer proyecto
> real en operación; (b) integración del modelo de tests rojos
> pre-cargados validado.
>
> **Fecha:** 18 de mayo de 2026

---

## Qué contiene el paquete

| Archivo | Versión | Cambio desde versión anterior |
|---|---|---|
| `Proyecto_de_Proyectos_v1_6.md` | 1.6 | Sí, diez cambios principales (ver §0 del doc) |
| `General_Starter_Kit_v1_2.md` | 1.2 | Sí, cambios estructurales mayores: tests pre-cargados + patrones operacionales del proyecto real |
| `DeepSeek_Auditor_Integration_v1_2.md` | 1.2 | Sí, §9 reescrita completa (de hash determinístico a blob SHA per-archivo) |
| `Prompt_Revision_de_Epica_con_O.md` | 1.1 | Menor: input alternativo `.md` para D, checklist por par N2 |
| `Prompt_Auditoria_Documentos_D_y_G.md` | 1.1 | Menor: nota sobre auditoría del par N2 (`.md` + script) |

Los cinco archivos son consistentes entre sí en versiones y
referencias cruzadas.

---

## Resumen de cambios v1.5 → v1.6

Dos fuentes de aprendizaje integradas:

### A. Patrones rescatados del primer proyecto real

- Mensajes-instrucción al agente embebidos en errores de CI (cada
  error recuperable trae la receta exacta de recuperación).
- Auto-aplicación de `requires-human-review` por complejidad declarada
  en el formulario.
- Lista exhaustiva de `PROTECTED_PATTERNS` multi-stack como apéndice
  del Starter Kit (Python, Node, Dart, Rust, Go, Docker, Terraform,
  k8s, Alembic, Prisma, Firestore).
- "Nunca re-aplicar `auto-merge` en sync" (respetar decisiones humanas
  previas).
- `skip_validators` como input del orquestador.
- Concurrencia diferenciada: orquestador cancela superseded; auto-merge
  nunca cancela in-flight.
- Flags `--only=<scope>` y `--continue` en scripts CI.
- Helpers de CI con fallback inline (`lib/_common.sh` opcional).
- Bootstrap y codegen como pasos previos del CI.
- `sleep` antes de buscar siguiente Issue (eventual consistency de
  GitHub).
- **PAT del arquitecto como "marca de procedencia"**, no solo
  permisos elevados.
- Fallback en cascada para detectar Issue cerrado por un PR.
- `project_manifest.json` y `branch_protections_rules.sh` como
  artefactos canónicos.
- Un script de creación de Issues por bloque, no monolítico.
- DoD como checkboxes editables, campo "Rutas afectadas", campo
  "Comandos extra de validación" en el formulario.
- `Issue link required` y CHANGELOG validation como gates de
  governance.
- **Tests sobre las herramientas del kit** como regla, no
  recomendación.

### B. Modelo de tests rojos pre-cargados

- Tests pre-cargados en el body del Issue como fuente de verdad.
- Workflow `prepare-issue-branch.yml` los materializa como primer
  commit de la rama (`test(EXX-NNN): scaffold red tests`).
- Check `check_test_immutability.sh` verifica blob SHA per-archivo en
  cada PR; pasa el job governance.
- Auto-desactivación del check cuando el primer commit no es scaffold
  (Issues sin tests, ramas legacy o creadas a mano).
- Reemplaza al modelo de v1.5 basado en `tests/contract/<epic>/` +
  manifiesto de hashes per-épica.
- N2 como par `.md` (fuente de verdad) + script bash (consecuencia),
  ambos auditados por D+G en chat.
- **El ejecutor nunca edita el Issue.** La etiqueta del ejecutor
  nunca se retira.
- El workflow no comenta el Issue (el body imperativo ya da las
  instrucciones; audit trail en log de Actions).

### Otros cambios derivados

- Label `requires-architect-review` → `requires-human-review` en todo.
- **G no audita PR** (clarificación de roles).
- Revisor de épica: O obligatorio cuando se invoca modo 2, D opcional
  con `.md` concatenado.
- Recurso operacional documentado: anteceder sesiones de diseño con
  *"Vamos con el Bloque N. Te informo que será auditado, así que haz
  tu mejor esfuerzo"* mejora la calidad observable del output.
- PR size budget default subido de 400 a 2000 líneas (alineado con
  realidad operacional, override con `size-override`).
- Eliminaciones: `tests/contract/<epic>/` como prescripción rígida,
  `docs/orchestrator/contract-hashes/`, cálculo portable de hash
  (innecesario con blob SHA), comentario del workflow al Issue.

---

## Orden de lectura sugerido

Si revisas todo el paquete:

1. **`Proyecto_de_Proyectos_v1_6.md`** primero — es el documento
   paraguas. Su §0 lista los cambios desde v1.5.
2. **`General_Starter_Kit_v1_2.md`** — la especificación técnica del
   kit. Su §0 lista cambios estructurales + patrones del proyecto
   real. Apéndice A con `PROTECTED_PATTERNS`. Apéndice B con patrones
   operacionales destacables.
3. **`DeepSeek_Auditor_Integration_v1_2.md`** — solo si te interesa
   la implementación. §9 reescrita explica el modelo de inmutabilidad
   nuevo.
4. **`Prompt_Revision_de_Epica_con_O.md`** — el prompt para chat con
   O (y opcionalmente D). Cambio menor: input alternativo `.md`.
5. **`Prompt_Auditoria_Documentos_D_y_G.md`** — cambio menor: nota
   sobre auditoría del par N2.

---

## Uso de los dos prompts

| Prompt | Cuándo se usa | Con quién | Modalidad |
|---|---|---|---|
| `Prompt_Auditoria_Documentos_D_y_G.md` | Auditar el par N2 (`.md` + script) antes de crear Issues | D y G | Chat manual |
| `Prompt_Revision_de_Epica_con_O.md` | Revisar el estado de una épica con `.zip` (O) o `.md` concatenado (D) | O obligatorio, D opcional | Chat manual |

Ambos se usan en chat, no como workflows. El prompt del auditor de
PR (que sí es workflow) vive en
`tools/auditor-prompts/pr-auditor-system.md` dentro de cada
repositorio, no en este paquete.

---

## Notas finales

- Cada documento del paquete tiene en su §0 el changelog completo
  desde la versión anterior. Si solo quieres ver qué cambió, esos
  `§0` son la entrada eficiente.
- Las referencias cruzadas entre documentos están actualizadas a las
  versiones nuevas (ej: el Proyecto v1.6 referencia al Starter Kit
  v1.2).
- Cualquier ambigüedad se resuelve contra el documento más
  específico: para el orquestador y workflows,
  `General_Starter_Kit_v1_2.md`; para el modelo de inmutabilidad de
  tests, `DeepSeek_Auditor_Integration_v1_2.md §9`; para el flujo
  end-to-end y filosofía, `Proyecto_de_Proyectos_v1_6.md`.
- Lo no documentado aquí (calibración de prompts, métricas exactas,
  kits por plataforma) se materializa operando, no especificando.

---

## Migración desde v1.5

Si tienes un proyecto en operación con v1.5 (o un subconjunto), los
pasos accionables de migración están en `Proyecto_de_Proyectos_v1_6.md §12`.
En síntesis:

1. Renombrar la label `requires-architect-review` → `requires-human-review`.
2. Eliminar `docs/orchestrator/contract-hashes/` si existe.
3. Integrar los archivos del paquete de tests rojos pre-cargados:
   `.github/scripts/prepare_issue_branch.py`,
   `.github/workflows/prepare-issue-branch.yml`,
   `tools/ci/check_test_immutability.sh`.
4. Patch a `jules-auto-flow.yml` para invocar `prepare-issue-branch.yml`
   como job final.
5. Patch a `governance.yml` para incluir `Test scaffold immutability`,
   `Issue link required`, y `CHANGELOG validated` como steps.
6. Rehabilitar el health-check de `main` si está comentado.
7. Agregar tests propios a `tools/changelog.py` y al nuevo
   `check_test_immutability.sh`.

Para Issues legacy (creados antes del cambio): no requieren retrofit.
El check de inmutabilidad se auto-desactiva cuando el primer commit
de la rama no es un scaffold.
