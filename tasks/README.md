# Task Board

> [!NOTE]
> This is the central index tracking all project tasks. 
> To generate or update this list dynamically based on GDD requirements, run the `/task` command.
> To execute a task, tell the agent: *"Kerjakan task [ID]"*.

---

## 📋 Task Index

### 🔴 To Do
* `[ ]` [001-setup-system-name](file:///d:/Experiments/Roblox%20AI%20Framework/tasks/001-setup-system-name.md) - `[Brief description]`
* `[ ]` [002-another-task](file:///d:/Experiments/Roblox%20AI%20Framework/tasks/002-another-task.md) - `[Brief description]`

### 🟡 In Progress
* *None*

### 🟢 Completed
* *None*

---

## 🛠️ Instructions for Coding Agents
1. **Command `/task`**: 
   * Scan `.agents/GDD/` documents.
   * Scrape the gameplay specifications, monetization tables, and map configurations.
   * Generate an ordered, highly granular, step-by-step implementation roadmap.
   * Save each step to a distinct file: `tasks/XXX-task-name.md`.
   * Re-write this `tasks/README.md` file listing all generated tasks in order under the **To Do** section.
2. **Reconciliation**:
   * If `/task` is run and tasks already exist, preserve the **Completed** history. 
   * Update the pending tasks under **To Do** to reflect the new GDD context, updating existing files or creating new ones.
3. **Execution**:
   * When asked to run a task (e.g. "Kerjakan task 001"), move it to **In Progress** in this index, open the task file, write and test the code, mark it as **Completed** in both files, and notify the user.
