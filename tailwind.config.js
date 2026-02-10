/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/renderer/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        primary: '#5E9BFF',
        'primary-dark': '#4A7DD9',
        'primary-light': '#7AADFF',
      },
    },
  },
  plugins: [],
}
