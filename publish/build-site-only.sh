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
#
# Preserve the per-locale landing (index.md) if present — it lives under
# publish/site/<lang>/index.md and is NOT part of books/. Historically
# this step did `rm -rf publish/site/<lang>` which silently wiped the
# landing; that caused /en/ and /et/ to 404 in production.
for lang in ru en et; do
  mkdir -p "publish/site/$lang"
  # Remove only chapter files (NN-*.md). Keep index.md and anything else.
  find "publish/site/$lang" -maxdepth 1 -type f -name '[0-9][0-9]-*.md' -delete
  cp -R "books/$lang/." "publish/site/$lang/"
done

# Publish the Oracle bundle as static site assets — the book's oracle
# chapter links to https://zen.tyche.institute/oracle/<file>.
mkdir -p publish/site/public/oracle
cp oracle/system-prompt.md oracle/corpus.jsonl oracle/examples.md oracle/README.md \
   publish/site/public/oracle/

echo "→ [3/3] Build VitePress"
cd publish/site
# CF Pages provides node + npm. Install if deps missing.
[ -d node_modules ] || npm ci || npm install
npx vitepress build

echo
echo "Done. Site at: $ROOT/publish/site/.vitepress/dist"
