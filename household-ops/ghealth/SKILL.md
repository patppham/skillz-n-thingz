---
name: ghealth
description: Setup and query Google Health API v4 using the ghealth CLI and MCP tools.
---

# Google Health CLI & MCP Skill

This skill allows agents to interact with Google Health data using the `ghealth` command-line interface or the registered `ghealth` MCP tools.

## Setup & Credentials

Before calling any Google Health endpoints, configure your OAuth credentials:
```sh
ghealth config set client-id YOUR_CLIENT_ID
ghealth config set client-secret YOUR_CLIENT_SECRET
ghealth auth login
```

Verify your authentication status using:
```sh
ghealth doctor
```
Or via the MCP tool: `ghealth_doctor`

## Common Queries

- **List Heart Rate Variability:**
  Call `ghealth_list_data` with:
  - `type`: `heart-rate-variability`
  - `from`: `2026-06-14T00:00:00Z`
  - `to`: `2026-06-15T00:00:00Z`

- **Daily Steps Rollup:**
  Call `ghealth_get_rollup` with:
  - `mode`: `daily`
  - `type`: `steps`
  - `from`: `2026-06-01`
  - `to`: `2026-06-15`
  - `window_days`: `1`

- **Reconcile Sleep:**
  Call `ghealth_reconcile_data` with:
  - `type`: `sleep`
  - `from`: `2026-06-01T00:00:00Z`
  - `to`: `2026-06-15T00:00:00Z`

- **Raw API Escape Hatch:**
  If you need to access a newly added or unsupported v4 REST endpoint, use `ghealth_raw_api` or run:
  ```sh
  ghealth api GET /v4/users/me/profile
  ```
