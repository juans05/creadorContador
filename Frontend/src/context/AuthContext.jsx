import { create } from 'zustand';
import { persist } from 'zustand/middleware';
import authService from '../services/auth';

const useAuthStore = create(
  persist(
    (set, get) => ({
      user: null,
      token: null,
      isAuthenticated: false,
      isLoading: true,

      login: async (email, password) => {
        set({ isLoading: true });
        try {
          const response = await authService.login(email, password);
          if (response.success) {
            const { userId, email, name, userType, accessToken } = response.data;
            localStorage.setItem('luxor_token', accessToken);
            set({
              user: { id: userId, email, name, type: userType },
              token: accessToken,
              isAuthenticated: true,
              isLoading: false,
            });
            return { success: true };
          }
          throw new Error(response.message);
        } catch (error) {
          set({ isLoading: false });
          return { success: false, error: error.response?.data?.message || 'Error al iniciar sesión' };
        }
      },

      register: async (userData) => {
        set({ isLoading: true });
        try {
          const response = await authService.register(userData);
          if (response.success) {
            set({ isLoading: false });
            return { success: true, data: response.data };
          }
          throw new Error(response.message);
        } catch (error) {
          set({ isLoading: false });
          const errors = error.response?.data?.errors || [];
          return { success: false, errors };
        }
      },

      logout: () => {
        localStorage.removeItem('luxor_token');
        set({
          user: null,
          token: null,
          isAuthenticated: false,
          isLoading: false,
        });
      },

      updateUser: (updates) => {
        set((state) => ({
          user: { ...state.user, ...updates },
        }));
      },

      setLoading: (isLoading) => set({ isLoading }),
    }),
    {
      name: 'luxor-auth',
      partialize: (state) => ({
        user: state.user,
        token: state.token,
        isAuthenticated: state.isAuthenticated,
      }),
    }
  )
);

export const useAuth = () => {
  const store = useAuthStore();
  return store;
};

export default useAuthStore;