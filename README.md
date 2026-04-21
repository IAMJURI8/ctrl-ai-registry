# Ctrl+AI Registry — deployable agent configs for Ctrl+AI Advisory. Canonical state and operating rules live in the [Master Doc](https://www.notion.so/340824baea2b819eaafcce451dfa4fb3).

## After cloning

Install the Registry-staleness pre-commit hook:

```
ln -sf ../../scripts/pre-commit.sh .git/hooks/pre-commit
```

The hook blocks commits that touch `agents/*/system-prompt.xml` or `agents/*/workflow.json` when the matching Agent Registry row's **Last Updated** is older than today (Europe/Berlin). See `skills/update-agent.md` for the four-step release sequence.

Requires `curl`, `jq`, and a Notion integration token either in `NOTION_TOKEN` or at `~/.config/ctrl-ai/notion-token`.
