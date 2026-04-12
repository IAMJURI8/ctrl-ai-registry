# Claude Code — Ctrl+AI Registry

## What this repo is

`ctrl-ai-registry` is the central agent registry for **Ctrl+AI Advisory** — a one-person, vendor-neutral AI consulting firm for SMEs, founded and led by Julian (JuRi). Every AI agent that operates within the firm is registered here.

This is the **execution layer**. Strategy decisions come from Claude.ai sessions and land in Notion. Claude Code reads them directly via Notion MCP.

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

## Document layer — Notion is the single source of truth

All living documents live in Notion. Both Claude.ai (via the Notion connector) and Claude Code (via Notion MCP) read from and write to the same pages. There is no Google Drive, no local markdown mirror, no build step.

**Two Notion pages hold everything:**

- **Master Doc** — `340824ba-ea2b-819e-aafc-ce451dfa4fb3`
  Project Zero spec, firm positioning, agent roadmap, infrastructure, way-of-working.
- **Strategy Digest** — `22d6f96c-1f2c-447e-897a-c064c3484d50`
  Current phase, active decisions, backlog, open questions, recently completed.

**How to access them:** Use the Notion MCP tools (`notion-fetch`, `notion-update-page`) with the page IDs above. Read the Strategy Digest at the start of any session where current state or backlog matters.

**What you do NOT need:**
- No `build-context.sh`. Claude Code reads Notion directly — there is nothing to generate.
- No handoff block format. Claude.ai writes strategy decisions straight to the Strategy Digest via its own Notion connector.
- No local mirror of the Master Doc or Strategy Digest. If you need the content, fetch it.

---

## Way of working

- **Claude.ai** = brain. Strategy, decisions, work orders. Reads Notion via connector, writes decisions directly to the Strategy Digest.
- **Claude Code** = hands. Execution. Reads Notion via MCP, writes back to Notion and GitHub.
- **Notion** = document layer + operational hub. Single source of truth.
- **Julian** = bridge. Pastes work orders from Claude.ai into Claude Code. No interpretation, no editing.
- **GitHub** = code, agent configs, deployment state.

---

## Infrastructure

- **Repo:** `github.com/IAMJURI8/ctrl-ai-registry`
- **Registry manifest:** `registry.json` — single source of truth for all agents
- **Orchestration:** n8n running on VPS
- **Notion MCP** is connected — Claude Code reads and writes both Notion pages directly

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
- When strategy context is needed, fetch the Strategy Digest from Notion rather than relying on stale local copies.
