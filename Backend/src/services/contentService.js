const contentRepository = require('../repositories/contentRepository');
const influencerRepository = require('../repositories/influencerRepository');
const cloudinaryService = require('./cloudinaryService');
const fs = require('fs');

class ContentService {
  async uploadContent({ userId, file, description, visibility, ppvPrice, mediaType }) {
    const influencer = await influencerRepository.findByUserId(userId);
    if (!influencer) {
      const error = new Error('Solo las creadoras pueden subir contenido');
      error.status = 403;
      throw error;
    }

    const finalVisibility = visibility || 'public';
    const finalPrice = finalVisibility === 'ppv' ? (parseInt(ppvPrice, 10) || 50) : null;
    const isVideo = file.mimetype.startsWith('video/');

    const resourceType = isVideo ? 'video' : 'image';

    const result = await cloudinaryService.uploadFile(file.path, 'luxor_content', resourceType);

    if (fs.existsSync(file.path)) {
      fs.unlinkSync(file.path);
    }

    let content;
    if (isVideo) {
      content = await contentRepository.createVideo({
        influencerId: influencer.id,
        url: result.secure_url,
        cloudinaryPublicId: result.public_id,
        description,
        visibility: finalVisibility,
        ppvPrice: finalPrice,
        duration: result.duration || null
      });
      return { message: 'Video subido exitosamente', data: content };
    } else {
      content = await contentRepository.createPhoto({
        influencerId: influencer.id,
        url: result.secure_url,
        thumbnailUrl: result.secure_url,
        cloudinaryPublicId: result.public_id,
        description,
        visibility: finalVisibility,
        ppvPrice: finalPrice
      });
      return { message: 'Foto subida exitosamente', data: content };
    }
  }

  async getMyContent(userId) {
    const influencer = await influencerRepository.findByUserId(userId);
    if (!influencer) {
      const error = new Error('Solo las creadoras pueden ver contenido');
      error.status = 403;
      throw error;
    }

    const photos = await contentRepository.findPhotosByInfluencerForOwner(influencer.id);
    const videos = await contentRepository.findVideosByInfluencerForOwner(influencer.id);

    const allContent = [...photos, ...videos].sort((a, b) =>
      new Date(b.created_at) - new Date(a.created_at)
    );

    return allContent;
  }

  async deleteContent({ userId, id, type }) {
    const influencer = await influencerRepository.findByUserId(userId);
    if (!influencer) {
      const error = new Error('Solo las creadoras pueden eliminar contenido');
      error.status = 403;
      throw error;
    }

    let content;
    if (type === 'video') {
      content = await contentRepository.findVideoById(id, influencer.id);
      if (!content) {
        const error = new Error('Contenido no encontrado');
        error.status = 404;
        throw error;
      }
      await cloudinaryService.deleteFile(content.cloudinary_public_id, 'video');
      await contentRepository.deleteVideo(id, influencer.id);
    } else {
      content = await contentRepository.findPhotoById(id, influencer.id);
      if (!content) {
        const error = new Error('Contenido no encontrado');
        error.status = 404;
        throw error;
      }
      await cloudinaryService.deleteFile(content.cloudinary_public_id, 'image');
      await contentRepository.deletePhoto(id, influencer.id);
    }

    return { message: 'Contenido eliminado exitosamente' };
  }
}

module.exports = new ContentService();