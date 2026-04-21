# Covers

Two print-ready SVGs at 6 × 9 inch trim (1800 × 2700 px @ 300 DPI):

| File | Purpose |
|---|---|
| `cover.svg`      | Front cover. Also used as the EPUB cover (rasterised to `cover.png` at build time by `publish/build.sh`). |
| `back-cover.svg` | Back cover. For print only — EPUB has no back cover. Carries the v2.3 pull-quote, the trilingual tagline, the lotus mark, site URL, and an ISBN / barcode block. |
| `cover.png`      | 1200 px rasterised front — committed so EPUB readers that don't rasterise SVG (most) see the cover. |
| `back-cover.png` | Convenience raster for print proofing. |
| `logo.svg`       | Small lotus mark used on the web (favicon, hero, README). |
| `og.svg`         | 1200 × 630 Open Graph card for social sharing. |

## Regenerate

```bash
# front + back to PNG at 1200 px wide
python3 -c "import cairosvg; cairosvg.svg2png(url='publish/covers/cover.svg',      write_to='publish/covers/cover.png',      output_width=1200)"
python3 -c "import cairosvg; cairosvg.svg2png(url='publish/covers/back-cover.svg', write_to='publish/covers/back-cover.png', output_width=1200)"

# 300-DPI PDF for a printer
rsvg-convert -f pdf publish/covers/cover.svg      > dist/cover.pdf
rsvg-convert -f pdf publish/covers/back-cover.svg > dist/back-cover.pdf
```

## Palette

- `#faf8f1` / `#efe8d1` — old paper, warm.
- `#1a1a1a` — ink black.
- `#4a3b2a` — lotus sepia.
- `#6a5a3a` — warm grey for secondary text.
- `#b4aa88` — faded hex pattern (entropy, but gently).

## Print file assembly

For a real print run (KDP, IngramSpark, a local Estonian printer):

1. Build the interior PDF: `bash publish/build.sh` → `dist/pki-zen-<lang>.pdf`.
2. Take `cover.svg` + `back-cover.svg`, place them side-by-side in a layout
   tool (Affinity Publisher, InDesign, or `scribus-ng` CLI) with the spine
   width computed from page count × paper weight; e.g. for ~100 pages on
   60 lb white, spine ≈ 6.4 mm. Print shops usually do this for you once
   you hand them both covers.
3. Replace the `ISBN: 978-9949-00-0000-0` placeholder on the back cover
   with the real ISBN the Estonian National Library assigns you
   (see the ISBN instructions in `DEPLOY.md`).

## ISBN (Estonia)

Free, online, non-bureaucratic:
- Apply at <https://www.nlib.ee/en/publishing/isbn-office>.
- One ISBN per edition — request three (RU / EN / ET). Turnaround is
  usually 1–2 working days.
- Once you have it, update `ISBN:` on the back cover and optionally
  add it to the EPUB metadata (`publish/pandoc/metadata.<lang>.yaml`
  key `identifier:`).
