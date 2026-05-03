# 🏛️ Análisis Funcional Senior: LUXOR vs Titanes (Loyalfans & ManyVids)

**Documento para:** Stitch (Diseño), OpenCode (Frontend), Backend (Integración)
**Analista:** Senior Functional Analyst (10+ years exp)
**Alcance:** Módulos de Plataforma, Monetización, Interacción y Herramientas de Creadora.

---

## 1. Visión General de la Competencia

| Plataforma | DNA Principal | Feature "Hook" |
| :--- | :--- | :--- |
| **Loyalfans** | Interacción Social & Comunidad | **Shout Outs** & Perfil de Alto Impacto (Cherry Model) |
| **ManyVids** | E-commerce de Contenido | **Global Video Store** & Gestión de Media Masiva |
| **LUXOR** | LATAM Mobile-First (TikTok style) | **Diamantes & Métodos de Pago Locales** |

---

## 2. Módulo de Acceso y Registro (Onboarding)

### ❌ RF-AUTH-01: Registro con Toggle de Rol (Fan/Creador)
**Descripción:** Siguiendo el modelo de ManyVids, un único punto de entrada con un interruptor para definir el tipo de cuenta.

*   **User Story:** "Como nuevo usuario, quiero elegir si soy Fan o Creador en el mismo formulario para no perderme buscando links separados."
*   **Campos:** Username, Email, Password, Checkbox +18.
*   **Impacto Técnico:** El backend debe asignar el `role_id` correspondiente inmediatamente tras la validación del email.

### ❌ RF-AUTH-02: Login Social (Fricción Cero)
**Descripción:** Integración con **Google** y **X (Twitter)** para Fans. Los creadores deben registrarse vía email para vinculación legal del KYC.

### ❌ RF-PRIV-01: Centro de Seguridad y Geoblocking
**Descripción:** Herramienta crítica de privacidad que permite a la creadora ocultar su perfil en zonas geográficas específicas.

*   **Funcionalidad:** Bloqueo por **País** y **Estado/Región**.
*   **Impacto Técnico:** Requiere base de datos de Geo-IP (ej. MaxMind) actualizada para filtrar el acceso en el middleware de la aplicación.

**Wireframe ASCII (Geoblocking):**
```text
+-------------------------------------------------------------+
| CONFIGURACIÓN DE PRIVACIDAD                                 |
+-------------------------------------------------------------+
| [ ] Bloquear por País: [ Seleccionar País v ] [ Añadir ]    |
|     - 🇵🇪 Perú [ Eliminar ]                                  |
|     - 🇨🇴 Colombia [ Eliminar ]                              |
|                                                             |
| [ ] Bloquear por IP específica: [ 190.x.x.x ] [ Añadir ]    |
+-------------------------------------------------------------+
| [ Guardar Cambios ]                                         |
+-------------------------------------------------------------+
```

---

## 3. Matriz de Brechas (Gap Analysis)

| Módulo | Loyalfans/ManyVids | LUXOR (Estado Actual) | Estatus |
| :--- | :--- | :--- | :--- |
| **Marketplace de Video** | Tienda global con búsqueda por tags | Tienda por creadora (aislada) | 🔄 Needs Improvement |
| **Custom Content Requests** | Formulario estructurado "Shout Outs" | No contemplado | ❌ Missing |
| **Llamadas 1:1 (Video/Audio)** | Integrado (tarificado por minuto) | Solo Live Streaming masivo | ❌ Missing |
| **Herramientas de Marketing** | Media Kits, Códigos de Descuento | No contemplado | ❌ Missing |
| **Gamification** | Rankings, MV Awards, Contests | Sistema de Diamantes básico | 🔄 Needs Improvement |
| **CRM de Fans** | Notas sobre fans, tracking de gasto | Solo chat privado | ❌ Missing |

---

## 3. Especificación de Nuevos Requisitos (RFs Faltantes)

### ❌ RF-MARK-01: Global Video Marketplace (VOD Store)
**Descripción:** Un motor de búsqueda y descubrimiento donde el Fan puede comprar videos individuales de *cualquier* creadora sin necesidad de estar suscrito a su perfil.

*   **User Story:** "Como fan, quiero buscar 'videos de baile' y comprar uno de $5 sin tener que pagar una suscripción mensual de $15."
*   **Impacto Técnico:** Requiere indexación elástica (ElasticSearch/Meilisearch) para búsqueda rápida por etiquetas y categorías.

**Wireframe ASCII (Buscador Global):**
```text
+-------------------------------------------------------------+
| [Buscar videos: 'fitness'...] [Filtros: Precio | Duración] |
+-------------------------------------------------------------+
| +--------------+  +--------------+  +--------------+        |
| | [Video Preview]|  | [Video Preview]|  | [Video Preview]|        |
| | $5.99 [Buy]  |  | $9.00 [Buy]  |  | $4.50 [Buy]  |        |
| | @creadora_1  |  | @creadora_2  |  | @creadora_3  |        |
| +--------------+  +--------------+  +--------------+        |
+-------------------------------------------------------------+
```

