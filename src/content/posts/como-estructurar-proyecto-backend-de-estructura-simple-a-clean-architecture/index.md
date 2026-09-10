---
title: "Como estructurar un proyecto backend que pueda crecer: de una estructura simple a Clean Architecture"
description: "Guía paso a paso para estructurar un proyecto backend que pueda crecer, desde una estructura simple hasta Clean Architecture, utilizando Python + FastAPI, ASP.NET Core 10 y Spring Boot 4."
pubDate: "2026-09-09"
category: "sistemas-arquitectura"
---

# Cómo estructurar un proyecto backend que pueda crecer: de una estructura simple a Clean Architecture

Cuando comenzamos un proyecto backend es tentador crear unas cuantas carpetas y empezar a programar:

```text
controllers/
services/
repositories/
models/
```

Funciona.

Hasta que el proyecto crece.

Aparecen nuevas funcionalidades, más desarrolladores, más reglas de negocio, integraciones externas, diferentes tipos de persistencia, pruebas, caché, autenticación, colas, etc.

Entonces surge una pregunta importante:

> **¿Cómo puedo hacer crecer la estructura de mi proyecto sin terminar con un sistema difícil de mantener?**

La respuesta no es crear 30 carpetas desde el primer día.

La respuesta es entender **qué problema resuelve cada nivel de arquitectura**, y especialmente entender **la dirección de las dependencias**.

En este artículo vamos a construir mentalmente un CRM y veremos cómo evolucionar su estructura utilizando:

- Python + FastAPI
- ASP.NET Core 10
- Spring Boot 4
- `uv` como package/project manager en Python
- Fedora Linux 44
- Layered Architecture
- Feature-based Architecture
- Clean Architecture
- Hexagonal Architecture
- Dependency Inversion Principle

La implementación se profundizará en **FastAPI**, mientras que ASP.NET Core 10 y Spring Boot 4 se utilizarán para demostrar que estos conceptos no dependen de un framework específico.

---

# 1. Primero: arquitectura ≠ carpetas

Esta es probablemente la primera idea que debemos aclarar.

Una estructura como:

```text
src/
├── controllers/
├── services/
├── repositories/
└── models/
```

no constituye por sí sola una arquitectura.

Las carpetas son solamente una **representación física de determinadas decisiones arquitectónicas**.

La arquitectura también define:

- responsabilidades;
- límites;
- dependencias;
- comunicación entre componentes;
- reglas de negocio;
- dirección de las dependencias;
- qué componentes conocen a otros componentes;
- qué partes del sistema pueden reemplazarse sin modificar el núcleo de la aplicación.

Por ejemplo, podemos tener:

```text
domain/
application/
infrastructure/
presentation/
```

y aun así tener una mala arquitectura si `domain` importa directamente SQLAlchemy, FastAPI o PostgreSQL.

Por eso:

> **No basta con organizar correctamente las carpetas. Hay que controlar las dependencias.**

---

# 2. Nuestro ejemplo: un CRM

Imaginemos que estamos construyendo un CRM.

Inicialmente necesitamos:

- clientes;
- contactos;
- oportunidades;
- usuarios;
- actividades.

Comenzaremos con algo sencillo y dejaremos que la arquitectura evolucione conforme aumente la complejidad.

Una posible visión global del sistema sería:

```text
                    ┌──────────────┐
                    │   Frontend   │
                    └──────┬───────┘
                           │ HTTP
                           ▼
                    ┌──────────────┐
                    │    CRM API   │
                    │   Backend    │
                    └──────┬───────┘
                           │
              ┌────────────┼────────────┐
              ▼            ▼            ▼
          PostgreSQL      Redis      External API
```

Esta es la **arquitectura global del sistema**.

Pero todavía no hemos decidido cómo organizar internamente el backend.

---

# 3. Empezar sencillo

No necesitamos Clean Architecture desde el primer commit.

Un proyecto pequeño podría comenzar así:

```bash
uv init crm-api
cd crm-api
```

```text
crm-api/
├── src/
│   └── crm_api/
│       ├── main.py
│       ├── models.py
│       ├── schemas.py
│       ├── routes.py
│       └── database.py
│
├── tests/
├── pyproject.toml
└── README.md
```

Esto es perfectamente válido para un proyecto pequeño.

El problema aparece cuando `models.py`, `routes.py` o `services.py` comienzan a crecer demasiado.

