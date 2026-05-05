-- Crear schema si no existe
CREATE SCHEMA IF NOT EXISTS luxordb;
SET search_path TO luxordb, public;

-- TABLA 1: users
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
  status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'suspended', 'deleted')),
  last_login TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT age_check CHECK (date_of_birth <= CURRENT_DATE - INTERVAL '18 years'),
  CONSTRAINT phone_format CHECK (phone ~ '^\d{9,12}$')
);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_phone ON users(phone);
CREATE INDEX idx_users_status ON users(status);

-- TABLA 2: email_verification_tokens
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
CREATE UNIQUE INDEX idx_user_pending_verification ON email_verification_tokens(user_id) WHERE used_at IS NULL;

-- TABLA 3: user_sessions
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

-- TABLA 4: influencers
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
  status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'suspended', 'deleted')),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_influencers_username ON influencers(username);
CREATE INDEX idx_influencers_rating ON influencers(rating DESC);
CREATE INDEX idx_influencers_suscriptores ON influencers(suscriptores_count DESC);

-- TABLA 5: subscriptions
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

-- TABLA 6: transactions
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

-- TABLA 7: photos
CREATE TABLE photos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  influencer_id UUID NOT NULL REFERENCES influencers(id) ON DELETE CASCADE,
  url VARCHAR(500) NOT NULL,
  thumbnail_url VARCHAR(500),
  cloudinary_public_id VARCHAR(500),
  description TEXT,
  visibility VARCHAR(20) DEFAULT 'public' CHECK (visibility IN ('public', 'subscribers', 'ppv')),
  ppv_price_diamonds INT,
  likes_count INT DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_photos_influencer ON photos(influencer_id);
CREATE INDEX idx_photos_visibility ON photos(visibility);

-- TABLA 8: transfer_logs
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

-- TABLA 9: messages
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

-- TABLA 10: diamonds_balance
CREATE TABLE diamonds_balance (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
  balance INT DEFAULT 0,
  total_spent INT DEFAULT 0,
  total_earned INT DEFAULT 0,
  last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_diamonds_user ON diamonds_balance(user_id);

-- TABLA 11: diamond_purchases
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

-- TABLA 12: user_diamond_purchases (RF-017)
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

-- TABLA 13: diamond_conversions
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

-- TABLA 14: conversion_logs (Auditoria)
CREATE TABLE conversion_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  conversion_id UUID NOT NULL REFERENCES diamond_conversions(id),
  status VARCHAR(20),
  error_message TEXT,
  attempt_number INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_conversion_logs_conversion ON conversion_logs(conversion_id);

-- TABLA 15: videos
CREATE TABLE videos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  influencer_id UUID NOT NULL REFERENCES influencers(id) ON DELETE CASCADE,
  url VARCHAR(500) NOT NULL,
  thumbnail_url VARCHAR(500),
  cloudinary_public_id VARCHAR(500),
  description TEXT,
  visibility VARCHAR(20) DEFAULT 'public' CHECK (visibility IN ('public', 'subscribers', 'ppv')),
  ppv_price_diamonds INT,
  duration INT,
  views_count INT DEFAULT 0,
  likes_count INT DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_videos_influencer ON videos(influencer_id);
CREATE INDEX idx_videos_visibility ON videos(visibility);

-- TABLA 16: likes (favoritos/likes)
CREATE TABLE likes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  content_id UUID NOT NULL,
  content_type VARCHAR(20) NOT NULL CHECK (content_type IN ('photo', 'video')),
  influencer_id UUID NOT NULL REFERENCES influencers(id) ON DELETE CASCADE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(user_id, content_id)
);
CREATE INDEX idx_likes_user ON likes(user_id);
CREATE INDEX idx_likes_content ON likes(content_id, content_type);
CREATE INDEX idx_likes_influencer ON likes(influencer_id);

