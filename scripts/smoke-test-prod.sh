#!/usr/bin/env bash
# Post-deploy verification: hit the REAL domain and assert that the
# redirect rules the Worker is supposed to apply actually fire in
# production. This complements scripts/smoke-test-site.sh (which tests
# the same thing locally via `wrangler dev`) — that one proves the code
# is correct, this one proves the code actually got deployed.
#
# If any assertion fails, exit non-zero so the GitHub Actions run is
# marked red and we SEE that prod is broken instead of trusting the
# local test and claiming victory.
#
# Usage: bash scripts/smoke-test-prod.sh [base_url]
#   base_url default: https://pki-zen.h2oatlas.ee

set -euo pipefail
BASE="${1:-https://pki-zen.h2oatlas.ee}"
echo "Probing $BASE"

fails=0
check() {
  local path="$1" want_code="$2" want_loc_suffix="${3:-}"
  # -L is NOT set — we want to see the redirect itself, not follow it.
  # --max-time bounds each request; the whole script should finish in
  # well under a minute even if the edge is slow.
  local got
  got=$(curl -sS -o /dev/null -w "%{http_code}|%{redirect_url}" \
              --max-time 15 \
              --retry 3 --retry-delay 5 --retry-connrefused \
              "$BASE$path" || echo "000|")
  local code="${got%%|*}" loc="${got#*|}"
  if [ "$code" != "$want_code" ]; then
    echo "  FAIL  $path  got $code, wanted $want_code   (loc=$loc)"
    fails=$((fails + 1))
    return
  fi
  if [ -n "$want_loc_suffix" ] && [[ "$loc" != *"$want_loc_suffix" ]]; then
    echo "  FAIL  $path  redirected to '$loc', wanted suffix '$want_loc_suffix'"
    fails=$((fails + 1))
    return
  fi
  echo "  OK    $path  $code${loc:+ → $loc}"
}

echo "== language-switcher redirects =="
check /en/ru/00-prolog          301 /en/00-prologue
check /et/ru/00-prolog          301 /et/00-proloog
check /en/ru/06-terabayt        301 /en/06-terabyte
check /et/ru/09-pole-doveriya   301 /et/09-usalduse-vali

echo "== oracle per-locale (should be 200, not 404) =="
check /ru/oracle  200
check /en/oracle  200
check /et/oracle  200

echo "== oracle legacy + lang-switch redirects =="
check /oracle        301 /ru/oracle
check /en/ru/oracle  301 /en/oracle
check /et/ru/oracle  301 /et/oracle

echo "== landing pages =="
check /       200
check /en/    200
check /et/    200

if [ "$fails" -ne 0 ]; then
  echo ""
  echo "::error::$fails production smoke-test assertion(s) failed against $BASE"
  echo "The deploy reported success but prod is not serving the expected redirects."
  echo "Possible causes:"
  echo "  - Cloudflare edge cache serving stale response (wait 1-2min, re-run)"
  echo "  - wrangler deploy pushed to a different worker name"
  echo "  - The custom domain route is attached to a different service"
  echo "  - Dashboard override of the Worker code"
  exit 1
fi
echo ""
echo "All production smoke tests passed against $BASE."