Por ejemplo:

```text
routes.py
```

puede terminar conteniendo:

```text
HTTP
↓
validación
↓
reglas de negocio
↓
SQL
↓
transacciones
↓
manejo de errores
↓
respuesta HTTP
```

Entonces tenemos un problema de **responsabilidades mezcladas**.

---

# 4. Layered Architecture

Una primera evolución natural es separar responsabilidades por capas, tambien se dice separar por tipo de archivo o por responsabilidad tecnica:

```text
src/
└── crm_api/
    ├── routers/
    ├── services/
    ├── repositories/
    ├── models/
    └── schemas/
```

Por ejemplo:

```text
routers/
    customers.py

services/
    customers.py

repositories/
    customers.py

models/
    customer.py

schemas/
    customer.py
```

El flujo sería:

```text
HTTP Request
     │
     ▼
┌──────────────┐
│    Router    │
└──────┬───────┘
       ▼
┌──────────────┐
│   Service    │
└──────┬───────┘
       ▼
┌──────────────┐
│ Repository   │
└──────┬───────┘
       ▼
   Database
```

Cada capa tiene una responsabilidad.

## Router

Se preocupa principalmente por:

- HTTP;
- endpoints;
- request;
- response;
- status codes.

## Service

Se preocupa principalmente por:

- casos de uso;
- reglas de aplicación;
- coordinación.

## Repository

Se preocupa por:

- persistencia;
- consultas;
- acceso a la base de datos.

## Model

Representa datos o entidades del dominio/persistencia, dependiendo del diseño.

## Schema

Representa contratos de entrada/salida.

---

# 5. El problema de organizar únicamente por tipo

Esta estructura:

```text
routers/
    customers.py
    contacts.py
    opportunities.py

services/
    customers.py
    contacts.py
    opportunities.py

repositories/
    customers.py
    contacts.py
    opportunities.py
```

funciona.

Pero observa qué sucede cuando tenemos 30 funcionalidades.

Para trabajar en `customers`, tenemos que recorrer:

```text
routers/
services/
repositories/
models/
schemas/
```

Toda la funcionalidad está distribuida.

Esto nos lleva a otra estrategia.

---

# 6. Feature-based Architecture

En lugar de organizar primero por tipo de archivo, podemos organizar por funcionalidad:

```text
src/
└── crm_api/
    ├── customers/
    │   ├── router.py
    │   ├── service.py
    │   ├── repository.py
    │   ├── model.py
    │   └── schema.py
    │
    ├── contacts/
    │   ├── router.py
    │   ├── service.py
    │   ├── repository.py
    │   ├── model.py
    │   └── schema.py
    │
    └── opportunities/
        ├── router.py
        ├── service.py
        ├── repository.py
        ├── model.py
        └── schema.py
```

Ahora todo lo relacionado con `customers` está junto.

Esto mejora la **cohesión**.

---

# 7. Una tercera evolución: Feature + Layers

Podemos combinar las dos ideas.

En lugar de elegir entre:

```text
por capas
```

y:

```text
por features
```

podemos utilizar ambas:

```text
src/
└── crm_api/
    ├── customers/
    │   ├── domain/
    │   ├── application/
    │   ├── infrastructure/
    │   └── presentation/
    │
    ├── contacts/
    │   ├── domain/
    │   ├── application/
    │   ├── infrastructure/
    │   └── presentation/
    │
    └── opportunities/
        ├── domain/
        ├── application/
        ├── infrastructure/
        └── presentation/
```

Aquí tenemos dos dimensiones:

```text
Feature
  │
  ├── Domain
  ├── Application
  ├── Infrastructure
  └── Presentation
```

Esta estructura nos acerca mucho más a **Clean Architecture** y **Hexagonal Architecture**.

---

# 8. Clean Architecture: el concepto realmente importante

Clean Architecture no consiste simplemente en crear:

```text
domain/
application/
infrastructure/
presentation/
```

La idea fundamental es la **dirección de las dependencias**.

Las políticas internas de la aplicación no deberían depender de detalles externos.

Podemos representarlo así:

```text
                EXTERIOR
                   │
                   ▼
        ┌─────────────────────┐
        │    Presentation     │
        │      FastAPI        │
        └──────────┬──────────┘
                   ▼
        ┌─────────────────────┐
        │     Application     │
        │      Use Cases      │
        └──────────┬──────────┘
                   ▼
        ┌─────────────────────┐
        │       Domain        │
        │   Business Rules    │
        └─────────────────────┘
```

