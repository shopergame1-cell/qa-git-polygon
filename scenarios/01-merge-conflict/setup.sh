#!/usr/bin/env bash
# Готує стан: у main і feature/logger конфліктують два файли.
set -euo pipefail
echo "01-merge-conflict" > .polygon-scenario

mkdir -p src
git checkout -q main 2>/dev/null || git checkout -q -b main

cat > src/Logger.java <<'EOF'
package app;

public class Logger {
    public void logInfo(String msg) {
        System.out.println("[INFO] " + msg);
    }
}
EOF

cat > src/Config.java <<'EOF'
package app;

public class Config {
    public static final int TIMEOUT_SECONDS = 10;
    public static final int RETRIES = 1;
}
EOF

git add src && git commit -q -m "base: logger and config"

# гілка «колеги»: розширює logger і config
git checkout -q -b feature/logger
cat > src/Logger.java <<'EOF'
package app;

public class Logger {
    public void logInfo(String msg) {
        System.out.println("[INFO] " + msg);
    }

    public void logWarn(String msg) {
        System.out.println("[WARN] " + msg);
    }
}
EOF
cat > src/Config.java <<'EOF'
package app;

public class Config {
    public static final int TIMEOUT_SECONDS = 10;
    public static final int RETRIES = 3;
}
EOF
git add src && git commit -q -m "feat: add warn level and retries"

# у main інші зміни в тих самих рядках — виникне конфлікт
git checkout -q main
cat > src/Logger.java <<'EOF'
package app;

public class Logger {
    public void logInfo(String msg) {
        System.out.println("[INFO][" + System.currentTimeMillis() + "] " + msg);
    }

    public void logError(String msg) {
        System.err.println("[ERROR] " + msg);
    }
}
EOF
cat > src/Config.java <<'EOF'
package app;

public class Config {
    public static final int TIMEOUT_SECONDS = 30;
    public static final int RETRIES = 1;
}
EOF
git add src && git commit -q -m "main: timestamps, error level, timeout 30"

git checkout -q feature/logger
echo "Сценарій готовий. Тепер: git checkout main && git merge feature/logger (буде конфлікт)."
echo "Розвʼяжи так, щоб збереглись ОБИДВА наміри, і закоміть merge."
