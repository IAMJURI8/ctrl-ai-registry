# Alex (A2) — Changelog

## v0.3 — 2026-04-20 — Agentic CRUD
Replaced the linear capture + query routing pipeline with a fully agentic AI Agent node that has direct Notion tool access. Alex now handles multi-turn CRUD conversations natively within a single context window: capture → query → reclassify → archive, all without workflow-level branching.

**Removed nodes:** `Is Query?`, `Build Query Filter`, `Notion Query`, `Format Query Results`, `Send Query Results` (old routing branch). `Parse Classification`, `Is Clarification?`, `Notion Create Page`, `Send Capture Confirmation`, `Send Clarification` (old structured-output capture path).

**Added tools** (attached to Alex Agent via `ai_tool`, all using the existing `notionApi` credential and Notion-Version `2022-06-28`):
- `queryKB` — POST `/v1/databases/{db}/query`, agent passes the full filter/sorts/page_size body.
- `getEntry` — GET `/v1/pages/{pageId}`, for full property detail on a single entry.
- `createEntry` — POST `/v1/pages`, agent constructs parent+properties body per KB schema.
- `updateEntry` — PATCH `/v1/pages/{pageId}`, agent passes a `properties` subset to update.
- `archiveEntry` — PATCH `/v1/pages/{pageId}` with `archived: true`. Hard confirmation gate: agent must state the entry name and wait for explicit "yes" before calling.

**Added node:** single `Send Reply` Telegram node consumes the agent's `output` and replies to `chatId`.

**Kept:** Telegram Trigger, Extract Context (simplified — no more query-intent detection), Route Input Type (text/voice/url), Get Voice File, Whisper Transcribe, Fetch URL, Extract Meta, Build Prompt, Anthropic Chat Model (Claude Sonnet 4.5), Conversation Memory (10-turn Window Buffer, keyed on chatId). Page IDs returned by `queryKB` stay in the buffer so follow-up instructions like "change the second one to Reference" or "delete the first one" resolve naturally.

**System prompt:** rewritten. Drops the "return JSON" contract; adds `<Intent>` (Capture/Query/Mutate), `<Tools>` with the confirmation gate, `<NotionSchema>` with property shapes, and multi-turn examples.

Node count: 21 → 17. Workflow ID `3PDLYV2gpwbQCqNp`. Live 2026-04-20.

## v0.2 — 2026-04-12 — Read/query capability (retired)
Added an `Is Query?` routing branch (`Build Query Filter` → `Notion Query` → `Format Query Results` → `Send Query Results`) alongside the capture path. Supported `show my Inbox`, `show YouTube links`, `find <keyword>`, etc. with filters on GTD Status / Source / keyword. Results capped at 10, sorted by created_time desc. Superseded by the agentic CRUD design in v0.3.

## v0.1 — 2026-04-12 — Initial build
Telegram Trigger → Extract Context → Route (text/voice/url) → (Whisper / URL enrichment) → Build Prompt → Alex Agent (Claude Sonnet 4.5 + 10-turn Window Buffer keyed on chatId) → Parse Classification → Is Clarification? → Notion Create Page → Send Capture Confirmation. GTD classification, strict JSON output, Blue 60 / Green 25 / Red 10 / Yellow 5 personality.
