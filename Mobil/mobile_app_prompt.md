# 🚀 PROMPT PARA CLAUDE/OPENCODE - APP MOBILE

Copia y pega este prompt completo en Claude, Gemini, o OpenCode.

---

## PROMPT COMPLETO:

```
PROYECTO: LUXOR Mobile App - Plataforma de Contenido Sensual Premium
TECNOLOGÍA: React Native + Expo (Compatible iOS & Android)
PLAZO: MVP funcional en 7 días

DESCRIPCIÓN DEL PROYECTO:
Crear una aplicación mobile donde creadores de contenido (principalmente mujeres) 
suban videos sensuales (sin desnudez explícita) y los suscriptores paguen para acceder.

MODELO DE NEGOCIO:
1. Suscripciones recurrentes mensuales (Basic/Premium/VIP)
2. PPV (Pay-Per-View) para videos especiales con diamantes
3. Chat privado entre usuario y creadora
4. Servicios adicionales vía Telegram (fuera de la app, sin procesar pagos)

---

## ESPECIFICACIONES TÉCNICAS:

### STACK RECOMENDADO:
- React Native + Expo (desarrollo rápido, iOS + Android)
- Node.js Backend
- PostgreSQL base de datos
- Stripe/Culqi para pagos
- Firebase Storage para videos
- Socket.io para chat en tiempo real
- Telegram Bot API (solo integración, no pagos)

### REQUISITOS FUNCIONALES:

RF-001: AUTENTICACIÓN
- Registro con email/contraseña
- Verificación de email
- Login/Logout
- JWT tokens
- Recordar sesión

RF-002: REGISTRO CREADORA
- Formulario especial para creadores
- Validación IBAN/número bancario
- Foto de perfil
- Bio
- Datos de pago (IBAN para transferencias)

RF-003: HOME FEED
- Feed infinito de creadores
- Tarjetas con preview de videos (30 seg sin sonido)
- Búsqueda por nombre
- Filtros
- Trending/Top creadores

RF-004: PERFIL CREADORA
- Foto grande de perfil
- Bio y descripción
- Rating/reseñas
- Galería de videos con acceso según suscripción
- Botón suscribirse
- Botón chat (si suscrito)

RF-005: SUSCRIPCIÓN
- Modal con 3 planes:
  * Basic: S/ 9.99/mes
  * Premium: S/ 19.99/mes
  * VIP: S/ 49.99/mes
- Integración Stripe/Culqi checkout
- Confirmación de pago
- Auto-renovación

RF-006: REPRODUCTOR DE VIDEO
- Video player responsive
- Calidad adaptativa (HD/SD)
- Controles: play, pause, volumen, fullscreen
- Subtítulos (opcional)
- Reporte de contenido

RF-007: PPV VIDEOS (Diamantes)
- Compra de diamantes en paquetes:
  * 50 💎 = S/ 9.99
  * 150 💎 = S/ 24.99
  * 350 💎 = S/ 49.99
  * 1000 💎 = S/ 129.99
- Gastar diamantes para desbloquear videos
- Balance de diamantes en tiempo real
- Historial de transacciones

RF-008: CHAT PRIVADO
- Chat 1-a-1 con creadora
- Mensajes en tiempo real (Socket.io)
- Historial de conversaciones
- Notificaciones push
- Indicador "escribiendo..."
- Timestamps en mensajes

RF-009: DASHBOARD CREADORA
- Resumen de ganancias (hoy/mes/total)
- Número de suscriptores
- Rating promedio
- Últimas transacciones
- Botón retirar dinero
- Historial de retiradas

RF-010: UPLOAD DE VIDEOS
- Seleccionar video de galería
- Compresión automática
- Thumbnail automático
- Descripción
- Visibilidad (libre/solo suscriptores/PPV)
- Precio en diamantes (si PPV)
- Botón publicar

RF-011: NOTIFICACIONES PUSH
- Nuevo video de creador favorito
- Nuevo mensaje en chat
- Pago recibido (creadora)
- Recordatorio renovación suscripción

RF-012: PERFIL DE USUARIO
- Foto de perfil
- Email
- Cambiar contraseña
- Datos de pago guardados
- Historial de suscripciones
- Historial de compras diamantes
- Opciones privacidad

RF-013: LINK TELEGRAM (No en app)
- En chat privado: botón [Contactar por Telegram]
- Abre Telegram con número de creadora
- NO procesa pagos en app
- Solo facilita contacto directo

RF-014: SISTEMA DE RATINGS
- Usuario califica creadora (1-5 estrellas)
- Comentario opcional
- Rating promedio actualiza en perfil

RF-015: RETIRADA DE DINERO
- Mínimo S/ 100
- Transferencia a IBAN
- Estado de retiros (pendiente/completado)
- Cálculo automático de comisión (20% plataforma)

RF-016: BÚSQUEDA Y FILTROS
- Búsqueda por nombre creadora
- Filtros: new, trending, top rated
- Ordenar por suscriptores/rating/fecha

RF-017: LEGAL Y COMPLIANCE
- Términos y condiciones (aceptar en registro)
- Política de privacidad
- Política de contenido (no explícito)
- Sobre nosotros
- Contacto soporte

---

## ESTRUCTURA DE CARPETAS:

```
src/
├── components/
│   ├── Auth/
│   │   ├── LoginScreen.jsx
│   │   ├── RegisterScreen.jsx
│   │   └── VerifyEmailScreen.jsx
│   ├── Home/
│   │   ├── HomeScreen.jsx
│   │   ├── CreatorCard.jsx
│   │   └── FeedList.jsx
│   ├── Creator/
│   │   ├── CreatorProfileScreen.jsx
│   │   ├── VideoPlayer.jsx
│   │   └── VideoGallery.jsx
│   ├── Dashboard/
│   │   ├── ConsumerDashboard.jsx
│   │   ├── CreatorDashboard.jsx
│   │   └── EarningsWidget.jsx
│   ├── Chat/
│   │   ├── ChatScreen.jsx
│   │   └── ChatList.jsx
│   ├── Diamonds/
│   │   ├── DiamondStore.jsx
│   │   └── DiamondBalance.jsx
│   ├── Upload/
│   │   └── UploadVideoScreen.jsx
│   └── Common/
│       ├── Button.jsx
│       ├── Input.jsx
│       ├── Modal.jsx
│       └── Loading.jsx
├── screens/
│   ├── index.jsx (Navigation)
│   ├── SplashScreen.jsx
│   └── NotFoundScreen.jsx
├── services/
│   ├── api.js
│   ├── auth.js
│   ├── creators.js
│   ├── subscriptions.js
│   ├── diamonds.js
│   ├── chat.js
│   └── upload.js
├── hooks/
│   ├── useAuth.js
│   ├── useFetch.js
│   └── useSocket.js
├── context/
│   ├── AuthContext.jsx
│   └── UserContext.jsx
├── utils/
│   ├── validation.js
│   ├── formatters.js
│   └── constants.js
├── styles/
│   ├── colors.js
│   ├── typography.js
│   └── spacing.js
├── App.jsx
└── index.js
```

---

## BASE DE DATOS POSTGRESQL:

TABLAS PRINCIPALES:
1. users (email, password_hash, phone, date_of_birth, status)
2. creators (user_id, username, bio, rating, subscribers_count)
3. videos (creator_id, url, thumbnail, description, visibility, ppv_price)
4. subscriptions (user_id, creator_id, plan_type, active, expires_at)
5. transactions (user_id, creator_id, amount, type, status)
6. diamonds_balance (user_id, balance, total_spent)
7. diamond_purchases (user_id, package_size, price_soles, status)
8. messages (sender_id, receiver_id, content, created_at)
9. ratings (user_id, creator_id, stars, comment)
10. withdrawals (creator_id, amount, status, iban, processed_at)

---

## FLUJOS PRINCIPALES:

FLUJO 1: Suscriptor nuevo
Login → Home/Feed → Buscar creadora → Ver preview → Suscribirse → Checkout → Dashboard → Ver videos

FLUJO 2: Creadora nueva
Register → Completar perfil → Dashboard vacío → Subir video → Esperar suscriptores

FLUJO 3: Pago PPV
Dashboard → "Comprar diamantes" → Seleccionar paquete → Checkout → Balance actualizado → Usar en video

FLUJO 4: Chat privado
Ver perfil creadora → [Chat] → ChatScreen → Escribir mensaje → Socket.io en tiempo real

---

## PALETA DE COLORES:

Primary: #667eea (Púrpura)
Secondary: #764ba2 (Púrpura oscuro)
Success: #10b981 (Verde)
Danger: #dc2626 (Rojo)
Background: #ffffff
Text: #333333
Diamond: #ffd700 (Dorado)

---

## INTEGRACIONES EXTERNAS:

1. Stripe/Culqi API - Pagos y suscripciones
2. Firebase Storage - Almacenamiento de videos
3. Socket.io - Chat en tiempo real
4. Telegram Bot API - Solo integración (no pagos)
5. Expo Push Notifications - Notificaciones
6. React Native Video - Reproductor

---

## SEGURIDAD:

- HTTPS en toda comunicación
- JWT tokens (exp 24h)
- Bcrypt para contraseñas
- Encriptación de datos sensibles
- Validación de edad (18+)
- Rate limiting en endpoints
- Sanitización de inputs

---

## REQUISITOS DE ENTREGA:

1. App funcional en simulador iOS/Android
2. Todas las pantallas implementadas
3. APIs conectadas y funcionando
4. Sistema de pagos integrado
5. Chat en tiempo real
6. Notificaciones push funcionando
7. Base de datos migrada

---

## INSTRUCCIONES PARA CLAUDE/OPENCODE:

1. Crea estructura completa del proyecto React Native
2. Implementa todas las pantallas mencionadas
3. Conecta APIs backend (proporciona endpoints)
4. Integra Stripe/Culqi para pagos
5. Implementa Socket.io para chat
6. Configura notificaciones push
7. Optimiza para iOS y Android
8. Incluye instrucciones de deploy

---

**Comienza con la estructura base y el flujo de autenticación.**
**Luego implementa Home/Feed y detalles de creadores.**
**Finalmente, pagos y chat.**

```

