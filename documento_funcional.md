# 📋 Documento Funcional — Plataforma de Contenido LATAM
**Versión:** 0.1 — Idea inicial
**Fecha:** Mayo 2026
**Estado:** 🟡 En definición

---

## 1. Resumen ejecutivo

Plataforma de monetización de contenido para creadores latinoamericanos con scroll infinito estilo TikTok. Permite a actores, artistas, músicos, streamers y creadoras adultas monetizar su contenido en un solo lugar, en español, con métodos de pago locales de LATAM.

La plataforma tiene dos secciones claramente separadas:
- **General (SFW):** disponible en app móvil y web
- **Adulto (NSFW):** disponible únicamente en web desktop

---

## 2. Problema que resuelve

| Problema actual | Cómo lo resuelve esta plataforma |
|---|---|
| OnlyFans/Fansly están en inglés | Plataforma 100% en español |
| No hay métodos de pago LATAM | Integración con Yape, Plin, Mercado Pago, Pix, PSE |
| No existe feed de descubrimiento | Scroll infinito estilo TikTok |
| Plataformas separadas por tipo de contenido | Todo en un solo lugar |
| Comisiones altas (20–30%) | Comisión más baja del mercado |
| App Store rechaza contenido adulto | Adulto solo en web, app limpia |

---

## 3. Público objetivo

### Creadoras
| Tipo | Monetización principal |
|---|---|
| 🎬 Actriz / Actor | PPV, suscripción, lives |
| 🎵 Cantante / Músico | Conciertos virtuales, merch, suscripción |
| 💪 Fitness / Bienestar | Rutinas PPV, coaching en vivo |
| 🎮 Gamer / Streamer | Lives, donaciones, suscripción |
| 🔞 Creadora adulta | Suscripción, PPV, chat, diamantes |
| 🎨 Artista / Ilustrador | Venta digital, marketplace |

### Fans / Usuarios
- Hombres y mujeres 18–40 años
- Consumidores de contenido digital en LATAM
- Usuarios de TikTok, Instagram, YouTube
- Fans de celebridades y creadoras locales

---

## 4. Estructura de la plataforma

```
┌──────────────────────────────────────────┐
│            [Nombre de marca]             │
│                                          │
│   📱 APP MÓVIL        💻 WEB DESKTOP     │
│   ─────────────       ──────────────     │
│   ✅ Feed general     ✅ Feed general    │
│   ✅ Videos PPV       ✅ Videos PPV      │
│   ✅ Lives            ✅ Lives           │
│   ✅ Conciertos       ✅ Conciertos      │
│   ✅ Marketplace      ✅ Marketplace     │
│   ❌ Sección adulta   ✅ Sección adulta  │
└──────────────────────────────────────────┘
```

---

## 5. Funcionalidades

### 5.1 Feed principal
- Scroll vertical infinito de videos (estilo TikTok)
- Videos gratuitos + videos bloqueados (PPV)
- Al tocar video bloqueado → opción de desbloquear o suscribirse
- Algoritmo de recomendación por historial e intereses
- Filtro por categoría (música, fitness, adulto, etc.)

### 5.2 Perfil de creadora
- Foto, bio y categoría
- Contador de suscriptores y videos
- Feed propio de contenido
- Botón de suscripción mensual
- Tienda personal integrada
- Calendario de próximos eventos en vivo

### 5.3 Sistema de pagos y monetización
| Modelo | Descripción |
|---|---|
| 🔒 Suscripción mensual | Acceso completo al perfil por precio fijo mensual |
| 📹 PPV | Video individual con precio fijo para desbloquear |
| 🔴 Live streaming | Entrada de pago o propinas en tiempo real |
| 🎤 Conciertos virtuales | Ticket de acceso a evento programado |
| 🛍️ Marketplace | Venta de productos físicos y digitales |
| 💎 Diamantes | Propinas/regalos enviados por fans |
| 💬 Chat privado | Mensajes directos con costo por conversación |

### 5.4 Live streaming
- Transmisión en vivo desde app y web
- Chat en tiempo real con fans
- Envío de diamantes durante el live
- Grabación automática para vender como PPV después
- Eventos programados con tickets de entrada

### 5.5 Marketplace
- Creadora puede listar productos físicos (merch, fotos firmadas)
- Productos digitales (packs de fotos, videos, preset, etc.)
- Carrito de compras y checkout integrado
- Envíos gestionados por la creadora

### 5.6 Sistema de diamantes
- El fan compra paquetes de diamantes con dinero real
- Envía diamantes en lives, videos o como propina
- La creadora acumula diamantes y los convierte a dinero
- Más gamificado y emocional que el pago directo

