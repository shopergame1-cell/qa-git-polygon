#!/usr/bin/env bash
# Перевіряє: втрачений коміт відновлено у гілці 'recovered' зі збереженим кодом.
set -uo pipefail
fail=0
say() { printf '%-68s %s\n' "$1" "$2"; }
ok()  { say "$1" "✅"; }
bad() { say "$1" "❌"; fail=1; }

git rev-parse --verify recovered >/dev/null 2>&1 && ok "гілка recovered існує" || bad "немає гілки recovered (коміт не відновлено)"

if git rev-parse --verify recovered >/dev/null 2>&1; then
  git log --pretty=%s recovered | grep -q "lost: важлива зміна" \
    && ok "у recovered є втрачений коміт" || bad "у recovered немає коміту 'lost: важлива зміна'"
  git show recovered:src/Report.java 2>/dev/null | grep -q "lost: важлива зміна" \
    && ok "код втраченої зміни відновлено" || bad "код втраченої зміни не відновлено"
fi

if [ "$fail" -eq 0 ]; then echo "РЕЗУЛЬТАТ: УСПІХ"; else echo "РЕЗУЛЬТАТ: НЕ РОЗВʼЯЗАНО"; fi
exit "$fail"
