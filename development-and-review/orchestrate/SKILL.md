---
name: orchestrate
description: Selectively coordinate substantial work with Codex subagents while the primary agent remains responsive to the user. Use when explicitly invoked, or automatically only when a large task has at least two substantive, independent, non-overlapping workstreams and delegation offers a clear time or quality benefit. Do not use for routine tasks or marginal parallelism.
---

# Orchestrate

Act as the coordinator. Keep the user-facing conversation, integration decisions, approvals, and final verification in the primary agent.

## Decide Whether to Delegate

When invoked explicitly, follow this workflow. When considering automatic invocation, use it only if all of these are true:

- The overall task is substantial enough that a single local pass would be lengthy or materially less reliable.
- At least two assignments are independently useful and substantial, not merely tiny pieces created to justify parallelism.
- Each assignment has concrete success criteria and distinct ownership.
- The assignments can progress concurrently without continuous coordinator input or likely edit conflicts.
- The expected time, coverage, or quality gain clearly exceeds the extra token and coordination cost.

If the benefit is borderline, stay local. Do not orchestrate routine explanations, ordinary lookups, small edits, standard test runs, or tightly sequential debugging. A task spanning multiple files is not by itself a reason to delegate.

Use available concurrency for genuinely independent lanes, not to manufacture parallelism. Prefer two focused agents over several thin or overlapping assignments.

## Choose the Agent

Use `gpt-5.6-luna` with `reasoning_effort: "max"` and `fork_turns: "none"` for very clear, bounded leaf work. Good Luna assignments include:

- Locating specific files, flows, tests, or evidence.
- Implementing a scoped change with explicit file ownership.
- Adding or updating narrow tests.
- Running a defined validation and summarizing failures.
- Reviewing a bounded diff against stated criteria.
- Mechanical or repetitive changes with an objective completion check.

Keep broad decomposition, ambiguous architecture, cross-cutting tradeoffs, risky decisions, and final synthesis with the primary agent. If an assignment cannot be made crisp, clarify or investigate locally before delegating it.

To select Luna, spawn a default agent with an explicit model override. Model overrides require fresh or limited context, so use `fork_turns: "none"`; do not use a full-history fork.

If Luna is unavailable, continue locally. Use another model only with explicit user approval, and disclose the fallback.

## Write a Complete Assignment

Give every fresh-context agent all task-local facts it needs:

1. Objective and expected deliverable.
2. Exact ownership: files, module, investigation question, or validation surface.
3. Constraints, applicable local guidance, and approval boundaries.
4. Success criteria and the narrowest meaningful validation.
5. Relevant paths, symbols, commands, or artifacts already known.
6. Coordination boundary: do not undo others' edits and adapt to concurrent changes.
7. Leaf boundary: complete the assignment directly and do not spawn subagents.

Use a prompt shaped like:

```text
Complete this assignment directly; do not spawn other agents.

Objective: <one bounded outcome>
Ownership: <specific files or responsibility>
Context: <only the facts needed from the parent task>
Constraints: <guidance, safety, and scope boundaries>
Success: <observable completion criteria>
Validate: <specific check, or explain why none applies>

You are not alone in the codebase. Do not revert others' edits; accommodate concurrent changes. Report changed files, validation results, and any remaining risk.
```

## Coordinate the Work

1. Inspect enough context to define non-overlapping assignments.
2. Tell the user briefly what is being delegated and why.
3. Spawn independent agents promptly; keep one ownership domain per agent.
4. Continue useful coordinator work instead of blocking on agents.
5. Share discoveries directly with an agent when they affect its assignment.
6. Collect results, reconcile conflicts, and inspect all material edits yourself.
7. Run or confirm integrated validation at the coordinator level.
8. Report one unified outcome; do not dump raw agent transcripts on the user.

Do not delegate permission decisions. Subagents inherit no authority beyond the user's request, and fresh-context agents must receive every essential safety or mutation boundary explicitly.

## Recover and Stop

- If an agent is heading out of scope, interrupt it and reassign only the remaining bounded work.
- If two agents overlap, stop one before both mutate the same ownership area.
- If a result is incomplete but useful, integrate it and finish locally when that is cheaper than another handoff.
- Do not keep spawning agents after the critical path becomes sequential.