### 5.7 Sección adulta (solo web)
- Acceso mediante verificación de edad (KYC básico)
- Mismas funcionalidades que sección general
- Contenido NSFW permitido bajo términos específicos
- Completamente invisible desde la app móvil

---

## 6. Verificación de identidad (KYC)

| Usuario | Nivel de verificación |
|---|---|
| Fan — contenido general | ❌ No requerido |
| Fan — sección adulta | ✅ Verificación de edad (DNI) |
| Creadora general | ⚠️ Básico (para habilitar cobros) |
| Creadora adulta | ✅ KYC completo (DNI + selfie) |

**Proveedor sugerido:** Truora o MetaMap (ambos con fuerte presencia en LATAM)

---

## 7. Métodos de pago

### Para fans (comprar)
| País | Métodos |
|---|---|
| 🇵🇪 Perú | Yape, Plin, tarjeta, PagoEfectivo |
| 🇲🇽 México | SPEI, OXXO, tarjeta |
| 🇨🇴 Colombia | PSE, Nequi, Daviplata, tarjeta |
| 🇦🇷 Argentina | Mercado Pago, tarjeta |
| 🇧🇷 Brasil | Pix, Boleto, tarjeta |
| 🌎 Global | Tarjeta de crédito/débito (Visa, Mastercard) |

### Para creadoras (cobrar)
- Transferencia bancaria local
- Mercado Pago
- Retiro mínimo bajo (a definir, sugerido $10–$20)
- Pagos semanales o quincenales

---

## 8. Comisiones

| Plataforma | Comisión | Creadora recibe |
|---|---|---|
| OnlyFans | 20% | 80% |
| Fansly | 20% | 80% |
| JustForFans | 30% | 70% |
| **Esta plataforma** | **< 15%** | **> 85%** |

> ⚠️ Comisión exacta a definir según costos operativos y de procesamiento de pagos.

---

## 9. Plataformas y dispositivos

| Plataforma | Contenido general | Contenido adulto |
|---|---|---|
| App iOS | ✅ | ❌ |
| App Android | ✅ | ❌ |
| Web mobile | ✅ | ✅ (con verificación) |
| Web desktop | ✅ | ✅ (con verificación) |

---

## 10. Funcionalidades NO incluidas en MVP

Las siguientes funcionalidades son parte del roadmap futuro:

| Funcionalidad | Estado |
|---|---|
| 💬 Chat privado v2 | ❌ Post-MVP |
| 📊 Analytics dashboard | ❌ Post-MVP |
| 🎤 Conciertos virtuales | ❌ Fase 2 |
| 🛍️ Marketplace | ❌ Fase 2 |
| ⭐ Reseñas / ratings | ❌ Por definir |
| 📱 App Store / Play Store | ❌ Fase 2 |

---

## 11. Roadmap

### 🥚 Fase 1 — MVP
- [ ] Feed scroll vertical con videos
- [ ] Registro y perfil de creadoras
- [ ] Suscripción mensual
- [ ] PPV básico
- [ ] Pagos: tarjeta + Mercado Pago + 1 método local
- [ ] Web completa (general + adulto)
- [ ] App móvil básica (solo general)
- [ ] KYC básico para creadoras adultas

### 🐣 Fase 2 — Crecimiento
- [ ] Live streaming
- [ ] Sistema de diamantes
- [ ] Chat privado
- [ ] Más métodos de pago LATAM
- [ ] Analytics para creadoras
- [ ] App en App Store y Play Store

### 🚀 Fase 3 — Expansión
- [ ] Conciertos y eventos con tickets
- [ ] Marketplace
- [ ] Algoritmo de recomendación avanzado
- [ ] Programa de referidos para creadoras
- [ ] Expansión a México, Colombia, Brasil

---

## 12. Diferenciación competitiva

> **No somos el OnlyFans de LATAM.**
> Somos la plataforma donde cualquier creadora latinoamericana — artista, actriz, cantante o modelo — tiene todo lo que necesita para vivir de su contenido, en su idioma, con sus métodos de pago.

| Diferenciador | Descripción |
|---|---|
| 🌎 Hecho para LATAM | Idioma, pagos, soporte y cultura pensados para la región |
| 📱 Scroll TikTok | Descubrimiento orgánico sin depender de redes externas |
| 💰 Comisión más baja | Las creadoras se quedan con más de su dinero |
| 🎭 General + Adulto | Una sola plataforma para todo tipo de creadora |
| 💎 Diamantes | Sistema emocional de propinas único |
| 🔒 Privacidad real | Anonimato, watermark, cargo bancario discreto |

---

*Documento en evolución — v0.1 Mayo 2026*
