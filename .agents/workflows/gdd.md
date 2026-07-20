# Workflow: /gdd

Parses unstructured game design drafts and maps them into the modular `.agents/GDD/` Knowledge Base.

## Execution Steps
1. Accept input via `/gdd [file_path]` or `/gdd [raw pasted text]`.
2. Extract concepts, loops, user stories, lore, technical systems, badges, gamepasses, map design, and UI components.
3. Write formatted specs and Luau config table mockups to `.agents/GDD/` subfolders (`GDD/`, `gameplay/`, `monetization/`, `assets/`, `map_design/`, `ui_ux/`).
4. Report updated and created GDD files.
