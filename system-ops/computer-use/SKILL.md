---
name: computer-use
description: Drive the macOS desktop in the background without stealing keyboard focus, the cursor, or Space.
---

# macOS Background Computer Use

You have access to a background desktop automation helper via the command-line bridge script `computer_use.py`. 
Your actions do **NOT** move the user's cursor, steal active keyboard focus, or switch Spaces. The user can keep typing in their editor while you interact with another app in the background.

## Running actions

To run any action, execute:
```bash
python3 /path/to/computer_use.py '<JSON>'
```

---

## Canonical Workflow

To ensure the user has full visibility of the agent's actions, **always use a visual cursor session** for your workflow.

### Step 1 — Start the Session
Start by initiating a session. This creates a visual "Agent Cursor" overlay that glides across the screen to show the user what you are doing in real time:
```bash
python3 /path/to/computer_use.py '{"action": "start_session", "session": "my-session-id"}'
```

### Step 2 — Capture/Focus target app
Capture the target app window you want to work on. This initializes the session state (`active_pid`, `active_window_id`, `last_app`):
```bash
python3 /path/to/computer_use.py '{"action": "capture", "mode": "som", "app": "Safari"}'
```
*   `mode`: Use `"som"` (Segment-of-Model) to get a screenshot with numbered overlays + AX-tree index. Use `"vision"` for raw screenshots. Use `"ax"` for text-only accessibility trees.
*   `app`: Limit focus to a specific app name (e.g. `"Safari"`, `"Notes"`, `"Slack"`).

The response returns the screen layout and logs elements like:
`  #7 AXLink 'Sign In' @ (900, 420, 80, 24)`
It also saves the screenshot to `/path/to/last_capture.png`. You must use vision capability on this file if you need to inspect visual elements.

### Step 3 — Action targeting element indices with session ID
Perform actions targeting element numbers (`element: N`) rather than raw coordinates. You must pass your `"session"` ID to ensure visual cursor feedback is drawn:
```bash
python3 /path/to/computer_use.py '{"action": "click", "element": 7, "session": "my-session-id"}'
```

### Step 4 — End the session
When you are done with the task, clean up the cursor overlay by ending the session:
```bash
python3 /path/to/computer_use.py '{"action": "end_session", "session": "my-session-id"}'
```

---

## Tool Reference

### Capture Layout
```bash
python3 /path/to/computer_use.py '{"action": "capture", "mode": "som", "app": "Slack"}'
```

### Pointer Actions (Click/Drag/Scroll)
```bash
# Click on element 12
python3 /path/to/computer_use.py '{"action": "click", "element": 12}'

# Double click
python3 /path/to/computer_use.py '{"action": "double_click", "element": 12}'

# Click with modifier
python3 /path/to/computer_use.py '{"action": "click", "element": 12, "modifiers": ["cmd"]}'

# Drag
python3 /path/to/computer_use.py '{"action": "drag", "from_element": 3, "to_element": 8}'

# Scroll
python3 /path/to/computer_use.py '{"action": "scroll", "direction": "down", "amount": 5, "element": 2}'
```

### Keyboard Actions (Type/Key Shortcuts)
To ensure actions do **NOT** take over the user's active keyboard focus, always pass `"element"` when using `type` or `key` actions whenever possible. This routes the input directly to the target element's AX text value buffer rather than posting global keystrokes.
```bash
# Type text directly into element index 15 in the background
python3 /path/to/computer_use.py '{"action": "type", "element": 15, "text": "Hello world"}'

# Trigger keyboard shortcut (e.g. Return key on element index 21 in the background)
python3 /path/to/computer_use.py '{"action": "key", "element": 21, "keys": "return"}'

# Global shortcut (app-level hotkey)
python3 /path/to/computer_use.py '{"action": "key", "keys": "cmd+s"}'
```

### Dropdowns and Form Controls
```bash
# Set value on AXPopUpButton (select dropdowns) directly
python3 /path/to/computer_use.py '{"action": "set_value", "element": 15, "value": "Blue"}'
```

### Session management & Wait
If you want to enable the visual "Agent Cursor" overlay that glides across the screen (independent of the user's cursor), always specify `"session"` (e.g. `"session": "my-run-1"`) in your actions. The cursor overlay will appear on the first action. When done, call `end_session` to remove it.
```bash
# Start a color-coded visual cursor session
python3 /path/to/computer_use.py '{"action": "start_session", "session": "agent-run-1"}'

# Move the agent visual cursor overlay to coordinates (100, 200) without moving the user's mouse
python3 /path/to/computer_use.py '{"action": "move_cursor", "session": "agent-run-1", "x": 100, "y": 200}'

# Perform an action tied to the session (enables visual cursor glide/feedback)
python3 /path/to/computer_use.py '{"action": "click", "element": 9, "session": "agent-run-1"}'

# End the session and clean up the cursor
python3 /path/to/computer_use.py '{"action": "end_session", "session": "agent-run-1"}'

# Focus app window context without raising window
python3 /path/to/computer_use.py '{"action": "focus_app", "app": "Safari"}'

# List active app names
python3 /path/to/computer_use.py '{"action": "list_apps"}'

# Wait
python3 /path/to/computer_use.py '{"action": "wait", "seconds": 2}'
```

---

## Critical Rules

1.  **Always Use a Session ID (Visual Cursor Overlay):**
    *   **Do not execute actions in silence.** Always start by invoking `{"action": "start_session", "session": "unique-id"}` and pass `"session": "unique-id"` to all subsequent clicks, typing, scroll, and key actions.
    *   End your task by calling `{"action": "end_session", "session": "unique-id"}`.
    *   To show a smooth gliding mouse cursor (resembling real user interaction), calculate the target element's center coordinates from the accessibility tree, call `move_cursor` first, and then perform the click/type action.
2.  **Strict Background Execution (No Screen Takeover & Focus Theft):**
    *   **Always prefer element-based actions** (passing `"element"`) over coordinate-based actions (`"coordinate"` or `"x, y"`). Coordinate-based clicks/drags simulate physical mouse movement and *will* move your cursor.
    *   **Always prefer element-targeted typing** (passing `"element"` with `"type"` or `"key"`) to interact with input elements. Sending free untargeted key/text actions relies on active window focus and may intercept typing if the user is actively working.
    *   **Prevent Focus Theft**: Do not call `bring_to_front` or run window-activation commands (like AppleScript `activate`) unless absolutely needed for apps that reject background access. Always use background-safe flags like `open -g <app_path>` or `launch_app` (which preserve active window focus) to launch applications. Never steal focus from the user's active application.
3.  **Verify UI state shifts:** After sending clicking/typing actions, run `capture` again (or pass `"capture_after": true` in the action JSON) to retrieve the updated elements overlay.
4.  **Safety blocks:** Keyboard shortcuts that force log out, lock the system, or execute destructive commands (e.g. `sudo rm -rf`) are strictly blocked at the runner level.
5.  **Security boundaries:** Never type API keys, passwords, or credit card numbers using this tool.
