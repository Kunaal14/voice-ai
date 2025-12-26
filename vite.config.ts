import path from 'path';
import { defineConfig, loadEnv } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig(({ mode }) => {
    const env = loadEnv(mode, '.', '');
    return {
      server: {
        port: 3000,
        host: '0.0.0.0',
      },
      plugins: [react()],
      define: {
        // API Keys (fallback - prefer Azure Function)
        'process.env.API_KEY': JSON.stringify(env.GEMINI_API_KEY),
        'process.env.GEMINI_API_KEY': JSON.stringify(env.GEMINI_API_KEY),
        // Azure Function URL for secure API key retrieval
        'process.env.GEMINI_API_KEY_URL': JSON.stringify(env.GEMINI_API_KEY_URL),
        // Webhook URLs
        'process.env.FORM_WEBHOOK_URL': JSON.stringify(env.FORM_WEBHOOK_URL),
        'process.env.TRANSCRIPT_WEBHOOK_URL': JSON.stringify(env.TRANSCRIPT_WEBHOOK_URL),
        'process.env.CALENDAR_AVAILABILITY_URL': JSON.stringify(env.CALENDAR_AVAILABILITY_URL),
      },
      resolve: {
        alias: {
          '@': path.resolve(__dirname, '.'),
        }
      }
    };
});
