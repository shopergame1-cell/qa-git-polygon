#!/usr/bin/env bash
# Перевіряє: rebase доведено до кінця, конфлікти розвʼязано, історія лінійна, обидва наміри збережені.
set -uo pipefail
fail=0
say() { printf '%-68s %s\n' "$1" "$2"; }
ok()  { say "$1" "✅"; }
bad() { say "$1" "❌"; fail=1; }

if [ -d .git/rebase-merge ] || [ -d .git/rebase-apply ]; then
  bad "rebase не завершено (ви в процесі rebase)"
else
  ok "rebase завершено"
fi

if grep -rInE '^(<<<<<<<|=======|>>>>>>>)' src >/dev/null 2>&1; then
  bad "у src залишились маркери конфлікту"
else
  ok "маркерів конфлікту немає"
fi

MERGE=$(git rev-list --merges HEAD 2>/dev/null | wc -l | tr -d ' ')
[ "$MERGE" = "0" ] && ok "історія лінійна (без merge-комітів)" || bad "є merge-коміти — це rebase, а не merge"

grep -q "addExact" src/Calc.java && ok "збережено безпечне додавання з гілки" || bad "втрачено Math.addExact"
grep -q "v2" src/Calc.java && ok "збережено маркер v2 з main" || bad "втрачено маркер v2"
grep -q "UAH" src/Format.java && ok "збережено формат UAH з гілки" || bad "втрачено формат UAH"

if [ "$fail" -eq 0 ]; then echo "РЕЗУЛЬТАТ: УСПІХ"; else echo "РЕЗУЛЬТАТ: НЕ РОЗВʼЯЗАНО"; fi
exit "$fail"
