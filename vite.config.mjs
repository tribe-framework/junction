import { defineConfig, loadEnv } from 'vite';
import { extensions, classicEmberSupport, ember } from '@embroider/vite';
import { babel } from '@rollup/plugin-babel';

export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, process.cwd(), '');
  const liveTribe = env.TRIBE_LIVE_URL;
  const liveJunction = env.JUNCTION_LIVE_URL;

  const toLiveTribe = {
    target: liveTribe,
    changeOrigin: true,
    secure: true,
    configure: (proxy) => {
      proxy.on('proxyReq', (proxyReq) => {
        if (liveJunction) proxyReq.setHeader('origin', liveJunction);
        proxyReq.removeHeader('referer');
      });
      proxy.on('proxyRes', (proxyRes) => {
        const cookies = proxyRes.headers['set-cookie'];
        if (cookies) {
          proxyRes.headers['set-cookie'] = cookies.map((cookie) =>
            cookie.replace(/;\s*secure/gi, '').replace(/;\s*domain=[^;]+/gi, ''),
          );
        }
      });
    },
  };

  return {
    plugins: [
      classicEmberSupport(),
      ember(),
      babel({
        babelHelpers: 'runtime',
        extensions,
      }),
    ],
    server: {
      port: 4200,
      strictPort: true,
      ...(liveTribe
        ? {
            proxy: {
              '^/(api|auth|uploads|search|upgrades)\\.php': toLiveTribe,
              '^/uploads/': toLiveTribe,
            },
          }
        : {}),
    },
    css: {
      preprocessorOptions: {
        scss: {
          quietDeps: true,
          silenceDeprecations: [
            'import',
            'global-builtin',
            'color-functions',
            'if-function',
          ],
        },
      },
    },
  };
});