import datetime
import json
import math
import os
from pathlib import Path
import sys
import urllib.request


USAGE_URL = "https://opencode.ai/zen/go/v1/usage"
WINDOWS = {
    "fiveHour": ("rolling", 300),
    "sevenDay": ("weekly", 10080),
    "thirtyDay": ("monthly", 43200),
}


class NoRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, request, file, code, message, headers, new_url):
        return None


def api_key():
    key = os.environ.get("OPENCODE_GO_API_KEY")
    if key:
        return key

    agent_dir = Path(os.environ.get("PI_CODING_AGENT_DIR", Path.home() / ".pi" / "agent"))
    try:
        auth = json.loads((agent_dir / "auth.json").read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        return None

    if not isinstance(auth, dict):
        return None
    credential = auth.get("opencode-go")
    if not isinstance(credential, dict) or credential.get("type") != "api_key":
        return None
    key = credential.get("key")
    if not isinstance(key, str) or not key or key.startswith(("!", "$")):
        return None
    return key


def parse_window(value, duration_mins):
    if not isinstance(value, dict):
        return None
    percent = value.get("percent")
    reset = value.get("resetsAt")
    if isinstance(percent, bool) or not isinstance(percent, (int, float)) or not math.isfinite(percent):
        return None
    if not isinstance(reset, str):
        return None
    try:
        reset_time = datetime.datetime.fromisoformat(reset.replace("Z", "+00:00"))
        if reset_time.tzinfo is None:
            reset_time = reset_time.replace(tzinfo=datetime.timezone.utc)
        resets_at = int(reset_time.timestamp())
    except ValueError:
        return None
    return {
        "usedPercent": max(0, min(100, percent)),
        "windowDurationMins": duration_mins,
        "resetsAt": resets_at,
    }


def main():
    key = api_key()
    if not key:
        raise RuntimeError("OpenCode Go auth unavailable")

    request = urllib.request.Request(
        USAGE_URL,
        headers={"Accept": "application/json", "Authorization": f"Bearer {key}", "User-Agent": ""},
    )
    with urllib.request.build_opener(NoRedirect()).open(request, timeout=10) as response:
        body = json.loads(response.read(65536))

    usage = body.get("usage") if isinstance(body, dict) else None
    windows = usage if isinstance(usage, dict) else {}
    result = {
        name: parse_window(windows.get(api_name), duration_mins)
        for name, (api_name, duration_mins) in WINDOWS.items()
    }
    print(json.dumps(result, separators=(",", ":")))


if __name__ == "__main__":
    try:
        main()
    except Exception:
        sys.exit(1)
