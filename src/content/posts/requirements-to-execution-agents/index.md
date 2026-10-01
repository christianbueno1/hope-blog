---
title: "Requirements-to-Execution: de la documentación del proyecto a un sistema de coordinación para agentes de IA"
description: Cómo evolucionar la documentación de un proyecto para que los agentes de IA puedan participar en su desarrollo.
pubDate: 2026-10-01
category: sistemas-web
image: "/og/requirements-to-execution-agents.webp"
---

Cuando un agente de IA participa en el desarrollo de software, uno de los problemas más difíciles no es conseguir que escriba código.

El problema es conseguir que **entienda dónde está el proyecto, qué se ha decidido, qué todavía no se ha decidido y qué debe hacer a continuación**.

En un proyecto pequeño podemos mantener gran parte de ese contexto en una conversación.

Pero a medida que el proyecto crece aparecen preguntas como:

* ¿Por qué existe este proyecto?
* ¿Qué problema intenta resolver?
* ¿Qué funcionalidades fueron realmente acordadas?
* ¿Qué decisiones siguen pendientes?
* ¿Qué arquitectura fue aprobada?
* ¿Qué estamos implementando actualmente?
* ¿Qué trabajo queda pendiente?
* ¿Por qué se tomó determinada decisión técnica?
* ¿Qué aprendimos durante la implementación?

Cuando estas respuestas viven únicamente en conversaciones, el proyecto empieza a depender de una memoria que no es persistente.

Por eso he ido evolucionando un patrón que llamo **Requirements-to-Execution**.

La idea sigue siendo:

> Convertir la intención humana en trabajo ejecutable mediante una cadena de documentación persistente, versionada y trazable.

Pero hay una evolución importante respecto al modelo inicial:

> **La documentación no debe aparecer toda de una vez. Debe crecer conforme crece el conocimiento del proyecto.**

---

## El problema de empezar por una plantilla

Una tentación habitual cuando comenzamos un proyecto con agentes de IA es crear inmediatamente:

```text
AGENTS.md
MISSION.md
PRD.md
TECH-STACK.md
SPECIFICATIONS.md
ROADMAP.md
PRODUCT_BACKLOG.md
SPRINT_BACKLOG.md
SPRINT_TASK.md
CHANGELOG.md
```

La estructura parece organizada.

Pero existe un problema:

**al principio probablemente no sabemos suficiente para llenar todos esos archivos correctamente.**

Podemos saber que queremos construir una aplicación.

Pero quizá todavía no sabemos:

* todos los casos de uso;
* todas las reglas de negocio;
* la arquitectura;
* la tecnología definitiva;
* las prioridades;
* el orden de implementación.

Si intentamos completar esos documentos desde el primer día, existe el riesgo de que el agente empiece a rellenar los espacios mediante suposiciones.

Y eso es precisamente lo que queremos evitar.

---

# Documentación progresiva

Una alternativa es tratar la documentación como una consecuencia del descubrimiento.

El proyecto puede comenzar con:

```text
AGENTS.md
MISSION.md
```

Después, cuando existe suficiente conocimiento del producto:

```text
AGENTS.md
MISSION.md
PRD.md
```

Posteriormente:

```text
AGENTS.md
MISSION.md
PRD.md
TECH-STACK.md
SPECIFICATIONS.md
```

Y cuando ya podemos establecer una estrategia de implementación:

```text
AGENTS.md
MISSION.md
PRD.md
TECH-STACK.md
SPECIFICATIONS.md
ROADMAP.md
```

Finalmente, cuando comienza la ejecución:

```text
PRODUCT_BACKLOG.md
SPRINT_BACKLOG.md
SPRINT_TASK.md
CHANGELOG.md
```

No todos los proyectos necesitan exactamente estos archivos.

Tampoco necesitan tenerlos todos desde el principio.

La estructura debe crecer junto con el conocimiento disponible.

---

# La entrevista como punto de partida

En un proyecto nuevo, el agente puede comenzar realizando una entrevista.

Pero no necesariamente una entrevista gigantesca.

La conversación puede avanzar progresivamente.

```text
                 ENTREVISTA
                     │
                     ▼
                ¿Por qué?
                     │
                     ▼
                MISSION.md
                     │
                     ▼
                ¿Qué producto?
                     │
                     ▼
                  PRD.md
                     │
                     ▼
              ¿Con qué tecnología?
                     │
                     ▼
              TECH-STACK.md
                     │
                     ▼
               ¿Cómo construirlo?
                     │
                     ▼
             SPECIFICATIONS.md
                     │
                     ▼
              ¿En qué orden?
                     │
                     ▼
                ROADMAP.md
                     │
                     ▼
                  BACKLOG
```

