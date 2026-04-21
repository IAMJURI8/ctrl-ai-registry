# Skills — ctrl-ai-registry

Machine-readable checklists. Claude Code reads the relevant skill BEFORE executing the matching task type. Skills encode the four-step atomic action across Git, Registry, n8n, and Strategy Digest as explicit checklists so no surface is left stale.

## When to read which skill

| Task | Skill |
|------|-------|
| Modify existing agent (prompt, workflow, model, config) | `update-agent.md` |
| Build a new agent from a Notion spec | `create-agent.md` |
| Retire or deactivate an existing agent | `retire-agent.md` |
| Execute a Pending Handoff from Strategy Digest | `execute-handoff.md` |

If a task touches an agent, the matching skill is required reading before any write. If a handoff references a skill by name, read that skill too.

## Canonical surfaces

- **Git** (this repo) — `agents/[id]-[short-name]/system-prompt.xml`, `workflow.json`, `CLAUDE.md`
- **Agent Registry DB** — data source `ba781fc9-fdd0-418e-a34c-55f235b4f6e2`
- **Strategy Digest** — page `22d6f96c-1f2c-447e-897a-c064c3484d50`
- **Master Doc Operating Rules** — page `340824ba-ea2b-819e-aafc-ce451dfa4fb3`

## The four-step atomic action (agent changes)

Any change to a live agent is ONE action across four surfaces:

1. **Git** — edit, commit, push. Record commit hash.
2. **Registry** — update every changed field + Last Updated (today, Europe/Berlin).
3. **n8n (via MCP)** — apply the same change to the live workflow. Verify via `n8n_get_workflow`.
4. **Strategy Digest** — one-liner in Recently Completed referencing the commit.

All four or rollback. No partial completions. Rollback reverses the same order: n8n → Registry → Git → Strategy Digest rollback entry.

## Iteration vs release

- **Iteration mode** — WIP commits on a feature branch while drafting. No Registry touch, no live n8n touch, no Digest entry. Used while the change is still being designed or tested.
- **Release mode** — the four-step atomic action above, triggered when the change is ready to land on `main` and go live.

Skills list both modes explicitly. Do not mix them.

## Prohibitions (applies across all skills)

- No direct n8n canvas edits. Changes flow Git → MCP. If a canvas edit happens under pressure, re-export the workflow via `n8n_get_workflow` and commit it to `workflow.json` before the session ends.
- No concurrent sessions on the same agent.
- No partial four-step completions. Either all four surfaces or rollback.
- No `--no-verify` on commits without an explicit Recently Completed entry stating why.
