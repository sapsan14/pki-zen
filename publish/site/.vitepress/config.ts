import { defineConfig } from 'vitepress';

// PKI-ZEN trilingual sūtra — one config, three locales. Sidebars are
// generated from the fixed book order so adding a verse only requires
// editing Markdown.

const BOOKS_RU = [
  { text: '0. Пролог',            link: '/ru/00-prolog' },
  { text: 'I. Путь инженера',     link: '/ru/01-put-inzhenera' },
  { text: 'II. Тень доверия',     link: '/ru/02-ten-doveriya' },
  { text: 'III. Карма алгоритмов', link: '/ru/03-karma-algoritmov' },
  { text: 'IV. DevOps-самсара',   link: '/ru/04-devops-samsara' },
  { text: 'V. Тишина мониторинга', link: '/ru/05-tishina-monitoringa' },
  { text: 'VI. Терабайт',          link: '/ru/06-terabayt' },
  { text: 'VII. Контейнеры и карма', link: '/ru/07-konteynery-i-karma' },
  { text: 'VIII. После энтропии', link: '/ru/08-zhizn-posle-entropii' },
  { text: 'IX. Поле доверия',     link: '/ru/09-pole-doveriya' },
  { text: 'X. Кодекс Нуля',       link: '/ru/10-kodeks-nolya' },
  { text: 'Приложение',           link: '/ru/99-appendix-origin' },
  { text: 'Колофон',              link: '/ru/99-colophon' },
];

const BOOKS_EN = [
  { text: '0. Prologue',              link: '/en/00-prologue' },
  { text: 'I. Way of the Engineer',   link: '/en/01-way-of-the-engineer' },
  { text: 'II. Shadow of Trust',      link: '/en/02-shadow-of-trust' },
  { text: 'III. Karma of Algorithms', link: '/en/03-karma-of-algorithms' },
  { text: 'IV. DevOps Saṃsāra',       link: '/en/04-devops-samsara' },
  { text: 'V. Silence of Monitoring', link: '/en/05-silence-of-monitoring' },
  { text: 'VI. One Terabyte',         link: '/en/06-terabyte' },
  { text: 'VII. Containers and Karma',link: '/en/07-containers-and-karma' },
  { text: 'VIII. After Entropy',      link: '/en/08-life-after-entropy' },
  { text: 'IX. Field of Trust',       link: '/en/09-field-of-trust' },
  { text: 'X. Codex Zero',            link: '/en/10-codex-zero' },
  { text: 'Appendix',                 link: '/en/99-appendix-origin' },
  { text: 'Colophon',                 link: '/en/99-colophon' },
];

const BOOKS_ET = [
  { text: '0. Proloog',              link: '/et/00-proloog' },
  { text: 'I. Inseneri tee',         link: '/et/01-inseneri-tee' },
  { text: 'II. Usalduse vari',       link: '/et/02-usalduse-vari' },
  { text: 'III. Algoritmide karma',  link: '/et/03-algoritmide-karma' },
  { text: 'IV. DevOps-saṃsāra',      link: '/et/04-devops-samsara' },
  { text: 'V. Monitooringu vaikus',  link: '/et/05-monitooringu-vaikus' },
  { text: 'VI. Üks terabait',        link: '/et/06-terabait' },
  { text: 'VII. Konteinerid ja karma', link: '/et/07-konteinerid-ja-karma' },
  { text: 'VIII. Pärast entroopiat', link: '/et/08-parast-entroopiat' },
  { text: 'IX. Usalduse väli',       link: '/et/09-usalduse-vali' },
  { text: 'X. Nullkoodeks',          link: '/et/10-nullkoodeks' },
  { text: 'Lisa',                    link: '/et/99-lisa-paritolu' },
  { text: 'Kolofon',                 link: '/et/99-colophon' },
];

// Single source of truth for the "latest GitHub Release" page. Each
// locale's nav gets a localised label pointing here; the home-page
// download sections link directly to the assets with the same base URL.
const RELEASES = 'https://github.com/sapsan14/pki-zen/releases/latest';
const DL = 'https://github.com/sapsan14/pki-zen/releases/latest/download';

// Base-path: defaults to "/" (subdomain deployment: pki-zen.tyche.institute).
// Override with PKI_ZEN_BASE=/pki-zen/ env var if deploying under a subpath
// (e.g. h2oatlas.ee/pki-zen/). Must start and end with a slash.
const BASE = process.env.PKI_ZEN_BASE ?? '/';

// Cache-bust for logo / favicon / og — bump when the visual changes so
// browsers and CF edge don't serve yesterday's logo forever.
const ASSET_VERSION = 'v4';

