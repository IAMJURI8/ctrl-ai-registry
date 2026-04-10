#!/usr/bin/env bash
# build-context.sh — assembles CLAUDE.md from preamble + live Notion + repo state
# Usage: NOTION_API_KEY=secret_xxx bash scripts/build-context.sh
set -euo pipefail

# ── paths ────────────────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PREAMBLE_FILE="$ROOT/docs/claude-preamble.md"
OUTPUT_FILE="$ROOT/CLAUDE.md"

# Strategy Digest page ID (Notion)
NOTION_PAGE_ID="22d6f96c1f2c447e897ac064c3484d50"

# ── dependency checks ─────────────────────────────────────────────────────────
command -v curl    >/dev/null 2>&1 || { echo "ERROR: curl not found";    exit 1; }
command -v python3 >/dev/null 2>&1 || { echo "ERROR: python3 not found"; exit 1; }

[[ -n "${NOTION_API_KEY:-}" ]] || {
  echo "ERROR: NOTION_API_KEY is not set."
  echo "  Export it before running: export NOTION_API_KEY=secret_xxx"
  exit 1
}

[[ -f "$PREAMBLE_FILE" ]] || {
  echo "ERROR: $PREAMBLE_FILE not found."
  exit 1
}

# ── 1. preamble ───────────────────────────────────────────────────────────────
echo "[build-context] Reading preamble..."
PREAMBLE=$(cat "$PREAMBLE_FILE")

# ── 2. Strategy Digest from Notion ───────────────────────────────────────────
echo "[build-context] Fetching Strategy Digest from Notion..."

NOTION_RESPONSE=$(curl -sf \
  -H "Authorization: Bearer $NOTION_API_KEY" \
  -H "Notion-Version: 2022-06-28" \
  "https://api.notion.com/v1/blocks/$NOTION_PAGE_ID/children?page_size=100") || {
    echo "ERROR: Notion API request failed. Check NOTION_API_KEY and network."
    exit 1
  }

STRATEGY_DIGEST=$(echo "$NOTION_RESPONSE" | python3 -c "
import json, sys

blocks = json.load(sys.stdin)

def text(rich_text):
    return ''.join(rt['plain_text'] for rt in rich_text)

lines = []
for b in blocks.get('results', []):
    t = b['type']
    if t == 'heading_2':
        lines.append('')
        lines.append('## ' + text(b['heading_2']['rich_text']))
    elif t == 'heading_3':
        lines.append('')
        lines.append('### ' + text(b['heading_3']['rich_text']))
    elif t == 'paragraph':
        content = text(b['paragraph']['rich_text'])
        if content.strip():
            lines.append(content)
    elif t == 'bulleted_list_item':
        lines.append('- ' + text(b['bulleted_list_item']['rich_text']))
    elif t == 'numbered_list_item':
        lines.append('- ' + text(b['numbered_list_item']['rich_text']))
    elif t == 'divider':
        lines.append('')
        lines.append('---')

print('\n'.join(lines).strip())
")

# ── 3. repo state ─────────────────────────────────────────────────────────────
echo "[build-context] Reading repo state..."
TODAY=$(date +%Y-%m-%d)

BRANCHES=$(git -C "$ROOT" branch --format="%(refname:short)" 2>/dev/null || echo "(no branches)")
COMMITS=$(git -C "$ROOT" log --oneline -5 2>/dev/null || echo "(no commits)")

REPO_STATE="Last updated: $TODAY

**Active branches:**
$(echo "$BRANCHES" | sed 's/^/- /')

**Recent commits:**
$(echo "$COMMITS" | sed 's/^/- /')"

# ── 4. assemble CLAUDE.md ─────────────────────────────────────────────────────
echo "[build-context] Writing CLAUDE.md..."

{
  printf '%s\n' "$PREAMBLE"
  printf '\n---\n\n'
  printf '<!-- STRATEGY_DIGEST_START -->\n'
  printf '%s\n' "$STRATEGY_DIGEST"
  printf '<!-- STRATEGY_DIGEST_END -->\n'
  printf '\n<!-- REPO_STATE_START -->\n'
  printf '%s\n' "$REPO_STATE"
  printf '<!-- REPO_STATE_END -->\n'
  printf '\n<!-- ACTIVE_AGENT_SPEC_START -->\n'
  printf '<!-- ACTIVE_AGENT_SPEC_END -->\n'
} > "$OUTPUT_FILE"

# ── 5. commit ─────────────────────────────────────────────────────────────────
echo "[build-context] Committing..."
git -C "$ROOT" add "$OUTPUT_FILE"

if git -C "$ROOT" diff --cached --quiet; then
  echo "[build-context] No changes — CLAUDE.md is already up to date."
else
  git -C "$ROOT" commit -m "chore: update CLAUDE.md via build-context [$TODAY]"
  echo "[build-context] Done. CLAUDE.md committed."
fi