Esto transforma la entrevista en una especie de **proceso de descubrimiento asistido**.

El agente no está simplemente preguntando para generar código.

Está ayudando a convertir conocimiento informal en conocimiento persistente.

---

# MISSION.md: el punto de partida

La primera pregunta no debería ser:

> ¿Qué framework vamos a utilizar?

Debería ser:

> **¿Por qué existe este proyecto?**

De ahí surge `MISSION.md`.

La misión puede establecer:

* el problema;
* el propósito;
* el objetivo;
* los usuarios o beneficiarios;
* los límites;
* los principios fundamentales.

Por ejemplo:

```text
¿Por qué existe ClinicFlow?

¿Qué problema queremos resolver?

¿Para quién?

¿Qué queremos aprender o conseguir?

¿Qué queda fuera del proyecto?
```

No necesitamos conocer todavía todos los endpoints.

Necesitamos conocer el **norte**.

---

# PRD.md: convertir la intención en producto

Una vez que sabemos por qué existe el proyecto podemos preguntar:

> **¿Qué debe hacer?**

Aquí aparece `PRD.md`.

El PRD puede contener:

```text
Actores
    ↓
Requisitos
    ↓
Casos de uso
    ↓
Reglas de negocio
    ↓
Requisitos no funcionales
    ↓
Criterios de aceptación
```

Por ejemplo:

```text
UC-01 — Registrar paciente

Actor:
Personal administrativo

Objetivo:
Registrar un nuevo paciente.

Resultado:
El paciente queda disponible para futuras consultas.
```

Esto sigue una distinción importante:

> **Un caso de uso describe una necesidad del producto, no su implementación técnica.**

Por eso `POST /api/v1/patients` no es el caso de uso.

Es una posible implementación técnica del caso de uso.

---

# TECH-STACK.md: decidir con qué construir

Después podemos responder:

> **¿Con qué tecnologías construiremos el producto?**

Aquí aparece `TECH-STACK.md`.

Puede contener:

```text
Language
Framework
Database
ORM
Migration tool
Testing framework
Package manager
Containerization
Code quality tools
```

Pero también puede establecer restricciones.

Por ejemplo:

```text
Python >= X
PostgreSQL
FastAPI
SQLAlchemy
Alembic
pytest
uv
```

La diferencia respecto a `SPECIFICATIONS.md` es importante.

`TECH-STACK.md` responde:

> ¿Qué utilizamos?

`SPECIFICATIONS.md` responde:

> ¿Cómo utilizamos esas tecnologías para construir este sistema?

---

# SPECIFICATIONS.md: transformar requisitos en diseño técnico

Aquí pasamos de:

```text
WHAT
```

a:

```text
HOW
```

Por ejemplo:

```text
PRD

UC-01 — Registrar paciente
```

puede derivar en:

```text
SPECIFICATIONS

POST /api/v1/patients

PatientCreate
PatientResponse

Validation rules

Persistence strategy

Exception handling
```

La especificación puede establecer:

* arquitectura;
* estructura de directorios;
* modelo de dominio;
* contratos de API;
* persistencia;
* validaciones;
* excepciones;
* configuración;
* seguridad;
* testing;
* convenciones técnicas.

---

# ROADMAP.md: establecer el camino

Cuando sabemos qué queremos construir y cómo pensamos construirlo, podemos preguntar:

> **¿En qué orden lo implementamos?**

Ahí aparece `ROADMAP.md`.

Por ejemplo:

```text
Phase 1 — Foundation

Phase 2 — Patient domain

Phase 3 — Patient CRUD

Phase 4 — Validation and errors

Phase 5 — Testing

Phase 6 — Security

Phase 7 — Production readiness
```

El roadmap no es el backlog.

El roadmap establece:

> **dirección y secuencia.**

El backlog establece:

> **trabajo concreto.**

---

# La cadena completa

La evolución puede representarse así:

```text
MISSION
  │
  │ Why?
  ▼
PRD
  │
  │ What?
  ▼
TECH-STACK
  │
  │ With what?
  ▼
SPECIFICATIONS
  │
  │ How?
  ▼
ROADMAP
  │
  │ In what order?
  ▼
PRODUCT BACKLOG
  │
  │ What work exists?
  ▼
SPRINT BACKLOG
  │
  │ What are we doing now?
  ▼
SPRINT TASK
  │
  │ What exactly are we executing?
  ▼
IMPLEMENTATION
  │
  │ What did we build?
  ▼
CHANGELOG
  │
  │ What happened and why?
  └───────────────────────↺
```

