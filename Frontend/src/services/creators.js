import api from './api';

export const creatorsService = {
  register: async (data) => {
    const response = await api.post('/influencers/register', {
      username: data.username,
      bio: data.bio,
      category: data.category,
    });
    return response.data;
  },

  getProfile: async (username) => {
    const response = await api.get(`/influencers/${username}`);
    return response.data;
  },

  getFeed: async (page = 1, limit = 10) => {
    const response = await api.get(`/home/feed?page=${page}&limit=${limit}`);
    return response.data;
  },

  getTrending: async () => {
    const response = await api.get('/home/trending');
    return response.data;
  },

  search: async (query) => {
    const response = await api.get(`/home/search?q=${encodeURIComponent(query)}`);
    return response.data;
  },
  
  getDashboardStats: async () => {
    const response = await api.get('/influencers/dashboard/stats');
    return response.data;
  },
};

export default creatorsService;