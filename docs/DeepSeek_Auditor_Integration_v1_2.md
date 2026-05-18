# DeepSeek Auditor Integration — v1.2

> Especificación técnica de integración de DeepSeek (**D**) como
> auditor de PR en el enjambre LLM del Proyecto de Proyectos.
> Complementa al `General_Starter_Kit_v1_2.md` con las decisiones
> operacionales específicas de la API de DeepSeek y el workflow de
> GitHub Actions que la invoca.
>
> **Versión:** 1.2 · **Fecha:** 18 de mayo de 2026
> **Reemplaza:** v1.1 (cambia §9 completa: el modelo de inmutabilidad
> pasa de hash determinístico per-épica a blob SHA per-archivo del
> commit scaffold de tests pre-cargados)
> **Documentos hermanos:** `General_Starter_Kit_v1_2.md`,
> `Proyecto_de_Proyectos_v1_6.md`,
> `Prompt_Auditoria_Documentos_D_y_G.md`,
> `Prompt_Revision_de_Epica_con_O.md`
> **Audiencia:** la LLM (o el humano) que implementa el workflow real
> del kit.

---

## 0. Cambios desde v1.1

**Reemplazo del modelo de inmutabilidad de tests.** La v1.1
prescribía hash determinístico per-épica calculado con `shasum -a 256`
sobre los archivos de `tests/contract/<epic>/`, registrado en
`docs/orchestrator/contract-hashes/epic-NNN.txt`. Operacionalmente fue
más fricción que beneficio: mantener manifiestos de hashes
sincronizados con cambios legítimos era complicado y los tests
ubicados fuera del árbol natural del código eran menos descubribles.

El v1.2 adopta el modelo de **tests rojos pre-cargados** validado en
operación real:

- Los tests viven junto al código que validan (ruta natural del
  proyecto, no en un directorio especial).
- La fuente de verdad es el body del Issue, sección
  `### Tests rojos pre-cargados`.
- Un workflow (`prepare-issue-branch.yml`) materializa los tests como
  primer commit de la rama del Issue (subject:
  `test(EXX-NNN): scaffold red tests`).
- La inmutabilidad se verifica con **blob SHA per-archivo** comparando
  el commit scaffold contra HEAD del PR.
- El check se auto-desactiva cuando el primer commit de la rama no es
  un scaffold (Issues sin tests, ramas creadas a mano).

Otros cambios:

1. **Convención de ubicación de tests eliminada como prescripción del
   kit.** Cada proyecto decide dónde viven sus tests; el scaffold
   declara las rutas explícitamente. La inmutabilidad ya no depende
   de un directorio canónico.
2. **Manifiesto de hashes per-épica eliminado.** No hay archivos
   `epic-NNN.txt` que mantener; los blob SHAs viven en git mismo.
3. **§9 reescrita completa.** El resto del documento (cliente API,
   prefix caching, streaming, telemetría, parámetros canónicos, rate
   limiting, workflow `audit-pr.yml`) no cambia respecto a v1.1.

---

## 1. Propósito

Este documento define **cómo** se llama a D desde el workflow
`audit-pr.yml`, no **qué** decisiones audita (eso está en el v1.6).
Cubre el cliente API, las optimizaciones obligatorias, los parámetros,
y los mecanismos de inmutabilidad de tests pre-cargados.

Sin estas decisiones técnicas concretadas, el `audit/pass`, el
`audit/fail`, y el bloqueo por modificación del scaffold de tests
son aspiracionales. Con ellas, son enforceables.

---

## 2. Modelo y rol asignado

| Rol | Modelo canónico | Usado en |
|---|---|---|
| Auditor de PR | `deepseek-v4-flash` | Workflow `audit-pr.yml` |

**Restricción importante**: los aliases legacy `deepseek-chat` y
`deepseek-reasoner` se retiran el 24 de julio de 2026. El workflow del
kit debe usar el nombre canónico (`deepseek-v4-flash`) desde el día 1.
Un check de governance puede grep `deepseek-chat` o `deepseek-reasoner`
en workflows y fallar el CI.

