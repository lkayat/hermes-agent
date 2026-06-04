#!/usr/bin/env bash
# scripts/preflight.sh — "definition of done" gate. Agents MUST pass this before reporting done.
# Usage: ./scripts/preflight.sh [--e2e]
#   --e2e  also runs the live WS pipeline test (assumes Redis + WS:8000 + dev:3000 are up).
# Exits non-zero if anything fails. Does NOT stop on first failure — it reports ALL problems.

set -uo pipefail
cd "$(dirname "$0")/.." || exit 2
fail=0
step() { echo ""; echo "▶ $1"; }

step "TypeScript typecheck"
if npx --yes tsc --noEmit; then echo "✓ types ok"; else echo "✗ typecheck failed (fix the FIRST error above)"; fail=1; fi

step "Production build (catches what dev hides)"
if npm run --silent build; then echo "✓ build ok"; else echo "✗ build failed"; fail=1; fi

step "Lint (if configured)"
if npm run --silent lint >/dev/null 2>&1; then echo "✓ lint ok"; else echo "· no lint script — skipped"; fi

step "Asset hygiene — no /tmp paths in source"
if grep -RIn "/tmp/" src/ 2>/dev/null; then echo "✗ source references /tmp — move assets into public/assets/"; fail=1; else echo "✓ no /tmp references"; fi

step "Git state — committed & pushed"
if [ -n "$(git status --porcelain)" ]; then echo "✗ uncommitted changes — commit them"; fail=1; fi
branch="$(git rev-parse --abbrev-ref HEAD)"
git fetch -q origin "$branch" 2>/dev/null || true
if git rev-parse "origin/$branch" >/dev/null 2>&1; then
  if [ "$(git rev-parse HEAD)" != "$(git rev-parse "origin/$branch")" ]; then
    echo "✗ local HEAD != origin/$branch — push your branch"; fail=1
  else echo "✓ pushed"; fi
else
  echo "✗ origin/$branch does not exist — push your branch"; fail=1
fi

if [ "${1:-}" = "--e2e" ]; then
  step "E2E — live WS pipeline"
  if npx playwright test tests/e2e/test_ws_pipeline_e2e.spec.ts --reporter=line; then echo "✓ e2e ok"; else echo "✗ e2e failed"; fail=1; fi
fi

echo ""
if [ "$fail" -eq 0 ]; then
  echo "✅ PREFLIGHT PASSED — you may report done."
else
  echo "❌ PREFLIGHT FAILED — fix the ✗ items above. You are NOT done."
fi
exit $fail
