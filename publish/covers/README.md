# Covers

`cover.svg` is the canonical trilingual cover — vector, self-contained,
embedded hex-byte pattern symbolising entropy, an eight-petal lotus
symbolising the eight non-prologue books plus the two new ones.

Regenerate raster versions for EPUB/PDF:

```bash
# 1200 px wide for EPUB (3:2 aspect kept)
rsvg-convert -w 1200 publish/covers/cover.svg > publish/covers/cover.png
# 600 dpi PDF for print
rsvg-convert -f pdf publish/covers/cover.svg > publish/covers/cover.pdf
```

Colour palette (intentional):

- `#faf8f1` / `#e8e3d1` — old paper, warm.
- `#1a1a1a` — ink black.
- `#4a3b2a` — lotus sepia.
- `#b4aa88` — faded hex pattern (entropy, but gently).

Feel free to replace with a photograph of an HSM at dawn.