Esta es una evolución del modelo Requirements-to-Execution.

Ya no lo veo simplemente como una secuencia de archivos.

Lo veo como una **cadena de transformación del conocimiento**.

---

# ¿Dónde entra AGENTS.md?

Aquí aparece una diferencia fundamental.

`AGENTS.md` no debería ser otro documento de requisitos.

Tampoco debería convertirse en una copia de toda la documentación del proyecto.

Su función es diferente:

> **Enseñarle al agente cómo orientarse dentro del sistema documental y cómo trabajar con él.**

Por ejemplo:

```text
AGENTS.md

¿Cómo debo leer el proyecto?

¿Qué documento contiene los requisitos?

¿Dónde están las decisiones técnicas?

¿Qué debo hacer cuando falta información?

¿Cuándo debo preguntar?

¿Qué documento debo actualizar?

¿Cómo funciona el workflow de Git?

¿Qué reglas de ejecución debo respetar?
```

Por eso `AGENTS.md` puede considerarse el **entry point operativo del agente**.

---

# AGENTS.md como orquestador

El agente puede encontrar algo como:

```text
AGENTS.md
    │
    ├── MISSION.md
    ├── PRD.md
    ├── TECH-STACK.md
    ├── SPECIFICATIONS.md
    ├── ROADMAP.md
    │
    ├── PRODUCT_BACKLOG.md
    ├── SPRINT_BACKLOG.md
    ├── SPRINT_TASK.md
    │
    └── CHANGELOG.md
```

Pero `AGENTS.md` no necesita contener el contenido de esos documentos.

Solo necesita explicar:

```text
qué representa cada uno
qué documento consultar
qué documento actualizar
qué hacer si falta información
cómo resolver conflictos
qué reglas seguir
```

Esto permite mantener las instrucciones globales relativamente pequeñas.

---

# Una regla especialmente importante: preguntar antes de asumir

Cuando el agente encuentra algo que no está definido, existen dos posibilidades.

### Mal enfoque

```text
No sabemos cómo manejar autenticación.

→ Implementar JWT porque es una práctica común.
```

### Mejor enfoque

```text
Authentication:
Por confirmar.

→ Preguntar al humano antes de implementar.
```

La ausencia de una decisión no significa que el agente tenga permiso para inventarla.

Esta regla es especialmente importante en decisiones que afectan:

* alcance;
* arquitectura;
* seguridad;
* persistencia;
* comportamiento del producto;
* tecnologías;
* prioridades.

---

# Tres estados para representar conocimiento incompleto

Una forma sencilla de manejar esto es utilizar tres estados:

### Definido

Decisión aprobada.

```text
Database: PostgreSQL
Status: Definido
```

El agente debe respetarla.

### Por confirmar

Todavía no existe una decisión.

```text
Authentication: ?
Status: Por confirmar
```

El agente debe preguntar cuando esa decisión sea necesaria.

### Evolutivo

La decisión está deliberadamente pospuesta.

```text
Caching:
Status: Evolutivo
```

No necesitamos resolverla ahora.

Esto permite que la documentación represente honestamente el nivel de conocimiento del proyecto.

---

# La documentación no debe convertirse en burocracia

Existe un riesgo al hablar de tantos archivos.

Podríamos terminar creando documentación por el simple hecho de crear documentación.

Ese no es el objetivo.

La regla debería ser:

> **Crear un documento cuando exista una necesidad real de separar y preservar ese conocimiento.**

No:

> "Nuestro template tiene diez archivos, por lo tanto debemos crear diez archivos."

Un proyecto pequeño puede necesitar muy pocos.

Un proyecto grande puede necesitar muchos más.

La estructura debe responder al proyecto.

---

# El backlog sigue siendo importante

La evolución hacia una constitución progresiva no elimina el modelo operativo anterior.

Una vez que el roadmap establece una fase:

```text
ROADMAP

Phase 2 — Patient
```

podemos convertirla en trabajo:

```text
PRODUCT_BACKLOG

TASK-001 Create Patient model
TASK-002 Create Patient schemas
TASK-003 Create Patient repository
TASK-004 Create POST /patients
...
```

Después:

