---
title: "Requirements-to-Execution: un patrón de documentación para coordinar proyectos de software con agentes de IA"
description: "Cómo mantener la trazabilidad, el contexto y la intención de un proyecto de software cuando agentes de IA participan en su desarrollo."
pubDate: 2026-09-15
category: "sistemas-web"
image: "/og/requirements-to-execution.webp"
---

Cuando trabajamos con agentes de IA para desarrollar software, una de las dificultades más importantes no es conseguir que el agente escriba código.

El verdadero desafío es **mantener el contexto, el orden y la trazabilidad del proyecto a medida que este crece**.

Un proyecto puede comenzar con una idea relativamente pequeña:

> "Construir una REST API para administrar clientes."

Después aparecen requisitos, decisiones de diseño, nuevas funcionalidades, cambios de alcance, correcciones, tareas que no estaban previstas y decisiones que deben recordarse semanas después.

Si todo ese conocimiento permanece únicamente en las conversaciones con el agente, el proyecto se vuelve difícil de mantener.

Por esta razón, en algunos proyectos he venido utilizando un patrón de documentación que denomino **Requirements-to-Execution Documentation Pattern**.

La idea es sencilla:

> **Convertir la intención del proyecto en una cadena de documentos que permita pasar de los requisitos a la ejecución, manteniendo una fuente de verdad y trazabilidad durante todo el ciclo de desarrollo.**

No es un framework ni un estándar formal. Es un patrón de trabajo que he ido construyendo y refinando a partir de la experiencia utilizando agentes de código como **Claude Code** y **Codex CLI**.

---

## El problema: el código no es suficiente para representar el proyecto

Un repositorio contiene código, tests, configuraciones y documentación.

Pero el código por sí solo no responde completamente preguntas como:

* ¿Por qué se construyó esta funcionalidad?
* ¿Cuál era el alcance original?
* ¿Qué requisitos fueron acordados?
* ¿Qué tareas están pendientes?
* ¿Qué tarea se está ejecutando actualmente?
* ¿Por qué se tomó determinada decisión técnica?
* ¿Qué cambios se realizaron anteriormente?
* ¿Qué trabajo nuevo apareció durante el desarrollo?
* ¿Qué parte del proyecto todavía no está implementada?

Estas preguntas son especialmente importantes cuando un agente de IA participa en el desarrollo.

Un agente puede analizar el código actual, pero **el estado actual del código no necesariamente contiene toda la historia ni toda la intención del proyecto**.

Existe una diferencia entre:

```text
Lo que el software hace actualmente
```

y:

```text
Lo que el proyecto pretende hacer
```

El patrón intenta mantener ambas dimensiones conectadas.

---

## La idea central

El patrón utiliza varios documentos con responsabilidades diferentes.

Una estructura conceptual puede verse así:

```text
                    PROJECT INTENT
                         │
                         ▼
                 SOURCE OF TRUTH
                         │
                ┌────────┴────────┐
                │                 │
                ▼                 ▼
       SPECIFICATIONS.md       PRD.md
                │                 │
                └────────┬────────┘
                         ▼
                PRODUCT_BACKLOG.md
                         │
                         ▼
                 SPRINT_BACKLOG.md
                         │
                         ▼
                    SPRINT_TASK.md
                         │
                         ▼
                    IMPLEMENTATION
                         │
                         ▼
                    CHANGELOG.md
```

No todos los proyectos necesitan exactamente estos archivos ni estos nombres.

Lo importante es el **flujo de información**.

La intención del proyecto se transforma progresivamente en trabajo ejecutable.

---

## Source of Truth

Uno de los conceptos fundamentales del patrón es establecer una **fuente de verdad**.

Los documentos que describen el producto, sus requisitos y sus especificaciones constituyen la referencia principal para comprender qué se pretende construir.

Por ejemplo:

```text
SPECIFICATIONS.md
PRD.md
```

Estos documentos representan la intención del proyecto.

El resto de los documentos no debería convertirse en una fuente independiente de requisitos contradictorios.

En términos conceptuales:

```text
                SOURCE OF TRUTH
                       │
             ┌─────────┴─────────┐
             ▼                   ▼
      Product decisions      Requirements
             │                   │
             └─────────┬─────────┘
                       ▼
                  Planning
```

Esto es importante porque evita que el proyecto dependa exclusivamente del contexto de una conversación.

La conversación puede desaparecer.

El contexto puede cambiar.

