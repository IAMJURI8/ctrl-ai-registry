# Ctrl+AI Registry

Deployment repo for the AI agents of **Ctrl+AI Advisory** — a one-person, vendor-neutral AI consulting firm for SMEs. Part of [Project Zero](https://www.notion.so/Project-Zero-Master-Doc-340824baea2b819eaafcce451dfa4fb3).

## What this is

This repo holds the **deployable configuration** for every agent operating within the firm — one folder per agent, containing the system prompt and the n8n workflow export.

It is deliberately slim. The agent **registry itself** — roster, status, model, role, relationships, version notes — lives in a Notion database under the Project Zero Master Doc. That is the single source of truth for agent state. This repo only holds what needs to be deployed to n8n.

## Structure

```
ctrl-ai-registry/
├── CLAUDE.md                           # Instructions for Claude Code
├── README.md
├── agents/
│   ├── a1-sarah-hr-manager/
│   │   ├── system-prompt.xml           # The system prompt
│   │   └── workflow.json               # n8n workflow export
│   └── a2-alex-knowledge-assistant/
│       ├── system-prompt.xml
│       └── workflow.json
└── templates/
    └── system-prompt-template.xml      # Standard prompt structure
```

## How it works

1. **New agent needed** → Julian briefs Sarah (A1 — HR Manager) via Telegram.
2. **Sarah runs onboarding** → guided conversation → produces a job description (XML).
3. **Agent gets built** → n8n workflow created, system prompt committed to `agents/[id]-[name]/system-prompt.xml`, workflow exported to `workflow.json`.
4. **Registry updated** → a new row is added to the Notion Agent Registry with status, phase, model, personality, and a link to this folder.

## Conventions

- **Agent IDs** are sequential: `a1`, `a2`, `a3`, …
- **Folder names** follow the pattern: `[id]-[short-name]` (e.g., `a1-sarah-hr-manager`)
- **All prompts** use the XML job description format defined in `templates/system-prompt-template.xml`
- **Status values** (tracked in the Notion registry, not here): `active`, `building`, `planned`, `retired`
- Mutable state — versions, changelogs, infra notes — lives on the corresponding row in the Notion registry, not in this repo.

## Where things live

| What | Where |
|---|---|
| Deployable agent configs (prompts + workflows) | This repo |
| Agent registry (roster, status, state, notes) | Notion database (under Master Doc) |
| Strategy, positioning, roadmap, way-of-working | Notion Master Doc |
| Current decisions, backlog, open questions | Notion Strategy Digest |
| Orchestration runtime | n8n on VPS |

Both Claude.ai (brain) and Claude Code (hands) read from Notion and from this repo. Julian bridges strategy from Claude.ai to execution in Claude Code.
