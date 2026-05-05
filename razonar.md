# Sistema de Razonamiento, Arquitectura Limpia y Eventos (Backend & Frontend)

Antes de generar una sola línea de código para cualquier tarea, debes ejecutar un análisis obligatorio y documentarlo bajo el encabezado `## 🧠 Fase de Razonamiento`. No omitas ningún paso.

## 🧠 Fase de Razonamiento

### 1. Requisitos, Arquitectura y Casos Límite
- **Contexto del Proyecto:** Identifica si la tarea aplica a **Backend** (Clean Architecture + EDA) o **Frontend** (Clean Architecture + EDA + Gestión de Estado).
- **Entradas y Salidas:** Especifica tipos de datos, formatos esperados, contratos de eventos y restricciones.
- **Casos límite (Edge Cases):** Identifica escenarios críticos (eventos duplicados, fallos de red, estados inválidos, valores nulos).

### 2. Diseño de Arquitectura Limpia y Eventos (EDA)
- **Backend (Clean Architecture):** Define la separación por capas:
  - *Dominio:* Entidades, eventos de dominio e interfaces de repositorios/event-bus.
  - *Aplicación:* Casos de uso (Use Cases) y manejadores de eventos (Event Handlers).
  - *Infraestructura:* Implementación de adaptadores (Bases de datos, Kafka, RabbitMQ, etc.).
- **Frontend (Clean Architecture & Estado):**
  - *Dominio/Aplicación:* Casos de uso e interfaces.
  - *Estado y Eventos:* Define cómo se capturan los eventos (ej. CustomEvents, EventBus centralizado) y cómo actualizan el estado de la UI de forma inmutable y reactiva.

### 3. Prevención de Errores de Compilación
- **Tipado estricto:** Especifica tipos e interfaces completas (evita el uso de `any` o tipados genéricos ambiguos).
- **Importaciones válidas:** Verifica que todas las dependencias y módulos existan y estén correctamente importados.

---

## 💻 Fase de Implementación
*Una vez completada la fase de razonamiento, escribe el código bajo el encabezado `## 💻 Código de Producción`.*

- **Manejo de errores:** Implementa bloques try/catch robustos, validaciones previas y políticas de reintento para eventos fallidos.
- **Código modular:** Cada clase o función debe tener una única responsabilidad (Single Responsibility Principle).

---

## 🧪 Fase de Testing y Verificación
*Al terminar el desarrollo del código, genera obligatoriamente la sección `## 🧪 Pruebas Unitarias e Integración`.*

- **Tests de Backend:** Crea tests unitarios para los casos de uso de la capa de aplicación y tests de integración para la publicación/suscripción de eventos.
- **Tests de Frontend:** Crea tests unitarios para el manejador de estados y el flujo de eventos en la UI (ej. con Testing Library).
- **Casos a probar:** Valida al menos un flujo de éxito (Happy Path) y dos flujos de error o casos límite identificados en la fase 1.
