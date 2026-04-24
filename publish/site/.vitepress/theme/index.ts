import DefaultTheme from 'vitepress/theme';
import { inBrowser } from 'vitepress';
import type { Theme } from 'vitepress';
import './custom.css';

// VitePress's language switcher rewrites locale prefixes based on the
// current path. For our trilingual sūtra it can produce URLs the SPA
// doesn't know about but the Worker (src/worker.js) redirects to the
// real page. VitePress's SPA router then catches the click, can't
// resolve the route, and renders its built-in 404 page entirely in the
// browser — no HTTP request is made, so the Worker redirect never
// fires. Refresh fixes it because that triggers a real GET.
//
// There are three URL shapes the switcher can emit that the SPA 404s on:
//
//   1. Double locale prefix — from a /ru/<slug> page, clicking EN or ET:
//      /en/ru/<ru-slug>   /et/ru/<ru-slug>   /en/et/<slug>   /et/en/<slug>
//   2. Single-segment, no locale — from /en/ or /et/ pages, clicking
//      Русский (root locale's link is `/`):
//      /<en-slug>   /<et-slug>   /oracle
//   3. Cross-locale slug — from /en/<en> clicking ET, /et/<et> clicking EN:
//      /et/<en-slug>   /en/<et-slug>   (already double-prefix form but
//      with locale-vs-locale instead of ru-as-source)
//
// The rule: if the target path is anything other than a canonical
// /(ru|en|et)/... page, the bare landing, or an asset URL with an
// extension, hand the navigation to window.location so the Worker can
// redirect it.
function needsFullNav(pathname: string): boolean {
  // Case 1 + 3: double locale prefix of any form.
  if (/^\/(en|et)\/(en|et|ru)\//.test(pathname)) return true;
  // Case 2: single segment with no dot (rules out /favicon.svg etc)
  // and not the landing, not a locale root.
  if (/^\/[^/.]+$/.test(pathname)
      && !/^\/(ru|en|et)$/.test(pathname)) return true;
  return false;
}

export default {
  extends: DefaultTheme,
  enhanceApp({ router }) {
    if (!inBrowser) return;
    const prev = router.onBeforeRouteChange;
    router.onBeforeRouteChange = (to) => {
      const pathname = to.split(/[?#]/)[0];
      if (needsFullNav(pathname)) {
        window.location.href = to;
        // Cancel the SPA route change; the full navigation above
        // replaces it.
        return false;
      }
      return prev ? prev(to) : undefined;
    };
  },
} satisfies Theme;
