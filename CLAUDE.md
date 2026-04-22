# Claude Code — ctrl-ai-registry

## What this is
Execution layer for Ctrl+AI Advisory agents. Owner: JuRi.

## Source of truth: Notion
- Master Doc — `340824ba-ea2b-819e-aafc-ce451dfa4fb3`. Operating Rules live here; read them at session start.
- Strategy Digest — `22d6f96c-1f2c-447e-897a-c064c3484d50`. Pending Handoffs and Recently Completed.
- Agent Registry DB — `b3f81c65-8bd5-4bf6-8a3e-9805f6c2f9ec`. Canonical roster and agent state.

Fetch via Notion MCP when current state matters. Do not assume from local copies or memory.

## Skills-first
Before any agent-touching task (update, create, retire) or executing a Pending Handoff, read the matching file in `/skills/`. Start at `skills/README.md`. Skills encode the four-step atomic action (Git → Registry → n8n MCP → Strategy Digest) as checklists; follow the matching Release DoD instead of reinventing the sequence.

## Writing and commit conventions
- No emojis
- No filler phrases ("Great!", "Sure!")
- Concise, no trailing summaries
- German terms stay untranslated (Steuerberater, Versicherungsmakler)
- No Oxford commas
- Commit format: `type: description [date]`
- Read files before modifying them
- Never commit without being asked
- Prefer editing existing files over creating new ones
