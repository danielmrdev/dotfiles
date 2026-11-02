#!/usr/bin/env python3
import json
import os
import re
import subprocess
import tempfile
from pathlib import Path

APP_HOME = Path(os.environ.get("HERDR_APP_HOME", Path.home() / ".config/herdr-app"))
HEX_COLOR = re.compile(r"^#[0-9a-fA-F]{6}$")


def read_palette():
    result = subprocess.run(
        ["omarchy-theme-color", "--all"],
        check=True,
        capture_output=True,
        text=True,
    )
    palette = {}
    for line in result.stdout.splitlines():
        if "\t" in line:
            key, value = line.split("\t", 1)
            palette[key] = value
    return palette


def color(palette, key, fallback=None):
    value = palette.get(key, fallback)
    if not value or not HEX_COLOR.fullmatch(value):
        raise ValueError(f"Missing or invalid Omarchy color: {key}")
    return value


def write_json(path, data):
    temporary = None
    try:
        with tempfile.NamedTemporaryFile(
            mode="w",
            encoding="utf-8",
            dir=path.parent,
            prefix=f".{path.name}.",
            suffix=".tmp",
            delete=False,
        ) as file:
            temporary = Path(file.name)
            json.dump(data, file, indent=2)
            file.write("\n")
        os.replace(temporary, path)
    finally:
        if temporary and temporary.exists():
            temporary.unlink()


def main():
    palette = read_palette()
    mode = palette.get("mode")
    if mode not in {"light", "dark"}:
        raise ValueError(f"Invalid Omarchy appearance: {mode!r}")

    foreground = color(palette, "foreground")
    theme = {
        "background": color(palette, "background"),
        "foreground": foreground,
        "selection": color(palette, "selection"),
        "cursor": color(palette, "cursor", foreground),
        "ansi": [color(palette, f"color{index}") for index in range(16)],
        "colors": {
            "accent": color(palette, "accent", palette.get("color4")),
        },
    }

    settings_path = APP_HOME / "settings.json"
    settings = {}
    if settings_path.exists():
        settings = json.loads(settings_path.read_text(encoding="utf-8"))
    settings["theme"] = "omarchy"
    settings["appearance"] = mode

    themes_path = APP_HOME / "themes"
    themes_path.mkdir(parents=True, exist_ok=True)
    write_json(themes_path / "omarchy.json", theme)
    write_json(settings_path, settings)


if __name__ == "__main__":
    try:
        main()
    except (OSError, ValueError, subprocess.CalledProcessError, json.JSONDecodeError) as error:
        raise SystemExit(f"Could not sync Omarchy theme to Herdr: {error}")
