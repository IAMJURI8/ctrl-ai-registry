#!/usr/bin/env bash
# Registry Last Updated gate.
# Blocks commits that modify agents/*/system-prompt.xml or agents/*/workflow.json
# when the Agent Registry row for that agent has not been touched today
# (Europe/Berlin). See /skills/update-agent.md for the four-step release sequence.

set -euo pipefail

REGISTRY_DB_ID="${CTRL_AI_REGISTRY_DB_ID:-b3f81c65-8bd5-4bf6-8a3e-9805f6c2f9ec}"
NOTION_VERSION="${NOTION_VERSION:-2022-06-28}"
TOKEN_FILE="${CTRL_AI_NOTION_TOKEN_FILE:-$HOME/.config/ctrl-ai/notion-token}"

fail() {
  printf '\n\033[1;31m[pre-commit] %s\033[0m\n' "$1" >&2
  shift
  for line in "$@"; do
    printf '            %s\n' "$line" >&2
  done
  printf '\nBypass with --no-verify only if you have an explicit Recently Completed entry explaining why.\n' >&2
  exit 1
}

STAGED="$(git diff --cached --name-only --diff-filter=ACMR)"
TARGETS="$(printf '%s\n' "$STAGED" | grep -E '^agents/[^/]+/(system-prompt\.xml|workflow\.json)$' || true)"

if [ -z "$TARGETS" ]; then
  exit 0
fi

AGENT_IDS="$(printf '%s\n' "$TARGETS" | awk -F/ '{print $2}' | awk -F- '{print $1}' | sort -u)"

TOKEN="${NOTION_TOKEN:-}"
if [ -z "$TOKEN" ] && [ -r "$TOKEN_FILE" ]; then
  TOKEN="$(tr -d '\r\n' < "$TOKEN_FILE")"
fi
if [ -z "$TOKEN" ]; then
  fail "Notion token not configured." \
    "Set NOTION_TOKEN in your environment, or write the integration token to:" \
    "  $TOKEN_FILE" \
    "The token must have access to the Agent Registry database."
fi

for bin in curl jq; do
  command -v "$bin" >/dev/null 2>&1 || fail "Missing required binary: $bin" "Install it and retry."
done

TODAY="$(TZ='Europe/Berlin' date +%Y-%m-%d)"

RESPONSE="$(curl -sS -X POST "https://api.notion.com/v1/databases/$REGISTRY_DB_ID/query" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Notion-Version: $NOTION_VERSION" \
  -H 'Content-Type: application/json' \
  -d '{"page_size":100}')" || fail "Failed to reach Notion API." "Check connectivity and token."

if [ "$(printf '%s' "$RESPONSE" | jq -r '.object // empty')" = "error" ]; then
  MSG="$(printf '%s' "$RESPONSE" | jq -r '.message // "unknown error"')"
  fail "Notion API error: $MSG" \
    "Verify CTRL_AI_REGISTRY_DB_ID ($REGISTRY_DB_ID) and that the token has access."
fi

STALE=""
for AID in $AGENT_IDS; do
  ROW="$(printf '%s' "$RESPONSE" | jq --arg id "$AID" '.results[] | select((.properties.ID.rich_text[0].plain_text // "") == $id)')"
  if [ -z "$ROW" ]; then
    fail "No Agent Registry row found for id '$AID'." \
      "Either the id in the folder name is wrong, or the Registry row is missing." \
      "See /skills/update-agent.md."
  fi
  LAST="$(printf '%s' "$ROW" | jq -r '.properties["Last Updated"].date.start // empty')"
  NAME="$(printf '%s' "$ROW" | jq -r '.properties.Name.title[0].plain_text // $id' --arg id "$AID")"
  if [ -z "$LAST" ]; then
    STALE="$STALE\n  - $AID ($NAME): Last Updated is empty"
  elif [ "$LAST" \< "$TODAY" ]; then
    STALE="$STALE\n  - $AID ($NAME): Last Updated = $LAST (today is $TODAY)"
  fi
done

if [ -n "$STALE" ]; then
  printf '\n\033[1;31m[pre-commit] Agent Registry is stale for staged changes.\033[0m\n' >&2
  printf '%b\n' "$STALE" >&2
  printf '\nUpdate the Last Updated field on each affected Registry row before committing.\n' >&2
  printf 'Procedure: /skills/update-agent.md (step 2 of the four-step release).\n' >&2
  printf '\nBypass with --no-verify only if you have an explicit Recently Completed entry explaining why.\n' >&2
  exit 1
fi

exit 0
