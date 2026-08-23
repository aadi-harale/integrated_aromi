import { defineConfig } from "vite"
import react from "@vitejs/plugin-react"

export default defineConfig({
  plugins: [react()],
  // In HF Spaces the app is served from root; VITE_API_URL points to the same origin
  base: "/",
  build: {
    outDir: "dist",
    sourcemap: false,
  },
  server: {
    port: 5173,
    proxy: {
      // Proxy all /auth, /children etc. to FastAPI during local dev
      "/auth":       "http://127.0.0.1:8080",
      "/children":   "http://127.0.0.1:8080",
      "/growth":     "http://127.0.0.1:8080",
      "/attendance": "http://127.0.0.1:8080",
      "/activity":   "http://127.0.0.1:8080",
      "/mpr":        "http://127.0.0.1:8080",
      "/photo": "http://127.0.0.1:8080",
      "/voice":      "http://127.0.0.1:8080",
      "/rag":        "http://127.0.0.1:8080",
      "/agent":      "http://127.0.0.1:8080",
      "/dashboard":  "http://127.0.0.1:8080",
      "/visits":     "http://127.0.0.1:8080",
    },
  },
})
