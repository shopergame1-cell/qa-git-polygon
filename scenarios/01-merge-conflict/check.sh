#!/usr/bin/env bash
# Перевіряє: merge зроблено, конфлікт розвʼязано, обидва наміри збережені.
set -uo pipefail
fail=0
say() { printf '%-68s %s\n' "$1" "$2"; }
ok()  { say "$1" "✅"; }
bad() { say "$1" "❌"; fail=1; }

git rev-parse --verify main >/dev/null 2>&1 && ok "гілка main існує" || bad "немає гілки main"
git rev-parse --verify feature/logger >/dev/null 2>&1 && ok "гілка feature/logger існує" || bad "немає гілки feature/logger"

# merge-коміт у main
MERGE=$(git rev-list --merges main 2>/dev/null | wc -l | tr -d ' ')
[ "$MERGE" -ge 1 ] && ok "у main є merge-коміт ($MERGE)" || bad "у main немає merge-коміту — гілку не змерджено"

# жодних маркерів конфлікту
if grep -rInE '^(<<<<<<<|=======|>>>>>>>)' src >/dev/null 2>&1; then
  bad "у src залишились маркери конфлікту"
else
  ok "маркерів конфлікту немає"
fi

# обидва наміри збережені
grep -q "logWarn" src/Logger.java && ok "збережено logWarn з гілки" || bad "втрачено logWarn (намір гілки)"
grep -q "logError" src/Logger.java && ok "збережено logError з main" || bad "втрачено logError (намір main)"
grep -q "TIMEOUT_SECONDS = 30" src/Config.java && ok "збережено timeout=30 з main" || bad "втрачено timeout=30"
grep -q "RETRIES = 3" src/Config.java && ok "збережено RETRIES=3 з гілки" || bad "втрачено RETRIES=3"

if [ "$fail" -eq 0 ]; then echo "РЕЗУЛЬТАТ: УСПІХ"; else echo "РЕЗУЛЬТАТ: НЕ РОЗВʼЯЗАНО"; fi
exit "$fail"