Puede cambiar el agente.

Puede incorporarse otra persona al proyecto.

Pero la documentación versionada permanece en el repositorio.

---

## De requisitos a ejecución

El patrón puede entenderse como una progresión:

```text
Requirements
     ↓
Planning
     ↓
Prioritization
     ↓
Execution
     ↓
History
```

Cada nivel responde una pregunta diferente.

### Requirements

¿Qué debe hacer el producto?

### Product Backlog

¿Qué trabajo existe para construir el producto?

### Sprint Backlog

¿Qué parte de ese trabajo se realizará ahora?

### Sprint Task

¿Qué actividad concreta se está ejecutando?

### Implementation

¿Qué se implementó realmente?

### Changelog

¿Qué decisiones y cambios ocurrieron durante el proceso?

Esta separación reduce la mezcla entre **qué queremos construir** y **qué estamos haciendo actualmente**.

---

## El backlog como memoria operativa

Uno de los problemas habituales durante el desarrollo es que aparecen nuevas tareas.

Por ejemplo:

```text
Estamos implementando autenticación.
```

Durante el trabajo descubrimos:

```text
- Hay que agregar refresh tokens.
- Falta validar expiración.
- Necesitamos modificar el modelo de usuario.
- Hay que agregar pruebas.
```

Es muy fácil que alguna de estas tareas quede simplemente en una conversación.

El patrón intenta evitarlo.

Una nueva necesidad puede convertirse en una tarea registrada:

```text
Nueva necesidad
       ↓
PRODUCT_BACKLOG.md
       ↓
SPRINT_BACKLOG.md
       ↓
SPRINT_TASK.md
       ↓
Implementation
```

De esta manera, una tarea nueva **no queda en el aire**.

Esto también permite diferenciar entre:

> "Esto sería bueno hacerlo."

y:

> "Esto forma parte del trabajo pendiente del proyecto."

Esa diferencia parece pequeña, pero se vuelve importante cuando el proyecto empieza a crecer.

---

## El Sprint como unidad de contexto

El `PRODUCT_BACKLOG.md` representa el universo de trabajo conocido.

Pero un agente no necesita necesariamente trabajar con todo ese universo en cada momento.

El Sprint permite reducir el contexto:

```text
PRODUCT_BACKLOG
       │
       ▼
SPRINT_BACKLOG
       │
       ▼
SPRINT_TASK
```

El agente puede concentrarse en una porción concreta del proyecto sin perder la relación con el objetivo general.

Esto produce una especie de **context window documental**:

```text
Proyecto completo
       │
       └── Backlog completo

Trabajo actual
       │
       └── Sprint actual

Contexto inmediato
       │
       └── Task actual
```

La documentación, por tanto, no solamente sirve para registrar información.

También sirve para **controlar el contexto que recibe el agente**.

---

## El CHANGELOG como memoria histórica

Otro componente importante es `CHANGELOG.md`.

En este patrón no se utiliza únicamente como una lista de versiones publicadas.

También puede funcionar como una **memoria histórica del proyecto**.

Por ejemplo:

```text
¿Qué hicimos?
¿Por qué lo hicimos?
¿Qué decisión tomamos?
¿Qué problema resolvimos?
```

Esto resulta especialmente útil cuando meses después se necesita modificar una parte del sistema.

El código puede mostrar:

```text
Esta funcionalidad existe.
```

El historial puede explicar:

```text
Por qué existe.
```

La diferencia es importante.

---

## El proyecto adquiere memoria

Una de las propiedades más interesantes del patrón es que la documentación puede evolucionar junto con el proyecto.

No se trata de escribir documentación una sola vez y abandonarla.

El ciclo es:

```text
          ┌───────────────────────┐
          │                       │
          ▼                       │
      Requirements               │
          │                       │
          ▼                       │
       Planning                  │
          │                       │
          ▼                       │
      Development                │
          │                       │
          ▼                       │
        Changes                  │
          │                       │
          └───────────────────────┘
```

Las decisiones y aprendizajes obtenidos durante el desarrollo pueden modificar el conocimiento que tenemos del proyecto.

Por eso el patrón debe ser **evolutivo**.

La estructura documental que funciona para un proyecto pequeño probablemente no será suficiente para uno mucho más grande.

---

## AGENTS.md como punto de entrada

En proyectos orientados a agentes, aparece otro elemento importante:

```text
AGENTS.md
```

Este archivo no necesariamente contiene todo el conocimiento del proyecto.

