import api from './api';

export const contentService = {
  upload: async (formData) => {
    const response = await api.post('/content/upload', formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
    });
    return response.data;
  },

  getMyContent: async () => {
    const response = await api.get('/content/my');
    return response.data;
  },

  delete: async (contentId) => {
    const response = await api.delete(`/content/${contentId}`);
    return response.data;
  },

  unlock: async (contentId, diamonds) => {
    const response = await api.post('/content/unlock', { contentId, diamonds });
    return response.data;
  },
};

export const tipsService = {
  send: async (creatorId, amount, message) => {
    const response = await api.post('/tips', { creatorId, amount, message });
    return response.data;
  },

  getHistory: async () => {
    const response = await api.get('/tips/history');
    return response.data;
  },
};

export default contentService;