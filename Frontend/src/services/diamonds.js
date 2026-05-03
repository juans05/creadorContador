import api from './api';

export const diamondsService = {
  getPackages: async () => {
    const response = await api.get('/diamonds/packages');
    return response.data;
  },

  purchase: async (packageId, paymentMethod) => {
    const response = await api.post('/diamonds/purchase', { packageId, paymentMethod });
    return response.data;
  },

  getBalance: async () => {
    const response = await api.get('/diamonds/balance');
    return response.data;
  },

  getHistory: async () => {
    const response = await api.get('/diamonds/history');
    return response.data;
  },
};

export default diamondsService;