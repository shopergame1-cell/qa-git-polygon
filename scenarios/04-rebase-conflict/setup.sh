#!/usr/bin/env bash
# Готує стан: гілка, яка конфліктує з main при rebase (два файли).
set -euo pipefail
echo "04-rebase-conflict" > .polygon-scenario

mkdir -p src
git checkout -q main 2>/dev/null || git checkout -q -b main
cat > src/Calc.java <<'EOF'
package app;

public class Calc {
    public int sum(int a, int b) {
        return a + b;
    }
}
EOF
cat > src/Format.java <<'EOF'
package app;

public class Format {
    public String money(int cents) {
        return cents + "c";
    }
}
EOF
git add src && git commit -q -m "base: calc and format"

git checkout -q -b feature/improve
sed -i 's/return a + b;/return Math.addExact(a, b);/' src/Calc.java
sed -i 's/cents + "c";/String.format("%.2f", cents \/ 100.0) + " UAH";/' src/Format.java
git add src && git commit -q -m "feat: safe sum and money format"

git checkout -q main
sed -i 's/public class Calc {/public class Calc { \/\/ v2/' src/Calc.java
sed -i 's/return cents + "c";/return cents + " kopiykas";/' src/Format.java
git add src && git commit -q -m "main: v2 marker and kopiykas"

git checkout -q feature/improve
echo "Сценарій готовий. Зроби: git rebase main (буде конфлікт у двох файлах), розвʼяжи й продовж."
