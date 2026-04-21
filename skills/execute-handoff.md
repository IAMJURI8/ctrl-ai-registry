# Skill: execute-handoff

## When to use

- Julian says "work through pending handoffs"
- Julian says "start #N pending handoff" or "do handoff N"
- Claude Code session starts, Pending Handoffs is non-empty, and Julian confirms execution

Trigger phrases: "work through handoffs", "do handoff N", "execute pending", "run the next handoff", "start the handoff".

Out of scope: writing a new handoff (that happens in Claude.ai or by Julian directly), or editing a handoff's format.

## Required reads

1. `CLAUDE.md` at repo root
2. `skills/README.md`
3. Strategy Digest — page `22d6f96c-1f2c-447e-897a-c064c3484d50`. Read the full Pending Handoffs section, not just the target entry — check for ordering, dependencies, and format consistency.
4. Master Doc Operating Rules — page `340824ba-ea2b-819e-aafc-ce451dfa4fb3`. Specifically the Handoff format section.
5. Any skill referenced by or implied by the target handoff:
   - Agent-touching handoff → read `update-agent.md`, `create-agent.md`, or `retire-agent.md` as applicable.
   - Multi-agent handoff → read the agent skill for each targeted agent.
6. Any files or Notion resources listed in the handoff's "Files/resources" section.

## Execution modes

### Iteration

A handoff is never "iterated" without committing. Either it is ready to execute (release mode) or it needs a Strategy Digest edit first. If the handoff is malformed, ambiguous, or blocked, ask Julian to update the Digest rather than silently reinterpreting.

### Release

Execute in this order:

1. **Validate format.** Confirm the handoff has Title / Context / Task / Definition of Done / Files+resources. If malformed, stop and flag to Julian.
2. **Validate DoD interpretability.** Every DoD item must be verifiable. If any item is vague, ask before starting.
3. **Follow the matching agent skill's four-step action** for any agent-touching steps. Do not reinvent the sequence.
4. **Execute the Task steps in order.** Respect any ordering rationale the handoff provides (e.g., "Francis first because...").
5. **Verify every DoD item** before marking the handoff done. Partial = failure.
6. **Move the handoff** from Pending Handoffs to Recently Completed. The Recently Completed entry must reference the commit hash(es) and any workflow IDs touched.
7. **Surface any new follow-ups** as fresh Pending Handoffs with the canonical format.

## Release DoD checklist (meta — for handoff execution itself)

- [ ] Handoff format validated (Title / Context / Task / DoD / Files)
- [ ] All Task steps executed in order (respecting stated rationale)
- [ ] All handoff-level DoD items verified (not self-reported — actually checked)
- [ ] Commit hashes recorded for every code change
- [ ] Workflow IDs recorded for every n8n change
- [ ] Handoff entry removed from Pending Handoffs
- [ ] Recently Completed entry appended with commit refs and date
- [ ] Any new follow-ups surfaced as fresh Pending Handoffs

## Rollback procedure

If the handoff fails mid-flight:

1. **Reverse any completed sub-steps** using the relevant agent skill's rollback (n8n → Registry → Git).
2. **Leave the handoff in Pending Handoffs** — do NOT move it to Recently Completed.
3. **Append a blocker note** to the handoff body: "Attempted YYYY-MM-DD, failed at step X. Blocker: `<short>`. Rolled back `<hashes>`."
4. **Surface the blocker to Julian** with enough context to decide: retry, redesign, or drop.

## Failure modes and prohibitions

- **No direct n8n canvas edits during handoff execution.** The handoff flows through MCP. If a canvas-only change sneaks in, re-export the workflow via `n8n_get_workflow` and commit it to `workflow.json` before the session ends.
- **No marking the handoff complete with any DoD item unverified.** Self-reporting ("should be fine") does not count as verification.
- **No concurrent sessions executing the same handoff.** If a handoff is in-flight from another surface, a second session must wait or work a different handoff.
- **No skipping the relevant agent skill.** If the handoff touches an agent, the matching skill is required reading first, not optional.
- **No silently reinterpreting a malformed handoff.** If it deviates from the canonical format, fix the format with Julian first, then execute.
- **No reordering Task steps** without explicit permission. If the handoff specifies "X first, Y second", that ordering is load-bearing.
