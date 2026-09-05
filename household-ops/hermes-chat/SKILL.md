---
name: hermes-chat
description: Start and interact with a persistent Hermes Agent session directly from Antigravity.
---
# Hermes Chat Skill

This skill allows Antigravity to start, track, and continue a persistent Hermes Agent session. Because Hermes normally runs in a terminal PTY or via interactive messaging platforms, this skill provides a stateless-friendly wrapper python script to maintain conversation threads using the Hermes CLI's session-resume capabilities (`--resume` / `-r`).

## How it works

The helper script [hermes_chat.py](file:///Users/patppham/Documents/pats-skills/household-ops/hermes-chat/scripts/hermes_chat.py) wraps the `hermes` CLI:
1. **Starts a new session** and extracts the generated session ID from the output.
2. **Saves the session ID** to a configuration state file `~/.hermes/.last_antigravity_session`.
3. **Resumes the session** for subsequent queries, sending them to the same session ID.

## Commands

Use these commands with `run_command`:

### 1. Start a new session
Start a new conversation thread with Hermes. You can pass an optional initial prompt.
```bash
python3 /Users/patppham/Documents/pats-skills/household-ops/hermes-chat/scripts/hermes_chat.py start "Hello, we are pair programming to configure the local environment."
```

### 2. Send a message to the active session
Continue the active thread by passing your message.
```bash
python3 /Users/patppham/Documents/pats-skills/household-ops/hermes-chat/scripts/hermes_chat.py send "Can you check the current status of the database?"
```

### 3. Check session status
Verify the active tracked session ID:
```bash
python3 /Users/patppham/Documents/pats-skills/household-ops/hermes-chat/scripts/hermes_chat.py status
```

### 4. List recent sessions
List all recent Hermes sessions:
```bash
python3 /Users/patppham/Documents/pats-skills/household-ops/hermes-chat/scripts/hermes_chat.py list
```
