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

echo "→ [2.3/6] Compute canonical Russian SHA-256 and inject into colophons"
# The colophon carries a 'trust receipt' — the SHA-256 of the concatenated
# Russian canonical text. Substitute the placeholder in each locale's
# colophon with the real fingerprint (zero-leading-zero safe).
RU_SHA=$(find books/ru -name '*.md' -print0 | sort -z | xargs -0 cat | sha256sum | awk '{print $1}')
echo "   canonical RU sha256: $RU_SHA"
# Break the 64-char hash into two lines of two space-separated 16-char
# groups. Even at \small the single-line form (64+3 chars) overflows the
# 6-inch column; two 33-char lines fit comfortably.
RU_SHA_FORMATTED="${RU_SHA:0:16} ${RU_SHA:16:16}"$'\n'"${RU_SHA:32:16} ${RU_SHA:48:16}"
# Work on COPIES under the dist tree so the source .md stays unchanged
# (and verify-parallel stays deterministic).
mkdir -p "$DIST/books-stamped"
for lang in ru en et; do
  mkdir -p "$DIST/books-stamped/$lang"
  cp -a books/"$lang"/. "$DIST/books-stamped/$lang/"
done
# Replace the placeholder line (anything between the code-fence that
# starts with <computed|вычисляется|arvutatakse) with the fingerprint.
for f in "$DIST/books-stamped"/*/99-colophon.md; do
  python3 - "$f" "$RU_SHA_FORMATTED" <<'PY'
import re, sys
path, sha = sys.argv[1:]
src = open(path, encoding='utf-8').read()
out = re.sub(
    r'```\n<(?:computed|вычисляется|arvutatakse)[^>]*>\n```',
    f'```\n{sha}\n```',
    src,
)
open(path, 'w', encoding='utf-8').write(out)
PY
done

echo "→ [2.5/6] Rasterise cover SVG → PNG for EPUB, PDF for XeLaTeX"
mkdir -p "$DIST"
COVER_PNG="$DIST/cover.png"
COVER_PDF="$DIST/cover.pdf"
BACK_COVER_PDF="$DIST/back-cover.pdf"
if command -v rsvg-convert >/dev/null 2>&1; then
  rsvg-convert -w 1200                 publish/covers/cover.svg       > "$COVER_PNG"
  rsvg-convert -f pdf                  publish/covers/cover.svg       > "$COVER_PDF"
  rsvg-convert -f pdf                  publish/covers/back-cover.svg  > "$BACK_COVER_PDF"
elif command -v cairosvg >/dev/null 2>&1 || python3 -c "import cairosvg" 2>/dev/null; then
  python3 -c "import cairosvg; cairosvg.svg2png(url='publish/covers/cover.svg', write_to='$COVER_PNG', output_width=1200)"
  python3 -c "import cairosvg; cairosvg.svg2pdf(url='publish/covers/cover.svg',      write_to='$COVER_PDF')"
  python3 -c "import cairosvg; cairosvg.svg2pdf(url='publish/covers/back-cover.svg', write_to='$BACK_COVER_PDF')"
else
  echo "   ! no SVG rasteriser found; PDFs will have no embedded covers"
  COVER_PNG="publish/covers/cover.svg"
  COVER_PDF=""
  BACK_COVER_PDF=""
fi
echo "   ✓ $COVER_PNG  $COVER_PDF  $BACK_COVER_PDF"

echo "→ [3/6] Build EPUBs (3 languages)"
build_epub() {
  local lang="$1"; local meta="publish/pandoc/metadata.$lang.yaml"
  local out="$DIST/pki-zen-$lang.epub"
  # --mathml: native math in EPUB3 (pandoc default). Offline-safe;
  # modern readers (Apple Books, Calibre, Kobo, Android readers)
  # render it with their built-in math font. The previous --webtex
  # approach depended on codecogs.com being reachable at reader-open
  # time, which is brittle on planes, metros, and libraries.
  # --section-divs: wraps each verse in <section class="level2"> so
  # the EPUB CSS can keep a verse whole across page breaks.
  pandoc \
    --metadata-file="$meta" \
    --css=publish/pandoc/epub.css \
    --epub-cover-image="$COVER_PNG" \
    --webtex=https://latex.codecogs.com/svg.image? \
    --section-divs \
    --toc --toc-depth=2 \
    -o "$out" \
    "$DIST/books-stamped/$lang"/*.md
  echo "   ✓ $out"
}
build_epub ru
build_epub en
build_epub et

echo "→ [4/6] Build PDFs (3 languages) via XeLaTeX"
# Post-process the stamped tree for PDF-only rendering tweaks:
#   1. Inject \newpage before the 'At one point I asked' paragraph
#      so Book VIII's origin opens on its own spread.
#   2. Glue the '*Probability: X*' closing line into the preceding
#      verse body as a hard-break-within-paragraph. That way LaTeX's
#      widow penalty (=10000) keeps the probability stuck to the
#      verse body — no more orphan probabilities on the next page.
# Both edits land ONLY in the stamped tree, right before the PDF
# build, so EPUB / web (which already rendered the same tree) see
# the clean Markdown.
python3 <<'PY'
import pathlib, re

DIST = pathlib.Path('dist/books-stamped')

# --- 1. \newpage before "At one point I asked" (appendix) ---
MARKERS = [
    ('ru', r'(?m)^(В какой-то момент я спросил:)$'),
    ('en', r'(?m)^(At one point I asked:)$'),
    ('et', r'(?m)^(Ühel hetkel küsisin:)$'),
]
for lang, pat in MARKERS:
    for md in sorted(DIST.joinpath(lang).glob('99-*origin*.md')) + \
              sorted(DIST.joinpath(lang).glob('99-*paritolu*.md')):
        src = md.read_text(encoding='utf-8')
        out = re.sub(pat, r'\\newpage\n\n\1', src, count=1)
        if out != src:
            md.write_text(out, encoding='utf-8')
            print(f'   ✓ \\newpage → {md.relative_to(DIST.parent.parent)}')

# --- 2. Glue probability line to previous paragraph, render smaller ---
# Pattern: any line, blank line, '*Probability|Вероятность|Tõenäosus: X*'
# Replace: previous line keeps trailing two spaces (markdown hard break),
#          blank line removed, probability now in the same paragraph and
#          wrapped in raw LaTeX so it renders one size smaller than the
#          verse body.
prob_re = re.compile(
    r'([^\n]+)\n\n\*((?:Probability|Вероятность|Tõenäosus):[^\n*]+)\*',
)
def _prob_sub(m):
    body = m.group(1).rstrip()
    inner = m.group(2).strip()
    # {\small \emph{...}} — raw LaTeX passes through pandoc's raw_tex
    # extension and renders as small italic inside the verse paragraph.
    return f'{body}  \n{{\\small \\emph{{{inner}}}}}'
for md in sorted(DIST.glob('*/*.md')):
    src = md.read_text(encoding='utf-8')
    out = prob_re.sub(_prob_sub, src)
    if out != src:
        md.write_text(out, encoding='utf-8')
PY

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
    --metadata=cover-pdf:"$COVER_PDF" \
    --metadata=back-cover-pdf:"$BACK_COVER_PDF" \
    --pdf-engine=xelatex \
    --template=publish/pandoc/pdf-template.tex \
    --no-highlight \
    --toc --toc-depth=2 \
    -o "$out" \
    "$DIST/books-stamped/$lang"/*.md
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
