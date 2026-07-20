# Workflow: /task

Generates, reconciles, and executes file-based tasks from GDD specifications.

## Execution Steps
1. Scan `.agents/GDD/` knowledge base and `tasks/` directory at project root.
2. If no tasks exist, generate sequential granular tasks (`tasks/XXX-name.md`) following `tasks/task-blueprint.md.template` with User Stories and extreme technical specs, updating `tasks/README.md`.
3. If tasks exist, reconcile To Do tasks with updated GDD specs while preserving Completed history.
4. When instructed (e.g. "Kerjakan task 001"), set status to In Progress, perform code changes, verify, and mark as Completed.
