#!/usr/bin/env python3
"""Verify that every verse ID (v<book>.<verse>) exists in all three languages.

Exit 0 if the trilingual corpus is structurally parallel; exit 1 otherwise.
Does NOT check translation quality — only that no verse is missing and
that the verse counts per book match across ru / en / et.
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
BOOKS = ROOT / "books"
LANGS = ("ru", "en", "et")
VERSE_RE = re.compile(r"^##\s+(v\d+\.\d+)", re.MULTILINE)


def scan(lang: str) -> dict[str, list[str]]:
    out: dict[str, list[str]] = {}
    lang_dir = BOOKS / lang
    for md in sorted(lang_dir.glob("*.md")):
        ids = VERSE_RE.findall(md.read_text(encoding="utf-8"))
        out[md.name] = ids
    return out


def main() -> int:
    per_lang = {l: scan(l) for l in LANGS}
    verse_sets = {l: {v for vs in per_lang[l].values() for v in vs} for l in LANGS}

    ok = True
    ref = verse_sets["ru"]
    for l in ("en", "et"):
        missing = sorted(ref - verse_sets[l])
        extra = sorted(verse_sets[l] - ref)
        if missing:
            ok = False
            print(f"[{l}] missing verses compared to ru: {missing}", file=sys.stderr)
        if extra:
            ok = False
            print(f"[{l}] extra verses not in ru: {extra}", file=sys.stderr)

    # Verse count per "book number" must match across languages.
    def book_counts(vs: set[str]) -> dict[int, int]:
        counts: dict[int, int] = {}
        for v in vs:
            n = int(v.split(".")[0][1:])
            counts[n] = counts.get(n, 0) + 1
        return counts

    ru_counts = book_counts(verse_sets["ru"])
    for l in ("en", "et"):
        if book_counts(verse_sets[l]) != ru_counts:
            ok = False
            print(
                f"[{l}] per-book verse counts differ: {book_counts(verse_sets[l])} vs ru {ru_counts}",
                file=sys.stderr,
            )

    if ok:
        total = sum(ru_counts.values())
        print(f"OK — {total} verses in each of {', '.join(LANGS)}")
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
