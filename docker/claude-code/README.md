# Claude Code Remote Control — VPS Setup

Runs Claude Code in a Docker container on the Hostinger VPS with Remote Control enabled. Once running, the session is accessible from any device via claude.ai/code or the Claude mobile app.

---

## Prerequisites

- Docker and Docker Compose installed on the VPS
- The `ctrl-ai-registry` repo cloned on the VPS
- A Claude Code OAuth token (see step 2 below)

---

## Setup steps

### 1. SSH into the VPS

```bash
ssh root@<vps-ip>
```

### 2. Obtain an OAuth token

On any machine where Claude Code is installed and authenticated:

```bash
claude setup-token
```

Log in when prompted. Copy the resulting `sk-...` token — you will need it in step 4.

### 3. Clone the repo (if not already present)

```bash
git clone git@github.com:IAMJURI8/ctrl-ai-registry.git /opt/ctrl-ai-registry
```

Update the volume path in `docker-compose.yml` if you clone to a different location.

### 4. Set the token

Create a `.env` file next to `docker-compose.yml`:

```bash
echo "CLAUDE_CODE_OAUTH_TOKEN=sk-..." > .env
```

Do not commit this file — it is listed in `.gitignore`.

### 5. Update the repo volume path

Edit `docker-compose.yml` and replace `/path/to/ctrl-ai-registry` with the actual path on the VPS (e.g. `/opt/ctrl-ai-registry`).

### 6. First run — interactive

Run the container interactively the first time to accept the workspace trust prompt and configure Notion MCP:

```bash
docker compose run --rm -it claude-code
```

Inside the container:

- Accept the workspace trust prompt when asked.
- Configure Notion MCP:

```bash
claude mcp add --scope project notionhq-notion npx -y @notionhq/notion-mcp-server
```

Set the `NOTION_API_KEY` environment variable either via the MCP config or by adding it to the `.env` file and the `environment` block in `docker-compose.yml`.

- Verify Notion access: run a quick fetch of the Strategy Digest page (`22d6f96c-1f2c-447e-897a-c064c3484d50`) to confirm read/write works.
- Exit the container (`exit` or Ctrl+D).

### 7. Start in detached mode

```bash
docker compose up -d
```

### 8. Get the Remote Control session URL

```bash
docker logs claude-remote
```

Look for the `claude.ai/code` session URL in the output. Open it on your phone or any browser to connect.

### 9. Verify

From the remote client, confirm:

- CLAUDE.md loads correctly
- Notion pages are readable and writable
- Git commands work (repo files visible under `/workspace`)

---

## Git credentials inside the container

The container needs credentials to push to GitHub. Two options:

**Option A — SSH key mount** (recommended):

Add to `docker-compose.yml` under `volumes`:

```yaml
- /root/.ssh:/home/node/.ssh:ro
```

**Option B — GitHub personal access token:**

Configure the token inside the container:

```bash
git config --global credential.helper store
git remote set-url origin https://<token>@github.com/IAMJURI8/ctrl-ai-registry.git
```

The `claude-config` named volume persists this between container restarts.

---

## Notes

- The Remote Control session URL changes after each container restart. Check `docker logs claude-remote` after every restart to get the new URL.
- The container auto-restarts after VPS reboots (`restart: unless-stopped`), but the session URL must be retrieved again.
- Permission approvals still require interaction from the remote client — `--dangerously-skip-permissions` is not supported in Remote Control mode.
- VPS resource check: the container adds Node.js process overhead alongside Traefik, n8n, and Ollama. Monitor RAM after first deployment.
- The `claude-config` named volume persists auth and MCP config across container recreations.

---

## Optional follow-up

Evaluate `github.com/JessyTsui/Claude-Code-Remote` for Telegram notifications when Claude Code completes a task or needs input — consistent with the existing Telegram-as-interface pattern used by Sarah and Alex.
