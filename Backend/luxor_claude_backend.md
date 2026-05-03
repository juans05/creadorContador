# LUXOR - ESPECIFICACIONES PARA CLAUDE (Backend)

**Responsabilidad:** Backend, Base de datos, APIs, Lógica de negocio, Seguridad, Integraciones de pagos  
**Plazo:** 7 días MVP  
**Stack:** Node.js + Express, PostgreSQL, JWT, Culqi API, Socket.io

---

## 🎯 RFs ASIGNADOS A CLAUDE

- **RF-001:** REGISTRO DE USUARIOS (Backend)
- **RF-002:** REGISTRO DE CREADORAS (Backend)
- **RF-003:** HOME PAGE / FEED (API Backend)
- **RF-004:** PERFIL DE CREADORA (API Backend)
- **RF-005:** SUSCRIPCIÓN (Backend + Culqi)
- **RF-006:** TRANSFER AUTOMÁTICO DIARIO (Cron Job)
- **RF-007:** DASHBOARD DE CREADORA (API Backend)
- **RF-008:** SUBIR CONTENIDO (Backend + Cloudinary)
- **RF-009:** CHAT PRIVADO (Backend + Socket.io)
- **RF-010:** TIPS / PROPINAS (Backend + Culqi)
- **RF-011:** COMPRA DE DIAMANTES (Backend + Culqi)
- **RF-013:** CONVERTIR DIAMANTES A DINERO (Backend + Culqi)
- **RF-014:** CRON JOB CONVERSIÓN AUTOMÁTICA (Background Job)
- **RF-017:** VALIDACIÓN NO DUPLICADOS (Backend validation)

---

## 🗄️ ARQUITECTURA DE BASE DE DATOS

### Diagrama de relaciones:
```
users
├── email_verification_tokens
├── user_sessions
├── diamonds_balance
├── subscriptions (FK: user_id, influencer_id)
└── messages (FK: sender_id, receiver_id)

influencers (FK: user_id)
├── photos
├── diamond_purchases (FK: influencer_id)
├── subscriptions (FK: influencer_id)
├── transfer_logs (FK: influencer_id)
├── diamond_conversions (FK: influencer_id)
└── diamond_balance

transactions (FK: user_id, influencer_id)
conversion_logs
diamond_purchases (user_id + content_id UNIQUE)
```

### TABLA 1: users
```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  name VARCHAR(100) NOT NULL,
  phone VARCHAR(12) NOT NULL,
  date_of_birth DATE NOT NULL,
  age_confirmed BOOLEAN NOT NULL DEFAULT false,
  email_verified BOOLEAN DEFAULT false,
  terms_accepted BOOLEAN DEFAULT false,
  privacy_accepted BOOLEAN DEFAULT false,
  profile_picture_url VARCHAR(500),
  bio TEXT,
  status ENUM('active', 'suspended', 'deleted') DEFAULT 'active',
  last_login TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT age_check CHECK (date_of_birth <= CURRENT_DATE - INTERVAL '18 years'),
  CONSTRAINT phone_format CHECK (phone ~ '^\d{9,12}$')
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_phone ON users(phone);
CREATE INDEX idx_users_status ON users(status);
```

### TABLA 2: email_verification_tokens
```sql
CREATE TABLE email_verification_tokens (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  token VARCHAR(255) UNIQUE NOT NULL,
  verification_code VARCHAR(6) NOT NULL,
  expires_at TIMESTAMP NOT NULL,
  used_at TIMESTAMP DEFAULT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_verification_user ON email_verification_tokens(user_id);
CREATE INDEX idx_verification_token ON email_verification_tokens(token);
CREATE UNIQUE INDEX idx_user_pending_verification 
  ON email_verification_tokens(user_id) 
  WHERE used_at IS NULL;
```

### TABLA 3: user_sessions
```sql
CREATE TABLE user_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  jwt_token VARCHAR(1000) NOT NULL,
  refresh_token VARCHAR(1000),
  ip_address INET,
  user_agent TEXT,
  expires_at TIMESTAMP NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_sessions_user ON user_sessions(user_id);
CREATE INDEX idx_sessions_expires ON user_sessions(expires_at);
```