Su función puede ser mucho más interesante:

> **indicarle al agente cómo orientarse dentro del sistema documental.**

Por ejemplo:

```text
AGENTS.md
    │
    ├── cómo leer el proyecto
    ├── qué documentos consultar
    ├── qué documento actualizar
    ├── reglas de ejecución
    ├── reglas de Git
    └── principios generales
```

De esta forma, `AGENTS.md` funciona como un **entry point**.

No necesita contener todos los detalles.

Puede decirle al agente dónde encontrar esos detalles.

---

## Menos instrucciones, más estructura

Este es uno de los beneficios que encontré al utilizar este enfoque.

Cuando no existe una estructura documental clara, las instrucciones para el agente tienden a crecer:

```text
Recuerda hacer X.
Cuando ocurra Y haz Z.
Si aparece una nueva tarea recuerda anotarla.
No olvides actualizar...
Antes de modificar...
Después de implementar...
```

Con el tiempo, las instrucciones pueden convertirse en un documento enorme.

El patrón permite mover parte de esa información desde las instrucciones hacia documentos especializados.

En lugar de intentar colocar todo en:

```text
AGENTS.md
```

se puede tener:

```text
AGENTS.md
    ↓
cómo funciona el sistema

PRD.md
    ↓
qué debe hacer el producto

PRODUCT_BACKLOG.md
    ↓
qué falta por construir

SPRINT_BACKLOG.md
    ↓
qué estamos haciendo ahora

SPRINT_TASK.md
    ↓
qué tarea estamos ejecutando

CHANGELOG.md
    ↓
qué ha ocurrido
```

El resultado es una separación de responsabilidades.

**Menos instrucciones globales y más estructura documental.**

---

## Trazabilidad

Una propiedad importante de este patrón es la posibilidad de mantener trazabilidad.

Conceptualmente:

```text
Requirement
    ↓
Product Backlog Item
    ↓
Sprint Item
    ↓
Task
    ↓
Code Change
    ↓
Changelog
```

Esto permite responder preguntas como:

> ¿De dónde salió esta tarea?

> ¿Qué requisito intenta resolver?

> ¿Qué parte del Sprint la contiene?

> ¿Qué cambios se realizaron para completarla?

> ¿Por qué se modificó este componente?

No es necesario implementar una herramienta especializada de Requirements Management para obtener cierto nivel de trazabilidad.

Una estructura documental consistente puede proporcionar una versión sencilla y práctica de ella.

---

## Git como parte del patrón

La documentación no debería existir separada del código.

Debe formar parte del repositorio.

Esto permite que Git registre la evolución de:

```text
Código
+
Requisitos
+
Backlogs
+
Tareas
+
Decisiones
+
Historial
```

Por eso el patrón también puede incorporar reglas sobre Git:

```text
dev
 │
 ├── feature/...
 ├── fix/...
 └── chore/...
 │
 ▼
merge
 │
 ▼
main
```

El control de versiones deja de registrar solamente modificaciones de código.

También registra la evolución de la **intención y planificación del proyecto**.

---

## Documentación como infraestructura de desarrollo

Normalmente pensamos en documentación como algo que se escribe para explicar un software.

Este patrón propone una perspectiva ligeramente diferente.

La documentación también puede ser **infraestructura para desarrollar el software**.

```text
Documentation
      │
      ├── informs humans
      │
      ├── informs agents
      │
      ├── organizes work
      │
      ├── preserves decisions
      │
      └── maintains context
```

En otras palabras:

> La documentación no solamente describe el sistema; también ayuda a dirigir su construcción.

Esta distinción es particularmente importante en proyectos donde agentes de IA participan activamente en la implementación.

---

## El patrón no reemplaza al criterio humano

Aunque gran parte del trabajo pueda ser ejecutado por un agente, la fuente de verdad no debería convertirse en una excusa para delegar todas las decisiones.

El humano sigue teniendo responsabilidades importantes:

* definir objetivos;
* establecer alcance;
* aprobar prioridades;
* resolver ambigüedades;
* aceptar cambios importantes;
* revisar decisiones arquitectónicas;
* validar resultados.

El agente puede ayudar a transformar:

```text
intención → planificación → ejecución
```

pero eso no significa:

```text
agente → autoridad absoluta sobre el proyecto
```

Una de las reglas que considero importantes es:

> **Preguntar antes de asumir.**