---

## 📋 INSTRUCCIONES DE USO:

**En Claude:**
1. Abre claude.ai
2. Copia TODO el prompt arriba
3. Pégalo en el chat
4. Presiona Enter
5. Claude creará toda la estructura

**En OpenCode:**
1. Ve a opencode.claude.ai (si existe) o usa Cursor IDE
2. Copia el prompt
3. Usa comando `/new-project`
4. Pega el prompt

**En Gemini:**
1. Abre gemini.google.com
2. Pega el prompt
3. Espera generación

---

## 💡 VARIACIONES DEL PROMPT:

### Si quieres solo Frontend (Sin Backend):
Reemplaza "STACK RECOMENDADO" con:
```
Usar APIs mock con datos hardcodeados
No requiere Node.js
Usa Firebase para auth (más simple)
Usa Firestore para base datos (sin PostgreSQL)
```

### Si quieres solo Backend:
Reemplaza "TECNOLOGÍA" con:
```
Node.js + Express
PostgreSQL
Socket.io para chat
Stripe Webhooks
```

### Si quieres Web en lugar de Mobile:
Reemplaza "TECNOLOGÍA" con:
```
React 18 + Vite
TailwindCSS
Axios
Socket.io-client
```

---

**¿Necesitas ajustar algo del prompt antes de usarlo?**