### TABLA 4: influencers
```sql
CREATE TABLE influencers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
  username VARCHAR(50) UNIQUE NOT NULL,
  bio TEXT,
  profile_picture_url VARCHAR(500),
  yape_id_encrypted VARCHAR(500),
  culqi_account_id VARCHAR(500),
  rating FLOAT DEFAULT 0,
  rating_count INT DEFAULT 0,
  suscriptores_count INT DEFAULT 0,
  total_earnings_soles DECIMAL(12,2) DEFAULT 0,
  total_earnings_today DECIMAL(12,2) DEFAULT 0,
  status ENUM('active', 'suspended', 'deleted') DEFAULT 'active',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_influencers_username ON influencers(username);
CREATE INDEX idx_influencers_rating ON influencers(rating DESC);
CREATE INDEX idx_influencers_suscriptores ON influencers(suscriptores_count DESC);
```

### TABLA 5: subscriptions
```sql
CREATE TABLE subscriptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  influencer_id UUID NOT NULL REFERENCES influencers(id) ON DELETE CASCADE,
  plan_type VARCHAR(20) NOT NULL CHECK (plan_type IN ('basic', 'premium', 'vip')),
  amount DECIMAL(10,2) NOT NULL,
  active BOOLEAN DEFAULT true,
  started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  expires_at TIMESTAMP NOT NULL,
  auto_renew BOOLEAN DEFAULT true,
  culqi_subscription_id VARCHAR(500),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(user_id, influencer_id)
);

CREATE INDEX idx_subscriptions_user ON subscriptions(user_id);
CREATE INDEX idx_subscriptions_influencer ON subscriptions(influencer_id);
CREATE INDEX idx_subscriptions_active ON subscriptions(active) WHERE active = true;
```

### TABLA 6: transactions
```sql
CREATE TABLE transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  influencer_id UUID REFERENCES influencers(id) ON DELETE SET NULL,
  amount DECIMAL(10,2) NOT NULL,
  type VARCHAR(20) NOT NULL CHECK (type IN ('subscription', 'tip', 'ppv', 'diamond_purchase')),
  status VARCHAR(20) NOT NULL CHECK (status IN ('pending', 'completed', 'failed')),
  culqi_transaction_id VARCHAR(500),
  payment_method VARCHAR(20),
  description TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  processed_at TIMESTAMP
);

CREATE INDEX idx_transactions_user ON transactions(user_id);
CREATE INDEX idx_transactions_influencer ON transactions(influencer_id);
CREATE INDEX idx_transactions_status ON transactions(status);
CREATE INDEX idx_transactions_type ON transactions(type);
CREATE INDEX idx_transactions_created ON transactions(created_at DESC);
```

### TABLA 7: photos
```sql
CREATE TABLE photos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  influencer_id UUID NOT NULL REFERENCES influencers(id) ON DELETE CASCADE,
  url VARCHAR(500) NOT NULL,
  thumbnail_url VARCHAR(500),
  cloudinary_public_id VARCHAR(255),
  description TEXT,
  visibility VARCHAR(20) NOT NULL CHECK (visibility IN ('public', 'subscribers_only', 'ppv')),
  ppv_price_diamonds INT,
  views_count INT DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_photos_influencer ON photos(influencer_id);
CREATE INDEX idx_photos_visibility ON photos(visibility);
```

### TABLA 8: transfer_logs
```sql
CREATE TABLE transfer_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  influencer_id UUID NOT NULL REFERENCES influencers(id) ON DELETE CASCADE,
  amount DECIMAL(12,2) NOT NULL,
  status VARCHAR(20) NOT NULL CHECK (status IN ('pending', 'sent', 'failed')),
  culqi_transfer_id VARCHAR(500),
  transfer_method VARCHAR(50),
  error_message TEXT,
  retry_count INT DEFAULT 0,
  max_retries INT DEFAULT 3,
  sent_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_transfers_influencer ON transfer_logs(influencer_id);
CREATE INDEX idx_transfers_status ON transfer_logs(status);
CREATE INDEX idx_transfers_created ON transfer_logs(created_at DESC);
```

### TABLA 9: messages
```sql
CREATE TABLE messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sender_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  receiver_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  is_read BOOLEAN DEFAULT false,
  read_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_messages_sender ON messages(sender_id);
CREATE INDEX idx_messages_receiver ON messages(receiver_id);
CREATE INDEX idx_messages_conversation ON messages(sender_id, receiver_id, created_at DESC);
```