```text
PRODUCT_BACKLOG
       ↓
SPRINT_BACKLOG
       ↓
SPRINT_TASK
       ↓
CODE
```

La diferencia es que ahora sabemos de dónde viene ese trabajo.

---

# Trazabilidad

El sistema documental completo permite mantener una cadena como:

```text
Mission
   ↓
Requirement
   ↓
Use Case
   ↓
Roadmap Phase
   ↓
Backlog Item
   ↓
Sprint Item
   ↓
Task
   ↓
Code Change
   ↓
Changelog
```

Esto permite responder:

> ¿Por qué existe esta tarea?

```text
Porque implementa este requisito.
```

> ¿Por qué existe este requisito?

```text
Porque forma parte de este caso de uso.
```

> ¿Por qué implementamos este caso de uso ahora?

```text
Porque pertenece a esta fase del roadmap.
```

> ¿Por qué este código tiene este comportamiento?

```text
Porque implementa esta decisión documentada.
```

La trazabilidad reduce la distancia entre intención y ejecución.

---

# El contexto también puede ser progresivo

Hay otra propiedad interesante.

El agente no necesita recibir todo el proyecto como contexto operativo en cada momento.

Podemos pensar en niveles:

```text
                 PROJECT
                    │
                    ▼
              PRODUCT BACKLOG
                    │
                    ▼
              CURRENT SPRINT
                    │
                    ▼
               CURRENT TASK
                    │
                    ▼
              RELEVANT CODE
```

Esto permite reducir el contexto inmediato sin perder la conexión con el objetivo general.

En otras palabras:

> **La documentación no solamente preserva contexto; también ayuda a seleccionar contexto.**

---

# La documentación como memoria del proyecto

El código representa el estado actual.

Pero el proyecto necesita recordar más que eso.

```text
Código
→ qué hace actualmente

PRD
→ qué debería hacer

SPECIFICATIONS
→ cómo decidimos construirlo

ROADMAP
→ cómo pensamos evolucionarlo

BACKLOG
→ qué falta

SPRINT_TASK
→ qué estamos haciendo

CHANGELOG
→ qué ocurrió y por qué

AGENTS.md
→ cómo debe trabajar el agente
```

Cada documento preserva una dimensión diferente del conocimiento.

---

# El repositorio como memoria persistente

Las conversaciones con agentes son temporales.

Podemos cambiar de:

```text
Claude Code
```

a:

```text
Codex
```

o comenzar una nueva sesión.

También puede incorporarse otra persona al proyecto.

El repositorio, en cambio, puede conservar:

```text
intención
+
requisitos
+
decisiones
+
planificación
+
tareas
+
cambios
```

Por eso la documentación versionada funciona como una especie de **memoria persistente del proyecto**.

---

# Pero el humano sigue siendo quien decide

Un sistema documental no significa delegar la autoridad del proyecto al agente.

El humano sigue siendo responsable de:

* definir objetivos;
* establecer alcance;
* aprobar decisiones importantes;
* resolver ambigüedades;
* aceptar cambios relevantes;
* validar resultados.

El agente puede ayudar a transformar:

```text
intención
    ↓
documentación
    ↓
planificación
    ↓
implementación
```

pero eso no significa:

```text
agente
    ↓
autoridad sobre el proyecto
```

Una de las reglas más importantes sigue siendo:

> **Preguntar antes de asumir.**

---

# Un patrón que también evoluciona

Quizá esta sea la parte más importante de la evolución.

`AGENTS.md` tampoco debería ser considerado definitivo.

Durante el desarrollo podemos descubrir:

```text
Regla actual
    ↓
Problema
    ↓
Nueva decisión
    ↓
Actualización de AGENTS.md
    ↓
Mejor proceso
```

Por ejemplo, si descubrimos que durante las implementaciones siempre olvidamos actualizar determinada documentación, podemos convertir ese aprendizaje en una regla del agente.

Así, el repositorio no solamente acumula código.

También acumula **conocimiento sobre cómo desarrollar el código**.

---

# La nueva visión de Requirements-to-Execution

La primera versión del patrón puede resumirse como:

```text
Requirements
    ↓
Planning
    ↓
Execution
    ↓
History
```

La evolución que propongo ahora es:

```text
             DISCOVERY
                 │
                 ▼
              MISSION
                 │
                 ▼
             PRODUCT
                 │
                 ▼
           REQUIREMENTS
                 │
                 ▼
             TECHNICAL
                 │
                 ▼
              PLANNING
                 │
                 ▼
             EXECUTION
                 │
                 ▼
              HISTORY
                 │
                 └───────────↺
```

