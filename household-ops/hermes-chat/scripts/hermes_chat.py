#!/usr/bin/env python3
import sys
import os
import subprocess
import json
import re

STATE_FILE = os.path.expanduser("~/.hermes/.last_antigravity_session")

def strip_ansi(text):
    ansi_escape = re.compile(r'\x1B(?:[@-Z\\-_]|\[[0-?]*[ -/]*[@-~])')
    return ansi_escape.sub('', text)

def get_last_session():
    if os.path.exists(STATE_FILE):
        try:
            with open(STATE_FILE, 'r') as f:
                data = json.load(f)
                return data.get("session_id")
        except Exception:
            pass
    return None

def save_session(session_id):
    os.makedirs(os.path.dirname(STATE_FILE), exist_ok=True)
    with open(STATE_FILE, 'w') as f:
        json.dump({"session_id": session_id}, f)

def run_hermes_command(args):
    # Ensure standard environment variables are configured correctly
    env = os.environ.copy()
    env["HOME"] = "/Users/patppham"
    env["PATH"] = env.get("PATH", "") + ":/opt/homebrew/bin:/Users/patppham/.local/bin"
    
    # Run the command
    cmd = ["/Users/patppham/.local/bin/hermes"] + args
    result = subprocess.run(cmd, env=env, capture_output=True, text=True)
    return result

def main():
    if len(sys.argv) < 2:
        print("Usage: hermes_chat.py [start|send|status|list] [args]")
        sys.exit(1)
        
    cmd = sys.argv[1]
    
    if cmd == "start":
        query = sys.argv[2] if len(sys.argv) > 2 else "hello"
        res = run_hermes_command(["chat", "-q", query, "-Q"])
        output = strip_ansi(res.stdout + res.stderr)
        print(output)
        
        # Parse session ID from the output
        match = re.search(r"Resume this session with:\s+hermes --resume\s+(\S+)", output)
        if match:
            session_id = match.group(1)
            save_session(session_id)
            print(f"\n[hermes-chat] Tracked active session: {session_id}")
        else:
            match2 = re.search(r"Session:\s+(\S+)", output)
            match3 = re.search(r"session_id:\s*(\S+)", output)
            if match2:
                session_id = match2.group(1)
                save_session(session_id)
                print(f"\n[hermes-chat] Tracked active session: {session_id}")
            elif match3:
                session_id = match3.group(1)
                save_session(session_id)
                print(f"\n[hermes-chat] Tracked active session: {session_id}")
            else:
                print("\n[hermes-chat] Warning: Could not extract session ID from output.")
                
    elif cmd == "send":
        if len(sys.argv) < 3:
            print("Usage: hermes_chat.py send \"your query\"")
            sys.exit(1)
        query = sys.argv[2]
        session_id = get_last_session()
        if not session_id:
            print("[hermes-chat] No active session found. Please run 'start' first.")
            sys.exit(1)
            
        res = run_hermes_command(["chat", "--resume", session_id, "-q", query, "-Q"])
        output = strip_ansi(res.stdout + res.stderr)
        print(output)
        
    elif cmd == "status":
        session_id = get_last_session()
        if session_id:
            print(f"[hermes-chat] Tracked active session ID: {session_id}")
        else:
            print("[hermes-chat] No tracked session. Run 'start' to begin.")
            
    elif cmd == "list":
        res = run_hermes_command(["sessions", "list", "--limit", "10"])
        print(strip_ansi(res.stdout))
        
    else:
        print(f"Unknown command: {cmd}")
        sys.exit(1)

if __name__ == "__main__":
    main()