### TABLA 10: diamonds_balance
```sql
CREATE TABLE diamonds_balance (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
  balance INT DEFAULT 0,
  total_spent INT DEFAULT 0,
  total_earned INT DEFAULT 0,
  last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_diamonds_user ON diamonds_balance(user_id);
```

### TABLA 11: diamond_purchases
```sql
CREATE TABLE diamond_purchases (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  package_size INT NOT NULL CHECK (package_size IN (50, 150, 350, 1000)),
  price_soles DECIMAL(10,2) NOT NULL,
  diamonds_received INT NOT NULL,
  status VARCHAR(20) NOT NULL CHECK (status IN ('pending', 'completed', 'failed')),
  culqi_transaction_id VARCHAR(500),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  completed_at TIMESTAMP
);

CREATE INDEX idx_diamond_purchases_user ON diamond_purchases(user_id);
CREATE INDEX idx_diamond_purchases_status ON diamond_purchases(status);
```

### TABLA 12: user_diamond_purchases (RF-017)
```sql
CREATE TABLE user_diamond_purchases (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  content_id UUID NOT NULL REFERENCES photos(id) ON DELETE CASCADE,
  influencer_id UUID NOT NULL REFERENCES influencers(id),
  diamonds_spent INT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(user_id, content_id)
);

CREATE INDEX idx_user_purchases_user ON user_diamond_purchases(user_id);
CREATE INDEX idx_user_purchases_content ON user_diamond_purchases(content_id);
CREATE INDEX idx_user_purchases_influencer ON user_diamond_purchases(influencer_id);
```

### TABLA 13: diamond_conversions
```sql
CREATE TABLE diamond_conversions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  influencer_id UUID NOT NULL REFERENCES influencers(id) ON DELETE CASCADE,
  diamonds_converted INT NOT NULL,
  amount_soles DECIMAL(12,2) NOT NULL,
  status VARCHAR(20) NOT NULL CHECK (status IN ('pending', 'processing', 'completed', 'failed')),
  culqi_transfer_id VARCHAR(500),
  error_message TEXT,
  retry_count INT DEFAULT 0,
  requested_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  processed_at TIMESTAMP
);

CREATE INDEX idx_conversions_influencer ON diamond_conversions(influencer_id);
CREATE INDEX idx_conversions_status ON diamond_conversions(status);
```

### TABLA 14: conversion_logs (Auditoría)
```sql
CREATE TABLE conversion_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  conversion_id UUID NOT NULL REFERENCES diamond_conversions(id),
  status VARCHAR(20),
  error_message TEXT,
  attempt_number INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_conversion_logs_conversion ON conversion_logs(conversion_id);
```

---

## 🔌 API ENDPOINTS

### AUTH ENDPOINTS

#### POST /api/auth/register
**Descripción:** Registrar nuevo usuario
**Body:**
```json
{
  "email": "usuario@example.com",
  "password": "Password123!",
  "confirmPassword": "Password123!",
  "name": "Juan Pérez",
  "phone": "987654321",
  "dateOfBirth": "2000-05-15",
  "ageConfirmed": true,
  "termsAccepted": true,
  "privacyAccepted": true
}
```

**Response 201:**
```json
{
  "success": true,
  "message": "Usuario registrado. Revisa tu email",
  "data": {
    "userId": "550e8400-e29b-41d4-a716-446655440000",
    "email": "usuario@example.com",
    "verificationEmailSent": true,
    "expiresIn": 86400
  }
}
```

**Response 400 - Email duplicado:**
```json
{
  "success": false,
  "error": "EMAIL_ALREADY_EXISTS",
  "message": "Este email ya está registrado",
  "options": {
    "loginUrl": "/auth/login",
    "resetPasswordUrl": "/auth/forgot-password"
  }
}
```

**Response 422 - Validación fallida:**
```json
{
  "success": false,
  "error": "VALIDATION_ERROR",
  "errors": [
    {
      "field": "password",
      "message": "La contraseña debe tener mínimo 8 caracteres",
      "code": "MIN_LENGTH"
    },
    {
      "field": "phone",
      "message": "Formato inválido. Debe ser 9XXXXXXXXX",
      "code": "INVALID_FORMAT"
    }
  ]
}
```

**Rate Limit:** 5 registros por IP por hora
**Headers:**
```
X-RateLimit-Limit: 5
X-RateLimit-Remaining: 4
X-RateLimit-Reset: 1620000000
```

