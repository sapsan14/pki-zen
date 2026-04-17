#!/usr/bin/env bash
# Cloudflare Pages build: only the VitePress site (no Pandoc / XeLaTeX).
# EPUB / PDF live on GitHub Releases and are linked from the site.

set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

echo "→ [1/3] Verify trilingual parallel structure"
python3 scripts/verify-parallel.py

echo "→ [2/3] Sync books into site tree"
mkdir -p publish/site/ru publish/site/en publish/site/et
rsync -a --delete books/ru/ publish/site/ru/
rsync -a --delete books/en/ publish/site/en/
rsync -a --delete books/et/ publish/site/et/

echo "→ [3/3] Build VitePress"
cd publish/site
# CF Pages provides node + npm. Install if deps missing.
[ -d node_modules ] || npm ci || npm install
npx vitepress build

echo
echo "Done. Site at: $ROOT/publish/site/.vitepress/dist"
