#!/usr/bin/env bash
# Scores the LAB12 break-fix challenge: every scenario must pass `terraform validate` and `terraform test`
# (providers are mocked - no Azure access needed).   Usage: ./bin/check-breakfix.sh [N]
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
pass=0; total=0
echo "Break-fix challenge"
for d in "$ROOT"/break-fix/bf${1:-[0-9]}; do
  n=${d##*/bf}; total=$((total+1))
  ( cd "$d" && { terraform init -backend=false -input=false >/dev/null 2>&1 \
                 || terraform init -upgrade -backend=false -input=false >/dev/null 2>&1; } \
      && terraform validate >/dev/null 2>&1 && terraform test >/dev/null 2>&1 )
  if [[ $? -eq 0 ]]; then echo "  PASS  BF$n"; pass=$((pass+1)); else echo "  FAIL  BF$n   (cd break-fix/bf$n && terraform validate && terraform test)"; fi
done
echo; echo "Score: $pass / $total"
