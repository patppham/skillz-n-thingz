---
name: lazyweb-design
description: Design research using Lazyweb's 257k+ app screenshot database. Search, compare, and find similar designs for grounded UI recommendations.
---

# Lazyweb Design Research

## Tool Reference

### lazyweb_health

Check MCP server connectivity.

```json
{}
```

Returns: `{ "status": "ok", "screenshot_count": N }`

### lazyweb_search

Search app screenshots by query, category, platform, or component.

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `query` | string | Yes | Natural language search. e.g. "pricing page", "onboarding flow", "dark dashboard" |
| `category` | string | No | App category: "saas", "e-commerce", "fintech", "health", "social", "productivity", "education", etc. |
| `platform` | string | No | "mobile", "desktop", "tablet" |
| `component` | string | No | UI component: "navigation", "form", "card", "modal", "table", "chart", "sidebar", etc. |
| `limit` | number | No | Max results (default 10, max 50) |

**Tips:**
- Start broad, then narrow. First query: `"pricing page"`. Second: `"saas pricing page"` + `category: "saas"`.
- Use `component` filter when you need specific UI elements (e.g., `component: "modal"` for overlay patterns).
- Combine `platform` and `component` for targeted results (e.g., `platform: "mobile"` + `component: "navigation"`).

### lazyweb_find_similar

Find apps with screenshots similar to a given screenshot ID.

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `screenshot_id` | string | Yes | ID from a previous `lazyweb_search` result |
| `limit` | number | No | Max results (default 10) |

Use after `lazyweb_search` to expand results with visually similar designs.

### lazyweb_compare_image

Compare an uploaded image against the Lazyweb database to find similar app screenshots.

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `image_path` | string | Yes | Path to the image file to compare |
| `limit` | number | No | Max results (default 10) |

Use when the user provides a screenshot for comparison or improvement.

## Query Construction Guidelines

1. **Component-first**: Start with the component name (`"pricing page"`, `"checkout form"`, `"settings panel"`)
2. **Add qualifiers**: Narrow by platform, category, or style (`"mobile onboarding"`, `"dark dashboard"`, `"minimalist login"`)
3. **Iterate broad→narrow**: If a narrow query returns <3 results, broaden the query or remove one filter
4. **Synonym expansion**: Try alternate terms (`"sign up"` vs `"registration"`, `"cart"` vs `"checkout"`, `"sidebar"` vs `"navigation drawer"`)

## Result Evaluation Heuristics

When reviewing search results, evaluate:

- **Relevance**: Does the screenshot match the requested component/pattern? Prioritize exact matches over tangential ones.
- **Diversity**: Aim for 3-5 distinct design approaches, not 5 variations of the same pattern.
- **Quality signals**: Well-known apps (from established companies) tend to demonstrate battle-tested patterns. Prioritize these as primary references.
- **Platform match**: If the request specifies a platform, deprioritize mismatched results unless they show an interesting adaptation.
- **Recency**: If the search returns metadata with timestamps or version info, prefer recent screenshots that reflect current design trends.

## Design Pattern Vocabulary

Use these standard terms when describing patterns in your report:

| Term | Meaning |
|------|---------|
| Hero section | Large top-of-page banner with CTA |
| Sticky nav | Navigation that remains visible on scroll |
| Card grid | Content laid out in repeated card components |
| Progressive disclosure | Revealing complexity gradually (e.g., "Show more") |
| Floating CTA | Fixed-position call-to-action button |
| Bento grid | Asymmetric grid layout popular in modern dashboards |
| Segmented control | Tab-like toggle between 2-4 views |
| Bottom sheet | Mobile pattern: sliding panel from bottom |
| Stepper | Multi-step progress indicator |
| Empty state | Placeholder content for zero-data views |
| Skeleton screen | Loading placeholder mimicking final layout |

## Output Formatting Rules

- Always cite the **app name** from search results when referencing a pattern
- Never fabricate app names — only reference apps found in Lazyweb results
- Include the **screenshot_id** for key references so others can find them again
- Group recommendations by priority (critical design improvements first)
- When suggesting alternatives, explain *why* the referenced pattern works in that context
