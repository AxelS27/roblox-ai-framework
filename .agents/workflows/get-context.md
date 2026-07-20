# Workflow: /get-context

Synthesizes the complete project context, architecture, live Roblox Studio explorer tree status, active task checklist, and GDD knowledge base.

## Execution Steps
1. Read `AGENTS.md`, active `task.md`, `tasks/README.md`, and `.agents/GDD/`.
2. Query active Roblox Studio session via `roblox-studio` MCP tools (`get_studio_state` / `search_game_tree`).
3. Output a 360° summary of current framework rules, live Studio state, design specs, task progress, and active next steps.