export default defineConfig({
  title: 'PKI-ZEN',
  description: 'Сутра о сертификатах, YAML и почти-просветлении.',
  base: BASE,
  cleanUrls: true,
  srcDir: '.',
  ignoreDeadLinks: true,
  sitemap: {
    hostname: 'https://pki-zen.tyche.institute',
  },
  markdown: {
    // Render $...$  and  $$...$$  via MathJax 3 (SVG output).
    // Loaded from node_modules at build time; no runtime network.
    math: true,
  },
  head: [
    // Faster font load: open TCP + TLS to Google Fonts before the @import parses.
    ['link', { rel: 'preconnect', href: 'https://fonts.googleapis.com' }],
    ['link', { rel: 'preconnect', href: 'https://fonts.gstatic.com', crossorigin: '' }],
    ['link', { rel: 'icon', type: 'image/svg+xml', href: `${BASE}favicon.svg?${ASSET_VERSION}` }],
    ['meta', { name: 'theme-color', content: '#4a3b2a' }],
    ['meta', { property: 'og:type', content: 'book' }],
    ['meta', { property: 'og:title', content: 'PKI-ZEN — A Sūtra of Certificates, YAML, and Almost-Enlightenment' }],
    ['meta', { property: 'og:description', content: 'Ten small books. Three languages. One breath between two CRL updates.' }],
    ['meta', { property: 'og:image', content: `https://pki-zen.tyche.institute/og.png?${ASSET_VERSION}` }],
    ['meta', { property: 'og:image:width', content: '1200' }],
    ['meta', { property: 'og:image:height', content: '630' }],
    ['meta', { property: 'og:url', content: 'https://pki-zen.tyche.institute/' }],
    ['meta', { name: 'twitter:card', content: 'summary_large_image' }],
    ['meta', { name: 'twitter:image', content: `https://pki-zen.tyche.institute/og.png?${ASSET_VERSION}` }],
  ],

  locales: {
    root: {
      label: 'Русский',
      lang: 'ru-RU',
      link: '/',
      themeConfig: {
        sidebar: { '/ru/': [{ text: 'Тома', items: BOOKS_RU }] },
        nav: [
          { text: 'Оракул', link: '/ru/oracle' },
          { text: 'Скачать', link: RELEASES },
          { text: 'GitHub', link: 'https://github.com/sapsan14/pki-zen' },
        ],
        outline: { label: 'На этой странице', level: [2, 3] },
        returnToTopLabel: 'Наверх',
        sidebarMenuLabel: 'Меню',
        darkModeSwitchLabel: 'Тема',
        lightModeSwitchTitle: 'Светлая тема',
        darkModeSwitchTitle:  'Тёмная тема',
        langMenuLabel: 'Сменить язык',
        docFooter: { prev: 'Предыдущий', next: 'Следующий' },
      },
    },
    en: {
      label: 'English',
      lang: 'en-GB',
      link: '/en/',
      themeConfig: {
        sidebar: { '/en/': [{ text: 'Books', items: BOOKS_EN }] },
        nav: [
          { text: 'Oracle', link: '/en/oracle' },
          { text: 'Download', link: RELEASES },
          { text: 'GitHub', link: 'https://github.com/sapsan14/pki-zen' },
        ],
        outline: { label: 'On this page', level: [2, 3] },
      },
    },
    et: {
      label: 'Eesti',
      lang: 'et-EE',
      link: '/et/',
      themeConfig: {
        sidebar: { '/et/': [{ text: 'Köited', items: BOOKS_ET }] },
        nav: [
          { text: 'Oraakel', link: '/et/oracle' },
          { text: 'Laadi alla', link: RELEASES },
          { text: 'GitHub', link: 'https://github.com/sapsan14/pki-zen' },
        ],
        outline: { label: 'Sellel lehel', level: [2, 3] },
        returnToTopLabel: 'Üles',
        sidebarMenuLabel: 'Menüü',
        darkModeSwitchLabel: 'Teema',
        lightModeSwitchTitle: 'Hele teema',
        darkModeSwitchTitle:  'Tume teema',
        langMenuLabel: 'Vaheta keelt',
        docFooter: { prev: 'Eelmine', next: 'Järgmine' },
      },
    },
  },

  themeConfig: {
    // Intentionally no global logoLink — each locale's `link` above
    // controls where the PKI-ZEN logo navigates per language, so an
    // English reader going "home" lands on /en/ not /.
    search: { provider: 'local' },
    socialLinks: [{ icon: 'github', link: 'https://github.com/sapsan14/pki-zen' }],
    footer: {
      message: 'CC-BY-SA-4.0 · code under MIT',
      copyright: '© 2025–2026 Anton Sokolov & co-scribes',
    },
  },
});
