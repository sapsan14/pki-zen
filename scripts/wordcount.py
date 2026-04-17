#!/usr/bin/env python3
"""Print word-count statistics per book per language."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
BOOKS = ROOT / "books"
LANGS = ("ru", "en", "et")


def words(s: str) -> int:
    return len(re.findall(r"\w+", s, flags=re.UNICODE))


def main() -> None:
    print(f"{'file':42} {'ru':>8} {'en':>8} {'et':>8}")
    print("-" * 70)
    # Align by filename stem across languages where slugs differ.
    stems = sorted({md.stem for l in LANGS for md in (BOOKS / l).glob("*.md")})
    totals = {l: 0 for l in LANGS}
    for stem in stems:
        row = [stem[:42].ljust(42)]
        for l in LANGS:
            md = BOOKS / l / f"{stem}.md"
            w = words(md.read_text(encoding="utf-8")) if md.exists() else 0
            totals[l] += w
            row.append(f"{w:>8}")
        print(" ".join(row))
    print("-" * 70)
    print(f"{'total':42} {totals['ru']:>8} {totals['en']:>8} {totals['et']:>8}")


if __name__ == "__main__":
    main()
