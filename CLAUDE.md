# Claude Code — ctrl-ai-registry
## Role
Execution layer for Project Zero / Ctrl+AI Advisory. Strategy and execution both happen across Claude.ai and Claude Code — this surface handles anything that touches the filesystem, commits, scripts, or agent configs. Notion is the single source of truth for everything strategic.
## Notion is the source of truth
Three canonical resources, read via Notion MCP (`notion-fetch`, `notion-update-page`, `notion-search`):
- Master Doc (Firm Spec) — `340824ba-ea2b-819e-aafc-ce451dfa4fb3`. Stable. Owned by Julian. Do not edit without explicit instruction.
- Strategy Digest — `22d6f96c-1f2c-447e-897a-c064c3484d50`. Fluid. Holds current focus, active decisions, pending handoffs, recently completed.
- Agent Registry DB — find via `notion-search`. Canonical roster of all agents. Update when building, activating, or retiring an agent.
At the start of any session where current state matters, fetch the Strategy Digest. Do not cache strategy content in this file or anywhere else in the repo.
## Handoff protocol
When Julian says "work through pending handoffs" (or similar), read the Strategy Digest "Pending Handoffs" section, execute items in order, and for each completed item move it to "Recently Completed" with a brief note on what was done and any commit links. If an entry is unclear, ask before executing.
## Repo conventions
- Agent folders: `agents/[id]-[short-name]/` with `system-prompt.xml` and `workflow.json`
- Status values: `active`, `building`, `planned`, `retired`
- Commit format: `type: description [date]`, never skip hooks
- The Notion Agent Registry DB is canonical for agent state. Any `registry.json` file in the repo is deprecated.
## Writing principles
- No emojis
- No filler phrases ("Great!", "Sure!")
- Concise, no trailing summaries
- German terms stay untranslated (Steuerberater, Versicherungsmakler)
- No Oxford commas
## Working conventions
- Read files before modifying them
- Never commit without being asked
- Prefer editing existing files over creating new ones
- For strategy context, fetch from Notion — never rely on local copies