---

#### POST /api/auth/verify-email
**Descripción:** Verificar código o token de email
**Body:**
```json
{
  "userId": "550e8400-e29b-41d4-a716-446655440000",
  "verificationCode": "A1B2C3"
}
```
**O con token:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Response 200:**
```json
{
  "success": true,
  "message": "Email verificado exitosamente",
  "data": {
    "userId": "550e8400-e29b-41d4-a716-446655440000",
    "emailVerified": true,
    "redirectUrl": "/auth/login"
  }
}
```

---

#### POST /api/auth/login
**Descripción:** Iniciar sesión de usuario
**Body:**
```json
{
  "email": "usuario@example.com",
  "password": "Password123!"
}
```

**Response 200:**
```json
{
  "success": true,
  "data": {
    "userId": "550e8400-e29b-41d4-a716-446655440000",
    "email": "usuario@example.com",
    "name": "Juan Pérez",
    "userType": "consumer",
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "expiresIn": 86400
  }
}
```

---

### INFLUENCER ENDPOINTS

#### POST /api/influencers/register
**Descripción:** Registrar como creadora
**Headers:** `Authorization: Bearer <token>`
**Body:**
```json
{
  "username": "creadora_x",
  "bio": "Content creator especializada en...",
  "yapeNumber": "12345678901234"
}
```

**Validaciones:**
- Username: 3-50 caracteres, alphanumeric + guiones/guiones bajos
- YAPE: Exactamente 14 dígitos, encriptar en BD con AES-256
- Username único en tabla influencers

**Response 201:**
```json
{
  "success": true,
  "data": {
    "influencerId": "550e8400-e29b-41d4-a716-446655440001",
    "username": "creadora_x",
    "dashboard": "/dashboard/influencer",
    "canUploadContent": true
  }
}
```

---

#### GET /api/home/feed
**Descripción:** Obtener feed de creadoras
**Headers:** `Authorization: Bearer <token>`
**Query Params:**
- `page`: número de página (default: 1)
- `limit`: items por página (default: 20, máximo: 50)
- `sort`: 'trending' | 'recent' | 'rating' (default: 'trending')
- `search`: búsqueda por nombre creadora

**Response 200:**
```json
{
  "success": true,
  "data": {
    "total": 150,
    "page": 1,
    "limit": 20,
    "creators": [
      {
        "influencerId": "550e8400-e29b-41d4-a716-446655440001",
        "username": "creadora_x",
        "profilePicture": "https://cloudinary.url/image.jpg",
        "rating": 4.9,
        "ratingCount": 342,
        "subscribersCount": 1250,
        "isSubscribed": true,
        "previewPhotos": ["url1", "url2", "url3"]
      }
    ]
  }
}
```

**Performance:** Máximo 2 segundos de respuesta

---

#### GET /api/influencers/:username
**Descripción:** Obtener perfil completo de creadora
**Headers:** `Authorization: Bearer <token>`

**Response 200:**
```json
{
  "success": true,
  "data": {
    "influencerId": "550e8400-e29b-41d4-a716-446655440001",
    "username": "creadora_x",
    "name": "María García",
    "bio": "Content creator...",
    "profilePicture": "https://cloudinary.url/image.jpg",
    "rating": 4.9,
    "ratingCount": 342,
    "subscribersCount": 1250,
    "isSubscribed": true,
    "photos": [
      {
        "photoId": "photo-001",
        "url": "https://cloudinary.url/photo.jpg",
        "thumbnail": "https://cloudinary.url/thumb.jpg",
        "visibility": "subscribers_only",
        "ppvPrice": null,
        "hasAccess": true,
        "createdAt": "2024-05-01T10:30:00Z"
      }
    ]
  }
}
```

---

### SUBSCRIPTION ENDPOINTS

#### POST /api/subscriptions
**Descripción:** Crear suscripción
**Headers:** `Authorization: Bearer <token>`
**Body:**
```json
{
  "influencerId": "550e8400-e29b-41d4-a716-446655440001",
  "planType": "premium",
  "paymentMethod": "culqi"
}
```

**Plan pricing:**
- basic: S/ 9.99
- premium: S/ 19.99
- vip: S/ 49.99

