# LUXOR - ESPECIFICACIONES PARA GEMINI (Frontend)

**Responsabilidad:** Frontend, UI/UX, Responsive design, Landing page, Dashboards, Integraciones UI  
**Plazo:** 7 días MVP  
**Stack:** React 18+, Tailwind CSS, React Router, Axios, Socket.io-client

---

## 🎯 RFs ASIGNADOS A GEMINI

- **RF-001:** REGISTRO DE USUARIOS (Frontend)
- **RF-002:** REGISTRO DE CREADORAS (Frontend)
- **RF-003:** HOME PAGE / FEED (Frontend)
- **RF-004:** PERFIL DE CREADORA (Frontend)
- **RF-005:** SUSCRIPCIÓN (Frontend + Modal checkout)
- **RF-007:** DASHBOARD DE CREADORA (Frontend)
- **RF-008:** SUBIR CONTENIDO (Frontend + Upload)
- **RF-009:** CHAT PRIVADO (Frontend + UI)
- **RF-010:** TIPS / PROPINAS (Frontend + Modal)
- **RF-012:** GASTAR DIAMANTES EN CONTENIDO (Frontend)
- **RF-015:** TIENDA DE DIAMANTES (Frontend)
- **RF-016:** BALANCE DE DIAMANTES (Frontend - Widget)

---

## 🎨 DISEÑO SYSTEM

### PALETA DE COLORES
```css
:root {
  /* Primarios */
  --color-primary: #667eea;        /* Púrpura principal */
  --color-primary-dark: #764ba2;   /* Púrpura oscuro */
  --color-primary-light: #8b9eff;  /* Púrpura claro */
  
  /* Secundarios */
  --color-success: #10b981;        /* Verde */
  --color-danger: #dc2626;         /* Rojo */
  --color-warning: #f59e0b;        /* Ámbar */
  --color-info: #3b82f6;           /* Azul */
  
  /* Neutros */
  --color-bg-primary: #ffffff;
  --color-bg-secondary: #f5f5f5;
  --color-bg-tertiary: #eeeeee;
  --color-text-primary: #333333;
  --color-text-secondary: #666666;
  --color-border: #dddddd;
  
  /* Especiales */
  --color-diamond: #ffd700;        /* Dorado para diamantes */
  --color-overlay: rgba(0,0,0,0.5);
  
  /* Gradientes */
  --gradient-primary: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  --gradient-light: linear-gradient(135deg, #8b9eff 0%, #a78bfa 100%);
}
```

### TIPOGRAFÍA
```css
/* Familia */
--font-sans: 'Inter', 'Segoe UI', sans-serif;
--font-mono: 'Monaco', 'Courier New', monospace;

/* Tamaños */
--text-xs: 0.75rem;    /* 12px */
--text-sm: 0.875rem;   /* 14px */
--text-base: 1rem;     /* 16px */
--text-lg: 1.125rem;   /* 18px */
--text-xl: 1.25rem;    /* 20px */
--text-2xl: 1.5rem;    /* 24px */
--text-3xl: 1.875rem;  /* 30px */
--text-4xl: 2.25rem;   /* 36px */

/* Pesos */
--font-thin: 100;
--font-light: 300;
--font-normal: 400;
--font-medium: 500;
--font-semibold: 600;
--font-bold: 700;
--font-extrabold: 800;
```

### ESPACIADO (8px base)
```css
--spacing-0: 0;
--spacing-1: 0.25rem;   /* 2px */
--spacing-2: 0.5rem;    /* 4px */
--spacing-3: 0.75rem;   /* 6px */
--spacing-4: 1rem;      /* 8px */
--spacing-6: 1.5rem;    /* 12px */
--spacing-8: 2rem;      /* 16px */
--spacing-10: 2.5rem;   /* 20px */
--spacing-12: 3rem;     /* 24px */
--spacing-16: 4rem;     /* 32px */
--spacing-20: 5rem;     /* 40px */
```

### COMPONENTES BASE

