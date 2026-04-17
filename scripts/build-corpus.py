#!/usr/bin/env python3
"""Turn books/{ru,en,et}/*.md into a single oracle/corpus.jsonl.

One row per verse per language. Schema:

    {
      "id":          "v2.3",
      "book":        2,
      "verse":       3,
      "lang":        "en",
      "book_title":  "Book II. The Shadow of Trust and the HSM of the Soul",
      "text":        "True trust cannot be imported...",
      "probability": 0.96,
      "tags":        ["pki", "trust", "soul"],
      "rights":      "CC-BY-SA-4.0"
    }

Tags are derived from a simple keyword map applied to the verse text.
No ML — keep it deterministic so the corpus is reproducible.
"""
from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
BOOKS = ROOT / "books"
OUT = ROOT / "oracle" / "corpus.jsonl"
LANGS = ("ru", "en", "et")

VERSE_RE = re.compile(r"^##\s+(v(\d+)\.(\d+))(?:\s+—\s+(.+))?$", re.MULTILINE)
PROB_RE = re.compile(r"\*(?:Вероятность|Probability|Tõenäosus):\s*([0-9.∞]+)\*")

# Deterministic tag map — lowercase substrings → tag list.
TAG_MAP: list[tuple[str, str]] = [
    ("pki", "pki"), ("сертификат", "pki"), ("certificate", "pki"), ("sertifikaat", "pki"),
    ("hsm", "pki"),
    ("doveriya", "trust"), ("доверие", "trust"), ("trust", "trust"), ("usaldus", "trust"),
    ("crl", "pki-lifecycle"), ("ocsp", "pki-lifecycle"),
    ("yaml", "devops"), ("deploy", "devops"), ("rollback", "devops"),
    ("kubernetes", "k8s"), ("kubectl", "k8s"), ("pod", "k8s"), ("container", "k8s"),
    ("контейнер", "k8s"), ("konteiner", "k8s"),
    ("entropy", "entropy"), ("энтропия", "entropy"), ("entroopia", "entropy"),
    ("sha", "crypto"), ("aes", "crypto"), ("drbg", "crypto"), ("hash", "crypto"),
    ("хэш", "crypto"), ("хеш", "crypto"), ("räsi", "crypto"),
    ("prometheus", "observability"), ("grafana", "observability"),
    ("alert", "observability"), ("алерт", "observability"),
    ("monitoring", "observability"), ("мониторинг", "observability"),
    ("monitooring", "observability"),
    ("karma", "buddhism"), ("карма", "buddhism"),
    ("samsara", "buddhism"), ("саṃсāра", "buddhism"), ("сансар", "buddhism"),
    ("sokolov", "sokolov-law"), ("соколов", "sokolov-law"),
    ("aletheia", "aletheia"),
]

BOOK_TITLE_RE = re.compile(r"^#\s+(.+?)\s*$", re.MULTILINE)


def parse_prob(raw: str | None) -> float | None:
    if raw is None:
        return None
    if raw == "∞":
        return float("inf")
    try:
        return float(raw)
    except ValueError:
        return None


def derive_tags(text: str) -> list[str]:
    lowered = text.lower()
    tags: list[str] = []
    for needle, tag in TAG_MAP:
        if needle in lowered and tag not in tags:
            tags.append(tag)
    return tags


def scan_verses(md: Path) -> tuple[str, list[dict]]:
    content = md.read_text(encoding="utf-8")
    m = BOOK_TITLE_RE.search(content)
    book_title = m.group(1).strip() if m else md.stem

    rows: list[dict] = []
    # Split on verse headings and walk the chunks.
    chunks = re.split(r"(?=^##\s+v\d+\.\d+)", content, flags=re.MULTILINE)
    for chunk in chunks:
        h = VERSE_RE.match(chunk)
        if not h:
            continue
        vid, book, verse, _title = h.groups()
        body = chunk[h.end():].strip()
        prob = parse_prob(next(iter(PROB_RE.findall(body)), None))
        # Strip the probability line from displayed text.
        clean = PROB_RE.sub("", body).strip()
        rows.append({
            "id": vid,
            "book": int(book),
            "verse": int(verse),
            "book_title": book_title,
            "text": clean,
            "probability": prob if prob is not None else None,
            "tags": derive_tags(clean),
        })
    return book_title, rows


def main() -> None:
    OUT.parent.mkdir(parents=True, exist_ok=True)
    out_rows: list[dict] = []
    for lang in LANGS:
        for md in sorted((BOOKS / lang).glob("*.md")):
            if not re.match(r"^\d", md.name):
                # Skip non-book files if any.
                pass
            _, rows = scan_verses(md)
            for row in rows:
                out_rows.append({
                    **row,
                    "lang": lang,
                    "rights": "CC-BY-SA-4.0",
                })

    # Stable ordering: by (lang, book, verse).
    out_rows.sort(key=lambda r: (r["lang"], r["book"], r["verse"]))
    with OUT.open("w", encoding="utf-8") as f:
        for row in out_rows:
            # Represent infinity as the string "inf" for JSON compatibility.
            if row["probability"] is not None and row["probability"] == float("inf"):
                row = {**row, "probability": "inf"}
            f.write(json.dumps(row, ensure_ascii=False) + "\n")
    print(f"Wrote {len(out_rows)} verses → {OUT.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