**Importante sobre el rol de D**: D **solo** audita PR (vía API).
G (Gemini) que actúa como ejecutor (Jules) **NO** audita PR — codifica.
La co-auditoría de documentación inicial (D + G) ocurre en chat manual,
no en workflows. Ver §11 del Starter Kit v1.2.

---

## 3. Cliente API

### 3.1 Endpoint y autenticación

D expone una API OpenAI-compatible. No requiere SDK separado. Usar el
cliente oficial de OpenAI apuntando al endpoint de D es suficiente y
reduce dependencias.

- **Endpoint base**: `https://api.deepseek.com/v1`
- **Autenticación**: API key vía variable de entorno
  `DEEPSEEK_API_KEY` (o equivalente). Nunca hardcoded.
- **Secret en GitHub**: cada repositorio del portafolio declara
  `DEEPSEEK_API_KEY` en sus secrets de Actions. Política: una sola key
  compartida (no key por proyecto) para simplificar rotación.

### 3.2 Reutilización de cliente

Los scripts y workflows que hacen múltiples llamadas en la misma
sesión deben reutilizar la instancia del cliente HTTP. Crear una
sesión por llamada multiplica innecesariamente la latencia de conexión
y rompe el patrón de connection pooling esperado.

En contextos efímeros como steps de GitHub Actions, esta regla se
aplica dentro del step (no entre steps).

---

## 4. Prefix caching: la optimización crítica

D ofrece **descuento del 90-98% en cache hits** sobre el prefijo común
de los prompts. Esta es la diferencia entre que cada auditoría de PR
cueste ~$0.001 o ~$0.05. En un portafolio activo, esa diferencia
compone significativamente si no se aprovecha. No es opcional.

### 4.1 Qué se cachea (debe ser byte-idéntico entre llamadas)

- **System prompt** del auditor de PR (fijo).
- **AGENTS.md** del repositorio donde se hace la auditoría.
- **ADRs base** (los que no cambian entre PRs de la misma épica).
- **Schemas de tools** (si se usa tool calling).

### 4.2 Reglas inviolables del prefijo

El prefijo cacheado debe ser **byte-idéntico** entre llamadas.
Cualquier variación, por trivial que parezca, rompe el cache y
multiplica el costo por 50.

**Anti-patrones que rompen el cache**:

- Timestamps en system prompts (`"Auditoría iniciada: 2026-05-14..."`).
- IDs de sesión o de PR en el system prompt (deben ir en el user
  message, no en el system).
- JSON serializado sin `sort_keys` (el orden de claves no está
  garantizado).
- Concatenaciones con espacios o saltos de línea variables.
- Cambios cosméticos al system prompt durante calibración (cada cambio
  invalida todo el cache acumulado).

**Patrones correctos**:

- System prompt como string constante, versionado en el repo del kit
  (no construido dinámicamente).
- IDs y contexto variable en el user message.
- JSON serializado siempre con `sort_keys=True` o equivalente
  determinístico.
- Calibración de prompts en batches: si cambia el prompt, se acepta un
  período de cache miss y se documenta en ADR.

### 4.3 Qué NO rompe el cache

- Añadir nuevos turns de conversación (append-only).
- Cambiar entre streaming y non-streaming en distintas llamadas (mismo
  prefijo se cachea igual).
- Modificar el contenido del último mensaje user (lo único que no está
  en el prefijo).

### 4.4 Verificación del cache

D no expone directamente "cache hit" en la respuesta. La verificación
se hace inferencialmente: una llamada con prefijo nuevo a 5000 tokens
cuesta ~$0.001 (cache miss) la primera vez, ~$0.00005 (cache hit) las
siguientes. Si las llamadas repetidas mantienen costo alto, el cache
no está hitteando y algo en el prefijo varía.

**Métrica operacional**: relación entre `prompt_tokens` reportado y
costo esperado. Si en operación se observa cache miss rate >20%
sostenido, hay que auditar el código que construye los prompts.

### 4.5 TTL del cache