#### Button
```jsx
<button 
  className="px-6 py-2 bg-primary text-white rounded-lg font-medium hover:bg-primary-dark transition-all duration-200"
>
  Accionar
</button>

// Variantes
// - Primary (filled)
// - Secondary (outline)
// - Ghost (no background)
// - Disabled
// - Loading
// - Small/Medium/Large
```

#### Input
```jsx
<input 
  type="email"
  placeholder="tu@email.com"
  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:border-primary focus:ring-2 focus:ring-primary/20"
  onChange={(e) => handleChange(e)}
/>

// Con error
<div className="relative">
  <input className="border-red-500" />
  <span className="text-red-500 text-sm mt-1">Error message</span>
</div>
```

#### Modal
```jsx
<div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
  <div className="bg-white rounded-xl p-8 max-w-md w-full mx-4 shadow-xl">
    {/* Contenido */}
  </div>
</div>
```

---

## 📱 BREAKPOINTS RESPONSIVE

```css
/* Mobile First */
$mobile: 0;           /* < 640px */
$sm: 640px;          /* Tablet pequeño */
$md: 768px;          /* Tablet */
$lg: 1024px;         /* Desktop */
$xl: 1280px;         /* Desktop grande */
$2xl: 1536px;        /* Ultra wide */

/* Uso en Tailwind */
<div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3">
  {/* 1 col mobile, 2 tablet, 3 desktop */}
</div>
```

---

## 📂 ESTRUCTURA DE CARPETAS

```
src/
├── assets/
│   ├── images/
│   ├── icons/
│   └── logos/
├── components/
│   ├── Auth/
│   │   ├── RegisterForm.jsx
│   │   ├── LoginForm.jsx
│   │   ├── VerifyEmailModal.jsx
│   │   └── InfluencerRegisterForm.jsx
│   ├── Header/
│   │   ├── Navbar.jsx
│   │   └── MobileMenu.jsx
│   ├── Feed/
│   │   ├── CreatorCard.jsx
│   │   ├── FeedGrid.jsx
│   │   └── TrendingSidebar.jsx
│   ├── Creator/
│   │   ├── ProfileHeader.jsx
│   │   ├── PhotoGallery.jsx
│   │   └── SubscribeButton.jsx
│   ├── Dashboard/
│   │   ├── ConsumerDashboard.jsx
│   │   ├── InfluencerDashboard.jsx
│   │   ├── EarningsWidget.jsx
│   │   └── AnalyticsChart.jsx
│   ├── Chat/
│   │   ├── ChatWindow.jsx
│   │   ├── MessageList.jsx
│   │   └── MessageInput.jsx
│   ├── Diamond/
│   │   ├── DiamondStore.jsx
│   │   ├── DiamondPackage.jsx
│   │   └── DiamondBalance.jsx
│   ├── Common/
│   │   ├── Modal.jsx
│   │   ├── Button.jsx
│   │   ├── Input.jsx
│   │   ├── Card.jsx
│   │   └── Loading.jsx
│   └── Upload/
│       └── PhotoUploader.jsx
├── hooks/
│   ├── useAuth.js
│   ├── useFetch.js
│   ├── useInfiniteScroll.js
│   └── useSocket.js
├── services/
│   ├── api.js
│   ├── auth.js
│   ├── creators.js
│   ├── subscriptions.js
│   ├── diamonds.js
│   └── chat.js
├── context/
│   ├── AuthContext.jsx
│   ├── UserContext.jsx
│   └── SocketContext.jsx
├── pages/
│   ├── Landing.jsx
│   ├── Register.jsx
│   ├── Login.jsx
│   ├── Home.jsx
│   ├── CreatorProfile.jsx
│   ├── Dashboard.jsx
│   ├── DiamondStore.jsx
│   ├── Checkout.jsx
│   └── NotFound.jsx
├── styles/
│   ├── globals.css
│   ├── variables.css
│   └── animations.css
├── utils/
│   ├── validation.js
│   ├── formatters.js
│   ├── constants.js
│   └── helpers.js
└── App.jsx
```

---

## 🎬 PÁGINAS PRINCIPALES

