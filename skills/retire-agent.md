# Skill: retire-agent

## When to use

- An agent is replaced by a newer version (e.g., a model swap that warrants a fresh identity)
- An agent is deprecated by a strategy shift
- A workflow is decommissioned for cost, drift, or maintenance reasons

Trigger phrases: "retire [agent]", "deprecate [agent]", "shut down [agent]", "replace [agent] with X".

Out of scope: temporary pauses (those are `active = false` on the n8n workflow only, not a retirement) and prompt edits (use `update-agent.md`).

## Required reads

1. `CLAUDE.md` at repo root
2. `skills/README.md`
3. Strategy Digest — page `22d6f96c-1f2c-447e-897a-c064c3484d50`. Confirm retirement lives in a handoff, not an ad-hoc request.
4. Agent Registry row for the target — data source `ba781fc9-fdd0-418e-a34c-55f235b4f6e2`. Capture current Model, Phase, Status.
5. `agents/[id]-[short-name]/` — current repo state. Folder is preserved, not deleted.
6. Live n8n workflow via `n8n_get_workflow` — capture final state; confirm the `workflow.json` in repo matches before retiring. If drifted, reconcile first.
7. Any Registry row whose Notes reference this agent — check for inter-agent dependencies.

## Execution modes

### Iteration

- Retirement is typically a one-shot release. If retirement requires a preceding change (e.g., cut a dependency first), that change uses `update-agent.md` in iteration mode, committed and released BEFORE retirement begins.

### Release (the four-step atomic action)

1. **Git.** Optionally tag the final commit of the agent folder for historical reference: `git tag retired/[id]-[yyyy-mm-dd] && git push --tags`. Do NOT delete the agent folder — history matters.
2. **Registry.** Status → `retired`. Last Updated = today (Europe/Berlin). Append to Notes: "Retired YYYY-MM-DD. Reason: `<short>`. Replacement: `<agent id or 'none'>`."
3. **n8n via MCP.** Deactivate the workflow via `n8n_update_partial_workflow` setting `active: false`. Do NOT delete the workflow — leave for a recovery window (default 30 days) unless Julian explicitly requests deletion.
4. **Strategy Digest Recently Completed.** One-liner: agent retired, reason, replacement.

## Release DoD checklist

- [ ] (Optional) Final tag pushed: `retired/[id]-[yyyy-mm-dd]`
- [ ] Registry status = `retired`
- [ ] Registry Last Updated = today (Europe/Berlin)
- [ ] Registry Notes retirement entry appended with reason and replacement
- [ ] n8n workflow `active` = false, confirmed via `n8n_get_workflow`
- [ ] Telegram bot username recorded (so it can be reclaimed via BotFather later if needed)
- [ ] Strategy Digest Recently Completed entry appended

## Rollback procedure

If retirement turns out to be premature:

1. **n8n via MCP.** Re-activate the workflow via `n8n_update_partial_workflow` setting `active: true`.
2. **Registry.** Status → previous value (usually `active`). Last Updated = today. Notes append: "Un-retired `<date>`. Reason: `<short>`."
3. **Git.** Delete the retirement tag if it was created: `git tag -d retired/[id]-[yyyy-mm-dd] && git push origin :refs/tags/retired/[id]-[yyyy-mm-dd]`.
4. **Strategy Digest.** Append Recently Completed rollback entry.

## Failure modes and prohibitions

- **No deleting the agent folder.** Archival beats deletion. History is load-bearing for narrative and debugging.
- **No deleting the n8n workflow in the same action as retirement.** Deactivation first; deletion is a separate, dated follow-up after the recovery window closes.
- **No retiring an agent that other agents depend on without first cutting the dependency.** Check inter-agent webhooks and Registry Notes before flipping status. If a dependency exists, it gets cut via `update-agent.md` in a prior release.
- **No direct n8n canvas edits** to disable the workflow. Deactivation flows through MCP. If a canvas-only deactivation happens under pressure, re-export the workflow via `n8n_get_workflow` to confirm state and commit if anything else drifted.
- **No concurrent sessions retiring and updating the same agent.**
- **No partial four-step completions.** If n8n is deactivated but the Registry status is not flipped, treat as a drift incident and either complete the remaining steps or roll back.
