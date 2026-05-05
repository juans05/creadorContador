const interactionsRepository = require('../repositories/interactionsRepository');
const influencerRepository = require('../repositories/influencerRepository');
const contentRepository = require('../repositories/contentRepository');

exports.likeContent = async (req, res, next) => {
  try {
    const { contentId, contentType } = req.body;
    const userId = req.user.userId;

    if (!contentId || !contentType) {
      return res.status(400).json({ success: false, message: 'contentId y contentType son requeridos' });
    }

    if (!['photo', 'video'].includes(contentType)) {
      return res.status(400).json({ success: false, message: 'tipo inválido' });
    }

    const influencerId = await getInfluencerIdByContent(contentId, contentType);
    if (!influencerId) {
      return res.status(404).json({ success: false, message: 'Contenido no encontrado' });
    }

    await interactionsRepository.addLike({ userId, contentId, contentType, influencerId });
    const likesCount = await interactionsRepository.getLikesCount({ contentId, contentType });

    res.status(200).json({
      success: true,
      data: { liked: true, likesCount }
    });
  } catch (error) {
    next(error);
  }
};

exports.unlikeContent = async (req, res, next) => {
  try {
    const { contentId, contentType } = req.body;
    const userId = req.user.userId;

    await interactionsRepository.removeLike({ userId, contentId, contentType });
    const likesCount = await interactionsRepository.getLikesCount({ contentId, contentType });

    res.status(200).json({
      success: true,
      data: { liked: false, likesCount }
    });
  } catch (error) {
    next(error);
  }
};

exports.getLikeStatus = async (req, res, next) => {
  try {
    const { contentId } = req.params;
    const userId = req.user?.userId;

    const isLiked = userId ? await interactionsRepository.isLiked({ userId, contentId }) : false;
    const likesCount = await interactionsRepository.getLikesCount({ contentId, contentType: 'photo' });

    res.status(200).json({
      success: true,
      data: { isLiked, likesCount }
    });
  } catch (error) {
    next(error);
  }
};

exports.addComment = async (req, res, next) => {
  try {
    const { contentId, contentType, parentId, content } = req.body;
    const userId = req.user.userId;

    if (!contentId || !content || !contentType) {
      return res.status(400).json({ success: false, message: 'contentId, contentType y content son requeridos' });
    }

    const influencerId = await getInfluencerIdByContent(contentId, contentType);
    if (!influencerId) {
      return res.status(404).json({ success: false, message: 'Contenido no encontrado' });
    }

    const comment = await interactionsRepository.addComment({ userId, contentId, contentType, influencerId, parentId, content });

    res.status(201).json({
      success: true,
      data: comment
    });
  } catch (error) {
    next(error);
  }
};

exports.getComments = async (req, res, next) => {
  try {
    const { contentId, contentType = 'photo', limit = 50 } = req.query;

    const comments = await interactionsRepository.getComments({ contentId, contentType, limit: parseInt(limit) });

    res.status(200).json({
      success: true,
      data: { comments }
    });
  } catch (error) {
    next(error);
  }
};

exports.followInfluencer = async (req, res, next) => {
  try {
    const { influencerId } = req.body;
    const userId = req.user.userId;

    await interactionsRepository.followInfluencer({ followerId: userId, influencerId });

    res.status(200).json({
      success: true,
      data: { following: true }
    });
  } catch (error) {
    next(error);
  }
};

exports.unfollowInfluencer = async (req, res, next) => {
  try {
    const { influencerId } = req.body;
    const userId = req.user.userId;

    await interactionsRepository.unfollowInfluencer({ followerId: userId, influencerId });

    res.status(200).json({
      success: true,
      data: { following: false }
    });
  } catch (error) {
    next(error);
  }
};

exports.getFollowStatus = async (req, res, next) => {
  try {
    const { influencerId } = req.params;
    const userId = req.user?.userId;

    const isFollowing = userId ? await interactionsRepository.isFollowing({ followerId: userId, influencerId }) : false;
    const followersCount = await interactionsRepository.getFollowersCount(influencerId);

    res.status(200).json({
      success: true,
      data: { isFollowing, followersCount }
    });
  } catch (error) {
    next(error);
  }
};

async function getInfluencerIdByContent(contentId, contentType) {
  const table = contentType === 'video' ? 'videos' : 'photos';
  const { pool } = require('../config/db');
  const result = await pool.query(
    `SELECT influencer_id FROM ${table} WHERE id = $1`,
    [contentId]
  );
  return result.rows[0]?.influencer_id;
}