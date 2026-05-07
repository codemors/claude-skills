#!/usr/bin/env bash
# analyze-project.sh
# Quick structural scan of a project. Outputs JSON.
# Run from project root.
#
# Usage: ./analyze-project.sh [path]
# If no path given, uses current directory.

set -euo pipefail

ROOT="${1:-.}"
cd "$ROOT"

# --- Stack detection ---
detect_stack() {
  local stack=""
  [ -f "package.json" ] && stack+="node,"
  [ -f "pyproject.toml" ] || [ -f "setup.py" ] || [ -f "requirements.txt" ] && stack+="python,"
  [ -f "Cargo.toml" ] && stack+="rust,"
  [ -f "go.mod" ] && stack+="go,"
  [ -f "Gemfile" ] && stack+="ruby,"
  [ -f "composer.json" ] && stack+="php,"
  [ -f "pom.xml" ] || [ -f "build.gradle" ] && stack+="java,"
  [ -f "tsconfig.json" ] && stack+="typescript,"
  echo "${stack%,}"
}

# --- Package manager detection (Node) ---
detect_pkg_mgr() {
  [ -f "pnpm-lock.yaml" ] && echo "pnpm" && return
  [ -f "bun.lock" ] || [ -f "bun.lockb" ] && echo "bun" && return
  [ -f "yarn.lock" ] && echo "yarn" && return
  [ -f "package-lock.json" ] && echo "npm" && return
  [ -f "uv.lock" ] && echo "uv" && return
  [ -f "poetry.lock" ] && echo "poetry" && return
  echo ""
}

# --- Test framework detection ---
detect_tests() {
  local frameworks=""
  [ -f "vitest.config.ts" ] || [ -f "vitest.config.js" ] && frameworks+="vitest,"
  [ -f "jest.config.js" ] || [ -f "jest.config.ts" ] || [ -f "jest.config.json" ] && frameworks+="jest,"
  [ -f "playwright.config.ts" ] || [ -f "playwright.config.js" ] && frameworks+="playwright,"
  [ -f "cypress.config.ts" ] || [ -f "cypress.config.js" ] && frameworks+="cypress,"
  [ -f "pytest.ini" ] || [ -f "pyproject.toml" ] && grep -q "pytest" pyproject.toml 2>/dev/null && frameworks+="pytest,"
  echo "${frameworks%,}"
}

# --- Entry point detection ---
detect_entry() {
  if [ -f "package.json" ]; then
    local main
    main=$(grep -E '"main"|"module"|"types"' package.json | head -1 | sed 's/.*: *"\([^"]*\)".*/\1/' || true)
    [ -n "$main" ] && [ -f "$main" ] && echo "$main" && return
  fi
  for candidate in src/index.ts src/index.js src/main.ts src/main.py app.py main.go cmd/main.go; do
    [ -f "$candidate" ] && echo "$candidate" && return
  done
  echo ""
}

# --- Existing docs ---
detect_docs() {
  local docs=""
  [ -f "README.md" ] && docs+="README.md,"
  [ -f "CONTRIBUTING.md" ] && docs+="CONTRIBUTING.md,"
  [ -f "ARCHITECTURE.md" ] && docs+="ARCHITECTURE.md,"
  [ -d "docs" ] && docs+="docs/,"
  [ -f "CLAUDE.md" ] && docs+="CLAUDE.md(EXISTING!),"
  echo "${docs%,}"
}

# --- Folder candidates for sub-CLAUDE.md ---
# A folder is a candidate if: depth=2 from root, contains 5+ files OR has subfolders
detect_folder_candidates() {
  local candidates=""
  while IFS= read -r dir; do
    local file_count
    file_count=$(find "$dir" -maxdepth 1 -type f 2>/dev/null | wc -l)
    local subdir_count
    subdir_count=$(find "$dir" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l)

    if [ "$file_count" -ge 5 ] || [ "$subdir_count" -ge 2 ]; then
      candidates+="$dir,"
    fi
  done < <(find . -maxdepth 2 -mindepth 2 -type d \
              -not -path './node_modules*' \
              -not -path './.git*' \
              -not -path './dist*' \
              -not -path './build*' \
              -not -path './.next*' \
              -not -path './target*' \
              -not -path './__pycache__*' \
              -not -path './.venv*' \
              -not -path './venv*' \
              -not -path './.cache*' \
              -not -path './coverage*' \
              -not -path './tmp*' \
              -not -path './logs*' 2>/dev/null | sort)

  echo "${candidates%,}"
}

# --- Existing CLAUDE.md detection (load-bearing for safety mode) ---
detect_existing_claude_md() {
  find . -name "CLAUDE.md" -type f \
    -not -path './node_modules/*' \
    -not -path './.git/*' \
    -not -path './dist/*' \
    -not -path './build/*' \
    -not -path './.next/*' \
    2>/dev/null | sed 's|^\./||' | tr '\n' ',' | sed 's/,$//'
}

# --- Top-level folder line counts ---
folder_lines() {
  local results=""
  for dir in */; do
    case "$dir" in
      node_modules/|.git/|dist/|build/|.next/|target/|__pycache__/|.venv/|venv/|.cache/|coverage/|tmp/|logs/) continue ;;
    esac
    [ -d "$dir" ] || continue
    local lines
    lines=$(find "$dir" -type f \( -name "*.ts" -o -name "*.js" -o -name "*.py" -o -name "*.go" -o -name "*.rs" -o -name "*.rb" -o -name "*.php" -o -name "*.java" -o -name "*.tsx" -o -name "*.jsx" \) -exec cat {} + 2>/dev/null | wc -l | tr -d ' ')
    [ "$lines" -gt 0 ] && results+="${dir%/}:$lines,"
  done
  echo "${results%,}"
}

# --- Dev commands from package.json scripts ---
# JSON-safe: escape double quotes and strip newlines so output is a valid JSON string value.
detect_commands() {
  local raw=""
  if [ -f "package.json" ]; then
    raw=$(grep -E '"(dev|start|build|test|lint)"' package.json | head -10 | sed 's/^[[:space:]]*//' | tr '\n' ';' || true)
  elif [ -f "Makefile" ]; then
    raw=$(grep -E '^[a-z][a-z_-]*:' Makefile | head -10 | tr '\n' ';' || true)
  fi
  # Escape backslashes first, then double quotes
  printf '%s' "$raw" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

# --- Output JSON ---
cat <<EOF
{
  "root": "$(pwd)",
  "stack": "$(detect_stack)",
  "package_manager": "$(detect_pkg_mgr)",
  "test_frameworks": "$(detect_tests)",
  "entry_point": "$(detect_entry)",
  "existing_docs": "$(detect_docs)",
  "existing_claude_md": "$(detect_existing_claude_md)",
  "sub_claude_candidates": "$(detect_folder_candidates)",
  "folder_line_counts": "$(folder_lines)",
  "dev_commands_raw": "$(detect_commands)"
}
EOF
