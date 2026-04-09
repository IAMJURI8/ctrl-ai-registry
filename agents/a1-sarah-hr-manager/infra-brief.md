# Infrastructure Brief — A1 Sarah (HR Manager & Registry Clerk)

## Overview

| Field | Value |
|---|---|
| **Agent** | Sarah — HR Manager & Registry Clerk |
| **ID** | a1 |
| **Function** | Creates job descriptions (system prompts) for new AI agents; produces registry entries for the central manifest |
| **Interface** | Telegram (direct chat with Julian) |
| **Orchestration** | n8n workflow |
| **LLM** | Claude or GPT (conversational task — either works) |
| **Status** | Building |

## What needs to be built

### 1. Telegram bot
- Register a new bot via BotFather
- Name suggestion: `CtrlAI_Sarah_bot`
- Get the token, connect to n8n via Telegram Trigger node

### 2. n8n workflow
- **Trigger:** Telegram Trigger (on message)
- **Processing:** AI Agent node with Sarah's system prompt loaded
- **Response:** Telegram Send Message back to the same chat
- **Memory:** Conversation state must persist across messages (n8n's built-in AI memory or a simple session store) — Sarah asks questions one at a time across multiple messages
- **Reset:** A `/new` command should clear conversation memory and start a fresh onboarding session

### 3. System prompt
- Source: `agents/a1-sarah-hr-manager/system-prompt.xml` in this repo
- Load into the AI Agent node's system prompt field

### 4. Output handling
- Sarah produces two outputs at the end of each onboarding:
  1. Job description as XML
  2. Registry entry as JSON
- Telegram has a 4096 character limit per message
- If either output exceeds this, send as a file attachment instead of inline message
- Ideally: always send both as file attachments for easy copy-paste

## Nice-to-haves (not blocking launch)

- **Auto-persist outputs:** When Sarah completes an onboarding, automatically commit the job description XML and registry JSON to the GitHub repo (via n8n GitHub node or API call)
- **Registry read access:** Give Sarah read access to `registry.json` so she can answer questions about current team state and assign the next sequential agent ID automatically
- **Infra brief generation:** After producing the job description and registry entry, Sarah could also generate a draft infra brief using the template at `templates/infra-brief-template.md`

## Dependencies

- n8n instance running on VPS
- Telegram account
- LLM API key configured in n8n (Anthropic or OpenAI)
- GitHub repo created (`ctrl-ai-registry`)

## Cost estimate

- LLM API: ~€0.10–0.50 per onboarding session (conversational, ~10-15 messages)
- Telegram: free
- n8n: already running
- **Total marginal cost per agent onboarded: under €1**
