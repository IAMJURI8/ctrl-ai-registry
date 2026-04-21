# Skill: create-agent

## When to use

Spinning up a new agent from a Notion spec or a fresh design:

- A new row appears in the Agent Registry with status `planned` or `building`
- Julian provides a Notion page URL as the handoff payload
- An Agent roadmap phase advances and the next agent is ready to build

Trigger phrases: "build [agent] from Notion URL", "create a new agent for X", "start [agent name]", "hire [role]".

Out of scope: changing an existing agent (use `update-agent.md`), retirement (use `retire-agent.md`).

## Required reads

1. `CLAUDE.md` at repo root
2. `skills/README.md`
3. Strategy Digest — page `22d6f96c-1f2c-447e-897a-c064c3484d50`. Confirm a matching handoff exists and the agent is expected.
4. The Notion spec page for the agent (URL provided by Julian). Read appearance fields, system-prompt spec, and profile content.
5. Agent Registry row for the agent — data source `ba781fc9-fdd0-418e-a34c-55f235b4f6e2`. Capture the assigned ID, planned Phase, Model, Interface.
6. Master Doc Operating Rules — page `340824ba-ea2b-819e-aafc-ce451dfa4fb3`. Confirm the agent fits the current phase.
7. A reference agent folder as template (`agents/a2-alex-knowledge-assistant/` or `agents/a4-francis/` are current reference implementations).

## Execution modes

### Iteration

- Create `agents/[id]-[short-name]/` folder on a feature branch
- Draft `system-prompt.xml` from the Notion spec body
- Clone `workflow.json` from the closest sibling agent and adapt nodes
- WIP commits on the feature branch
- Deploy to a scratch n8n workflow (not the final ID) for roundtrip testing
- Registry row stays at status `building` — do not flip to `active` until release

### Release (the four-step atomic action)

1. **Git.** Merge feature branch to `main`. The commit must include both `system-prompt.xml` and `workflow.json`. Push. Record the commit hash.
2. **Registry.** Flip status → `active`. Fill GitHub folder link, Model, Interface, Orchestration, Phase, Personality. Set Created = original build start date, Last Updated = today (Europe/Berlin). Populate Notes with a one-line descriptor.
3. **n8n via MCP.** Deploy via `n8n_create_workflow` if the workflow does not exist yet, or `n8n_update_full_workflow` if a placeholder was created earlier. Capture the live workflow ID and add it to the Registry row (field: Notes or a dedicated workflow-ID field if present).
4. **Strategy Digest Recently Completed.** One-liner: agent activated, commit hash, live workflow ID.

## Release DoD checklist

- [ ] `agents/[id]-[short-name]/system-prompt.xml` committed
- [ ] `agents/[id]-[short-name]/workflow.json` committed
- [ ] Commit pushed, hash recorded: `<hash>`
- [ ] n8n workflow deployed, ID recorded: `<workflow_id>`
- [ ] Telegram bot bound and credentials attached (if applicable)
- [ ] End-to-end live trigger test passed (human message → agent output)
- [ ] Registry row: status = `active`
- [ ] Registry row: GitHub folder link filled
- [ ] Registry row: Model, Interface, Orchestration, Phase, Personality populated
- [ ] Registry row: Last Updated = today (Europe/Berlin)
- [ ] Strategy Digest Recently Completed entry appended with commit hash and workflow ID

## Rollback procedure

If activation fails or the agent misbehaves post-release:

1. **n8n via MCP.** Delete the newly created workflow via `n8n_delete_workflow`. (If it was a placeholder update, revert via `n8n_update_full_workflow` to the placeholder state.)
2. **Registry.** Revert status from `active` back to `building` (or `planned` if the folder is also being removed). Clear GitHub folder link if it was added. Append rollback note to Notes.
3. **Git.** `git revert <hash>` and push (or drop the branch if never merged).
4. **Strategy Digest.** Append Recently Completed rollback entry referencing the reverted commit and the reason.

## Failure modes and prohibitions

- **No direct n8n canvas creation.** Workflows are born via MCP deploy from `workflow.json`. A canvas-first workflow means the repo is the drift site — forbidden.
- **No flipping status to `active` before the live trigger test passes.** Status stays `building` until Telegram (or the equivalent interface) completes a full roundtrip.
- **No concurrent sessions building the same agent.**
- **No partial four-step completions.** If n8n deploy succeeds but Registry flip fails, treat as an incident — rollback and retry rather than leaving split state.
- **No inventing behavior not in the spec.** The Notion spec page is the source of truth for prompt content. If the spec is ambiguous, stop and ask Julian — do not fill gaps from training data.