El dominio está en el centro.

Los detalles externos están alrededor.

Por ejemplo:

```text
Domain
  │
  ├── NO conoce FastAPI
  ├── NO conoce SQLAlchemy
  ├── NO conoce PostgreSQL
  ├── NO conoce Redis
  └── NO conoce HTTP
```

Esto permite que el núcleo del sistema sea independiente de los detalles tecnológicos.

---

# 9. La regla de dependencias

Podemos establecer una regla sencilla:

```text
Presentation
      ↓
Application
      ↓
Domain
```

Mientras que infraestructura implementa los mecanismos externos:

```text
Infrastructure
      │
      ├── SQLAlchemy
      ├── PostgreSQL
      ├── Redis
      ├── APIs externas
      └── servicios cloud
```

Una forma más conceptual de verlo:

```text
            ┌───────────────────────┐
            │     Presentation      │
            │       FastAPI         │
            └───────────┬───────────┘
                        │
                        ▼
            ┌───────────────────────┐
            │      Application      │
            │       Use Cases       │
            └───────────┬───────────┘
                        │
                        ▼
            ┌───────────────────────┐
            │        Domain         │
            │    Business Rules     │
            └───────────────────────┘
                        ▲
                        │
                        │ implements
                        │
            ┌───────────┴───────────┐
            │     Infrastructure    │
            │ SQLAlchemy / Postgres │
            └───────────────────────┘
```

La infraestructura puede depender del dominio.

El dominio no debería depender de la infraestructura.

---

# 10. Un error muy común

Supongamos que tenemos:

```text
domain/
└── customer.py
```

Podríamos pensar:

> "Como está dentro de `domain`, es código de dominio."

Pero si hacemos esto:

```python
from sqlalchemy.orm import Mapped
from sqlalchemy.orm import mapped_column

class Customer:
    id: Mapped[int] = mapped_column(...)
```

tenemos:

```text
Domain
   │
   └──→ SQLAlchemy
```

Esto rompe la independencia del dominio.

Aunque la carpeta se llame `domain`.

La arquitectura no está determinada por el nombre de la carpeta.

Está determinada también por **las dependencias reales del código**.

---

# 11. Dependency Inversion Principle

Aquí aparece uno de los principios más importantes de Clean Architecture:

> **Las capas de alto nivel no deberían depender de detalles de bajo nivel. Ambos deberían depender de abstracciones.**

Por ejemplo, el caso de uso necesita guardar un cliente.

No debería necesitar saber que existe PostgreSQL.

Podemos definir una abstracción:

```python
from abc import ABC, abstractmethod

class CustomerRepository(ABC):

    @abstractmethod
    def save(self, customer):
        pass
```

El caso de uso trabaja con:

```text
CustomerRepository
```

y no con:

```text
SQLAlchemyCustomerRepository
```

Luego infraestructura implementa la abstracción:

```python
class SQLAlchemyCustomerRepository(CustomerRepository):

    def save(self, customer):
        ...
```

Tenemos:

```text
Application
     │
     ▼
CustomerRepository
     ▲
     │ implements
     │
SQLAlchemyCustomerRepository
```

Esto es Dependency Inversion.

---

# 12. Implementación con FastAPI

Ahora vamos a llevar estos conceptos a un proyecto real.

Utilizaremos Fedora Linux 44.

## 12.1 Crear el proyecto

Primero comprobamos Python:

```bash
python --version
```

Creamos el proyecto con `uv`:

```bash
mkdir -p ~/projects
cd ~/projects

uv init crm-api
cd crm-api
```

Podemos inspeccionar la estructura:

```bash
tree
```

Una estructura inicial basada en `src` puede verse así:

```text
crm-api/
├── pyproject.toml
├── README.md
├── src/
│   └── crm_api/
│       └── __init__.py
└── uv.lock
```

Aquí es importante recordar:

> `uv` proporciona herramientas para gestionar el proyecto Python, pero **no define la arquitectura de nuestro CRM**.

`src/` corresponde al llamado **src layout** de Python.

---

# 13. Crear nuestra estructura

Vamos a construir inicialmente:

