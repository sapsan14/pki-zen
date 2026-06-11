# Site — VitePress

This folder builds the PKI-ZEN website at [zen.tyche.institute](https://zen.tyche.institute/).

## Local development

```bash
cd publish/site
npm install
# Sync books into the site tree (otherwise /ru/ /en/ /et/ are empty):
../build-site-only.sh  # builds once
# Or for dev with live reload, sync manually then dev-serve:
rsync -a ../../books/ru/ ru/
rsync -a ../../books/en/ en/
rsync -a ../../books/et/ et/
npx vitepress dev
```

Site opens on `http://localhost:5173`. Edit Markdown in `books/**/*.md` (the canonical source), re-run rsync, and the page reloads.

## Build

```bash
bash ../build-site-only.sh
# Output: publish/site/.vitepress/dist/
```

## Deploy (Cloudflare Pages)

Automatic on every push to `main`. See `DEPLOY.md` at repo root for the one-time dashboard setup.

### Base-path override

If you ever deploy under a subpath (e.g. `h2oatlas.ee/pki-zen/`) instead of a subdomain:

```bash
PKI_ZEN_BASE=/pki-zen/ npx vitepress build
```

The config reads `PKI_ZEN_BASE` and prefixes all asset/nav links. Default is `/` for subdomain deployment.