**Response 201:**
```json
{
  "success": true,
  "data": {
    "subscriptionId": "sub-001",
    "influencerId": "550e8400-e29b-41d4-a716-446655440001",
    "planType": "premium",
    "amount": 19.99,
    "status": "active",
    "startsAt": "2024-05-02T10:30:00Z",
    "expiresAt": "2024-06-02T10:30:00Z",
    "redirectToCheckout": true,
    "checkoutUrl": "https://checkout.luxor.app/..."
  }
}
```

---

### TRANSFER ENDPOINTS

#### POST /api/transfers/manual
**Descripción:** Transferencia manual de creadora
**Headers:** `Authorization: Bearer <token>`
**Body:**
```json
{
  "amount": 150.00,
  "transferType": "manual"
}
```

**Response 201:**
```json
{
  "success": true,
  "data": {
    "transferId": "transfer-001",
    "influencerId": "550e8400-e29b-41d4-a716-446655440001",
    "amount": 150.00,
    "status": "processing",
    "yapeEnding": "*-**-4567",
    "estimatedArrival": "2024-05-03T12:00:00Z"
  }
}
```

---

### DIAMOND ENDPOINTS

#### POST /api/diamonds/purchase
**Descripción:** Comprar diamantes
**Headers:** `Authorization: Bearer <token>`
**Body:**
```json
{
  "packageSize": 150,
  "paymentMethod": "culqi"
}
```

**Response 201:**
```json
{
  "success": true,
  "data": {
    "purchaseId": "diam-purchase-001",
    "packageSize": 150,
    "priceSoles": 24.99,
    "status": "pending",
    "redirectToCheckout": true
  }
}
```

---

#### POST /api/diamonds/spend
**Descripción:** Gastar diamantes en contenido (RF-012)
**Headers:** `Authorization: Bearer <token>`
**Body:**
```json
{
  "contentId": "photo-001",
  "diamondAmount": 50
}
```

**Validaciones:**
- Usuario tiene suficientes diamantes
- Contenido existe
- Usuario NO compró antes (RF-017)

**Response 200:**
```json
{
  "success": true,
  "data": {
    "contentId": "photo-001",
    "diamondsSpent": 50,
    "diamondsRemaining": 100,
    "contentUnlocked": true,
    "creatorEarned": 40
  }
}
```

**Response 409 - Ya comprado:**
```json
{
  "success": false,
  "error": "CONTENT_ALREADY_PURCHASED",
  "message": "Ya desbloqueaste este contenido"
}
```

---

#### POST /api/diamonds/convert
**Descripción:** Convertir diamantes a dinero (RF-013)
**Headers:** `Authorization: Bearer <token>`
**Body:**
```json
{
  "diamondsAmount": 500
}
```

**Validaciones:**
- Mínimo 100 diamantes
- YAPE registrado

**Response 201:**
```json
{
  "success": true,
  "data": {
    "conversionId": "conv-001",
    "diamondsConverted": 500,
    "amountSoles": 50.00,
    "status": "pending",
    "estimatedProcessing": "2024-05-03T12:05:00Z",
    "yapeEnding": "*-**-4567"
  }
}
```

---

## 🔐 SEGURIDAD IMPLEMENTADA

- **HTTPS:** Obligatorio en todos los endpoints
- **JWT:** Token con exp: 24h, refresh token: 7 días
- **Bcrypt:** Salt rounds 10
- **Encriptación:** AES-256 para YAPE
- **Rate Limiting:** 5 req/seg por IP
- **CORS:** Configurado para dominio(s) permitido(s)
- **CSRF:** Tokens anti-CSRF en formularios
- **SQL Injection:** Prepared statements en todas las queries
- **XSS:** Sanitización de inputs

---

## ⏱️ CRON JOBS

