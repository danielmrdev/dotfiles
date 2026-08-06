#!/bin/bash

icon=$(omarchy-weather-icon 2>/dev/null)

if [[ -n $icon ]]; then
  temp=$(curl -fsS --max-time 3 "https://wttr.in?format=%t" 2>/dev/null)
  if [[ -n $temp && $temp =~ ^[+-]?[0-9]+°C$ ]]; then
    icon=$(printf '%s' "$icon" | sed 's/["\\]/\\&/g')
    printf '{"text":"%s %s"}\n' "$icon" "$temp"
  else
    icon=$(printf '%s' "$icon" | sed 's/["\\]/\\&/g')
    printf '{"text":"%s"}\n' "$icon"
  fi
else
  printf '{"text":"","class":"unavailable"}\n'
fi
