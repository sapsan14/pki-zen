#!/usr/bin/env bash
# Cloudflare Pages build: only the VitePress site (no Pandoc / XeLaTeX).
# EPUB / PDF live on GitHub Releases and are linked from the site.

set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

echo "→ [1/3] Verify trilingual parallel structure"
python3 scripts/verify-parallel.py

echo "→ [2/3] Sync books into site tree"
# Use POSIX cp instead of rsync: the Cloudflare Workers Builds image
# doesn't ship rsync, and we only need a straight copy — no rsync-specific
# features like deltas or remote sync.
for lang in ru en et; do
  rm -rf "publish/site/$lang"
  mkdir -p "publish/site/$lang"
  cp -R "books/$lang/." "publish/site/$lang/"
done

echo "→ [3/3] Build VitePress"
cd publish/site
# CF Pages provides node + npm. Install if deps missing.
[ -d node_modules ] || npm ci || npm install
npx vitepress build

echo
echo "Done. Site at: $ROOT/publish/site/.vitepress/dist"