Cuando existe una ambigüedad sobre el objetivo, el alcance o la prioridad, es preferible detenerse y consultar antes que inventar una decisión.

---

## Un sistema que aprende con el proyecto

Quizá la característica más interesante es que el patrón no tiene que ser estático.

En proyectos reales aparecen situaciones que no habían sido contempladas.

Por ejemplo:

```text
Regla inicial
      ↓
Problema descubierto
      ↓
Nueva decisión
      ↓
Actualización del patrón
      ↓
Regla mejorada
```

Después de varias iteraciones, `AGENTS.md` y los demás documentos pueden contener conocimiento obtenido de la experiencia real del proyecto.

Esto produce una forma de **memoria organizacional a nivel de repositorio**.

El proyecto no solamente acumula código.

También acumula conocimiento sobre **cómo debe ser desarrollado y mantenido**.

---

## Mi experiencia con el patrón

He utilizado este enfoque en diferentes proyectos con agentes de código, entre ellos:

* **Clasify**
* **Aluna**
* **PolySight**

En particular, lo he utilizado con **Claude Code** y **Codex CLI**.

Con el tiempo he encontrado varios beneficios prácticos.

### Mantener el orden de las tareas

El trabajo pendiente tiene un lugar explícito.

No depende exclusivamente de recordar qué se dijo en una conversación anterior.

### Evitar tareas perdidas

Cuando aparece una nueva necesidad durante la implementación, puede incorporarse al backlog correspondiente.

La tarea deja de ser una nota informal y pasa a formar parte del proyecto.

### Mantener contexto durante cambios

Cuando meses después se necesita modificar código, los documentos pueden ayudar al agente a comprender:

* qué se quería construir;
* qué trabajo se realizó;
* qué decisiones fueron tomadas;
* qué queda pendiente.

### Reducir instrucciones

Las instrucciones globales pueden mantenerse relativamente pequeñas porque gran parte del conocimiento se encuentra en documentos especializados.

### Evolucionar con el proyecto

El propio patrón puede modificarse cuando se descubren mejores formas de organizar el trabajo.

Esto último es especialmente importante.

**El patrón no es el resultado final; es un sistema que también evoluciona.**

---

## No es una metodología de desarrollo

Es importante establecer los límites del concepto.

Este patrón no pretende reemplazar metodologías como:

* Scrum;
* Kanban;
* Extreme Programming;
* Shape Up;
* u otras metodologías de gestión y desarrollo.

Tampoco pretende reemplazar:

* Git;
* issue trackers;
* sistemas de gestión de proyectos;
* herramientas de documentación;
* sistemas de Requirements Management.

Puede coexistir con ellos.

La propuesta es más pequeña y concreta:

> **establecer una estructura documental que conecte requisitos, planificación, ejecución y evolución del proyecto, especialmente cuando agentes de IA participan en el desarrollo.**

---

## Una forma de verlo

El patrón puede resumirse en cinco niveles:

```text
1. TRUTH
   ¿Qué queremos construir?

        ↓

2. PLAN
   ¿Qué trabajo necesitamos realizar?

        ↓

3. FOCUS
   ¿Qué estamos haciendo ahora?

        ↓

4. EXECUTION
   ¿Qué estamos implementando?

        ↓

5. MEMORY
   ¿Qué ocurrió y por qué?
```

O de forma aún más compacta:

```text
TRUTH
  ↓
PLAN
  ↓
EXECUTE
  ↓
REMEMBER
  ↺
```

La última flecha es importante.

El conocimiento obtenido durante la ejecución puede volver al sistema documental y mejorar el siguiente ciclo.

---

## Requirements-to-Execution

Por eso considero que **Requirements-to-Execution Documentation Pattern** describe bastante bien la idea.

No porque sea un estándar establecido, sino porque expresa su propósito:

```text
Requirements
     ↓
Planning
     ↓
Execution
     ↓
History
```

La documentación funciona como una cadena de transformación entre la intención humana y el trabajo ejecutable.

En proyectos tradicionales esto ya puede ser útil.

Pero cuando un agente de IA participa en el desarrollo, esta estructura adquiere todavía más valor porque proporciona algo que el agente necesita constantemente:

> **contexto persistente, estructurado y versionado.**

La conversación es temporal.

El repositorio es persistente.

La conversación puede contener el razonamiento de una sesión.

La documentación puede convertirse en la memoria que sobrevive a esa sesión.

Y el código representa únicamente una parte de la historia.

---

## Conclusión

