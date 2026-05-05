const categoriesRepository = require('../repositories/categoriesRepository');

exports.getCategories = async (req, res, next) => {
  try {
    const categories = await categoriesRepository.getAll();
    res.status(200).json({ success: true, data: { categories } });
  } catch (error) {
    next(error);
  }
};

exports.getTrendingTags = async (req, res, next) => {
  try {
    const { limit = 10 } = req.query;
    const tags = await categoriesRepository.getTrendingTags(parseInt(limit));
    res.status(200).json({ success: true, data: { tags } });
  } catch (error) {
    next(error);
  }
};

exports.getInfluencersByCategory = async (req, res, next) => {
  try {
    const { slug } = req.params;
    const { limit = 20 } = req.query;

    const category = await categoriesRepository.getBySlug(slug);
    if (!category) {
      return res.status(404).json({ success: false, message: 'Categoría no encontrada' });
    }

    const influencers = await categoriesRepository.getInfluencersByCategory(category.id, parseInt(limit));
    res.status(200).json({ success: true, data: { category, influencers } });
  } catch (error) {
    next(error);
  }
};

exports.useTag = async (req, res, next) => {
  try {
    const { tag } = req.body;
    if (!tag) {
      return res.status(400).json({ success: false, message: 'Tag es requerido' });
    }

    await categoriesRepository.incrementTagUsage(tag);
    res.status(200).json({ success: true });
  } catch (error) {
    next(error);
  }
};