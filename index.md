---
title: ashware
nav_order: 1
description: "Metodología operacional para arquitectos de software que orquestan enjambres de LLMs."
permalink: /
---

# ashware

> Metodología operacional para arquitectos de software que orquestan enjambres de LLMs como equipo, no como herramienta.

---

## La pregunta

¿Cómo opera un arquitecto solo una cartera de proyectos de software en 2026? Delegando casi todo el ciclo de vida a un enjambre de LLMs — con reglas estrictas sobre qué puede hacer cada uno, qué no puede tocar, y qué evidencia tiene que dejar.

Lo que sigue es la respuesta operacional de un arquitecto con cuarenta años de experiencia. Cinco documentos, una opinión clara, validada operando.

## Qué es esto, qué no es

**Es** una metodología completa para correr proyectos de software con un equipo de LLMs bajo dirección humana. Nativa de GitHub (Issues, PRs, Actions). Lista para usarse el día 1 de un repo nuevo. Económica (~$225/mes en máquina), sin cronograma, calibrable.

**No es** otro framework de multi-agente. LangGraph, CrewAI, AutoGen, MetaGPT — esos ya existen y resuelven cómo conectar agentes entre sí. Esto va encima: cómo se opera con ellos en proyectos reales sin que se rompa lo importante.

## Para quién

- Arquitectos de software senior que ven a la IA como su nuevo equipo, no como su nueva herramienta.
- Solopreneurs técnicos que quieren operar una cartera de proyectos sin contratar.
- CTOs de empresas pequeñas evaluando cómo introducir agentes sin volar el pipeline.

No es para programadores que recién empiezan con IA. Asume PRs, ADRs, GitHub Actions, y la intuición de por qué ningún modelo debe diseñar, ejecutar y auditar el mismo artefacto.

## Tres ideas que sostienen el sistema

**1. Segregación de funciones entre familias LLM.**
Anthropic, Google y DeepSeek nunca ocupan los tres roles sobre el mismo artefacto. Si Opus diseña, Jules ejecuta y DeepSeek audita. Tres familias, sesgos distintos, costo de captura coordinada del sistema mucho más alto.

**2. Equipo bueno, no perfecto.**
Los auditores aprueban lo razonable y comentan lo dudoso. Bloquean solo categorías graves: contrato roto, seguridad, scope creep evidente. Las dudas menores van como comentarios, no como bloqueos. Velocidad con calidad defendible, no pureza académica.

**3. Inmutabilidad mecánica de los contratos.**
Los tests rojos viven precargados en el body del Issue. Un workflow los materializa como primer commit de la rama. Un check verifica blob SHA per-archivo en cada PR. El ejecutor produce código contra el contrato; no negocia con él.

Hay más en los documentos.

## Los cinco documentos

**[Proyecto de Proyectos](/docs/proyecto/)** — el documento paraguas. Filosofía, roles, flujo end-to-end, operación en cartera. **Empieza aquí.**

**[General Starter Kit](/docs/starter-kit/)** — la especificación canónica del kit, agnóstica de