### ❌ RF-INT-01: Módulo "Shout Outs" (Videos Personalizados)
**Descripción:** Flujo formal para solicitar contenido a medida. La creadora define un "Menú de Custom" con precios y tiempos de entrega.

*   **Casos de Uso:** Pedir un saludo de cumpleaños, una rutina de ejercicio específica o contenido NSFW personalizado.
*   **Validaciones:**
    1.  Pago retenido (Escrow) hasta que la creadora sube el video.
    2.  Tiempo de expiración: Si la creadora no entrega en X días, reembolso automático.
    3.  Límite de caracteres en la descripción del pedido.

### ❌ RF-PROM-01: Herramientas de Crecimiento (Media Kit & Promos)
**Descripción:** Sistema para que la creadora genere cupones de descuento y una página de "Media Kit" con sus estadísticas para marcas o referidos.

*   **User Story:** "Como creadora, quiero crear un cupón 'BIENVENIDA50' para que mis nuevos fans tengan 50% de descuento el primer mes."

---

## 4. Requisitos que Necesitan Mejora (🔄 Improvements)

### 🔄 RF-GAM-01: Gamificación y Rankings Segmentados
**Mejora:** El sistema de rankings debe estar categorizado por sección para fomentar la competencia sana y el reconocimiento dentro de nichos específicos.

*   **Categorías de Ranking:** Adult, Music, Gaming, Beauty, Influencer, Art, Fitness.
*   **Segmentación:** 
    1.  **Top Fans del Mes:** Basado en diamantes enviados/gastados dentro de una categoría específica.
    2.  **Top Creadoras:** Basado en ingresos generados o crecimiento de suscriptores en su categoría principal.
*   **User Story:** "Como fan de Gaming, quiero aparecer en el Top 10 de mi sección favorita para que mi streamer favorito reconozca mi apoyo."

**Wireframe ASCII (Ranking por Sección):**
```text
+-------------------------------------------------------------+
| RANKING DE CREADORAS / FANS                                 |
| [ Adult ] [ Music ] [ >Gaming< ] [ Beauty ] [ Influencer ]  |
+-------------------------------------------------------------+
| # | CREADORA (Gaming)      | # | TOP FANS (Gaming)         |
|---|------------------------|---|---------------------------|
| 1 | @ProGamer_X [Live]     | 1 | @Donador_1 (💎 5000)      |
| 2 | @SpeedRunner_9 [New]   | 2 | @GamerGirl_8 (💎 3200)    |
| 3 | @Esports_Coach         | 3 | @Lucky_Fan (💎 2100)      |
+-------------------------------------------------------------+
```

---

## 5. Diseño del Perfil de Creadora (Modelo LUXOR "Impact")
*Inspirado en los perfiles top de Loyalfans.*

### 💎 RF-PRO-01: Header Dinámico y Social
**Descripción:** El perfil debe proyectar estatus y facilitar la conversión inmediata.