Y `AGENTS.md` atraviesa todo el proceso:

```text
                    AGENTS.md
                        │
        ┌───────────────┼────────────────┐
        ▼               ▼                ▼
    Discovery       Documentation     Execution
        │               │                │
        └───────────────┼────────────────┘
                        ▼
                    Project
```

No es simplemente otro archivo.

Es la capa que explica **cómo el agente debe utilizar el sistema documental**.

---

# No es una metodología

Este patrón no pretende sustituir:

* Scrum;
* Kanban;
* XP;
* Shape Up;
* Git;
* issue trackers;
* herramientas de gestión;
* sistemas de Requirements Management.

Puede convivir con ellos.

Tampoco pretende imponer una cantidad determinada de archivos.

La propuesta es más pequeña:

> **Crear una estructura documental que permita transformar progresivamente la intención humana en ejecución, manteniendo contexto, trazabilidad y memoria cuando agentes de IA participan en el desarrollo.**

---

# Una forma de resumirlo

Podemos pensar en cinco niveles:

```text
1. PURPOSE
   ¿Por qué existe?

        ↓

2. TRUTH
   ¿Qué queremos construir?

        ↓

3. PLAN
   ¿En qué orden lo construiremos?

        ↓

4. EXECUTION
   ¿Qué estamos implementando?

        ↓

5. MEMORY
   ¿Qué ocurrió y por qué?
```

Y alrededor de ellos:

```text
                    AGENTS.md
                       │
                       ▼
               ¿Cómo debe trabajar
                   el agente?
```

La idea central ya no es simplemente:

```text
Requirements → Execution
```

sino:

```text
Discovery
    ↓
Knowledge
    ↓
Requirements
    ↓
Technical Decisions
    ↓
Planning
    ↓
Execution
    ↓
Memory
    ↺
```

---

# Conclusión

La documentación para proyectos con agentes de IA no debería diseñarse como una colección fija de archivos.

Debería diseñarse como un **sistema de conocimiento progresivo**.

Al comenzar un proyecto quizá solo conocemos su propósito.

Entonces creamos `MISSION.md`.

Cuando entendemos el producto, aparece `PRD.md`.

Cuando conocemos las tecnologías, `TECH-STACK.md`.

Cuando podemos establecer la arquitectura, `SPECIFICATIONS.md`.

Cuando conocemos el orden de implementación, `ROADMAP.md`.

Cuando comienza el trabajo, aparecen los backlogs y las tareas.

Y mientras desarrollamos, `CHANGELOG.md` conserva la historia.

`AGENTS.md` conecta todo esto desde el punto de vista del agente:

> **Le dice cómo orientarse, qué consultar, cuándo preguntar y cómo trabajar con la memoria documental del proyecto.**

Por eso la documentación deja de ser únicamente algo que escribimos *sobre* el software.

Se convierte en parte de la infraestructura utilizada para **construirlo**.

Y esa es, probablemente, la evolución más importante del patrón Requirements-to-Execution: no se trata de tener más archivos, sino de conseguir que **cada pieza de conocimiento tenga un lugar, aparezca cuando existe suficiente información para justificarla y pueda sobrevivir a la conversación que la originó**.

# Ejemplo: AGENTS.md

````
# AGENTS.md — Agent Instructions

> Este archivo define cómo debe trabajar el agente dentro del proyecto.
> Es el punto de entrada operativo del agente y debe consultarse antes de
> realizar cambios relevantes en el proyecto.

---

## 1. Propósito de este archivo

`AGENTS.md` contiene las reglas de trabajo del agente dentro del repositorio.

No define el producto, la arquitectura ni las tecnologías del proyecto.

Su responsabilidad es establecer:

* cómo descubrir el contexto del proyecto;
* qué documentos consultar;
* qué responsabilidad tiene cada documento;
* cómo manejar información incompleta;
* cuándo preguntar al humano;
* cómo evolucionar la documentación;
* cómo organizar el trabajo;
* cómo mantener la trazabilidad;
* qué reglas seguir durante la implementación.

`AGENTS.md` debe considerarse un **contrato operativo entre el proyecto y el agente**.

---

# 2. Principio fundamental: no asumir

El agente debe **preguntar antes de asumir** cualquier información que pueda afectar:

* el propósito del proyecto;
* el alcance;
* los requisitos;
* los casos de uso;
* las reglas de negocio;
* las decisiones arquitectónicas;
* las tecnologías;
* las prioridades;
* el roadmap;
* las convenciones del proyecto.

