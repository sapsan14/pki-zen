#!/usr/bin/env bash
# PKI-ZEN full build: site + 3×EPUB + 3×PDF + oracle bundle + SHA-256 manifest.
# Requires: pandoc, xelatex, node (for vitepress), python3, jq.
# Fonts expected: EB Garamond, Noto Sans, JetBrains Mono, Noto Serif (Cyrillic fallback).

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

DIST="$ROOT/dist"
mkdir -p "$DIST"

echo "→ [1/6] Verify trilingual parallel structure"
python3 scripts/verify-parallel.py

echo "→ [2/6] Build Oracle corpus from Markdown"
python3 scripts/build-corpus.py
mkdir -p "$DIST/oracle"
cp oracle/system-prompt.md oracle/examples.md oracle/README.md oracle/corpus.jsonl "$DIST/oracle/"

echo "→ [3/6] Build EPUBs (3 languages)"
build_epub() {
  local lang="$1"; local meta="publish/pandoc/metadata.$lang.yaml"
  local out="$DIST/pki-zen-$lang.epub"
  pandoc \
    --metadata-file="$meta" \
    --css=publish/pandoc/epub.css \
    --epub-cover-image=publish/covers/cover.svg \
    --toc --toc-depth=2 \
    -o "$out" \
    books/"$lang"/*.md
  echo "   ✓ $out"
}
build_epub ru
build_epub en
build_epub et

echo "→ [4/6] Build PDFs (3 languages) via XeLaTeX"
build_pdf() {
  local lang="$1"; local babel="$2"
  local meta="publish/pandoc/metadata.$lang.yaml"
  local out="$DIST/pki-zen-$lang.pdf"
  pandoc \
    --metadata-file="$meta" \
    --metadata=babel-lang:"$babel" \
    --pdf-engine=xelatex \
    --template=publish/pandoc/pdf-template.tex \
    --toc --toc-depth=2 \
    -o "$out" \
    books/"$lang"/*.md
  echo "   ✓ $out"
}
build_pdf ru russian
build_pdf en english
build_pdf et estonian

echo "→ [5/6] Build VitePress site"
# Sync Markdown into the site tree so VitePress can resolve /ru/ /en/ /et/.
rsync -a --delete books/ru/  publish/site/ru/
rsync -a --delete books/en/  publish/site/en/
rsync -a --delete books/et/  publish/site/et/
# Rename files whose slugs differ from the book filenames (ru/et prologue).
# No renames required right now — book filenames match config.ts links.
if [ -d publish/site/node_modules ]; then :; else
  (cd publish/site && npm install --silent)
fi
(cd publish/site && npx vitepress build)
cp -r publish/site/.vitepress/dist "$DIST/site"

echo "→ [6/6] SHA-256 manifest"
( cd "$DIST" && find . -type f ! -name SHA256SUMS -print0 | sort -z \
   | xargs -0 sha256sum > SHA256SUMS )
echo
echo "Done. Artefacts in $DIST/:"
ls -la "$DIST"