### 1. LANDING PAGE (`/`)

**Secciones:**
- **Hero:** CTA principal, imagen fondo
- **Features:** 3-4 características clave
- **Stats:** Números impactantes (usuarios, creadoras, etc)
- **CTA Footer:** Botones [Registrarse] [Iniciar sesión]

**Layout:**
```
┌─────────────────────────────────────────┐
│        NAVBAR (Logo, Auth links)        │
├─────────────────────────────────────────┤
│                                         │
│   HERO (50vh)                           │
│   "Monetiza tu contenido"               │
│   [Soy suscriptor] [Soy creadora]      │
│                                         │
├─────────────────────────────────────────┤
│   FEATURES (3 columnas)                 │
├─────────────────────────────────────────┤
│   STATS                                 │
├─────────────────────────────────────────┤
│        FOOTER                           │
└─────────────────────────────────────────┘
```

---

### 2. REGISTRO - CONSUMIDOR (`/auth/register`)

**Flujo:**
```
┌─────────────────────────────────────────┐
│   ← Volver  |  Crear cuenta             │
├─────────────────────────────────────────┤
│                                         │
│  Email          [input]                │
│  Contraseña     [input] [👁️]            │
│  Confirmar      [input] [👁️]            │
│  Nombre         [input]                │
│  Teléfono       [input 9XXXXXXXXX]     │
│  Fecha nacim.   [date picker]          │
│                                         │
│  [✓] Tengo 18+ años                    │
│  [✓] Acepto términos y condiciones     │
│  [✓] Acepto política de privacidad     │
│                                         │
│  [CREAR CUENTA - DISABLED until valid]  │
│                                         │
│  ¿Ya tienes cuenta? [Inicia sesión]    │
│                                         │
└─────────────────────────────────────────┘
```

**Validaciones Real-time:**
- Email: ✓/✗ al salir del campo
- Contraseña: Medidor de fortaleza (Débil → Fuerte)
- Teléfono: Máscara automática
- Fecha: Calcula edad y muestra error si < 18
- Botón habilita SOLO si TODO válido

**Password strength indicator:**
```
Contraseña:  [▮▮▮▯▯] Fuerte
             Requisitos:
             ✓ 8+ caracteres
             ✓ Mayúscula
             ✓ Minúscula
             ✓ Número
             ✓ Símbolo
```

---

### 3. VERIFICACIÓN EMAIL (`/auth/verify-email`)

```
┌─────────────────────────────────────────┐
│      Verifica tu email                  │
├─────────────────────────────────────────┤
│                                         │
│  Enviamos un código a:                 │
│  usuario@example.com                   │
│                                         │
│  Ingresa el código de 6 dígitos:        │
│  [_] [_] [_] [_] [_] [_]               │
│                                         │
│  Expira en: 00:23:45 (countdown)       │
│                                         │
│  [VERIFICAR]                            │
│                                         │
│  ¿No llegó? [Reenviar] (3/3 disponibles)│
│                                         │
└─────────────────────────────────────────┘
```

---

### 4. HOME / FEED (`/home`)

**Layout:**
```
┌──────────────────────────────────────────┐
│ Logo    Search    Account ▼             │
├────────────────────────┬─────────────────┤
│                        │                 │
│   Feed                 │   Trending 🔥   │
│   (Scroll infinito)    │   1. Usuario A  │
│                        │   2. Usuario B  │
│   [Card]               │   3. Usuario C  │
│   [Card]               │   ...           │
│   [Card]               │                 │
│   (Loading...)         │                 │
│                        │                 │
└────────────────────────┴─────────────────┘
```

**Creator Card:**
```
┌─────────────────────────┐
│   [Image preview]       │
├─────────────────────────┤
│ Nombre creadora         │
│ ⭐ 4.9 (342 reviews)    │
│ 1,250 suscriptores      │
│                         │
│ [Suscribirse] [Ver +]  │
└─────────────────────────┘
```

**Search:**
- Búsqueda con debounce (300ms)
- Resultados en tiempo real
- Mostrar: imagen, nombre, rating

