import DefaultTheme from 'vitepress/theme';
import { inBrowser } from 'vitepress';
import type { Theme } from 'vitepress';
import './custom.css';

// VitePress's language switcher rewrites locale prefixes based on the
// current path. For our trilingual sūtra with translated slugs that
// produces URLs the SPA doesn't know about but the Worker
// (src/worker.js) knows how to redirect. Without intervention VitePress
// catches the click, fails to resolve the route, and renders its
// built-in 404 page entirely client-side — no HTTP request, so the
// Worker's redirect never fires. (Refresh works because THAT triggers
// a real GET.)
//
// Instead of re-deriving "which paths need server routing" by regex
// (which kept missing cases as we uncovered them), ask VitePress's
// own route map: __VP_HASH_MAP__ is a window global populated at boot
// with every page the site ships, keyed as e.g. `en_00-prologue.md`.
// If the target URL doesn't map to a known key, VitePress would 404
// on it — so we hand the navigation to window.location and let the
// Worker redirect decide what to do.
//
// Paths with a file extension (/favicon.svg, /sitemap.xml, /og.png …)
// are left alone because those are asset fetches, not SPA navigations.

function pathToPageKey(pathname: string): string {
  // "/"            → "index.md"
  // "/en/"         → "en_index.md"
  // "/en/00-prologue" → "en_00-prologue.md"
  // "/oracle"      → "oracle.md"
  let p = pathname.replace(/^\//, '');
  if (p === '' || p.endsWith('/')) p += 'index';
  return p.replace(/\//g, '_') + '.md';
}

export default {
  extends: DefaultTheme,
  enhanceApp({ router }) {
    if (!inBrowser) return;
    const prev = router.onBeforeRouteChange;
    router.onBeforeRouteChange = (to) => {
      const pathname = to.split(/[?#]/)[0];

      // Asset URL (has a file extension) — not an SPA navigation target.
      if (/\.[a-z0-9]+$/i.test(pathname)) {
        return prev ? prev(to) : undefined;
      }

      const hashMap = (globalThis as any).__VP_HASH_MAP__ as
        | Record<string, unknown>
        | undefined;
      // If the hash map isn't populated (shouldn't happen in prod),
      // fall back to letting the SPA try — the original behaviour.
      if (!hashMap) return prev ? prev(to) : undefined;

      if (!(pathToPageKey(pathname) in hashMap)) {
        // SPA would 404 here; let the Worker redirect take over.
        window.location.href = to;
        return false;
      }

      return prev ? prev(to) : undefined;
    };
  },
} satisfies Theme;
