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

echo "→ [2.5/6] Rasterise cover SVG → PNG for EPUB readers"
mkdir -p dist
COVER_PNG="$DIST/cover.png"
if command -v rsvg-convert >/dev/null 2>&1; then
  rsvg-convert -w 800 publish/covers/cover.svg > "$COVER_PNG"
elif command -v cairosvg >/dev/null 2>&1 || python3 -c "import cairosvg" 2>/dev/null; then
  python3 -c "import cairosvg; cairosvg.svg2png(url='publish/covers/cover.svg', write_to='$COVER_PNG', output_width=800)"
else
  echo "   ! no SVG rasteriser found; falling back to SVG cover (some EPUB readers may skip it)"
  COVER_PNG="publish/covers/cover.svg"
fi
echo "   ✓ $COVER_PNG"

echo "→ [3/6] Build EPUBs (3 languages)"
build_epub() {
  local lang="$1"; local meta="publish/pandoc/metadata.$lang.yaml"
  local out="$DIST/pki-zen-$lang.epub"
  # --webtex: render LaTeX math as external PNG images so readers
  # without MathML support (iPhone Books, older Android e-readers)
  # still see formulas correctly. MathML default leaves \lvert\rangle
  # etc. as unstyled unicode that many fonts show as .notdef boxes.
  pandoc \
    --metadata-file="$meta" \
    --css=publish/pandoc/epub.css \
    --epub-cover-image="$COVER_PNG" \
    --webtex=https://latex.codecogs.com/svg.image? \
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
  # --no-highlight: skip Pandoc's LaTeX syntax-highlighting macros
  # entirely. The book has a handful of inline code spans; they're
  # readable as plain monospace and this sidesteps the whole
  # Shaded/Tok/framed cascade that kept breaking the PDF build.
  pandoc \
    --metadata-file="$meta" \
    --metadata=babel-lang:"$babel" \
    --pdf-engine=xelatex \
    --template=publish/pandoc/pdf-template.tex \
    --no-highlight \
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