*   **Elementos del Encabezado:**
    1.  **Banner Full-Width:** Imagen de marca personal.
    2.  **Avatar Circular con Aura:** Borde de color que indica "Live" o "Estado Online".
    3.  **Botones de Acción Inmediata (CTAs):** Ubicados bajo el banner: `Propina 💎`, `Mensaje 💬`, `Shout Out 📹`.
    4.  **Bio Segmentada:** Tags clickeables (#Fitness, #Dance), Ubicación y Contador de Fans.

### 🔒 RF-PRO-02: Sistema de "Login Gate" en Videoteca
**Descripción:** Siguiendo el flujo de Loyalfans, la navegación por el catálogo de la Videoteca debe disparar un modal de registro si el usuario es anónimo.

### 🖼️ RF-PRO-03: Post de "Doble Conversión"
**Descripción:** Cada publicación bloqueada en el feed debe ofrecer dos caminos de monetización simultáneos.

*   **Botón A (Suscripción):** "Suscribirse por $X/mes" (Acceso a todo el perfil).
*   **Botón B (Unlock PPV):** "Desbloquear este video por $Y" (Pago único).
*   **Interacciones:** Corazón (Like), Comentarios, Compartir y el botón de **Propina Rápida** con icono de Diamante.

**Wireframe ASCII (Perfil de Creadora):**
```text
+-----------------------------------------------------------+
| [ BANNER DE MARCA PERSONAL (HIGH RES) ]                   |
|  +----+  @Username [Online]                               |
|  | AV |  Bio: Tags #Latam #Music | 8.2k Fans              |
|  +----+                                                   |
+-----------------------------------------------------------+
| [ Suscribirse $14 ] [ Tip 💎 ] [ Mensaje ] [ Shout Out ]  |
+-----------------------------------------------------------+
| [ Feed ] [ >Videoteca< ] [ Shout Outs ] [ About ]         |
+-----------------------------------------------------------+
| +----------+  +----------+  +----------+                  |
| | Video $5 |  | Video $9 |  | Video $4 |  <-- Videoteca   |
| | [ Lock ] |  | [ Lock ] |  | [ Lock ] |     Grid         |
| +----------+  +----------+  +----------+                  |
+-----------------------------------------------------------+
```

---

## 6. Diseño de Interfaz: El Modelo Híbrido LUXOR

Para maximizar la retención y la conversión, LUXOR adoptará una estructura de navegación dual:

### 📱 RF-UI-01: Discovery Feed (Scroll Vertical)
**Pantalla Principal (Default):** Flujo infinito estilo TikTok.
*   **Objetivo:** Descubrimiento orgánico y compra impulsiva de micro-PPV.
*   **Interacción:** Swipe arriba/abajo, doble tap para like, botón lateral de "Desbloquear" si el contenido es de pago.

### 🎥 RF-UI-02: Videoteca (Grilla de Selección)
**Sección de Catálogo:** Una grilla organizada accesible desde el buscador o el perfil.
*   **Objetivo:** Compra intencional y búsqueda por categorías/tags.
*   **Funcionalidad:** Filtros por duración, precio y fecha.

**Wireframe ASCII (Home Hybrid):**
```text
+-----------------------+      +-----------------------+
| [ Para Ti ] [Videoteca]|      | [Videoteca]  [Buscador]|
+-----------------------+      +-----------------------+
|                       |      | +-----+ +-----+ +-----+ |
|      TIKTOK STYLE     |      | | Vid | | Vid | | Vid | |
|      FULL SCREEN      |  =>  | +-----+ +-----+ +-----+ |
|        FEED           |      | | Vid | | Vid | | Vid | |
|                       |      | +-----+ +-----+ +-----+ |
+-----------------------+      +-----------------------+
```

---

## 6. Módulo de Creación y Carga de Contenido

### 📤 RF-UPL-01: Gestor de Carga Multimedia (Fotos/Videos)
**Descripción:** Interfaz unificada para subir contenido al Feed, Videoteca o Bóveda.

*   **Especificaciones Técnicas:**
    1.  **Videos:** Soporte MP4/MOV, hasta 2GB, generación automática de 3 miniaturas sugeridas.
    2.  **Fotos:** Soporte JPG/PNG/WebP, carga masiva para creación de "Álbumes/Packs".
    3.  **Protección:** Aplicación de blur automático y marca de agua (Watermark) en el pre-renderizado.
    4.  **Monetización:** Campo de "Precio" para convertir el contenido en PPV inmediatamente.

### 🔴 RF-LIVE-01: Live Streaming Pro
**Descripción:** Motor de transmisión en vivo con herramientas de monetización en tiempo real.

*   **Funcionalidades Clave:**
    1.  **Metas de Diamantes:** Barra de progreso visible (ej. "500💎 para baile especial").
    2.  **Entrada de Pago:** Opción de cobrar X diamantes para ingresar al Live.
    3.  **Chat Interactivo:** Prioridad en el chat para fans con mayor nivel de gasto.
    4.  **Grabación:** Guardar el stream automáticamente en la Videoteca al finalizar para venta posterior.

---

## 7. Plan de Implementación y Estimaciones

| Prioridad | Módulo | Descripción | Esfuerzo (Semanas) | Dependencia |
| :--- | :--- | :--- | :--- | :--- |
| **P0 (MVP)** | **Global Marketplace** | Buscador y checkout de clips VOD | 3 | Backend VOD |
| **P0 (MVP)** | **Geoblocking** | Bloqueo por país/región (Middleware) | 1 | GeoIP DB |
| **P0 (MVP)** | **Onboarding Toggle** | Registro unificado Fan/Creador | 1 | Auth Logic |
| **P0 (MVP)** | **Hybrid UI (Feed/Videoteca)**| Navegación dual App/Web | 3 | Frontend Logic |
| **P0 (MVP)** | **Media Upload** | Gestor de videos/fotos + PPV | 2 | Cloud Storage |
| **P1 (High)** | **Live Streaming** | Transmisión + Metas de Diamantes | 4 | Media Server |
| **P1 (High)** | **Vault & Watermark** | Repositorio de media + protección | 3 | Cloud Storage |
| **P2 (Med)** | **Fan CRM** | Segmentación y notas de fans | 2 | DB Schema |
| **P2 (Med)** | **Segmented Rankings**| Leaderboards por categoría | 2 | Backend Analytics |
| **P2 (Med)** | **1:1 Calls** | Integración WebRTC para llamadas | 4 | Media Server |
| **P3 (Nice)** | **Fan CRM** | Notas y segmentación de fans | 1 | DB Schema |

---

## 6. Recomendaciones Estratégicas

1.  **Stitch (Wireframes):** Priorizar la vista de "Video Store" ya que es el mayor generador de ingresos transaccionales (no recurrentes).
2.  **OpenCode (Frontend):** Implementar componentes de "Carga de Pedido" para Shout Outs con estados claros (Pendiente, En Proceso, Entregado).
3.  **Backend:** Diseñar la lógica de **Escrow** para asegurar que el dinero solo se libere cuando la creadora cumpla con la entrega del contenido personalizado.

---
*Documento evolucionado v0.2 - LUXOR Platform Intelligence*