El cache de prefijos en D tiene TTL de minutos, no horas. En la
práctica, para una sesión de auditoría continua (varios PRs seguidos
en el mismo repo) el cache se mantiene. Si entre auditorías pasa mucho
tiempo, la primera llamada tras la pausa será cache miss.

Esto es aceptable en operación normal: la mayoría de proyectos tienen
ráfagas de PRs (J termina varios Issues seguidos) y luego pausas. La
primera del lote paga miss, las siguientes hit.

---

## 5. Streaming y telemetría

### 5.1 Recomendación

**Activar streaming en todas las llamadas a D**, con
`stream_options={"include_usage": True}`. Razones:

- Primer token llega en ~300ms vs ~800ms non-streaming.
- El último chunk contiene `usage` con `prompt_tokens`,
  `completion_tokens`, y `completion_tokens_details.reasoning_tokens`.
- **Streaming no rompe el cache** — el prefijo se cachea igual.
- Telemetría granular sin llamada extra a la API.

### 5.2 Estructura del último chunk

El chunk final del stream (cuando `chunk.choices` está vacío) contiene
el bloque `usage`:

- `prompt_tokens`: input total. Útil para inferir cache hit/miss.
- `completion_tokens`: output total.
- `completion_tokens_details.reasoning_tokens`: tokens gastados en
  thinking mode (cero si thinking no está activo).

### 5.3 Telemetría health signals

Tres métricas operacionales que el workflow extrae del `usage` y
publica en el comentario `[telemetry]` del PR:

- **`reasoning_ratio = reasoning_tokens / completion_tokens`**:
  - Para auditor de PR sin thinking: debe ser 0.
  - Si supera 0 sostenido en auditoría de PR, hay un bug: el modelo
    está usando thinking cuando no se le pidió. Investigar
    configuración.

- **`cache_hit_ratio` inferido**: si `prompt_tokens` reportado es
  consistentemente alto en costo, el cache no está hitteando. Si
  supera 20% miss rate sostenido, auditar la construcción de prompts.

- **`total_cost_per_audit`**: tope blando. Si excede el ceiling
  documentado, el workflow aplica `requires-human-review`
  automáticamente. Es señal de Issue mal definido o auditor en bucle.

### 5.4 Keep-alive del servidor

Bajo carga, D puede enviar líneas SSE como `: keep-alive` para
mantener la conexión. El cliente debe ignorarlas (no parsearlas como
contenido). El SDK oficial de OpenAI ya lo maneja.

---

## 6. Thinking mode

Para auditor de PR con V4 Flash, **thinking está desactivado**. Diffs
son acotados; thinking añade tokens sin valor proporcional.

V4 Flash no soporta thinking mode; este punto es informativo para
evitar configuraciones erróneas.

---

## 7. Parámetros canónicos

| Parámetro | Valor |
|---|---|
| `model` | `deepseek-v4-flash` |
| thinking | desactivado (no soportado por Flash) |
| `temperature` | `0.0` |
| `max_tokens` | `8000` |
| `stream` | `true` |
| `stream_options` | `{"include_usage": true}` |

`max_tokens` actúa como **ceiling de costo**: si el modelo se acerca
al tope, se trunca. El workflow detecta truncación
(`finish_reason == "length"`) y la marca como `audit/fail` con razón
"respuesta truncada, prompt o scope incorrecto".

---

## 8. Rate limiting y backoff

D no publica límites fijos. En operación con varios proyectos en
cartera, los códigos 429 pueden ocurrir bajo ráfagas (varios PRs
cerrando simultáneamente).

**Política de retry obligatoria**:

- Backoff exponencial: 2^attempt segundos.
- Jitter: ±20% aleatorio sobre el wait.
- Tope: 30 segundos por wait individual.
- Máximo 3 reintentos.
- Tras el tercer fallo, el workflow aplica `requires-human-review`
  al PR con razón "deepseek-rate-limit-exceeded" y sigue.