El objetivo de este patrón no es producir más documentación.

De hecho, uno de sus objetivos es **evitar documentación innecesaria y concentrar cada tipo de información en el lugar donde corresponde**.

La idea fundamental es sencilla:

```text
Source of Truth
      ↓
Requirements
      ↓
Backlog
      ↓
Sprint
      ↓
Task
      ↓
Implementation
      ↓
History
```

Cada etapa reduce la distancia entre lo que se quiere construir y lo que realmente se está haciendo.

Las nuevas tareas tienen un lugar.

Las decisiones tienen un lugar.

El trabajo actual tiene un lugar.

El historial tiene un lugar.

Y las instrucciones del agente pueden mantenerse más pequeñas porque no necesitan contener todo el conocimiento del proyecto.

Después de utilizar este enfoque en varios proyectos, lo considero menos como una plantilla de archivos y más como un **patrón de coordinación entre humanos, documentación, código y agentes de IA**.

La idea central podría resumirse en una sola frase:

> **No depender de la memoria de la conversación para mantener el proyecto organizado; convertir el conocimiento importante del proyecto en una estructura persistente, versionada y ejecutable.**

## AGENTS.md / CLAUDE.md
```
# AGENTS.md — Agent Instructions

> Este archivo es el punto de entrada de cada sesión.
> Léelo primero, siempre, antes de hacer cualquier otra cosa.

---

## Archivos de orquestación del proyecto — qué es cada uno

| Archivo | Propósito | Quién lo edita |
|---|---|---|
| `AGENTS.md` | Instrucciones del agente (este archivo) | Solo el humano |
| `PRODUCT_BACKLOG.md` | Lista de features y tareas pendientes — el backlog completo | Agente agrega, humano aprueba |
| `SPRINT_BACKLOG.md` | Lista detallada de tareas del Sprint actual | Agente agrega, humano aprueba |
| `SPRINT_TASK.md` | Tarea o actividad especifica dentro de un Sprint | Agente agrega, humano aprueba |
| `CHANGELOG.md` | Log permanente de decisiones y acciones tomadas — con el porqué | Agente solo agrega, nunca edita entradas pasadas |
| `SPECIFICATIONS.md` | Documento de especificación técnica y de diseño del proyecto | Agente solo agrega, nunca edita entradas pasadas |
| `PRD.md` | Documento de especificación de producto y requerimientos | Agente solo agrega, nunca edita entradas pasadas |
---

## Cómo leer el contexto al inicio de cada sesión

`AGENTS.md` → `SPRINT_BACKLOG.md` → `SPRINT_TASK.md` → `CHANGELOG.md`.

Si los archivos no existen es la primera sesión, entonces revisar `SPECIFICATIONS.md` y `PRD.md` para entender el contexto del proyecto.
Confirmar el objetivo del proyecto con el humano y crear el `PRODUCT_BACKLOG.md` inicial si no existe.
Crear el `SPRINT_BACKLOG.md` inicial con las tareas de la primera fase, y el `SPRINT_TASK.md` con la primera tarea a ejecutar.

---

## Cómo funciona PRODUCT_BACKLOG.md / SPRINT_BACKLOG.md / SPRINT_TASK.md / CHANGELOG.md

`PRODUCT_BACKLOG.md` contiene la lista completa de features y tareas pendientes del proyecto, con su prioridad y estado.
`SPRINT_BACKLOG.md` contiene la lista de tareas del Sprint actual, con su prioridad y estado.
`SPRINT_TASK.md` contiene la descripción de la tarea o actividad específica que se está ejecutando en el Sprint actual, con su prioridad y estado.
`CHANGELOG.md` contiene un log permanente de decisiones y acciones tomadas, con el porqué de cada decisión.

---

## Flujo de trabajo con Git

Rama `dev` de integración, un branch por fase (`<type>/<descripcion-corta>`), commits atómicos, merge `--no-ff` a `dev` al cerrar cada fase, `main` reservada para releases estables.

## Principios generales

- **Elaboración progresiva.** Las fases bloqueadas se documentan como tal, nunca se ocultan ni se simulan como completas.
- **Una fase a la vez.**
- **Preguntar antes de asumir.** Cualquier ambigüedad sobre el objetivo del proyecto, la prioridad de las tareas o el alcance de una fase debe ser consultada con el humano antes de continuar.
- **Los cambios son trazables** — cada decisión relevante va a `CHANGELOG.md`.
```