### Cron 1: Transfer automático diario (RF-006)
**Hora:** 12:05 AM diarios
**Lógica:**
```javascript
// Pseudocódigo
const dailyTransfers = async () => {
  const transactions = await getTransactionsFromToday();
  const groupedByInfluencer = groupBy(transactions, 'influencer_id');
  
  for (let [influencerId, txns] of groupedByInfluencer) {
    const totalAmount = sum(txns.map(t => t.amount));
    const influencerShare = totalAmount * 0.70; // 70%
    const platformShare = totalAmount * 0.30; // 30%
    
    const influencer = await getInfluencer(influencerId);
    const yapeDecrypted = decrypt(influencer.yape_id_encrypted);
    
    try {
      const culqiTransfer = await culqi.transfers.create({
        amount_in_cents: Math.round(influencerShare * 100),
        destination_id: yapeDecrypted,
        description: `Ganancias del ${dateToday()}`
      });
      
      await logTransfer({
        influencer_id: influencerId,
        amount: influencerShare,
        status: 'sent',
        culqi_transfer_id: culqiTransfer.id
      });
      
      await sendNotification(influencer.user_id, 
        `¡Ganaste S/ ${influencerShare.toFixed(2)}! Revisa tu YAPE`);
    } catch (error) {
      await logTransferError(influencerId, error.message);
    }
  }
};
```

### Cron 2: Conversión de diamantes (RF-014)
**Hora:** 12:10 AM diarios
**Lógica:**
```javascript
const diamondConversions = async () => {
  const pendingConversions = await getDiamondConversions('pending');
  
  for (let conversion of pendingConversions) {
    try {
      const influencer = await getInfluencer(conversion.influencer_id);
      const yapeDecrypted = decrypt(influencer.yape_id_encrypted);
      
      const culqiTransfer = await culqi.transfers.create({
        amount_in_cents: Math.round(conversion.amount_soles * 100),
        destination_id: yapeDecrypted,
        description: `Conversión de ${conversion.diamonds_converted} diamantes`
      });
      
      await updateConversion(conversion.id, {
        status: 'completed',
        culqi_transfer_id: culqiTransfer.id,
        processed_at: new Date()
      });
      
      await sendEmail(influencer.user_id,
        `Convertiste ${conversion.diamonds_converted}💎 a S/ ${conversion.amount_soles.toFixed(2)}`);
        
    } catch (error) {
      await updateConversion(conversion.id, {
        status: 'failed',
        error_message: error.message,
        retry_count: conversion.retry_count + 1
      });
    }
  }
};
```

---

## 📞 SOCKET.IO EVENTS (RF-009)

**Conexión:**
```javascript
socket.on('connect', (data) => {
  // Autenticar usuario
  // Unir a sala de usuario
});

// Enviar mensaje
socket.emit('message:send', {
  receiverId: 'user-id',
  content: 'Hola!',
  timestamp: Date.now()
});

// Recibir mensaje (tiempo real)
socket.on('message:receive', (data) => {
  // Actualizar UI
});

// Indicador "escribiendo..."
socket.emit('typing:start', { receiverId: 'user-id' });
socket.on('typing:receive', (data) => {
  // Mostrar "está escribiendo..."
});
```

---

## 🚀 STACK RECOMENDADO

**Backend:**
- Node.js v18+
- Express.js v4.18+
- PostgreSQL 14+
- Socket.io v4+

**Librerías:**
- bcryptjs ^2.4.3
- jsonwebtoken ^9.0.0
- sequelize ^6.32.0 (ORM)
- joi ^17.11.0 (validación)
- axios ^1.6.0 (HTTP client)
- node-cron ^3.0.2
- express-rate-limit ^7.1.5
- helmet ^7.1.0
- cors ^2.8.5
- dotenv ^16.3.1

---

## 📋 CHECKPOINTS DE DESARROLLO

**Día 1:** Esquema BD + Endpoints autenticación  
**Día 2:** Endpoints suscripciones + Culqi integration  
**Día 3:** Endpoints influencers + Upload fotos  
**Día 4:** Socket.io chat + Diamantes endpoints  
**Día 5:** Cron jobs + Transfers automáticos  
**Día 6:** Validaciones adicionales + Testing  
**Día 7:** Deploy + Optimizaciones  

---

## 🎬 INICIO RÁPIDO

```bash
npm init -y
npm install express pg sequelize bcryptjs jsonwebtoken socket.io axios node-cron
npm install -D nodemon

# Crear estructura
mkdir src/{routes,controllers,models,middleware,utils}
touch src/server.js .env .gitignore

# Variables de entorno
DATABASE_URL=postgresql://user:password@localhost:5432/luxor
JWT_SECRET=your_secret_key_here
CULQI_API_KEY=your_culqi_key
CLOUDINARY_API_KEY=your_cloudinary_key
SENDGRID_API_KEY=your_sendgrid_key
PORT=3000
```

---

**Documento generado para CLAUDE - Backend Lead**