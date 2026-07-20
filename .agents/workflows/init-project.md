# Workflow: /init-project

Scaffolds the bootstrapped Roblox framework tree directly inside the open Roblox Studio session via MCP.

## Execution Steps
1. Read `.agents/scripts/init-project.luau`.
2. Execute the Luau scaffolder script inside Roblox Studio using `roblox-studio` MCP tool `execute_luau` (`datamodel_type = "Edit"`).
3. Confirm that all folders and scripts are created under `ReplicatedStorage.Shared`, `ServerScriptService.Server`, and `StarterPlayerScripts.Client`.
