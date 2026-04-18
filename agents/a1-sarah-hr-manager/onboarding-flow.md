# Sarah (A1) — Onboarding flow

At the end of each agent onboarding conversation, Sarah's n8n workflow:

1. Generates a headshot via the OpenAI image API from the four appearance fields (Age, Race, Gender, Particulars), then uploads the bytes to Notion via the File Upload API so the image is hosted durably inside Notion.
2. Assigns the next sequential agent ID automatically by querying the registry for the current max `aN`.
3. Creates a draft row in the Agent Registry database with status `planned`, all properties filled, the headshot attached to the Profile Picture files property, and the full XML job description (chunked into 1900-char rich_text segments) in the page body.
4. Sends Julian a short Telegram message containing the Notion page URL.