**Circuit breaker cross-workflow**: si en una ventana de 60 segundos
más del 30% de llamadas D fallan en cualquier workflow del portafolio,
se activa modo degradado: el orquestador deja de aplicar `audit/pass`
automáticamente y marca todos los PRs nuevos como
`requires-human-review`. Se resetea cuando una hora de operación
normal restaura el ratio.

---

## 9. Inmutabilidad de tests pre-cargados

### 9.1 Modelo conceptual

La fuente de verdad de los tests de un Issue es **el body del Issue**,
sección `### Tests rojos pre-cargados`. Esta sección contiene bloques
de código fenced con tag de lenguaje **y ruta de destino**:

````markdown
```dart:packages/core_kit/test/models/unit_of_measure_test.dart
import 'package:test/test.dart';
...
```
````

El workflow `prepare-issue-branch.yml` (ver §10 de este documento y
§5 del Starter Kit) parsea esta sección y materializa los archivos en
disco como **primer commit de la rama del Issue**, con subject:

```
test(EXX-NNN): scaffold red tests
```

Esos archivos son **inmutables para el ejecutor**: J puede agregar
tests adicionales en archivos nuevos, modificar cualquier archivo
fuera del scaffold (código de producción, otros tests preexistentes
en `main`), pero **no puede modificar, eliminar ni renombrar archivos
del scaffold**.

### 9.2 Verificación: blob SHA per-archivo

La inmutabilidad se verifica con git plumbing puro, no con la
aplicación. Esto es rápido, determinista, y no requiere compilar
nada.

El script `tools/ci/check_test_immutability.sh` corre en el job
governance del orquestador, en cada PR:

1. Calcula `merge-base` entre la rama del PR y `origin/main` (o la
   `base.ref` del PR si se pasa por variable de entorno `BASE_REF`).
2. Obtiene el primer commit de la rama tras el `merge-base`, siguiendo
   `--first-parent --reverse`.
3. Si el mensaje de ese commit **no matchea** el regex
   `^test\([eE][0-9]+-[0-9]+\): scaffold red tests$`, **se
   auto-desactiva** con un notice y exit 0. Esto cubre Issues sin
   tests pre-cargados (docs, chore puro, Issues legacy o creados a
   mano fuera del flujo).
4. Si matchea, lista los archivos que el commit tocó:
   ```
   git diff --name-only <SCAFFOLD_COMMIT>^ <SCAFFOLD_COMMIT>
   ```
5. Para cada archivo, compara blob SHA entre el árbol del
   `SCAFFOLD_COMMIT` y el árbol de `HEAD`:
   ```
   git ls-tree <SCAFFOLD_COMMIT> -- <FILE>  → SHA_scaffold
   git ls-tree HEAD -- <FILE>               → SHA_head
   ```
6. Si algún `SHA_head` está vacío (archivo eliminado), o difiere de
   `SHA_scaffold` (archivo modificado), el script falla con exit 1
   citando el archivo y la regla violada.

### 9.3 Por qué blob SHA y no hash de contenido

Git ya calcula el blob SHA de cada archivo committeado. Reusarlo
tiene ventajas:

- **Cero código nuevo de hashing.** La verificación es `git ls-tree`,
  trivial.
- **Portabilidad garantizada.** No depende de `shasum -a 256` ni
  `md5sum`; cualquier instalación de git lo provee idéntico en Linux,
  macOS, Windows.
- **Determinismo por construcción.** Dos archivos con contenido
  idéntico tienen el mismo blob SHA en cualquier máquina.
- **No hay manifiesto que mantener.** El hash vive en el objeto git,
  no en un archivo separado que pueda desincronizarse.

### 9.4 Auto-desactivación por convención de mensaje de commit

El comportamiento "este check no aplica a este PR" está codificado en
el subject del primer commit de la rama, no en un archivo de
configuración aparte. Si el subject es `chore(EXX-NNN): initialize
branch for #N` (commit vacío que el workflow crea cuando el Issue no
tiene tests pre-cargados), el check pasa con exit 0 y notice.

Esto es importante porque:

- No hay flag, label ni configuración que mantener en sincronía con la
  decisión "este Issue lleva tests o no".
