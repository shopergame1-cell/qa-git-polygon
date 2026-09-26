#!/usr/bin/env bash
# Готує стан: гілка з трьома «брудними» комітами поверх main.
set -euo pipefail
echo "02-rebase-squash" > .polygon-scenario

mkdir -p src
git checkout -q main 2>/dev/null || git checkout -q -b main
cat > src/UserService.java <<'EOF'
package app;

public class UserService {
    public String greet(String name) {
        return "Hello, " + name;
    }
}
EOF
git add src && git commit -q -m "base: user service"

git checkout -q -b feature/user-service
for i in 1 2 3; do
  printf '\n// чернетка %s\n' "$i" >> src/UserService.java
  git add src && git commit -q -m "wip $i"
done

echo "Сценарій готовий. Зроби: git rebase -i main (squash трьох у один коміт з повідомленням 'feat: user service')."
