# Skill: wrap-up

## When to use

Before ending any session in which you modified an agent (system prompt, workflow, infra brief), wrote to Notion, or changed any tracked file. If you did nothing this session, skip. If in doubt, run it.

Trigger phrases: "wrap up", "close out the session", "end of session", "we're done for today".

## Execution — in order, no skipping

1. **Self-audit.** List every agent touched this session (`system-prompt.xml`, `workflow.json`, `infra-brief.md`). If none, jump to step 5.
2. **Re-export workflows.** For each touched agent, re-export `workflow.json` from n8n via MCP (`n8n_get_workflow`). Do not rely on a previously exported copy — export fresh.
3. **Registry Last Updated.** For each touched agent, verify the Agent Registry row's Last Updated = today (Europe/Berlin). If not, update it now.
4. **Commit.** Commit all changed files to Git. Follow commit convention: `type: description [YYYY-MM-DD]`. Never commit without being asked — EXCEPTION: wrap-up commits are pre-authorised, no confirmation needed.
5. **Recently Completed entry.** Write the entry in the Strategy Digest. Format: one-line summary of what was done + commit hash(es) if applicable. Be specific enough that a future session can understand what changed without reading the diff.

## Definition of Done (self-check before closing)

- [ ] No modified agent file exists locally without a matching Git commit
- [ ] No agent touched this session has a Registry Last Updated older than today
- [ ] Recently Completed entry written — even if the only change was a Notion edit
- [ ] No open n8n workflow edits that were not re-exported

## Failure modes and prohibitions

- Do not skip the Recently Completed entry because "it was a small change." Small undocumented changes are how drift starts.
- Do not commit `workflow.json` without re-exporting fresh from n8n — stale exports are worse than no export.
- If Notion is unreachable and you cannot write the Recently Completed entry, note this explicitly in your final message to Julian so he can log it manually.
- If the pre-commit hook blocks (Registry row not updated), fix the row before bypassing with `--no-verify`.
