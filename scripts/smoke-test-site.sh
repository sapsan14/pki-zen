#!/usr/bin/env bash
# Route-level smoke test for the PKI-ZEN Worker.
#
# Boots `wrangler dev` against the built site (publish/site/.vitepress/dist)
# and curls the URLs that matter: every language-switcher rewrite, every
# Oracle URL (per-locale + the legacy /oracle bookmark), and a few sanity
# GETs. Fails non-zero if any assertion fails. Used by CI (see
# .github/workflows/deploy-site.yml) so the next time this breaks, CI
# catches it before prod.
#
# Usage: bash scripts/smoke-test-site.sh
# Assumes the site has already been built (dist/ exists) and that the
# Cloudflare credentials are NOT required — `wrangler dev` runs entirely
# locally against miniflare.

set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

PORT=8788
LOG="$(mktemp)"
trap 'kill $(jobs -p) 2>/dev/null || true; rm -f "$LOG"' EXIT

# Explicitly point wrangler at the config so this works from any CWD.
npx --yes wrangler@latest dev \
  --config "$ROOT/wrangler.jsonc" \
  --port "$PORT" --ip 127.0.0.1 \
  > "$LOG" 2>&1 &

# Wait up to 60s for the dev server to answer.
for i in $(seq 1 60); do
  if curl -sf -o /dev/null "http://127.0.0.1:$PORT/"; then
    break
  fi
  sleep 1
done
if ! curl -sf -o /dev/null "http://127.0.0.1:$PORT/"; then
  echo "::error::wrangler dev failed to start within 60s"
  echo "--- wrangler log ---"
  cat "$LOG"
  exit 1
fi

fails=0
check() {
  local path="$1" want_code="$2" want_loc_suffix="${3:-}"
  local got
  got=$(curl -s -o /dev/null -w "%{http_code} %{redirect_url}" "http://127.0.0.1:$PORT$path")
  local code="${got%% *}" loc="${got#* }"
  if [ "$code" != "$want_code" ]; then
    echo "  FAIL  $path  got $code, wanted $want_code"
    fails=$((fails + 1))
    return
  fi
  if [ -n "$want_loc_suffix" ] && [[ "$loc" != *"$want_loc_suffix" ]]; then
    echo "  FAIL  $path  redirected to $loc, wanted suffix $want_loc_suffix"
    fails=$((fails + 1))
    return
  fi
  echo "  OK    $path  $code${loc:+ → $loc}"
}

echo "== language-switcher redirects =="
# /ru/<ru-slug> + target-locale prefix → correct /<target>/<target-slug>
check /en/ru/00-prolog          301 /en/00-prologue
check /et/ru/00-prolog          301 /et/00-proloog
check /en/ru/06-terabayt        301 /en/06-terabyte
check /et/ru/09-pole-doveriya   301 /et/09-usalduse-vali
check /en/ru/10-kodeks-nolya    301 /en/10-codex-zero
check /et/ru/10-kodeks-nolya    301 /et/10-nullkoodeks

echo "== root-locale mis-routed pages go back to /ru/ =="
check /00-prologue          301 /ru/00-prolog
check /01-inseneri-tee      301 /ru/01-put-inzhenera

echo "== cross-locale slug rewrites =="
check /et/01-way-of-the-engineer 301 /et/01-inseneri-tee
check /en/06-terabait            301 /en/06-terabyte

echo "== oracle: per-locale pages =="
check /ru/oracle  200
check /en/oracle  200
check /et/oracle  200

echo "== oracle: legacy + lang-switch redirects =="
check /oracle        301 /ru/oracle
check /en/ru/oracle  301 /en/oracle
check /et/ru/oracle  301 /et/oracle

echo "== landing pages + a couple book chapters =="
check /                  200
check /en/                200
check /et/                200
check /ru/00-prolog       200
check /en/00-prologue     200
check /et/00-proloog      200

if [ "$fails" -ne 0 ]; then
  echo "::error::$fails smoke-test assertion(s) failed"
  exit 1
fi
echo "All smoke tests passed."