El agente no debe convertir una práctica habitual, una preferencia personal o una solución técnicamente común en una decisión del proyecto sin aprobación del humano.

Cuando una decisión no esté definida:

1. identificar que la información falta;
2. determinar si es necesaria para continuar;
3. preguntar al humano si la decisión afecta el trabajo actual;
4. no inventar una respuesta para completar documentación.

---

# 3. Definición progresiva del proyecto

La documentación del proyecto debe evolucionar junto con el conocimiento disponible.

No es obligatorio crear todos los documentos al inicio.

El agente debe crear un documento únicamente cuando exista suficiente información para darle contenido significativo.

Por ejemplo, un proyecto nuevo puede comenzar únicamente con:

```text
AGENTS.md
MISSION.md
```

Posteriormente puede evolucionar a:

```text
AGENTS.md
MISSION.md
PRD.md
```

y posteriormente:

```text
AGENTS.md
MISSION.md
PRD.md
TECH-STACK.md
SPECIFICATIONS.md
ROADMAP.md
```

Los documentos no deben crearse simplemente para completar una estructura de directorios.

### Regla

> La documentación debe ser consecuencia del conocimiento del proyecto, no una plantilla que el agente rellena mediante suposiciones.

---

# 4. Entrevista inicial

Cuando el proyecto se encuentra en una etapa temprana y existe poca información disponible, el agente debe utilizar una **entrevista progresiva** para descubrir el contexto.

La entrevista debe comenzar por las cuestiones más fundamentales y avanzar hacia decisiones más concretas.

Orden conceptual:

```text
Propósito
   ↓
Producto
   ↓
Tecnología
   ↓
Arquitectura
   ↓
Planificación
   ↓
Ejecución
```

## 4.1 Primera entrevista — Propósito

La primera entrevista debe buscar suficiente información para establecer:

```text
MISSION.md
```

Debe explorar, según corresponda:

* problema;
* propósito;
* objetivo;
* usuarios o beneficiarios;
* resultado esperado;
* alcance conceptual;
* límites;
* principios relevantes.

No es necesario determinar en esta etapa toda la funcionalidad ni la arquitectura.

---

## 4.2 Segunda entrevista — Producto

Cuando la misión sea suficientemente clara, el agente puede ayudar a establecer:

```text
PRD.md
```

Debe descubrir progresivamente:

* actores;
* funcionalidades;
* requisitos funcionales;
* casos de uso;
* reglas de negocio;
* restricciones;
* requisitos no funcionales;
* criterios de aceptación;
* alcance del producto.

---

## 4.3 Tercera entrevista — Tecnología y diseño técnico

Cuando exista suficiente definición del producto, el agente puede ayudar a establecer:

```text
TECH-STACK.md
SPECIFICATIONS.md
```

Debe diferenciar entre:

* tecnologías elegidas;
* restricciones tecnológicas;
* decisiones arquitectónicas;
* patrones;
* estructura;
* contratos;
* persistencia;
* validación;
* seguridad;
* testing;
* demás decisiones técnicas.

No se debe confundir una tecnología con una especificación arquitectónica.

---

## 4.4 Cuarta entrevista — Planificación

Cuando el producto y las decisiones técnicas sean suficientemente claras, el agente puede ayudar a establecer:

```text
ROADMAP.md
```

El roadmap debe definir la evolución del proyecto y el orden de implementación a alto nivel.

No debe convertirse en una lista exhaustiva de tareas.

---

# 5. Documentos de constitución del proyecto

Los siguientes documentos describen el proyecto y deben mantenerse conceptualmente separados.

| Archivo             | Pregunta principal          | Responsabilidad                                        |
| ------------------- | --------------------------- | ------------------------------------------------------ |
| `MISSION.md`        | ¿Por qué existe?            | Propósito, problema, objetivo y límites                |
| `PRD.md`            | ¿Qué producto queremos?     | Requisitos, casos de uso y reglas de negocio           |
| `TECH-STACK.md`     | ¿Con qué lo construiremos?  | Tecnologías, herramientas y restricciones tecnológicas |
| `SPECIFICATIONS.md` | ¿Cómo lo construiremos?     | Arquitectura, diseño técnico y contratos               |
| `ROADMAP.md`        | ¿En qué orden evolucionará? | Fases y evolución de alto nivel                        |

### Regla de separación