**Trending Sidebar:**
- Top 10 creadoras
- Actualiza cada hora
- Icono 🔥 o 📈
- Click → perfil

---

### 5. PERFIL CREADORA (`/creadora/:username`)

**Layout:**
```
┌──────────────────────────────────────────┐
│ ← Volver                                 │
├──────────────────────────────────────────┤
│   [Profile pic]  Nombre                 │
│                  ⭐ 4.9 (342)            │
│                  1,250 suscriptores     │
│                  Bio...                  │
│                                          │
│   [Suscribirse] [Chat] [Tips] [...]     │
│                                          │
│   GALERÍA (3 cols desktop, 2 tablet)    │
│   [Thumb] [Thumb] [Thumb]               │
│   [Thumb] [Thumb] [Thumb]               │
│                                          │
│   (Lazy load en scroll)                 │
│                                          │
└──────────────────────────────────────────┘
```

**Foto con watermark (sin suscripción):**
```
┌────────────────────────┐
│                        │
│   [Imagen + Watermark] │
│   🔒 Suscribirse       │
│                        │
└────────────────────────┘
```

---

### 6. DASHBOARD CONSUMIDOR (`/dashboard`)

**Tabs:**
- **Resumen** (default)
- **Mis diamantes**
- **Historial**
- **Perfil**

**Sección RESUMEN:**
```
┌────────────────────────────────────────┐
│  RESUMEN                               │
├────────────────────────────────────────┤
│  Diamantes: 150 💎                     │
│  [Comprar más]                         │
│                                        │
│  Suscripciones activas: 3              │
│  - @creadora1 (Premium)                │
│  - @creadora2 (Basic)                  │
│  - @creadora3 (VIP)                    │
│                                        │
│  Historial reciente:                   │
│  • Hace 2h: Compra de contenido        │
│  • Ayer: Envío de tip S/ 50            │
│                                        │
└────────────────────────────────────────┘
```

---

### 7. DASHBOARD CREADORA (`/dashboard/influencer`)

**Secciones:**
```
┌────────────────────────────────────────┐
│  RESUMEN (Cards)                       │
│  ┌──────┐ ┌──────┐ ┌──────┐           │
│  │Ganado│ │Suscr.│ │Rating│           │
│  │Hoy:  │ │Activ.│ │4.9⭐ │           │
│  │S/150 │ │250   │ │(342) │           │
│  └──────┘ └──────┘ └──────┘           │
│                                        │
│  GANANCIAS (Gráfico últimos 7 días)    │
│  [Chart]                               │
│                                        │
│  RETIRAR DINERO                        │
│  Balance: S/ 1,250.00                  │
│  YAPE: *-**-4567                       │
│  [RETIRAR] [CONVERTIR 💎]             │
│                                        │
│  TRANSACCIONES HOY                     │
│  User A se suscribió - S/ 19.99        │
│  User B envió tip - S/ 50.00           │
│  Total: S/ 69.99                       │
│                                        │
│  CONTENIDO                             │
│  [+ Subir foto]                        │
│  [Tus fotos...]                        │
│                                        │
└────────────────────────────────────────┘
```

---

### 8. TIENDA DE DIAMANTES (`/diamantes`)

