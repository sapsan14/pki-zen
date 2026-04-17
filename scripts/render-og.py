#!/usr/bin/env python3
"""Render publish/covers/og.svg → publish/site/public/og.png (1200×630)."""
from __future__ import annotations

from pathlib import Path
import sys

try:
    import cairosvg
except ImportError:
    print("Install cairosvg: pip install cairosvg", file=sys.stderr)
    sys.exit(1)

ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / "publish" / "covers" / "og.svg"
DST = ROOT / "publish" / "site" / "public" / "og.png"

DST.parent.mkdir(parents=True, exist_ok=True)
cairosvg.svg2png(
    url=str(SRC),
    write_to=str(DST),
    output_width=1200,
    output_height=630,
)
print(f"Wrote {DST.relative_to(ROOT)} ({DST.stat().st_size:,} bytes)")
