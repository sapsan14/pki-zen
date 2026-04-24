// Worker entry-point for the PKI-ZEN site.
//
// Most of the time this just delegates to the ASSETS binding (Cloudflare
// Workers Static Assets). The map below adds one explicit shortcut on
// top of that: VitePress's built-in language switcher does not strip the
// source locale before prepending the target one, so a reader on
// /ru/00-prolog who clicks `English` lands on /en/ru/00-prolog (a 404).
// The book also uses translated slugs per language, so even after fixing
// the prefix the right English page would be /en/00-prologue, not
// /en/00-prolog. The _redirects file in the assets dir was meant to do
// this in the runtime, but Workers Assets does not always pick those
// rules up reliably for the double-prefix pattern, so we apply the
// rewrite here, in code, before delegating to ASSETS.

// Per-book slug across the three locales (Book IV and the colophon are
// omitted because their slug is identical in all three languages).
const BOOKS = [
  { ru: '00-prolog',                en: '00-prologue',              et: '00-proloog' },
  { ru: '01-put-inzhenera',         en: '01-way-of-the-engineer',   et: '01-inseneri-tee' },
  { ru: '02-ten-doveriya',          en: '02-shadow-of-trust',       et: '02-usalduse-vari' },
  { ru: '03-karma-algoritmov',      en: '03-karma-of-algorithms',   et: '03-algoritmide-karma' },
  { ru: '05-tishina-monitoringa',   en: '05-silence-of-monitoring', et: '05-monitooringu-vaikus' },
  { ru: '06-terabayt',              en: '06-terabyte',              et: '06-terabait' },
  { ru: '07-konteynery-i-karma',    en: '07-containers-and-karma',  et: '07-konteinerid-ja-karma' },
  { ru: '08-zhizn-posle-entropii',  en: '08-life-after-entropy',    et: '08-parast-entroopiat' },
  { ru: '09-pole-doveriya',         en: '09-field-of-trust',        et: '09-usalduse-vali' },
  { ru: '10-kodeks-nolya',          en: '10-codex-zero',            et: '10-nullkoodeks' },
  { ru: '99-appendix-origin',       en: '99-appendix-origin',       et: '99-lisa-paritolu' },
];

// Build a flat `from path → to path` lookup for every URL the
// VitePress LangSwitch can produce. Six rule families per book:
//
//   /ru/<ru>            → no rewrite (canonical)
//   /en/ru/<ru>         → /en/<en>     (Russian page → English)
//   /et/ru/<ru>         → /et/<et>     (Russian page → Estonian)
//   /<en>               → /ru/<ru>     (English page → Русский, root locale)
//   /<et>               → /ru/<ru>     (Estonian page → Русский, root locale)
//   /et/<en>            → /et/<et>     (English page → Estonian)
//   /en/<et>            → /en/<en>     (Estonian page → English)
//
// Plus a couple of fixed singletons for non-book pages (oracle) that
// readers sometimes hit at /en/<page> or /et/<page> — neither locale
// has its own copy, the page lives at the root.
const REDIRECTS = (() => {
  const map = new Map();
  for (const b of BOOKS) {
    if (b.ru !== b.en) map.set(`/en/ru/${b.ru}`, `/en/${b.en}`);
    if (b.ru !== b.et) map.set(`/et/ru/${b.ru}`, `/et/${b.et}`);
    if (b.ru !== b.en) map.set(`/${b.en}`,       `/ru/${b.ru}`);
    if (b.ru !== b.et) map.set(`/${b.et}`,       `/ru/${b.ru}`);
    if (b.en !== b.et) map.set(`/et/${b.en}`,    `/et/${b.et}`);
    if (b.en !== b.et) map.set(`/en/${b.et}`,    `/en/${b.en}`);
  }
  // The Oracle page is a single document at /oracle, but readers (and
  // some external links) sometimes prepend the locale prefix. Send
  // /en/oracle and /et/oracle to the canonical /oracle URL.
  map.set('/en/oracle', '/oracle');
  map.set('/et/oracle', '/oracle');
  return map;
})();

export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    // Trim a single trailing slash so /en/ru/00-prolog/ matches the
    // map key /en/ru/00-prolog. Don't touch the bare "/" landing page.
    const key = url.pathname.length > 1
      ? url.pathname.replace(/\/$/, '')
      : url.pathname;
    const target = REDIRECTS.get(key);
    if (target) {
      return Response.redirect(new URL(target, url), 301);
    }
    return env.ASSETS.fetch(request);
  },
};