* `MISSION.md` no debe convertirse en un PRD.
* `PRD.md` no debe convertirse en una especificación técnica.
* `TECH-STACK.md` no debe contener toda la arquitectura.
* `SPECIFICATIONS.md` no debe redefinir los requisitos del producto.
* `ROADMAP.md` no debe convertirse en un backlog detallado.

---

# 6. Documentos operativos

Los documentos operativos representan el trabajo necesario para ejecutar el proyecto.

| Archivo              | Responsabilidad                            |
| -------------------- | ------------------------------------------ |
| `PRODUCT_BACKLOG.md` | Trabajo pendiente del producto             |
| `SPRINT_BACKLOG.md`  | Trabajo seleccionado para el sprint actual |
| `SPRINT_TASK.md`     | Tarea actualmente ejecutada                |

La relación conceptual es:

```text
ROADMAP
   ↓
PRODUCT_BACKLOG
   ↓
SPRINT_BACKLOG
   ↓
SPRINT_TASK
   ↓
IMPLEMENTATION
```

El roadmap establece la dirección y el orden de alto nivel.

El backlog transforma esa dirección en trabajo ejecutable.

---

# 7. Historial y trazabilidad

`CHANGELOG.md` conserva el historial relevante del proyecto.

Debe registrar, según corresponda:

* cambios significativos;
* decisiones importantes;
* motivo de las decisiones;
* relación con tareas o fases;
* cambios relevantes de comportamiento.

`CHANGELOG.md` representa **historia**, no necesariamente el estado técnico actual.

Por ejemplo:

```text
CHANGELOG.md
→ ¿Qué decisión tomamos y por qué?
```

mientras:

```text
SPECIFICATIONS.md
→ ¿Cuál es actualmente la decisión técnica vigente?
```

El agente no debe obligar al lector a reconstruir el estado actual leyendo todo el historial.

---

# 8. Estado de las decisiones

Cuando sea útil, las decisiones pueden clasificarse como:

### Definido

Decisión aprobada por el humano.

El agente debe respetarla durante la implementación.

### Por confirmar

Decisión pendiente.

El agente no debe implementarla basándose únicamente en una suposición.

Debe solicitar confirmación cuando la decisión sea necesaria para continuar.

### Evolutivo

Detalle que será definido durante una fase posterior del proyecto.

El agente no debe anticiparlo artificialmente si no es necesario para el trabajo actual.

---

# 9. Autoridad de los documentos

Cada documento tiene una responsabilidad específica.

Cuando exista información relevante, el agente debe consultar el documento correspondiente.

```text
MISSION.md
    ↓
Propósito

PRD.md
    ↓
Producto y requisitos

TECH-STACK.md
    ↓
Tecnologías

SPECIFICATIONS.md
    ↓
Diseño técnico vigente

ROADMAP.md
    ↓
Orden de evolución

PRODUCT_BACKLOG.md
    ↓
Trabajo pendiente

SPRINT_BACKLOG.md
    ↓
Trabajo del sprint

SPRINT_TASK.md
    ↓
Trabajo actual

CHANGELOG.md
    ↓
Historial
```

Si dos documentos contienen información aparentemente contradictoria, el agente no debe resolver el conflicto mediante una suposición.

Debe:

1. identificar el conflicto;
2. determinar qué decisiones están involucradas;
3. consultar al humano si no existe una regla explícita para resolverlo;
4. actualizar posteriormente los documentos afectados para recuperar consistencia.

---

# 10. Lectura del contexto

El agente debe comenzar consultando `AGENTS.md`.

Después debe determinar qué contexto es necesario para la tarea actual.

No es obligatorio leer todos los documentos en cada sesión.

Como referencia general:

```text
AGENTS.md
    ↓
MISSION.md
    ↓
PRD.md
    ↓
TECH-STACK.md
    ↓
SPECIFICATIONS.md
    ↓
ROADMAP.md
    ↓
PRODUCT_BACKLOG.md
    ↓
SPRINT_BACKLOG.md
    ↓
SPRINT_TASK.md
```

Para una tarea concreta, el agente debe consultar únicamente los documentos relevantes, manteniendo siempre suficiente contexto para evitar decisiones aisladas del resto del proyecto.

---

# 11. Casos de uso

Los casos de uso pertenecen al contexto del producto y deben documentarse en:

```text
PRD.md
```

No deben definirse principalmente en `SPECIFICATIONS.md`.

La relación es:

```text
PRD
    ↓
UC-01 — Registrar paciente
    ↓
SPECIFICATIONS
    ↓
POST /api/v1/patients
    ↓
IMPLEMENTATION
```

