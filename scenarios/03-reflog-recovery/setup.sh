#!/usr/bin/env bash
# Готує стан: робить коміт, потім «втрачає» його через reset --hard і видалення гілки.
set -euo pipefail
echo "03-reflog-recovery" > .polygon-scenario

mkdir -p src
git checkout -q main 2>/dev/null || git checkout -q -b main
cat > src/Report.java <<'EOF'
package app;

public class Report {
    public String title() {
        return "report";
    }
}
EOF
git add src && git commit -q -m "base: report"

git checkout -q -b feature/lost-work
cat > src/Report.java <<'EOF'
package app;

public class Report {
    public String title() {
        return "report";
    }

    public String summary() {
        return "lost: важлива зміна";
    }
}
EOF
git add src && git commit -q -m "lost: важлива зміна"

git checkout -q main
git branch -q -D feature/lost-work

echo "Сценарій готовий: коміт втрачено (гілку видалено)."
echo "Знайди його через: git reflog  (або git fsck --lost-found) і віднови у гілку 'recovered'."