-- TABLA 17: comments
CREATE TABLE comments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  content_id UUID NOT NULL,
  content_type VARCHAR(20) NOT NULL CHECK (content_type IN ('photo', 'video')),
  influencer_id UUID NOT NULL REFERENCES influencers(id) ON DELETE CASCADE,
  parent_id UUID REFERENCES comments(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_comments_content ON comments(content_id, content_type);
CREATE INDEX idx_comments_influencer ON comments(influencer_id);

-- TABLA 18: categories
CREATE TABLE categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(50) UNIQUE NOT NULL,
  slug VARCHAR(50) UNIQUE NOT NULL,
  icon VARCHAR(50),
  color VARCHAR(20),
  is_active BOOLEAN DEFAULT true,
  sort_order INT DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_categories_slug ON categories(slug);
CREATE INDEX idx_categories_active ON categories(is_active) WHERE is_active = true;

-- TABLA 19: influencer_categories
CREATE TABLE influencer_categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  influencer_id UUID NOT NULL REFERENCES influencers(id) ON DELETE CASCADE,
  category_id UUID NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(influencer_id, category_id)
);
CREATE INDEX idx_inf_cats_influencer ON influencer_categories(influencer_id);
CREATE INDEX idx_inf_cats_category ON influencer_categories(category_id);

-- TABLA 20: trending_tags
CREATE TABLE trending_tags (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tag VARCHAR(100) UNIQUE NOT NULL,
  usage_count INT DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_trending_tag ON trending_tags(tag);
CREATE INDEX idx_trending_active ON trending_tags(is_active) WHERE is_active = true;

-- TABLA 21: follows
CREATE TABLE follows (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  follower_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  influencer_id UUID NOT NULL REFERENCES influencers(id) ON DELETE CASCADE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(follower_id, influencer_id)
);
CREATE INDEX idx_follows_follower ON follows(follower_id);
CREATE INDEX idx_follows_influencer ON follows(influencer_id);

-- TABLA 22: notifications
CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  type VARCHAR(50) NOT NULL,
  title VARCHAR(255) NOT NULL,
  body TEXT,
  data JSONB,
  is_read BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  read_at TIMESTAMP
);
CREATE INDEX idx_notifications_user ON notifications(user_id);
CREATE INDEX idx_notifications_read ON notifications(user_id, is_read) WHERE is_read = false;
CREATE INDEX idx_notifications_created ON notifications(created_at DESC);

-- TABLA 23: reports (denuncias)
CREATE TABLE reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  reporter_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  reported_user_id UUID REFERENCES users(id) ON DELETE SET NULL,
  reported_influencer_id UUID REFERENCES influencers(id) ON DELETE SET NULL,
  content_id UUID,
  content_type VARCHAR(20),
  reason VARCHAR(50) NOT NULL,
  description TEXT,
  status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'reviewed', 'resolved', 'rejected')),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  resolved_at TIMESTAMP
);
CREATE INDEX idx_reports_reporter ON reports(reporter_id);
CREATE INDEX idx_reports_status ON reports(status);

-- DATOS INICIALES: categorias
INSERT INTO categories (name, slug, icon, color, sort_order) VALUES
  ('Adulto', 'adult', 'adult', '#FF4D6D', 1),
  ('Musica', 'music', 'music_note', '#FF8A00', 2),
  ('Juegos', 'gaming', 'sports_esports', '#9C27B0', 3),
  ('Belleza', 'beauty', 'spa', '#E91E63', 4),
  ('Influencer', 'influencer', 'star', '#00BCD4', 5)
ON CONFLICT (slug) DO NOTHING;

-- DATOS INICIALES: trending tags
INSERT INTO trending_tags (tag, usage_count) VALUES
  ('Trending', 1000),
  ('New', 800),
  ('Latam', 600),
  ('Live', 500),
  ('VIP', 400),
  ('Exclusive', 300),
  ('PPV', 250),
  ('18Plus', 200)
ON CONFLICT (tag) DO NOTHING;
