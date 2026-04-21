# Francis — Changelog

## v1.2 — 2026-04-21
- System prompt now fetched from Git at runtime instead of pasted into the n8n agent node. New `Fetch Prompt` (HTTP Request) and `Resolve Prompt` (Code) nodes inserted between `Flatten Best Practices` and `Francis Agent`. The agent's `systemMessage` is now the expression `={{ $('Resolve Prompt').item.json.prompt }}`.
- Cache-and-fallback layer in `Resolve Prompt` using n8n workflow static data (key `prompt_cache_a4`, 5-minute TTL). On HTTP success, prompt is cached and used live. On HTTP failure (non-200, timeout, network error), the last-known-good cached prompt is served and a fallback message is logged. If no cache exists at all, the workflow fails loudly rather than silently passing an empty prompt.
- The `{{ $('Flatten Best Practices').item.json.markdown }}` placeholder in the fetched prompt is interpolated server-side in `Resolve Prompt` (string `split`+`join`), since n8n doesn't recursively evaluate expressions inside expression results.
- HTTP node uses `onError: continueRegularOutput` so the resolve node can serve cache instead of halting the workflow.

## v1.1 — 2026-04-19
- Added Notion runtime fetch of LinkedIn Post Best Practices (`347824ba-ea2b-81d9-b1ba-f69b99e29637`) via new `Fetch Best Practices` (Notion block getAll) and `Flatten Best Practices` (Code) nodes, injected into the agent prompt under `<BestPractices>`. The doc is now the single source of truth for voice, length, vocabulary, and formatting rules.
- Slimmed the system prompt: content rules previously duplicated in-line are delegated to the injected playbook. Kept a `<NonNegotiables>` block as a fallback if the fetch is empty or truncated.
- Added `<image>` output after `<post>`. Parse Output already extracts only the `<post>` block for publishing, so the image suggestion is for Julian's reference and never reaches LinkedIn.
- Tightened length target to 800 to 1,000 characters, hard cap 1,100.
- Explicit em dash ban promoted into the non-negotiable block.
- Reconciled repo `workflow.json` and `system-prompt.xml` with live n8n workflow `DuRPGl2f9n9lTLhD` (previously drifted).

## v1.0 — 2026-04-14
- Initial build. Telegram-triggered LinkedIn content creator backed by Claude Opus 4.6, with `/new` session reset, `<post>` tag extraction, staged draft confirmation, and `/post` publish via LinkedIn REST API.
