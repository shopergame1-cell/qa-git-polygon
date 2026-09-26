#!/usr/bin/env bash
# Перевіряє: три коміти зведено в один, повідомлення правильне, історія лінійна.
set -uo pipefail
fail=0
say() { printf '%-68s %s\n' "$1" "$2"; }
ok()  { say "$1" "✅"; }
bad() { say "$1" "❌"; fail=1; }

BRANCH=$(git rev-parse --abbrev-ref HEAD)
say "поточна гілка" "$BRANCH"

COUNT=$(git rev-list --count main..HEAD 2>/dev/null | tr -d ' ')
[ "$COUNT" = "1" ] && ok "поверх main рівно один коміт (було 3)" || bad "поверх main $COUNT комітів, треба 1 (squash не зроблено)"

MSG=$(git log -1 --pretty=%s 2>/dev/null)
[ "$MSG" = "feat: user service" ] && ok "повідомлення коміту: '$MSG'" || bad "повідомлення '$MSG', треба 'feat: user service' (reword)"

MERGE=$(git rev-list --merges main..HEAD 2>/dev/null | wc -l | tr -d ' ')
[ "$MERGE" = "0" ] && ok "merge-комітів немає — історія лінійна" || bad "є merge-коміти, треба rebase"
grep -q "чернетка" src/UserService.java && bad "у коді лишились чернетки 'wip'" || ok "чернетки прибрані"

if [ "$fail" -eq 0 ]; then echo "РЕЗУЛЬТАТ: УСПІХ"; else echo "РЕЗУЛЬТАТ: НЕ РОЗВʼЯЗАНО"; fi
exit "$fail"
