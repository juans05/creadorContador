/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          DEFAULT: '#667eea',
          dark: '#764ba2',
          light: '#8b9eff',
        },
        success: '#10b981',
        danger: '#dc2626',
        warning: '#f59e0b',
        info: '#3b82f6',
        diamond: '#ffd700',
        overlay: 'rgba(0,0,0,0.5)',
      },
      fontFamily: {
        sans: ['Inter', 'Segoe UI', 'sans-serif'],
        mono: ['Monaco', 'Courier New', 'monospace'],
      },
    },
  },
  plugins: [],
}
