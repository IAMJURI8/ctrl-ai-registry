# Claude Code — Ctrl+AI Registry

## What this repo is

`ctrl-ai-registry` is the deployment repo for **Ctrl+AI Advisory** — a one-person, vendor-neutral AI consulting firm for SMEs, founded and led by Julian (JuRi). It holds the deployable configuration for every AI agent operating within the firm: one folder per agent, containing `system-prompt.xml` and `workflow.json`.

The **agent registry itself** — roster, status, model, relationships, state — lives in a Notion database, not in this repo. This repo is purely the execution layer. Strategy decisions come from Claude.ai sessions and land in Notion. Claude Code reads them directly via Notion MCP.

Both Claude.ai and Claude Code have read access to this repo (Claude.ai via project knowledge integration, Claude Code via local filesystem).

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
- **Every agent has two files in this repo:** `system-prompt.xml` (the prompt) and `workflow.json` (the n8n workflow export).
- **Everything else about an agent** — status, model, role, function, personality, relationships, version notes — lives in the Notion Agent Registry database, not in this repo.
- **Orchestration:** n8n (VPS-hosted) unless otherwise specified
- **Job descriptions** use the XML format defined in `templates/system-prompt-template.xml`
- **Status values (used in the Notion registry):** `active`, `building`, `planned`, `retired`

---

## Document layer — Notion is the single source of truth

All living documents and all mutable agent state live in Notion. Both Claude.ai (via the Notion connector) and Claude Code (via Notion MCP) read from and write to the same pages. There is no Google Drive, no local markdown mirror, no build step.

**Three Notion entities hold everything:**

- **Master Doc** — `340824ba-ea2b-819e-aafc-ce451dfa4fb3`
  Project Zero spec, firm positioning, agent roadmap, infrastructure, way-of-working.
- **Strategy Digest** — `22d6f96c-1f2c-447e-897a-c064c3484d50`
  Current phase, active decisions, backlog, open questions, recently completed.
- **Agent Registry database** (data source `ba781fc9-fdd0-418e-a34c-55f235b4f6e2`, embedded under the Master Doc)
  One row per agent. Holds name, ID, role, function, status, phase, model, interface, orchestration, personality, GitHub folder link, dates, and version notes.

**How to access them:** Use the Notion MCP tools (`notion-fetch`, `notion-update-page`, `notion-create-pages`, `notion-update-data-source`) with the IDs above. Read the Strategy Digest at the start of any session where current state or backlog matters. Query the Agent Registry whenever you need to know what exists, what's live, or what changed.

**What you do NOT need:**
- No `registry.json`. The registry is a Notion database.
- No per-agent `infra-brief.md` or `changelog.md` files. Infra details and version history live on the corresponding Notion registry row.
- No `build-context.sh`. Claude Code reads Notion directly — there is nothing to generate.
- No handoff block format. Claude.ai writes strategy decisions straight to the Strategy Digest via its own Notion connector.
- No local mirror of the Master Doc or Strategy Digest. If you need the content, fetch it.

---

## Agent build handoff

New agents are onboarded by **Sarah** (A1) over Telegram. At the end of onboarding, Sarah's n8n workflow:

1. Generates a headshot via the OpenAI image API from the four appearance fields (Age, Race, Gender, Particulars), then uploads the bytes to Notion via the File Upload API so the image is hosted durably inside Notion.
2. Assigns the next sequential agent ID automatically by querying the registry for the current max `aN`.
3. Creates a draft row in the Agent Registry database with status `planned`, all properties filled, the headshot attached to the **Profile Picture** files property, and the full XML job description (chunked into 1900-char rich_text segments) in the page body.
4. Sends Julian a short Telegram message containing the Notion page URL.

**When Julian asks Claude Code to build an agent from a Notion URL:**

1. `notion-fetch` the page to read the spec, appearance fields, and profile picture.
2. Create `agents/[id]-[short-name]/system-prompt.xml` (from the spec in the page body) and `workflow.json` (cloned from a template or sibling agent).
3. Update the Notion row: status → `building`, GitHub folder link filled, version notes added.
4. Report completion.

The Notion row is the handoff payload. No prompt is pasted into Claude Code.

---

## Way of working

- **Claude.ai** = brain. Strategy, decisions, work orders. Reads Notion via connector, writes decisions directly to the Strategy Digest.
- **Claude Code** = hands. Execution. Reads Notion via MCP, writes back to Notion and GitHub.
- **Notion** = document layer + operational hub. Single source of truth.
- **Julian** = bridge. Pastes work orders from Claude.ai into Claude Code. No interpretation, no editing.
- **GitHub** = code, agent configs, deployment state.

---

## Infrastructure

- **Repo:** `github.com/IAMJURI8/ctrl-ai-registry` — holds only deployable agent configs (`system-prompt.xml` + `workflow.json` per agent) plus templates and this doc. Claude.ai has read access via its GitHub project knowledge integration; Claude Code has local read/write access.
- **Agent registry:** Notion database under the Master Doc (data source `ba781fc9-fdd0-418e-a34c-55f235b4f6e2`) — single source of truth for agent roster and state.
- **Orchestration:** n8n running on VPS
- **Notion MCP** is connected — Claude Code reads and writes the Master Doc, Strategy Digest, and Agent Registry directly

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
