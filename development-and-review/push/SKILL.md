---
name: push
description: Safely finalize, document, and push code. Respects previously run checks to avoid redundancy, updates project memory, commits, pushes, and monitors deployments.
---
# Push Skill Instructions

You have been invoked to finalize the current work, document it, and push it to the remote repository.
Follow these steps to ensure code quality and project memory are maintained.

## Codex safety boundary

Only stage, commit, push, or monitor a deployment when the user explicitly requests that action. Otherwise, prepare the changes and report the remaining release steps without performing them.

## 1. Deduplication & Pre-flight Checks
Do not duplicate work! Before running any linters, formatters, tests, or builds:
- Check your recent terminal history and context. If you *already* ran the project's tests, linter, or build successfully in the current session *after* the last file modification, **skip them**.
- Only run the remaining pre-flight checks (e.g., `npm run build`, `npm test`) that have not been executed yet or if files were modified since they were last run.
- If a build or test fails, attempt to fix it autonomously before proceeding. Stop and inform the user if you are stuck.

## 2. Project Memory & Documentation
- Consult local project instructions (`AGENTS.md`, `CLAUDE.md`, etc.) to understand where documentation is stored.
- If the project uses `HISTORY.md`, `CHANGELOG.md`, or `ROADMAP.md`, parse the uncommitted diffs (`git diff`) and update the relevant documents with a summary of the completed work.
- Ensure any `task.md` or `implementation_plan.md` artifacts are marked as completed.

## 3. Version Control (Git)
- Stage all relevant changes (`git add .` or selectively add files).
- Generate a conventional commit message (`type(scope): description`) that accurately reflects the diff.
- Execute `git commit -m "<your message>"`.

## 4. Push and Deploy Monitoring
- Push the changes to the remote. If the branch has no remote tracking, push using `git push -u origin HEAD`. Otherwise, just `git push`.
- **Note:** Pushing will typically trigger your automated deploy job (which handles the direct SSH deployment to your VPS).
- *Optional:* If the `gh` CLI is installed, you can use `env -u GITHUB_TOKEN gh run watch` to monitor that deploy job's progress. Otherwise, just remind the user that the deploy job has been triggered.
- If the deploy job is known to fail frequently, offer to troubleshoot the recent action runs.

## 5. Summary
- Present a concise summary to the user of what was committed, documented, and the final deploy status. Provide a link to the commit or PR if possible.