Un caso de uso describe lo que un actor necesita conseguir.

Una especificación técnica describe cómo el sistema implementará ese comportamiento.

No asumir que:

```text
1 caso de uso = 1 endpoint
```

Un caso de uso puede requerir múltiples operaciones técnicas.

---

# 12. Requisitos y decisiones técnicas

El agente debe mantener separadas estas preguntas:

```text
PRD
¿Qué debe hacer el sistema?
```

```text
SPECIFICATIONS
¿Cómo se implementará?
```

Por ejemplo:

```text
PRD:
El número de identificación de un paciente debe ser único.
```

puede derivar en:

```text
SPECIFICATIONS:
La unicidad se garantizará mediante una restricción UNIQUE
en la base de datos.
```

El requisito pertenece al producto.

La implementación de ese requisito pertenece a la especificación técnica.

---

# 13. No completar documentos mediante invención

Cuando un documento contenga información insuficiente, el agente no debe completar los espacios mediante:

* preferencias personales;
* convenciones no aprobadas;
* tecnologías populares;
* patrones considerados "best practice" sin aprobación;
* requisitos inferidos;
* funcionalidades inventadas;
* decisiones arquitectónicas prematuras.

Es preferible escribir:

```text
Status: Por confirmar
```

o preguntar al humano.

---

# 14. Flujo general de trabajo

El flujo conceptual del proyecto es:

```text
DISCOVERY
   ↓
MISSION
   ↓
PRODUCT DEFINITION
   ↓
PRD
   ↓
TECHNICAL DEFINITION
   ↓
TECH-STACK
   ↓
SPECIFICATIONS
   ↓
PLANNING
   ↓
ROADMAP
   ↓
BACKLOG
   ↓
SPRINT
   ↓
TASK
   ↓
IMPLEMENTATION
   ↓
TESTING
   ↓
DOCUMENTATION / CHANGELOG
```

Este flujo no es estrictamente lineal.

Durante la implementación puede ser necesario volver a una etapa anterior.

Por ejemplo:

```text
Implementation
      ↓
Technical problem discovered
      ↓
SPECIFICATIONS needs clarification
      ↓
Human decision
      ↓
SPECIFICATIONS updated
      ↓
Implementation continues
```

La documentación debe evolucionar junto con el conocimiento del proyecto.

---

# 15. Flujo de trabajo con Git

La estrategia de Git del proyecto es:

* `dev` como rama de integración;
* un branch de trabajo por fase o unidad significativa de trabajo;
* nombres de branch descriptivos;
* commits atómicos;
* Conventional Commits;
* merge a `dev` al completar una unidad de trabajo;
* `main` reservada para releases o estados estables.

El agente debe evitar mezclar cambios no relacionados dentro del mismo commit.

Antes de realizar operaciones destructivas o cambios que puedan afectar trabajo existente, debe verificar el estado del repositorio.

---

# 16. Principios generales

### Elaboración progresiva

No todas las decisiones deben tomarse al inicio.

### Preguntar antes de asumir

Las decisiones importantes deben ser confirmadas cuando no estén definidas.

### Una fase a la vez

No avanzar artificialmente a fases posteriores si las dependencias necesarias no están establecidas.

### Trazabilidad

Las decisiones y cambios relevantes deben poder relacionarse con requisitos, tareas o fases.

### Separación de responsabilidades

Cada documento debe contener únicamente la información correspondiente a su propósito.

### Fuente única de verdad

Una decisión vigente debe tener una ubicación documental clara.

### No inventar contexto

La ausencia de información no autoriza al agente a crear requisitos o decisiones.

### Mantener la documentación útil

La documentación debe ayudar a tomar decisiones y ejecutar el proyecto; no debe crecer únicamente por cumplir una plantilla.

### Confirmación humana

Las decisiones que cambien el alcance, arquitectura, tecnología, seguridad o comportamiento esperado deben ser aprobadas por el humano cuando no estén previamente definidas.

---

# 17. Regla final

El agente debe recordar:

> **Primero comprender el proyecto, después documentarlo, luego planificarlo y finalmente implementarlo.**

La documentación debe aparecer progresivamente conforme aumenta el conocimiento del proyecto.

El agente debe preferir:

```text
preguntar
```

antes que:

```text
asumir
```

y debe preferir:

```text
documentar una decisión explícita
```

antes que:

```text
dejar una decisión importante implícita en el código.
```
````