- Issues legacy creados antes de adoptar el modelo pasan sin
  intervención: si el primer commit de su rama no es scaffold, el
  check no aplica.
- El supervisor humano que crea un Issue ad-hoc (sin pasar por el
  flujo del orquestador, ver §11.5 del v1.6) no necesita configurar
  nada: si no hay commit scaffold, no hay check.

### 9.5 Modificación legítima del scaffold

Hay dos vías legítimas para cambiar un test que ya fue scaffold:

**Vía 1 (recomendada): el arquitecto humano modifica el scaffold
directamente en un PR marcado `requires-human-review`.** El PR toca
los archivos del scaffold; el check de inmutabilidad falla; el
arquitecto añade `size-override` y `requires-human-review` (este
último suele aplicarse automáticamente por path-based protection si
los tests están en paths protegidos). El merge es manual del
arquitecto. Tras el merge, el hash inicial del scaffold deja de
importar: el nuevo contenido es la nueva referencia para PRs
posteriores que partan desde ese punto.

**Vía 2 (alternativa): cerrar el Issue mal especificado, crear uno
nuevo con el scaffold corregido.** El Issue malo queda cerrado con
label `jules` (la regla "la etiqueta `jules` nunca se retira"
sigue intacta), formando parte de la historia. El Issue nuevo entra
al flujo normal y produce su propia rama con su propio scaffold.

La vía 1 es más eficiente operacionalmente; la vía 2 es más limpia
conceptualmente. Cualquiera es válida.

**Nota sobre frecuencia esperada:** la combinación de O diseñando y
D+G auditando el N2 antes de subir Issues hace muy poco probable que
un scaffold llegue al repo mal especificado. Si pasa, es señal de que
la auditoría manual falló y vale documentarlo como hallazgo para la
revisión de épica con O.

### 9.6 No hay manifiesto de hashes

La v1.1 mantenía archivos `docs/orchestrator/contract-hashes/epic-NNN.txt`.
**En v1.2 estos archivos no existen.** La inmutabilidad se verifica
contra el commit scaffold en la propia historia de la rama del PR.

Si un proyecto migra de v1.1 a v1.2:

1. Eliminar `docs/orchestrator/contract-hashes/` del repo.
2. Adoptar el nuevo modelo solo para Issues a partir de cierto punto;
   los Issues anteriores ya cerrados no requieren retrofit.
3. Actualizar `tools/ci/check_test_immutability.sh` (versión nueva,
   especificada arriba).
4. Quitar la mención de manifiesto de hashes del `AGENTS.md` del
   proyecto si existe.

---

## 10. Workflow de GitHub Actions: auditor de PR

El kit incluye un único workflow que invoca a D: `audit-pr.yml`. Se
define en `.github/workflows/`. La especificación es funcional, no el
YAML literal (cada kit derivado lo materializa).

### 10.1 `audit-pr.yml` — auditor de PR

**Trigger**: `pull_request_target` con types `opened`, `synchronize`,
`reopened`. Razón del `_target`: el workflow corre con los permisos del
repositorio base, no del fork, lo que permite acceder al secret
`DEEPSEEK_API_KEY`. **Sin `_target`, el workflow no tiene acceso a
secrets en PRs de forks**.

**Pasos**:

1. Checkout del repo (ref del PR para tener el diff).
2. Obtener el diff del PR vía `gh pr diff`.
3. Construir el prompt: system prompt fijo del kit + AGENTS.md + ADRs
   vigentes en `docs/adr/` + N2 de la épica del Issue enlazado + diff
   del PR.
4. Llamar a D V4 Flash con `stream=True`,
   `stream_options={"include_usage": True}`, `temperature=0`,
   `max_tokens=8000`.
5. Parsear respuesta: extraer veredicto (`audit/pass` o `audit/fail`).
6. Aplicar label correspondiente al PR.
7. Publicar comentario con el razonamiento (visible) y el `usage`
   estructurado (`[telemetry]`).

**Idempotencia**: si el workflow se dispara múltiples veces
(`synchronize` por nuevos commits), no se acumulan comentarios. Se
actualiza el comentario existente identificable por marca
`<!-- deepseek-audit-comment -->`.

