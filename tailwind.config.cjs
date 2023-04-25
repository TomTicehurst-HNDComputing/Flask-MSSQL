module.exports = {
  content: ["./render/**/*.{html,js,ts,jinja}"],
  theme: {
    fontFamily: {
      sans: ["inter", "sans-serif"]
    },
    extend: {
      maxWidth: {
        "8xl": "85rem",
        "9xl": "92rem"
      }
    }
  },
  plugins: []
};
