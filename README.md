# Agentic Skills Library

A consolidated repository of custom agentic skills, system prompts, and tool configurations. These modules are loaded dynamically across runtime environments to steer AI assistants, automate development operations, and maintain a consistent workspace.

## Repository Structure

The library is organized by operational capability categories:

### 1. [System & Environment Ops](./system-ops)
Automated setups for cloud VPS deployments, secure Tailscale network tunnels, local port forwarding, and desktop/server control.
- [vps](./system-ops/vps)
- [hostinger](./system-ops/hostinger)
- [local-pc](./system-ops/local-pc)
- [local-model](./system-ops/local-model)
- [computer-use](./system-ops/computer-use)

### 2. [Browser & API Automation](./browser-and-api-automation)
Scripted browser testing pipelines, user interface regression audits, Google Workspace API integrations, and health metric sync.
- [playwright-cli](./browser-and-api-automation/playwright-cli)
- [ui-tester](./browser-and-api-automation/ui-tester)
- [ghealth](./browser-and-api-automation/ghealth)
- [gog](./browser-and-api-automation/gog)

### 3. [Workspace & State Memory](./workspace-and-state-memory)
Context-preserving system instructions, requirement specification planners, automated pre-push verification gates, and static code review heuristics.
- [historian](./workspace-and-state-memory/historian)
- [plan](./workspace-and-state-memory/plan)
- [push](./workspace-and-state-memory/push)
- [init](./workspace-and-state-memory/init)
- [reviewer](./workspace-and-state-memory/reviewer)

### 4. [Product Design & Visuals](./product-design-and-visuals)
Aesthetic styling pre-flight checks, screenshot-grounded UI pattern research, and high data-density visualization design principles.
- [designer](./product-design-and-visuals/designer)
- [design-taste-frontend](./product-design-and-visuals/design-taste-frontend)
- [lazyweb-design](./product-design-and-visuals/lazyweb-design)
- [tufte-viz](./product-design-and-visuals/tufte-viz)