### 10.2 Decisión: workflow propio vs `hustcer/deepseek-review`

La acción `hustcer/deepseek-review` está disponible en Marketplace y
funciona técnicamente, pero presenta tres problemas para producción:

- **No certificada por GitHub**: tercer-party con acceso a nuestra API
  key.
- **Modelo por defecto es `deepseek-chat`** (alias legacy que se
  retira el 24 de julio de 2026).
- **Non-streaming por defecto**: pierde la telemetría granular
  (`reasoning_tokens`, `usage` chunked) que el v1.6 requiere.

**Recomendación operacional**:

- **Prototipo (semanas iniciales)**: usar `hustcer/deepseek-review` con
  override del modelo a `deepseek-v4-flash` y sistema custom. Valida
  end-to-end rápidamente.
- **Producción (cuando el prototipo esté validado)**: workflow propio
  que llama directamente a la API de D vía el SDK OpenAI-compatible.
  Más control, sin dependencia de tercero, telemetría completa.

La transición prototipo → propio se hace cuando el flujo básico está
validado y antes de añadir el segundo proyecto al portafolio.

---

## 11. System prompt: estructura y versionado

### 11.1 Ubicación

El system prompt del auditor de PR vive como archivo versionado del
kit base:

```
tools/auditor-prompts/
└── pr-auditor-system.md
```

Este archivo es la fuente de verdad. El workflow lo lee y lo pasa al
cliente D. Cualquier cambio se hace vía PR contra el repo del kit, no
en línea.

(Los prompts manuales para chat — `Prompt_Auditoria_Documentos_D_y_G.md`
y `Prompt_Revision_de_Epica_con_O.md` — viven separadamente, no son
inputs de este workflow.)

### 11.2 Estructura recomendada

El system prompt del auditor de PR incluye, en este orden fijo:

1. **Rol**: una frase ("Eres el auditor de PRs del enjambre...").
2. **Mentalidad**: la consigna "razonable, no perfecto" explícita.
3. **Checklist binario**: la lista de categorías graves que disparan
   `audit/fail`. Cualquier cosa fuera de esta lista es comentario, no
   rechazo.
4. **Regla de reevaluación post-corrección**: las críticas técnicas
   válidas no se anulan por correcciones factuales.
5. **Formato de salida**: estructura exacta del veredicto.

### 11.3 Versionado

Cuando se calibre el prompt (ajustes para reducir falsos positivos,
añadir categorías graves descubiertas en operación), el cambio se
versiona explícitamente en el filename:

```
pr-auditor-system.md         (versión actual)
pr-auditor-system.v1.md      (versión anterior, archivada)
```

Esto permite A/B testing en cartera: aplicar el nuevo prompt en un
proyecto, mantener el anterior en otros, comparar métricas. Importante:
cambios al prompt invalidan cache; planear la migración para un
período de baja carga.

---

## 12. Cache invalidation y rolling updates

Cuando cambia algo en el prefijo cacheado (system prompt, `AGENTS.md`,
ADRs base), las primeras llamadas tras el cambio son cache miss. El
costo de esa transición se debe planear, no asumir.

**Patrón recomendado**:

- Cambios planificables (calibración de prompts, refactor de
  `AGENTS.md`) se hacen al final de una sesión activa, cuando el flujo
  del agente está pausado. La primera llamada del lote siguiente paga
  el miss; el resto del lote hitea.
- Cambios reactivos (ADR nuevo durante una sesión activa) aceptan el
  costo inmediato. Es <$0.10 en términos absolutos; no justifica
  retrasar.

**Cache invalidation NO documentada**: si D decide invalidar caches
por su lado (mantenimiento del proveedor), no hay forma de saberlo. El
primer indicador es subida abrupta de costos. La telemetría detecta
esto si se monitorea `prompt_tokens` agregados por sesión.

---

## 13. Idempotencia y manejo de errores

### 13.1 Comentarios de auditoría idempotentes

El workflow que publica comentario al PR usa marca HTML identificable:

