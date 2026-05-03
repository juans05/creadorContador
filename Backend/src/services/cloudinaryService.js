const cloudinary = require('cloudinary').v2;

cloudinary.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
  api_key: process.env.CLOUDINARY_API_KEY,
  api_secret: process.env.CLOUDINARY_API_SECRET
});

// Upload genérico para imágenes y videos
exports.uploadFile = async (filePath, folder = 'luxor_content', resourceType = 'auto') => {
  try {
    const result = await cloudinary.uploader.upload(filePath, {
      folder: folder,
      resource_type: resourceType,
      transformation: resourceType === 'video' ? [
        { quality: 'auto', fetch_format: 'auto' }
      ] : [
        { quality: 'auto', fetch_format: 'auto' }
      ]
    });
    return result;
  } catch (error) {
    console.error('Cloudinary upload error:', error);
    throw error;
  }
};

// Alias para compatibilidad
exports.uploadImage = async (filePath, folder = 'luxor_content') => {
  return exports.uploadFile(filePath, folder, 'image');
};

exports.uploadVideo = async (filePath, folder = 'luxor_content') => {
  return exports.uploadFile(filePath, folder, 'video');
};

// Eliminar archivo
exports.deleteFile = async (publicId, resourceType = 'image') => {
  try {
    const result = await cloudinary.uploader.destroy(publicId, {
      resource_type: resourceType
    });
    return result;
  } catch (error) {
    console.error('Cloudinary delete error:', error);
    throw error;
  }
};