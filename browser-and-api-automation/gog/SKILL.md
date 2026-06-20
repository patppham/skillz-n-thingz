---
name: gog
description: Google CLI for managing Gmail, Drive, Calendar, Sheets, Search Console, etc.
---

# Google CLI (gog) Skill

This skill allows the agent to interact with Google Account services (Gmail, Calendar, Drive, Sheets, Docs, Search Console, etc.) via the authenticated `gog` CLI tool.

## Configuration & Status

*   **Config Location:** `~/Library/Application Support/gogcli/config.json`
*   **Credentials Location:** `~/Library/Application Support/gogcli/credentials.json`
*   **Default Account:** `your-email@gmail.com`

To check the authentication and configuration status:
```bash
gog status
```

---

## Common Commands & Usage Examples

For most operations, you must specify the account email using the `-a` or `--account` flag (e.g., `-a your-email@gmail.com`).

### 1. Gmail Operations

#### Search messages / threads:
Uses standard Gmail query syntax:
```bash
gog -a your-email@gmail.com gmail search 'subject:"Test 2"'
gog -a your-email@gmail.com gmail search 'from:mailer-daemon'
```

#### Get thread details:
Retrieves all messages in a specific thread:
```bash
gog -a your-email@gmail.com gmail thread get <threadId>
```

#### Get message details (parsed format):
```bash
gog -a your-email@gmail.com gmail get <messageId>
```

#### Get message details (raw JSON / lossless headers):
Best for scripts or LLM analysis (includes MIME parts and base64 payloads):
```bash
gog -a your-email@gmail.com gmail raw <messageId>
```

#### Send an email:
```bash
gog -a your-email@gmail.com gmail send --to="recipient@example.com" --subject="Subject Line" --body="Email body content"
```

---

### 2. Google Drive Operations

#### List files (default directory):
```bash
gog ls
```

#### Search files:
```bash
gog search "filename"
```

#### Download a file:
```bash
gog download <fileId> --out="path/to/save"
```

#### Upload a file:
```bash
gog upload "path/to/local/file"
```

---

### 3. Google Sheets Operations

#### Read sheet range:
```bash
gog sheets read <spreadsheetId> <range>
```

---

## Command Flags

*   `-j, --json` — Output results in JSON format (ideal for programmatic parsing).
*   `-p, --plain` — Output stable, tab-separated parseable text.
*   `-v, --verbose` — Enable verbose logging for debugging API requests.
*   `-n, --dry-run` — Print the action that would be taken without modifying any remote data.
