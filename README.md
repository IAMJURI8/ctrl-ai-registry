# Ctrl+AI Registry

Central agent registry for Ctrl+AI Advisory — the fictional consulting firm at the heart of [Project Zero](https://github.com/[TBD]/project-zero).

## What this is

Every AI agent that operates within Ctrl+AI Advisory is registered here. This repo is the single source of truth for who's on the team, what they do, and how they're built.

## Structure

```
ctrl-ai-registry/
├── registry.json                      # Central manifest — all agents, status, references
├── agents/
│   └── a1-sarah-hr-manager/
│       ├── system-prompt.xml          # The actual system prompt
│       ├── infra-brief.md             # Infrastructure setup spec
│       └── changelog.md               # Version history for this agent
├── backlog/
│   └── backlog.md                     # Future agent concepts
└── templates/
    ├── system-prompt-template.xml     # Standard prompt structure
    └── infra-brief-template.md        # Standard brief structure
```

## How it works

1. **New agent needed** → Julian briefs Sarah (A1 — HR Manager) via Telegram
2. **Sarah runs onboarding** → guided conversation → produces job description (XML) + registry entry (JSON)
3. **Julian adds to repo** → system prompt goes in `agents/[id]-[name]/`, registry entry goes in `registry.json`
4. **Agent gets built** → infra brief goes to the Infrastructure project for implementation

## Conventions

- **Agent IDs** are sequential: `a1`, `a2`, `a3`, ...
- **Folder names** follow the pattern: `[id]-[short-name]` (e.g., `a1-sarah-hr-manager`)
- **Status values:** `active`, `building`, `planned`, `retired`
- **All prompts** use the XML job description format defined in `templates/`
- **All changes** get a changelog entry

## Related projects

- **Ctrl+AI Strategy** — brand, positioning, business model, go-to-market
- **Ctrl+AI Infrastructure** — VPS, n8n, technical implementation
