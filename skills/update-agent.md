# Skill: update-agent

## When to use

Any change to an existing active agent:

- System prompt edits
- Workflow structure changes (nodes added, removed, reconfigured)
- Model change
- Credential or config swap that affects runtime behavior
- Parameter changes on existing nodes (temperature, memory window, tool bindings)

Trigger phrases: "update [agent]", "change [agent]'s prompt", "swap [agent]'s model", "add X node to [agent]", "retrofit [agent]".

Out of scope: status flips to `retired` (use `retire-agent.md`), first-time agent build (use `create-agent.md`).

## Required reads (fetch BEFORE any write)

1. `CLAUDE.md` at repo root
2. `skills/README.md`
3. Strategy Digest — page `22d6f96c-1f2c-447e-897a-c064c3484d50`. Confirm no conflicting open handoff for the same agent.
4. Agent Registry row for the target agent — data source `ba781fc9-fdd0-418e-a34c-55f235b4f6e2`. Note current Model, Phase, Last Updated, Notes.
5. `agents/[id]-[short-name]/system-prompt.xml` and `workflow.json` — current repo state.
6. Live n8n workflow via `n8n_get_workflow`. Diff against repo `workflow.json`. If drifted, reconcile BEFORE starting the change (commit the reconciliation as its own step).

## Execution modes

### Iteration

- Create or switch to a feature branch: `git checkout -b feat/[agent]-[short-change]`
- WIP commits allowed, messages informal
- Do NOT touch the Registry
- Do NOT touch the live n8n workflow
- Do NOT write to the Strategy Digest
- Test against a scratch n8n workflow or local script if runtime verification needed

### Release (the four-step atomic action)

Execute in order. Verify each step before moving to the next.

1. **Git.** Merge feature branch to `main` (or commit directly on `main` for trivial changes). Push. Record the commit hash.
2. **Registry.** Update every field that changed (Model, Phase, Notes, etc.). Always update Last Updated to today (Europe/Berlin).
3. **n8n via MCP.** Apply the equivalent change to the live workflow using `n8n_update_full_workflow` or `n8n_update_partial_workflow`. Confirm with `n8n_get_workflow` that the live state matches the repo.
4. **Strategy Digest Recently Completed.** Append one-liner: what changed, agent ID, commit hash, date.

## Release DoD checklist

Copy into the handoff's DoD block if this skill is the executor:

- [ ] Feature branch merged to `main` (or direct commit on `main`)
- [ ] Commit pushed, hash recorded: `<hash>`
- [ ] Registry row: every changed field updated
- [ ] Registry row: Last Updated = today (Europe/Berlin)
- [ ] Live n8n workflow updated via MCP
- [ ] n8n workflow diff-verified against repo `workflow.json`
- [ ] **Tool wiring verified.** Every tool named in the system prompt's `<Skills_and_Authorities>` section is wired on the AI Agent node — verified by re-fetching the live workflow via `n8n_get_workflow` and listing the agent node's `tools` array. No prompt-only tool references.
- [ ] **Autonomous proof-of-life.** Run a representative synthetic input via n8n MCP (`n8n_test_workflow` / `executeWorkflow` / equivalent) — captured response is coherent, Cost Monitor logs the run, no errors. Julian's Telegram test stays his to run; do not consume his chat for verification.
- [ ] **Cost Monitor allowlist.** `GET https://monitor.controlplusai.com/api/agents` returns the agent. If missing, restart the monitor container (`docker compose -f /home/juri/ai-cost-monitor/docker-compose.yml restart`) so it re-pulls the Registry, then re-check.
- [ ] Strategy Digest Recently Completed entry appended with commit hash

## Rollback procedure

If any release step fails or a regression surfaces post-release, reverse in opposite order:

1. **n8n via MCP.** Revert the live workflow to the previous state using `n8n_update_full_workflow` with the pre-change `workflow.json` from repo history.
2. **Registry.** Restore previous field values. Set Last Updated to today with Notes suffix: "rollback of `<hash>`".
3. **Git.** `git revert <hash>` and push the revert commit. Record the revert hash.
4. **Strategy Digest.** Append Recently Completed entry: "Rolled back `<title>` — `<reason>`. Reverted `<hash>`, restored `<previous hash>`."

Never delete the original Recently Completed entry. Rollbacks are additive.

## Failure modes and prohibitions

- **Telegram `appendAttribution: false` is mandatory.** All Telegram Send Message nodes must have `appendAttribution: false` in `parameters.additionalFields`. Verify via MCP before session end.
- **No direct n8n canvas edits.** Changes must flow Git → MCP, never UI → canvas. If a canvas edit happens under pressure (emergency hotfix), re-export the workflow via `n8n_get_workflow` and commit it to `workflow.json` BEFORE the session ends. No session ends with canvas-only state.
- **No concurrent sessions on the same agent.** If two Claude surfaces are running against the same agent, one must stop until the other finishes the four-step action.
- **No partial four-step completions.** Either all four or rollback. Leaving Git+Registry updated but n8n stale is a drift incident — treat it as a bug, not a milestone.
- **No skipping Last Updated.** Enforced mechanically by `scripts/pre-commit.sh`: any staged `agents/*/system-prompt.xml` or `agents/*/workflow.json` whose matching Registry row has a Last Updated older than today (Europe/Berlin) blocks the commit. Update the Registry row first, then re-stage and commit.
- **No `--no-verify` on commits** except in one scenario: a genuine emergency where the Registry cannot be updated first (Notion outage, token missing, etc.). In that case:
  1. Julian must explicitly authorize the bypass in the session.
  2. Immediately after the bypass commit, fix the Registry (update Last Updated, Notes suffix with `<commit hash>`).
  3. Append a Recently Completed entry in the Strategy Digest naming the bypassed commit, the reason, and the follow-up Registry fix.
  No silent `--no-verify`. The whole point of the hook is that bypassing leaves a paper trail.