**Layout:**
```
┌──────────────────────────────────────────┐
│ ← Volver  |  Tu balance: 150 💎         │
├──────────────────────────────────────────┤
│                                          │
│  PAQUETES (Grid 2x2 desktop, 1x1 mobile)│
│                                          │
│  ┌─────────────┐  ┌─────────────┐      │
│  │  50 💎      │  │ 150 💎      │      │
│  │  S/ 9.99    │  │ S/ 24.99    │      │
│  │ "Entrada"   │  │ "+15% BONUS"│      │
│  │ [COMPRAR]   │  │ [POPULAR]   │      │
│  └─────────────┘  └─────────────┘      │
│                                          │
│  ┌─────────────┐  ┌─────────────┐      │
│  │ 350 💎      │  │1000 💎      │      │
│  │ S/ 49.99    │  │S/ 129.99    │      │
│  │ "+30% BONUS"│  │"+40% BONUS" │      │
│  │ [COMPRAR]   │  │[MEGA AHORRO]│      │
│  └─────────────┘  └─────────────┘      │
│                                          │
│  ¿QUÉ SON LOS DIAMANTES?                │
│  • 1 💎 = S/ 0.10                       │
│  • Desbloquea contenido exclusivo       │
│  • Envía tips mejorados                 │
│                                          │
│  TUS COMPRAS RECIENTES                  │
│  Fecha    | Paquete | Precio | Status  │
│  01/05    | 150 💎  | S/.25  | ✓       │
│  29/04    | 350 💎  | S/.50  | ✓       │
│                                          │
└──────────────────────────────────────────┘
```

---

### 9. MODAL SUSCRIPCIÓN (RF-005)

```
┌──────────────────────────────────┐
│ ✕                                │
│  Planes de suscripción           │
│                                  │
│  ┌──────────────────────────┐   │
│  │ Basic       Premium   VIP│   │
│  │ S/ 9.99/m   S/.20/m  S/.50│  │
│  │ ○           ●         ○  │   │
│  │                            │   │
│  │ MÉTODO DE PAGO:            │   │
│  │ [✓] YAPE  [ ] PLIN         │   │
│  │ [ ] Tarjeta                │   │
│  │                            │   │
│  │ [CONTINUAR A PAGO]         │   │
│  └──────────────────────────┘   │
└──────────────────────────────────┘
```

---

### 10. MODAL TIPS (RF-010)

```
┌────────────────────────────────┐
│ ✕                              │
│ Enviar tip a @creadora         │
│                                │
│ MONTO RÁPIDO:                  │
│ [S/ 5] [S/ 10] [S/ 20]        │
│                                │
│ O CANTIDAD PERSONALIZADA:      │
│ [_______________] S/           │
│                                │
│ MENSAJE (opcional):            │
│ [________________]            │
│                                │
│ [ENVIAR]                       │
│                                │
└────────────────────────────────┘
```

---

### 11. CHAT PRIVADO (RF-009)

**Layout:**
```
┌────────────────────────────────┐
│ ← @creadora  |  [☎️] [...]    │
├────────────────────────────────┤
│                                │
│ HISTORIAL DE MENSAJES:         │
│                                │
│          [Tu mensaje]     →    │
│          [Hace 2h]             │
│                                │
│ ←              [Su respuesta]  │
│                Hace 1h         │
│                                │
│ está escribiendo...            │
│                                │
├────────────────────────────────┤
│ [Emoji] [📎] [Escribe aquí...] [Send]│
│                                │
└────────────────────────────────┘
```

**Features:**
- Historial scrolleable
- Timestamps
- Typing indicator
- Emoji picker
- Read receipts (opcional)

---

### 12. UPLOAD FOTOS (RF-008)

```
┌──────────────────────────────────┐
│ + Subir foto                     │
├──────────────────────────────────┤
│                                  │
│ [Arrastra o clica para selec.]  │
│ [Drop zone - 200x200px mínimo]  │
│                                  │
│ Descripción (opcional):          │
│ [________________]              │
│                                  │
│ VISIBILIDAD:                     │
│ [✓] Libre (preview público)     │
│ [ ] Solo suscriptores           │
│ [ ] PPV (precio en diamantes)   │
│   Precio: [___] 💎              │
│                                  │
│ [SUBIR]  [CANCELAR]             │
│                                  │
│ Progreso: [████████░░] 80%      │
│                                  │
└──────────────────────────────────┘
```

---

## 🔄 FLUJOS DE USUARIO

### Flujo 1: Nuevo usuario → Suscriptor
```
Landing → [Registrarse] → Registro form → 
Verificar email → Login → Home/Feed → 
Buscar creadora → Perfil creadora → 
[Suscribirse] → Modal planes → Checkout → 
Dashboard con acceso
```

