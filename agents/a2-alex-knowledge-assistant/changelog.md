# Alex (A2) — Changelog

## v0.4 — 2026-04-21 — Prompt fetched from Git at runtime
- System prompt now fetched from Git at runtime instead of pasted into the n8n agent node. New `Fetch Prompt` (HTTP Request) and `Resolve Prompt` (Code) nodes inserted between `Build Prompt` and `Alex Agent`. The agent's `systemMessage` is now the expression `={{ $('Resolve Prompt').item.json.prompt }}`.
- Cache-and-fallback layer in `Resolve Prompt` using n8n workflow static data (key `prompt_cache_a2`, 5-minute TTL). On HTTP success, prompt is cached and used live. On HTTP failure (non-200, timeout, network error), the last-known-good cached prompt is served and a fallback message is logged. If no cache exists at all, the workflow fails loudly rather than silently passing an empty prompt.
- HTTP node uses `onError: continueRegularOutput` so the resolve node can serve cache instead of halting the workflow. HTTP body is read from `data ?? body` since `responseFormat: text` + `fullResponse: true` puts the payload in `data`.
- `Resolve Prompt` passes through `Build Prompt`'s `chatId` and `userMessage` so downstream Alex Agent and Send Reply expressions resolve unchanged. No `{{ }}` placeholders in Alex's prompt to interpolate (unlike Francis), so the resolve step is a pure pass-through plus prompt assembly.
- Removed obsolete `_notes` field from `workflow.json`. Repo is now self-explanatory: the prompt fetched at runtime is the canonical `system-prompt.xml`.

## v0.3.1 — 2026-04-20 — Tool schema fixes
Two fixes to make v0.3 actually work end-to-end with live Notion calls.

- Headers migrated from legacy `headerParameters.parameters` to v1.1 `parametersHeaders.values` with `valueProvider: "fieldValue"` and `specifyHeaders: "keypair"`. The legacy key triggered an n8n fallback that injected a bogus `{name: "", sendIn: "headers"}` placeholder, which produced a tool schema with an empty-string property key and Anthropic rejected the request (`properties: Property keys should match pattern '^[a-zA-Z0-9_.-]{1,64}$'`).
- Full-body placeholder renamed from `{body}` to `{payload}` in `queryKB`, `createEntry`, and `updateEntry`. In `ToolHttpRequest` utils, when `parameter.sendIn === parameter.name` the substitution loop assigns directly to `options[sendIn]` and skips the `bodyRaw` branch, so the `{body}` template was never substituted and `jsonParse` choked on the literal string.

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
