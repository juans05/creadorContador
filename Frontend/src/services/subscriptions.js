import api from './api';

export const subscriptionsService = {
  subscribe: async (creatorId, plan) => {
    const response = await api.post('/subscriptions', { creatorId, plan });
    return response.data;
  },

  getMySubscriptions: async () => {
    const response = await api.get('/subscriptions/my');
    return response.data;
  },

  cancel: async (subscriptionId) => {
    const response = await api.delete(`/subscriptions/${subscriptionId}`);
    return response.data;
  },

  getPlans: async (creatorId) => {
    const response = await api.get(`/subscriptions/plans/${creatorId}`);
    return response.data;
  },
};

export default subscriptionsService;