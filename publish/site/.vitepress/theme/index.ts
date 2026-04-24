import DefaultTheme from 'vitepress/theme';
import { inBrowser } from 'vitepress';
import type { Theme } from 'vitepress';
import './custom.css';

// VitePress's language switcher emits <a href="/<target-locale>/<current-path>">.
// For our trilingual sūtra that produces URLs like /en/ru/00-prolog — a
// path the site doesn't have. VitePress's SPA router then catches the
// click, can't resolve the route, and renders its built-in 404 page
// entirely client-side. No HTTP request is made, so the Worker's
// /en/ru/<ru-slug> → /en/<en-slug> redirect (src/worker.js) never fires.
// The user hitting refresh *does* trigger a real GET, which is why the
// server redirect works on reload but not on the initial click.
//
// Intercept the SPA navigation for these double-prefix paths and fall
// back to window.location so the browser performs a full-page request
// and the Worker redirect takes over.
const DOUBLE_PREFIX = /^\/(en|et)\/(ru|en|et)\//;

export default {
  extends: DefaultTheme,
  enhanceApp({ router }) {
    if (!inBrowser) return;
    const prev = router.onBeforeRouteChange;
    router.onBeforeRouteChange = (to) => {
      // Only handle paths the router would otherwise 404 on. If the
      // target starts with a second locale segment the Worker knows
      // how to rewrite, hand the browser off for a full navigation.
      const pathname = to.split(/[?#]/)[0];
      if (DOUBLE_PREFIX.test(pathname)) {
        window.location.href = to;
        // Cancel the SPA route change; the full navigation above
        // replaces it.
        return false;
      }
      return prev ? prev(to) : undefined;
    };
  },
} satisfies Theme;