```
<!-- deepseek-audit-comment -->
[contenido del comentario]
```

En cada ejecución, antes de publicar, el workflow busca un comentario
con esa marca y lo actualiza si existe; lo crea si no. Esto evita
acumulación de comentarios en PRs largos con muchas iteraciones de J.

### 13.2 Errores de red durante streaming

Si la conexión se rompe mid-stream:

- El workflow registra el chunk recibido hasta ese momento (puede ser
  parcial pero útil para debugging).
- Reintenta la llamada completa con backoff.
- Si el reintento sucede, el comentario se actualiza con la respuesta
  completa (no se acumula).

### 13.3 Stateless por PR

Cada audit es independiente. El workflow no mantiene historial de
auditorías previas del mismo PR ni de PRs hermanos. El contexto
necesario está en el prefijo cacheado (`AGENTS.md`, ADRs) más el
contenido específico del PR.

Esto evita "memoria del auditor", que podría introducir drift o sesgos
acumulados. Si se necesita contexto cross-PR (ej. "este es el tercer
PR de esta épica"), se incluye en el user message, no en el system.

---

## 14. Telemetría: formato del comentario `[telemetry]`

El comentario que publica el auditor al cerrar tiene estructura exacta
para facilitar parseo posterior:

```
[telemetry]
auditor: pr-auditor
model: deepseek-v4-flash
prompt_tokens: N
completion_tokens: N
reasoning_tokens: 0
cache_hit_inferred: true | false
result: pass | fail
duration_seconds: N
trigger: opened | synchronize | manual
```

Buscable con `gh pr list --search "[telemetry]"`. Un script de
agregación (a producirse cuando se tenga el primer proyecto en
operación) parsea estos comentarios cross-proyecto y produce CSV o
markdown.

---

## 15. Resumen y orden de implementación

### 15.1 Resumen

D se integra con un workflow (`audit-pr.yml`) que invoca el SDK
OpenAI-compatible apuntando al endpoint de D. La economía depende del
**prefix caching byte-idéntico** (system prompt + ADRs + AGENTS.md).
La telemetría se captura vía streaming con `include_usage` y se publica
como comentario estructurado en cada PR.

La inmutabilidad de tests pre-cargados se verifica por blob SHA
per-archivo en el script `tools/ci/check_test_immutability.sh`, que se
auto-desactiva cuando el primer commit de la rama no es un scaffold
(convención de mensaje de commit).

### 15.2 Orden de implementación

1. **Primera semana**: secret `DEEPSEEK_API_KEY` configurado. System
   prompt versionado en `tools/auditor-prompts/`. Workflow
   `prepare-issue-branch.yml` y script `check_test_immutability.sh`
   validados.
2. **Primera y segunda semana**: prototipo de `audit-pr.yml` usando
   `hustcer/deepseek-review` con override de modelo y prompt. Validar
   comentarios, labels, y captura de telemetría.
3. **Tras el prototipo validado**: reemplazar `audit-pr.yml` por
   workflow propio (sin la acción de terceros).
4. **Primera épica real con el workflow activo**: medir cache hit
   ratio real, costo por audit, tasa de falsos positivos. Ajustar
   prompt según datos.

(Las referencias de tiempo son relativas al primer proyecto en
operación, no a fechas calendario.)

### 15.3 Criterio de aceptación de v1.2

Esta especificación se considera materializada cuando, en operación
real con un proyecto:

- Cache hit ratio >80% sostenido durante una sesión activa.
- Costo de auditoría de PR <$0.005 promedio (con cache hitteando).
- `reasoning_ratio` del auditor de PR = 0 (Flash no soporta thinking).
- Cero modificaciones detectadas a archivos del scaffold por el
  guard de blob SHA en 50 PRs consecutivos.
- Tasa de falsos positivos del auditor de PR <15% (medida en
  comentarios `[telemetry]` agregados).

Si cualquiera de estos criterios falla sostenidamente, se ajusta el
prompt o el flujo correspondiente. No se reescribe el documento; se
itera la implementación.