```text
src/
└── crm_api/
    ├── customers/
    │   ├── domain/
    │   ├── application/
    │   ├── infrastructure/
    │   └── presentation/
    │
    ├── contacts/
    │   ├── domain/
    │   ├── application/
    │   ├── infrastructure/
    │   └── presentation/
    │
    ├── core/
    └── main.py
```

Desde Fedora podemos crearla con:

```bash
mkdir -p src/crm_api/{core,customers/{domain,application,infrastructure,presentation},contacts/{domain,application,infrastructure,presentation}}
```

Crear los archivos:

```bash
touch src/crm_api/main.py

touch src/crm_api/customers/domain/customer.py
touch src/crm_api/customers/domain/repository.py

touch src/crm_api/customers/application/create_customer.py
touch src/crm_api/customers/application/get_customer.py

touch src/crm_api/customers/infrastructure/sqlalchemy_repository.py

touch src/crm_api/customers/presentation/router.py
```

Y los `__init__.py`:

Este comando crea archivos `__init__.py` en los directorios de manera recursiva para que Python los reconozca como paquetes:
```bash
find src/crm_api -type d -exec touch {}/__init__.py \;
```

Podemos comprobar:

```bash
tree src
```

---

# 14. Estructura resultante

```text
src/
└── crm_api/
    ├── __init__.py
    ├── main.py
    │
    ├── core/
    │   └── __init__.py
    │
    ├── customers/
    │   ├── __init__.py
    │   │
    │   ├── domain/
    │   │   ├── __init__.py
    │   │   ├── customer.py
    │   │   └── repository.py
    │   │
    │   ├── application/
    │   │   ├── __init__.py
    │   │   ├── create_customer.py
    │   │   └── get_customer.py
    │   │
    │   ├── infrastructure/
    │   │   ├── __init__.py
    │   │   └── sqlalchemy_repository.py
    │   │
    │   └── presentation/
    │       ├── __init__.py
    │       └── router.py
    │
    └── contacts/
        ├── __init__.py
        ├── domain/
        ├── application/
        ├── infrastructure/
        └── presentation/
```

Esta estructura ya refleja una arquitectura.

Pero todavía debemos implementar correctamente las dependencias.

---

# 15. Domain: las reglas del negocio

Supongamos que nuestro CRM tiene esta regla:

> Un cliente debe tener un nombre.

Nuestro dominio podría comenzar así:

```python
class Customer:
    def __init__(self, name: str, email: str):
        if not name.strip():
            raise ValueError("Customer name cannot be empty")

        self.name = name
        self.email = email
```

Observemos algo importante.

No tenemos:

```python
from fastapi import ...
```

Ni:

```python
from sqlalchemy import ...
```

Ni:

```python
from pydantic import ...
```

El dominio conoce solamente las reglas que necesita.

---

# 16. Application: el caso de uso

Ahora tenemos:

```text
application/
└── create_customer.py
```

Podríamos implementar:

```python
from crm_api.customers.domain.customer import Customer
from crm_api.customers.domain.repository import CustomerRepository


class CreateCustomer:

    def __init__(self, repository: CustomerRepository):
        self.repository = repository

    def execute(self, name: str, email: str):

        customer = Customer(
            name=name,
            email=email,
        )

        return self.repository.save(customer)
```

Aquí aparece nuevamente Dependency Inversion.

`CreateCustomer` no sabe si el repositorio utiliza:

- PostgreSQL;
- MySQL;
- SQLite;
- MongoDB;
- una API externa;
- memoria.

Solamente conoce:

```text
CustomerRepository
```

---

# 17. El Repository como Port

Nuestro dominio puede definir el contrato:

```python
from abc import ABC, abstractmethod

from crm_api.customers.domain.customer import Customer


class CustomerRepository(ABC):

    @abstractmethod
    def save(self, customer: Customer) -> Customer:
        raise NotImplementedError
```

Esto es conceptualmente un **Port** en Hexagonal Architecture.

Estamos diciendo:

> "El sistema necesita alguna forma de guardar un Customer."

No estamos diciendo:

> "Necesito SQLAlchemy."

La diferencia es enorme.

---

# 18. Infrastructure

Ahora podemos implementar ese port utilizando SQLAlchemy:

```text
infrastructure/
└── sqlalchemy_repository.py
```

Conceptualmente:

```python
from crm_api.customers.domain.customer import Customer
from crm_api.customers.domain.repository import CustomerRepository


class SQLAlchemyCustomerRepository(CustomerRepository):

    def save(self, customer: Customer) -> Customer:
        # Persistencia utilizando SQLAlchemy
        ...
```

Ahora la dependencia es:

```text
Infrastructure
      │
      ▼
Domain
```

y no:

```text
Domain
      │
      ▼
Infrastructure
```

---

# 19. Presentation: FastAPI

Ahora llegamos al framework:

```text
presentation/
└── router.py
```

Aquí sí podemos importar FastAPI:

Con `tags=["customers"]` agrupa y categoriza los endpoints en la documentación automática de OpenAPI/Swagger UI. 
```python
from fastapi import APIRouter

router = APIRouter(
    prefix="/customers",
    tags=["customers"],
)


@router.post("/")
def create_customer():
    ...
```

FastAPI pertenece a la capa de presentación.

Por lo tanto:

```text
Presentation → FastAPI
```

es completamente normal.

Lo que queremos evitar es:

```text
Domain → FastAPI
```

---

# 20. El flujo completo

Ahora podemos visualizar el caso de uso:

```text
POST /customers
       │
       ▼
┌──────────────────────┐
│      FastAPI         │
│    presentation      │
└──────────┬───────────┘
           ▼
┌──────────────────────┐
│   CreateCustomer     │
│     application      │
└──────────┬───────────┘
           ▼
┌──────────────────────┐
│      Customer        │
│       domain         │
└──────────┬───────────┘
           │
           ▼
┌─────────────────────────────┐
│ SQLAlchemyCustomerRepository│
│       infrastructure        │
└──────────────┬──────────────┘
               ▼
           PostgreSQL
```

---

# 21. ¿Dónde debería estar SQLAlchemy?

Esta pregunta genera bastante confusión.

Si estamos aplicando Clean Architecture estrictamente, SQLAlchemy es un **detalle de infraestructura**.

Por ejemplo:

```text
customers/
├── domain/
│   └── customer.py
│
├── application/
│   └── create_customer.py
│
├── infrastructure/
│   └── sqlalchemy_repository.py
│
└── presentation/
    └── router.py
```

Entonces:

```text
SQLAlchemy
    ↓
Infrastructure
```

No:

```text
SQLAlchemy
    ↓
Domain
```

---

# 22. ¿Y los modelos de SQLAlchemy?

Aquí aparece una decisión arquitectónica importante.

Podemos tener:

```text
domain/
    customer.py
```

y:

```text
infrastructure/
    customer_model.py
```

El primero representa el modelo de dominio. Es el que contiene las reglas de negocio.

El segundo representa el modelo de persistencia. Es el que contiene los detalles de cómo se guarda en la base de datos.

Por ejemplo:

```text
Domain Customer
       │
       │ mapping
       ▼
SQLAlchemy CustomerModel
```

Esto puede generar algo más de código, pero mantiene desacoplado el dominio de la tecnología de persistencia.

No siempre necesitamos llegar a este nivel de separación.

La decisión depende de la complejidad del sistema.

---

# 23. No hay que sobrediseñar

Esta es otra idea fundamental.

Si nuestro CRM solamente tiene:

```text
5 endpoints
2 tablas
1 desarrollador
pocas reglas de negocio
```

probablemente esto:

```text
domain/
application/
infrastructure/
presentation/
ports/
adapters/
factories/
```

sea demasiado.

Una arquitectura demasiado compleja también tiene un coste.

Por eso:

> **La arquitectura debe evolucionar junto con la complejidad del sistema.**

---

# 24. ¿Cómo evolucionar sin romper la arquitectura?

Podemos imaginar una progresión:

```text
Proyecto pequeño
       │
       ▼
┌──────────────────┐
│ Estructura simple│
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ Layered          │
│ Architecture     │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ Feature-based    │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ Feature + Layers │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ Clean /          │
│ Hexagonal        │
└──────────────────┘
```

Pero hay una condición:

> **Durante cada etapa debemos controlar la dirección de las dependencias.**

---

# 25. El peligro de evolucionar solamente moviendo archivos

Supongamos que inicialmente tenemos:

```text
services/
    customers.py
```

y después lo movemos a:

```text
customers/
    application/
        service.py
```

Podríamos pensar:

> "Ya tengo Clean Architecture."

No necesariamente.

Si `service.py` contiene:

```python
from fastapi import HTTPException
from sqlalchemy.orm import Session
```

tenemos:

```text
Application
   ├──→ FastAPI
   └──→ SQLAlchemy
```

La estructura de carpetas parece correcta.

Las dependencias no.

Por eso, al refactorizar, no debemos preguntarnos solamente:

> "¿Dónde debería mover este archivo?"

También debemos preguntar:

> **"¿De quién debería depender este código?"**

---

# 26. Una regla práctica para recordar

Podemos utilizar esta tabla como referencia:

| Capa | Puede conocer | Evitar conocer |
|---|---|---|
| Domain | reglas de negocio | FastAPI, SQLAlchemy, HTTP |
| Application | Domain + Ports | Frameworks concretos |
| Infrastructure | Domain/Application + DB/frameworks | — |
| Presentation | Application + framework HTTP | reglas de persistencia |

Una simplificación:

```text
Domain
  ↓
NO depende de tecnología

Application
  ↓
coordina casos de uso

Infrastructure
  ↓
implementa detalles externos

Presentation
  ↓
traduce HTTP ↔ Application
```

---

# 27. La misma idea en ASP.NET Core 10

Los nombres cambian, pero el concepto es el mismo.

Una posible estructura:

```text
src/
├── CRM.Api/
│   ├── Controllers/
│   └── Program.cs
│
├── CRM.Application/
│   ├── Customers/
│   │   ├── CreateCustomer.cs
│   │   └── GetCustomer.cs
│   └── Interfaces/
│
├── CRM.Domain/
│   └── Customers/
│       ├── Customer.cs
│       └── ICustomerRepository.cs
│
└── CRM.Infrastructure/
    ├── Persistence/
    │   └── AppDbContext.cs
    └── Repositories/
        └── CustomerRepository.cs
```

La dirección conceptual:

```text
CRM.Api
   ↓
CRM.Application
   ↓
CRM.Domain
   ↑
CRM.Infrastructure
```

ASP.NET Core puede estar en:

```text
CRM.Api
```

Entity Framework Core en:

```text
CRM.Infrastructure
```

Mientras que:

```text
CRM.Domain
```

no debería necesitar conocer ninguno de ellos.

---

# 28. La misma idea en Spring Boot 4

Podemos hacer algo equivalente:

```text
src/main/java/com/example/crm/

├── customer/
│   ├── domain/
│   │   ├── Customer.java
│   │   └── CustomerRepository.java
│   │
│   ├── application/
│   │   └── CreateCustomer.java
│   │
│   ├── infrastructure/
│   │   └── JpaCustomerRepository.java
│   │
│   └── presentation/
│       └── CustomerController.java
│
└── CrmApplication.java
```

Spring Boot se utiliza principalmente en las capas externas.

Por ejemplo:

```text
CustomerController
       ↓
CreateCustomer
       ↓
Customer
       ↑
JpaCustomerRepository
       ↓
Hibernate/JPA
```

La tecnología cambia.

El principio arquitectónico no.

---

# 29. FastAPI, ASP.NET Core y Spring Boot: mismo concepto

Podemos comparar:

| Responsabilidad | FastAPI | ASP.NET Core | Spring Boot |
|---|---|---|---|
| HTTP | FastAPI | ASP.NET Core | Spring MVC |
| Controller | Router | Controller | Controller |
| Application | Use Case / Service | Use Case / Service | Use Case / Service |
| Domain | Python | C# | Java |
| Persistencia | SQLAlchemy | EF Core / Dapper | JPA / Hibernate |
| Dependency Injection | FastAPI DI | Built-in DI | Spring DI |

Por lo tanto:

> **Clean Architecture no es una arquitectura de FastAPI.**

Tampoco es una arquitectura de ASP.NET Core o Spring Boot.

Es un enfoque arquitectónico que podemos implementar utilizando cualquiera de ellos.

---

# 30. Clean Architecture y Hexagonal Architecture

Ambas arquitecturas comparten una idea fundamental:

> **El núcleo de la aplicación debe estar protegido de los detalles externos.**

En Hexagonal Architecture podemos pensar en:

```text
                  REST
                   │
                Adapter
                   │
                   ▼
          ┌─────────────────┐
          │                 │
          │  Application    │
          │     Domain      │
          │                 │
          └───────┬─────────┘
                  │
                 Port
                  │
        ┌─────────┴─────────┐
        ▼                   ▼
   PostgreSQL          External API
     Adapter              Adapter
```

Los **Ports** representan capacidades que el núcleo necesita.

Los **Adapters** conectan esas capacidades con tecnologías concretas.

Por ejemplo:

```text
Port:

CustomerRepository
```

y:

```text
Adapters:

SQLAlchemyCustomerRepository
PostgresCustomerRepository
InMemoryCustomerRepository
```

Esto permite reemplazar detalles externos.

---

# 31. ¿Qué ganamos con esto?

Imaginemos que comenzamos con PostgreSQL:

```text
Application
     ↓
CustomerRepository
     ↑
PostgreSQL Adapter
```

Después decidimos utilizar otra tecnología.

Podemos tener:

```text
Application
     ↓
CustomerRepository
     ↑
MySQL Adapter
```

El caso de uso no debería cambiar.

De igual manera, para testing:

```text
Application
     ↓
CustomerRepository
     ↑
InMemoryCustomerRepository
```

Podemos probar la lógica de negocio sin necesitar una base de datos real.

---

# 32. Arquitectura como reglas

Una forma muy útil de pensar sobre arquitectura es convertirla en reglas.

Por ejemplo:

```text
RULE 1

Domain cannot import FastAPI.
```

```text
RULE 2

Domain cannot import SQLAlchemy.
```

```text
RULE 3

Application cannot depend directly on PostgreSQL.
```

```text
RULE 4

Infrastructure can implement Domain/Application interfaces.
```

```text
RULE 5

Presentation communicates with Application.
```

Entonces la arquitectura deja de ser solamente un dibujo.

Se convierte en una serie de **restricciones verificables**.

---

# 33. Revisar imports durante el desarrollo

Cada vez que agreguemos una dependencia importante podemos hacernos estas preguntas:

```text
¿Quién importa a quién?
```

Por ejemplo:

```text
presentation
      ↓
application
      ↓
domain
```

Correcto.

```text
infrastructure
      ↓
domain
```

Correcto.

Pero:

```text
domain
      ↓
infrastructure
```

Alerta.

Y:

```text
domain
      ↓
FastAPI
```

Alerta.

Y:

```text
application
      ↓
SQLAlchemy
```

Alerta si estamos intentando mantener una separación estricta.

---

# 34. La arquitectura debe evolucionar, pero con dirección

No debemos tener miedo de empezar con:

```text
main.py
routes.py
models.py
database.py
```

y posteriormente evolucionar.

Lo importante es que cada refactorización tenga un objetivo.

Por ejemplo:

```text
Problema:
routes.py es demasiado grande.

       ↓

Acción:
separar casos de uso.

       ↓

Problema:
services dependen directamente de SQLAlchemy.

       ↓

Acción:
introducir Repository abstraction.

       ↓

Problema:
Domain depende de SQLAlchemy.

       ↓

Acción:
separar Domain Model de Persistence Model.

       ↓

Resultado:
núcleo independiente de infraestructura.
```

Esta es una evolución arquitectónica real.

---

# 35. Una posible estructura final para nuestro CRM

Después de crecer, podríamos terminar con:

```text
crm-api/
│
├── docs/
│
├── scripts/
│
├── tests/
│   ├── unit/
│   └── integration/
│
├── src/
│   └── crm_api/
│       │
│       ├── core/
│       │   ├── config.py
│       │   └── dependencies.py
│       │
│       ├── customers/
│       │   ├── domain/
│       │   │   ├── customer.py
│       │   │   └── repository.py
│       │   │
│       │   ├── application/
│       │   │   ├── create_customer.py
│       │   │   └── get_customer.py
│       │   │
│       │   ├── infrastructure/
│       │   │   ├── models.py
│       │   │   └── sqlalchemy_repository.py
│       │   │
│       │   └── presentation/
│       │       ├── schemas.py
│       │       └── router.py
│       │
│       ├── contacts/
│       │   ├── domain/
│       │   ├── application/
│       │   ├── infrastructure/
│       │   └── presentation/
│       │
│       └── main.py
│
├── pyproject.toml
├── uv.lock
└── README.md
```

Esta estructura no es una receta universal.

