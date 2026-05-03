import api from './api';

export const authService = {
  register: async (data) => {
    const response = await api.post('/auth/register', {
      email: data.email,
      password: data.password,
      confirmPassword: data.confirmPassword,
      name: data.name,
      phone: data.phone,
      dateOfBirth: data.birthDate,
      ageConfirmed: data.accept18,
      termsAccepted: data.acceptTerms,
      privacyAccepted: data.acceptTerms,
    });
    return response.data;
  },

  login: async (email, password) => {
    const response = await api.post('/auth/login', { email, password });
    return response.data;
  },

  verifyEmail: async (userId, code) => {
    const response = await api.post('/auth/verify-email', { userId, code });
    return response.data;
  },
};

export default authService;