### Flujo 2: Nuevo usuario → Creadora
```
Landing → [Soy creadora] → Registro form → 
Verificar email → Registro creadora → 
Dashboard creadora → [Subir foto] → 
Upload form → Dashboard → Esperar 
suscriptores
```

### Flujo 3: Compra de diamantes
```
Dashboard → [Comprar diamantes] → 
Tienda → Seleccionar paquete → 
Checkout → Pago completado → 
Balance actualizado
```

---

## 🎯 COMPONENTES A CREAR

**Prioritarios (Día 1-2):**
- [ ] Navbar
- [ ] RegisterForm
- [ ] LoginForm
- [ ] Button (todas variantes)
- [ ] Input (todas variantes)
- [ ] Modal

**Día 3-4:**
- [ ] CreatorCard
- [ ] FeedGrid
- [ ] ProfileHeader
- [ ] PhotoGallery
- [ ] DashboardCard

**Día 5-6:**
- [ ] ChatWindow
- [ ] DiamondStore
- [ ] PhotoUploader
- [ ] AnalyticsChart

**Día 7:**
- [ ] Testing
- [ ] Responsividad
- [ ] Optimizaciones

---

## 📊 ANALYTICS & TRACKING

```javascript
// Eventos a trackear
trackEvent('user_registered', { userType: 'consumer' });
trackEvent('creator_registered');
trackEvent('subscription_clicked', { creatorId, planType });
trackEvent('diamond_purchase', { packageSize, amount });
trackEvent('content_unlocked', { contentId, method: 'diamonds' });
```

---

## 🚀 STACK RECOMENDADO

**React & Routing:**
- react ^18.2.0
- react-router-dom ^6.20.0
- react-dom ^18.2.0

**Styling:**
- tailwindcss ^3.3.0
- @tailwindcss/forms ^0.5.7
- postcss ^8.4.30

**HTTP & Real-time:**
- axios ^1.6.0
- socket.io-client ^4.5.4

**Formularios & Validación:**
- react-hook-form ^7.48.0
- zod ^3.22.4

**Utilidades:**
- date-fns ^2.30.0
- clsx ^2.0.0
- zustand ^4.4.0 (State management)

**Dev Tools:**
- vite ^5.0.0
- eslint ^8.55.0
- prettier ^3.1.0

---

## 📱 MOBILE FIRST APPROACH

```jsx
// Siempre pensar mobile first
<div className="
  grid grid-cols-1        // mobile: 1 column
  sm:grid-cols-2         // sm: 2 columns
  md:grid-cols-3         // md: 3 columns
  lg:grid-cols-4         // lg: 4 columns
">
```

---

## ⚡ PERFORMANCE TARGETS

- **FCP (First Contentful Paint):** < 1.5s
- **LCP (Largest Contentful Paint):** < 2.5s
- **CLS (Cumulative Layout Shift):** < 0.1
- **Lighthouse Score:** > 90

**Optimizaciones:**
- Code splitting por rutas
- Lazy loading de imágenes
- Compresión de assets
- Cacheo agresivo

---

## 📋 CHECKLIST SEMANAL

**Día 1:**
- [ ] Estructura proyecto + componentes base
- [ ] Navbar + Landing page
- [ ] Rutas básicas

**Día 2:**
- [ ] Formularios registro/login
- [ ] Validación real-time
- [ ] Página verificación email

**Día 3:**
- [ ] Home/Feed + infinite scroll
- [ ] Perfil creadora
- [ ] Búsqueda con debounce

**Día 4:**
- [ ] Dashboard consumidor
- [ ] Dashboard creadora
- [ ] Widgets de estadísticas

**Día 5:**
- [ ] Chat privado (Socket.io)
- [ ] Upload de fotos
- [ ] Modals (suscripción, tips)

**Día 6:**
- [ ] Tienda diamantes
- [ ] Balance de diamantes
- [ ] Responsividad ajustes

**Día 7:**
- [ ] Testing
- [ ] Bug fixes
- [ ] Optimizaciones
- [ ] Deploy staging

---

**Documento generado para GEMINI - Frontend Lead**