Es simplemente una posible consecuencia de que el sistema haya adquirido suficiente complejidad como para justificar estas separaciones.

---

# 36. ¿Qué papel juega `uv`?

`uv` ayuda a gestionar el proyecto Python:

```text
uv
│
├── Python version
├── dependencies
├── virtual environment
├── package management
├── project metadata
└── lock file
```

Pero no decide si nuestro CRM utiliza:

```text
Layered Architecture
Feature-based Architecture
Clean Architecture
Hexagonal Architecture
DDD
```

Podemos utilizar `uv` con cualquiera de ellas.

Por ejemplo:

```text
uv
 ↓
Python project
 ↓
src layout
 ↓
FastAPI
 ↓
Clean Architecture
```

Son decisiones diferentes.

---

# 37. El mapa mental que conviene recordar

Cuando comencemos un proyecto nuevo, podemos pensar en estos niveles:

```text
1. PROJECT
   │
   ├── pyproject.toml
   ├── README
   ├── tests
   ├── docs
   └── src
         │
         ▼
2. APPLICATION STRUCTURE
         │
         ├── features
         │
         └── layers
                 │
                 ▼
3. ARCHITECTURE
         │
         ├── responsibilities
         ├── boundaries
         └── dependencies
                 │
                 ▼
4. PRINCIPLES
         │
         ├── Separation of Concerns
         ├── Single Responsibility
         ├── Dependency Inversion
         └── High Cohesion / Low Coupling
```

---

# 38. Checklist para estructurar un proyecto

Antes de crear una nueva carpeta, pregunta:

### Responsabilidad

```text
¿Qué responsabilidad tiene este código?
```

### Cohesión

```text
¿Qué otros componentes están estrechamente relacionados con él?
```

### Dependencias

```text
¿De quién necesita depender?
```

### Dirección

```text
¿Estoy haciendo que una capa interna dependa de una externa?
```

### Tecnología

```text
¿Este código necesita realmente conocer FastAPI,
SQLAlchemy, PostgreSQL, Redis, etc.?
```

### Evolución

```text
Si mañana cambio PostgreSQL por otra tecnología,
¿tendré que modificar mis reglas de negocio?
```

### Testing

```text
¿Puedo probar mi lógica de negocio sin levantar
toda la infraestructura?
```

Si la respuesta a esta última pregunta es "no", puede ser una señal de acoplamiento excesivo.

---

# 39. La idea más importante

No debemos obsesionarnos con tener la estructura "perfecta" desde el primer día.

Una buena arquitectura puede evolucionar.

Lo importante es que durante esa evolución mantengamos claras las fronteras.

Podemos comenzar:

```text
simple
```

y evolucionar:

```text
simple
  ↓
layered
  ↓
feature-based
  ↓
feature + layers
  ↓
Clean / Hexagonal
```

Pero debemos evitar que la evolución termine en:

```text
Domain
   ↓
SQLAlchemy
   ↓
FastAPI
   ↓
PostgreSQL
```

porque en ese punto nuestro supuesto "núcleo" ya conoce los detalles externos.

La dirección que queremos proteger es:

```text
          EXTERNAL DETAILS
                 │
                 ▼
          Presentation
                 │
                 ▼
           Application
                 │
                 ▼
              Domain
```

y cuando necesitemos infraestructura:

```text
Infrastructure
       │
       │ implements
       ▼
     Ports
       ▲
       │
   Application
```

---

# Conclusión

La arquitectura de un backend no consiste en memorizar una estructura de carpetas.

Consiste en entender **responsabilidades, límites y dependencias**.

Podemos usar FastAPI, ASP.NET Core 10 o Spring Boot 4. El framework cambia, pero los principios permanecen.

Podemos comenzar con un proyecto pequeño y sencillo.

Cuando crezca:

1. separamos responsabilidades;
2. agrupamos funcionalidades relacionadas;
3. introducimos capas cuando exista una razón;
4. definimos interfaces/ports cuando necesitemos invertir dependencias;
5. aislamos infraestructura;
6. protegemos el dominio de los frameworks y tecnologías externas.

La pregunta más importante durante una refactorización no debería ser:

> **"¿En qué carpeta pongo este archivo?"**

Sino:

> **"¿Qué responsabilidad tiene este código y hacia dónde deberían apuntar sus dependencias?"**

Esa pregunta es mucho más poderosa que cualquier estructura de directorios.