const influencerRepository = require('../repositories/influencerRepository');
const subscriptionRepository = require('../repositories/subscriptionRepository');
const contentRepository = require('../repositories/contentRepository');
const interactionsRepository = require('../repositories/interactionsRepository');

class InfluencerService {
  async register({ userId, username, bio, yapeNumber }) {
    if (!username || username.length < 3 || username.length > 50) {
      const error = new Error('Username inválido');
      error.status = 422;
      throw error;
    }

    if (!/^\d{14}$/.test(yapeNumber)) {
      const error = new Error('Número YAPE debe tener 14 dígitos');
      error.status = 422;
      throw error;
    }

    const exists = await influencerRepository.usernameExists(username);
    if (exists) {
      const error = new Error('Username ya está en uso');
      error.status = 400;
      throw error;
    }

    const yapeEncrypted = Buffer.from(yapeNumber).toString('base64');

    const newInfluencer = await influencerRepository.create({
      userId,
      username,
      bio,
      yapeIdEncrypted: yapeEncrypted
    });

    return {
      influencerId: newInfluencer.id,
      username: newInfluencer.username,
      dashboard: '/dashboard/influencer',
      canUploadContent: true
    };
  }

  async getProfile(username, userId) {
    const influencer = await influencerRepository.findByUsername(username);
    if (!influencer) {
      const error = new Error('Creadora no encontrada');
      error.status = 404;
      throw error;
    }

    let isSubscribed = false;
    if (userId) {
      const sub = await subscriptionRepository.findActive(userId, influencer.influencer_id);
      isSubscribed = !!sub;
    }

    const photos = await contentRepository.findPhotosByInfluencer(influencer.influencer_id);

    const photosWithAccess = photos.map(p => {
      let hasAccess = p.visibility === 'public';
      if (p.visibility === 'subscribers_only' && isSubscribed) hasAccess = true;

      return {
        ...p,
        hasAccess,
        url: hasAccess ? p.url : null,
      };
    });

    return {
      ...influencer,
      isSubscribed,
      photos: photosWithAccess
    };
  }

  async getDashboardStats(userId) {
    const influencer = await influencerRepository.getStats(userId);
    if (!influencer) {
      const error = new Error('No eres una creadora registrada');
      error.status = 403;
      throw error;
    }

    const recentTransactions = await influencerRepository.getRecentTransactions(influencer.id);

    return {
      stats: influencer,
      recentTransactions
    };
  }

  async getGrid(username, userId) {
    const influencer = await influencerRepository.findByUsername(username);
    if (!influencer) {
      const error = new Error('Creadora no encontrada');
      error.status = 404;
      throw error;
    }

    let isSubscribed = false;
    let canAccessSubscribers = false;
    if (userId) {
      const sub = await subscriptionRepository.findActive(userId, influencer.influencer_id);
      isSubscribed = !!sub;
      canAccessSubscribers = isSubscribed;
    }

    const counts = await contentRepository.getGridCounts(influencer.influencer_id);
    const grid = await contentRepository.findGridByInfluencer(influencer.influencer_id);

    const gridWithAccess = grid.map(item => {
      let hasAccess = item.visibility === 'public';
      if (item.visibility === 'subscribers' && canAccessSubscribers) hasAccess = true;
      if (item.visibility === 'ppv') {
        hasAccess = item.ppvPrice === null || item.ppvPrice === 0;
      }

      return {
        id: item.id,
        type: item.type,
        thumbnail: item.thumbnail,
        url: hasAccess ? item.url : null,
        visibility: item.visibility,
        ppvPrice: item.ppvPrice,
        hasAccess,
        likesCount: item.likesCount,
        createdAt: item.createdAt
      };
    });

    return {
      username: influencer.username,
      totalItems: counts.photos + counts.videos,
      grid: gridWithAccess
    };
  }
}

module.exports = new InfluencerService();