---
name: init
description: Use when the user invokes /init or asks to create or update a repository AGENTS.md with compact, verified, high-signal guidance for future agent sessions.
---

# /init

Create or update `AGENTS.md` for the current repository. The result should help future OpenCode or Codex sessions avoid mistakes and ramp up quickly. Every line should pass this test: "Would an agent likely miss this without help?" If not, leave it out.

Treat any user-provided invocation text as focus or constraints and honor it.

## Investigate

Read the highest-value sources first:

- `README*`, root manifests, workspace config, lockfiles
- build, test, lint, formatter, typecheck, and codegen config
- CI workflows and pre-commit or task runner config
- existing instruction files such as `AGENTS.md`, `CLAUDE.md`, `.cursor/rules/`, `.cursorrules`, `.github/copilot-instructions.md`
- repo-local OpenCode config such as `opencode.json`

If architecture is still unclear after config and docs, inspect a small number of representative code files. Prefer wiring, entrypoint, package-boundary, and execution-flow files over random leaf files.

Prefer executable sources of truth over prose. If docs conflict with config or scripts, trust the executable source and only keep what you can verify.

## Extract

Capture only the highest-signal facts for an agent working in this repo:

- exact developer commands, especially non-obvious ones
- how to run one test, one package, or a focused verification step
- required command order when it matters, such as `lint -> typecheck -> test`
- monorepo or multi-package boundaries, ownership of major directories, and real app or library entrypoints
- framework or toolchain quirks: generated code, migrations, codegen, build artifacts, special env loading, dev servers, infra deploy flow
- repo-specific style or workflow conventions that differ from defaults
- testing quirks: fixtures, integration prerequisites, snapshot workflows, required services, flaky or expensive suites
- important constraints from existing instruction files worth preserving

Good `AGENTS.md` content is usually hard-earned context inferred from multiple files.

## Questions

Ask the user only if the repo cannot answer something important. Ask one short batch at most, using the available question/input tool if present; otherwise ask directly.

Good questions include undocumented team conventions, branch/PR/release expectations, or missing setup/test prerequisites that are known but not written down.

Do not ask about anything the repo already makes clear.

## Write

Include only high-signal, repo-specific guidance:

- exact commands and shortcuts an agent would otherwise guess wrong
- architecture notes that are not obvious from filenames
- conventions that differ from language or framework defaults
- setup requirements, environment quirks, and operational gotchas
- references to existing instruction sources that matter

Exclude:

- generic software advice
- long tutorials or exhaustive file trees
- obvious language conventions
- speculative claims or anything unverified
- content better stored in another file referenced through `opencode.json` `instructions`

Prefer short sections and bullets. If the repo is simple, keep the file simple. If the repo is large, summarize only the few structural facts that change how an agent should work.

If `AGENTS.md` already exists at the target path, improve it in place. Preserve verified useful guidance, delete fluff or stale claims, and reconcile it with the current codebase.

## Verify

Before finishing:

- reread `AGENTS.md` and remove any line that fails the "agent would miss this" test
- confirm each command, path, and constraint is sourced from the repo or clearly user-provided
- run the narrowest useful validation available for the edit, such as markdown lint if configured, or state that no validation applies
