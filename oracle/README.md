# PKI-ZEN Oracle

The book's LLM interface. Drop into any Claude / OpenAI call and let the
sūtra speak.

## Files

- **`system-prompt.md`** — the instructions that define the oracle's voice.
- **`corpus.jsonl`** — 324 rows (108 verses × 3 languages), one JSON object
  per line.
- **`examples.md`** — ten sample prompts and responses. Use as few-shot
  examples or as a spec for the voice.

## Corpus schema

Each line of `corpus.jsonl`:

```json
{
  "id": "v2.3",
  "book": 2,
  "verse": 3,
  "lang": "en",
  "book_title": "Book II. The Shadow of Trust and the HSM of the Soul",
  "text": "True trust cannot be imported ...",
  "probability": 0.96,
  "tags": ["trust", "pki"],
  "rights": "CC-BY-SA-4.0"
}
```

- `id` is stable across languages.
- `probability` is a float in (0.5, 1.0], or the string `"inf"` for closing
  verses of thought.
- `tags` are derived deterministically from keywords — they are advisory,
  not ground truth.

## Minimal Python wiring (Anthropic SDK)

```python
import json, pathlib
from anthropic import Anthropic

here = pathlib.Path(__file__).parent
system = here.joinpath("system-prompt.md").read_text()
corpus = "\n".join(here.joinpath("corpus.jsonl").read_text().splitlines())

client = Anthropic()
msg = client.messages.create(
    model="claude-opus-4-7",
    max_tokens=600,
    temperature=0.8,
    system=[
        {"type": "text", "text": system, "cache_control": {"type": "ephemeral"}},
        {"type": "text",
         "text": "Corpus (JSONL, one verse per line):\n" + corpus,
         "cache_control": {"type": "ephemeral"}},
    ],
    messages=[{"role": "user", "content": "How do I stop fearing Friday releases?"}],
)
print(msg.content[0].text)
```

The `cache_control` blocks cache both the system prompt and the corpus —
the cost per query drops by roughly 90 % after the first call.

## Updating the corpus

The corpus is generated from `books/**/*.md`:

```bash
python3 scripts/build-corpus.py
```

Run this any time you edit a verse or add a new one. Then run
`scripts/verify-parallel.py` to make sure you did not break the three-language
parity.

## Licence

Corpus and system prompt: CC-BY-SA-4.0. Attribution to `github.com/sapsan14/pki-zen`.
If you build a product on top of this, please keep the prompt's section
"**Respect the Mom / Dad / 38-year-old-brother test**" intact. That's the
soul of the book.
