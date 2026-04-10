# Claude Code — Ctrl+AI Registry

## What this repo is

`ctrl-ai-registry` is the central agent registry for **Ctrl+AI Advisory** — a one-person, vendor-neutral AI consulting firm for SMEs, founded and led by Julian (JuRi). Every AI agent that operates within the firm is registered here.

This is the **execution layer**. Strategy decisions come from Claude.ai sessions and land here via the Strategy Digest page in Notion.

---

## The firm

**Ctrl+AI Advisory** helps business owners answer: *"What does AI mean for my business, specifically — and what should I do first?"*

- No software sales, no tool pitches — strategic guidance grounded in how businesses actually run.
- Operates as a one-person firm where every business function is built and run with AI agents.
- Each agent has a real job, a personality, and is expected to deliver at professional quality.

---

## Target segments (ranked)

1. **Steuerberater** (tax consultants) — primary beachhead
2. **Versicherungsmakler** (insurance brokers) — secondary, scalable via pool partnerships
3. **Handwerk** (skilled trades) — volume play, lower ticket

---

## Agent architecture

- **Agent IDs** are sequential: `a1`, `a2`, `a3`, …
- **Folder names:** `agents/[id]-[short-name]/` (e.g., `agents/a1-sarah-hr-manager/`)
- **Every agent has three files:** `system-prompt.xml`, `infra-brief.md`, `changelog.md`
- **Orchestration:** n8n (VPS-hosted) unless otherwise specified
- **Job descriptions** use the XML format defined in `templates/system-prompt-template.xml`
- **Status values:** `active`, `building`, `planned`, `retired`

---

## Infrastructure

- **Repo:** `github.com/IAMJURI8/ctrl-ai-registry`
- **Registry manifest:** `registry.json` — single source of truth for all agents
- **Orchestration:** n8n running on VPS
- **Notion MCP** is connected — strategy context flows from Notion into CLAUDE.md via `scripts/build-context.sh`

---

## Writing principles

- No emojis.
- No filler phrases ("Great!", "Sure!", "Of course!").
- Concise — no trailing summaries, no restating what was just done.
- German company names and terms stay untranslated (e.g., Steuerberater, Versicherungsmakler).
- Commit messages follow: `type: description [date]` — never skip hooks.

---

## Working conventions

- Read files before modifying them.
- Never commit without being asked.
- Create files only when necessary — prefer editing existing ones.
- The dynamic sections below are populated by `scripts/build-context.sh`. Do not edit them manually.

---

<!-- STRATEGY_DIGEST_START -->
<!-- STRATEGY_DIGEST_END -->

<!-- REPO_STATE_START -->
<!-- REPO_STATE_END -->

<!-- ACTIVE_AGENT_SPEC_START -->
<!-- ACTIVE_AGENT_SPEC_END -->
