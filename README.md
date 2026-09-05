# Agentic Skills Library

A consolidated repository of custom agentic skills, system prompts, and tool configurations. These modules are loaded dynamically across runtime environments to steer AI assistants, automate development operations, and maintain a consistent workspace.

## Recent Codex Workflows

These portable skills capture workflows developed in day-to-day Codex use:

- [ponytail](./development-and-review/ponytail): choose the smallest implementation that meets the request, reuse native tools, and verify the result.
- [ponytail-review](./development-and-review/ponytail-review): review a diff for unnecessary complexity and name concrete replacements.
- [ponytail-audit](./development-and-review/ponytail-audit): rank repository-wide simplification opportunities without applying changes.
- [orchestrate](./development-and-review/orchestrate): delegate substantial independent work with explicit ownership; keep integration and verification with the primary agent. Adapt model choices to your available runtime.
- [init](./planning-and-design/init): create compact, evidence-based AGENTS.md guidance from the repository's actual commands and conventions.
- [push](./development-and-review/push): reuse completed checks, document changes, and commit or deploy only when explicitly requested.

Copy a selected skill folder into your Codex skills directory and invoke it by name. Review instructions before use; some older integration skills require tools or credentials specific to your environment. This repository does not currently declare a blanket license; check individual files for their terms.


The library is organized by operational capability categories:

## Repository Structure

### 1. [Planning & Design](./planning-and-design)
Aesthetic styling pre-flight checks, screenshot-grounded UI pattern research, requirement specification planners, marketing screenshot canvas editor, and canonical Edward Tufte visualization guidelines.
- [plan](./planning-and-design/plan)
- [init](./planning-and-design/init)
- [designer](./planning-and-design/designer)
- [design-taste-frontend](./planning-and-design/design-taste-frontend)
- [lazyweb-design](./planning-and-design/lazyweb-design)
- [app-store-screenshots](./planning-and-design/app-store-screenshots)
- [tufte](./planning-and-design/tufte)

### 2. [Development & Review](./development-and-review)
Context-preserving session logging, pre-push verification checks, and multi-language code review guidelines.
- [historian](./development-and-review/historian)
- [push](./development-and-review/push)
- [reviewer](./development-and-review/reviewer)

### 3. [Testing & QA](./testing-and-qa)
Headless browser testing pipelines, user interface visual regression audits, and background desktop OS GUI automation.
- [playwright-cli](./testing-and-qa/playwright-cli)
- [ui-tester](./testing-and-qa/ui-tester)
- [computer-use](./testing-and-qa/computer-use)

### 4. [Infrastructure & Ops](./infrastructure-and-ops)
Automated cloud VPS deployments, Hostinger domain/DNS configurations, remote headless PC connections, and local LLM fine-tuning/serving.
- [vps](./infrastructure-and-ops/vps)
- [hostinger](./infrastructure-and-ops/hostinger)
- [local-pc](./infrastructure-and-ops/local-pc)
- [local-model](./infrastructure-and-ops/local-model)

### 5. [Household Ops](./household-ops)
Google Workspace productivity automation and personal biometrics/health API synchronization.
- [gog](./household-ops/gog)
- [ghealth](./household-ops/ghealth)
- [hermes-chat](./household-ops/hermes-chat)
