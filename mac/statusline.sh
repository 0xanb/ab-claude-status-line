#!/bin/bash
# Claude Code status line for macOS (bash 3.2 or later).
# Shows: folder | model | effort | context pie + % | 5-hour limit % + bar + pace marker -> reset
# Usage numbers come from Claude Code itself (the rate_limits field it sends to the
# status line), so no separate usage app is needed. Needs jq, which is built into
# macOS 15 and later. See README.md for setup, previews of every preset, and all options.

# ---- Preset: pick a starting layout ----
#   classic    Me │ Opus 5.5 │ high │ C: ◔ 30% │ L: 23% ▓▓░░┃░░░░░ → 6:30 PM
#   countdown  Me │ Opus 5.5 │ high │ ◔ 30% │ 23% ▓▓░░┃░░░░░ → ⧗ 2h 15m (6:30 PM)
#   minimal    ◔ 30% │ 23% ▓▓░░┃░░░░░ → ⧗ 2h 15m
#   full       classic plus git branch, effort label, countdown and the weekly limit
#   plain      no bar, pie or hourglass, for fonts that show them as boxes
PRESET="classic"

# ---- Your changes: uncomment a line to override the preset ----
my_options() {
  : # keep this line
  # SHOW_DIRECTORY=1          # folder name
  # SHOW_BRANCH=1             # git branch
  # SHOW_MODEL=1              # model name
  # SHOW_EFFORT=1             # reasoning effort: low, medium, high, xhigh or max
  # SHOW_CONTEXT=1            # context window %
  # SHOW_CONTEXT_ICON=1       # pie clock that fills with the context %
  # SHOW_LIMIT=1              # 5-hour usage limit
  # SHOW_WEEKLY=1             # 7-day usage limit
  # SHOW_BAR=1                # progress bars
  # SHOW_PACE=1               # marker showing how far through the window you are
  # SHOW_RESET=1              # when the limit resets
  # RESET_STYLE="both"        # "time" → 6:30 PM, "countdown" → ⧗ 2h 15m, "both" → ⧗ 2h 15m (6:30 PM)
  # COUNTDOWN_ICON="⧗"        # or "⧖", "↻", or "" for none
  # USE_24_HOUR=1             # 18:30 instead of 6:30 PM
  # LIMIT_STEPS=(50 75 90)    # limit % where the color turns yellow, orange, red
  # CONTEXT_STEPS=(50 70 80)  # context % where the color turns yellow, orange, red
  # SHOW_EFFORT_LABEL=1       # "Effort: high"
  # SHOW_CONTEXT_LABEL=0      # "C: 30%"
  # SHOW_LIMIT_LABEL=0        # "L: 23%"
  # SHOW_WEEKLY_LABEL=0       # "Weekly: 41%"
  # SHOW_RESET_LABEL=1        # "→ Reset: 6:30 PM" or "→ ⧗ Reset in 2h 15m" on the 5-hour limit
}

# ---- Presets: classic is the base, the others change a few options from it ----
apply_preset() {
  SHOW_DIRECTORY=1; SHOW_BRANCH=0; SHOW_MODEL=1; SHOW_EFFORT=1
  SHOW_CONTEXT=1; SHOW_CONTEXT_ICON=1; SHOW_LIMIT=1; SHOW_WEEKLY=0
  SHOW_BAR=1; SHOW_PACE=1; SHOW_RESET=1
  RESET_STYLE="time"; COUNTDOWN_ICON="⧗"; USE_24_HOUR=0
  LIMIT_STEPS=(50 75 90); CONTEXT_STEPS=(50 70 80)
  SHOW_EFFORT_LABEL=0; SHOW_CONTEXT_LABEL=1; SHOW_LIMIT_LABEL=1; SHOW_WEEKLY_LABEL=1; SHOW_RESET_LABEL=0

  # Preset names work in any case: "Full" is the same as "full"
  case "$(printf '%s' "$PRESET" | tr '[:upper:]' '[:lower:]')" in
    countdown)
      RESET_STYLE="both"; SHOW_CONTEXT_LABEL=0; SHOW_LIMIT_LABEL=0 ;;
    minimal)
      SHOW_DIRECTORY=0; SHOW_MODEL=0; SHOW_EFFORT=0; RESET_STYLE="countdown"
      SHOW_CONTEXT_LABEL=0; SHOW_LIMIT_LABEL=0 ;;
    full)
      SHOW_BRANCH=1; SHOW_WEEKLY=1; SHOW_EFFORT_LABEL=1; RESET_STYLE="both" ;;
    plain)
      SHOW_CONTEXT_ICON=0; SHOW_BAR=0; COUNTDOWN_ICON=""; RESET_STYLE="both" ;;
  esac
}
apply_preset
my_options

# A steps list needs exactly three numbers; fall back to the defaults otherwise
[ "${#LIMIT_STEPS[@]}" -eq 3 ] || LIMIT_STEPS=(50 75 90)
[ "${#CONTEXT_STEPS[@]}" -eq 3 ] || CONTEXT_STEPS=(50 70 80)

# ---- Symbols and colors ----
ESC=$'\033'
C_RESET="${ESC}[0m"
C_BLUE="${ESC}[0;34m"
C_GREEN="${ESC}[0;32m"
C_GRAY="${ESC}[0;90m"
C_YELLOW="${ESC}[0;33m"
C_CYAN="${ESC}[0;36m"
C_MAGENTA="${ESC}[0;35m"

# Step colors for the limit and context percentages
C_OK="${ESC}[38;5;34m"       # green
C_AMBER="${ESC}[38;5;178m"   # yellow
C_ORANGE="${ESC}[38;5;208m"
C_RED="${ESC}[38;5;160m"

# Pace tiers: comfortable, on track, warming, pressing, critical, runaway
PACE=("${ESC}[38;5;34m" "${ESC}[38;5;37m" "${ESC}[38;5;178m" "${ESC}[38;5;208m" "${ESC}[38;5;160m" "${ESC}[38;5;135m")

# Pie clock: empty, quarter, half, three quarters, full circle
PIE=("○" "◔" "◑" "◕" "●")

# $2 below the first step, then yellow, orange and red from each step ($3 $4 $5) on
step_color() {
  if [ "$1" -ge "$5" ]; then printf '%s' "$C_RED"
  elif [ "$1" -ge "$4" ]; then printf '%s' "$C_ORANGE"
  elif [ "$1" -ge "$3" ]; then printf '%s' "$C_AMBER"
  else printf '%s' "$2"
  fi
}

# $1 is the usage % you would reach by the reset if you keep the current pace
pace_color() {
  if [ "$1" -lt 50 ]; then printf '%s' "${PACE[0]}"
  elif [ "$1" -lt 75 ]; then printf '%s' "${PACE[1]}"
  elif [ "$1" -lt 90 ]; then printf '%s' "${PACE[2]}"
  elif [ "$1" -lt 100 ]; then printf '%s' "${PACE[3]}"
  elif [ "$1" -lt 120 ]; then printf '%s' "${PACE[4]}"
  else printf '%s' "${PACE[5]}"
  fi
}

# Local time of epoch $1 in date format $2. 12-hour times drop the leading zero: "6:30 PM", "Sun 6:30 PM"
format_clock() {
  local epoch=$1 seconds=$(( $1 % 60 )) clock
  # Round to the nearest minute so the time doesn't flicker (6:59:45 -> 7:00)
  if [ "$seconds" -ge 30 ]; then epoch=$(( epoch + 60 - seconds )); else epoch=$(( epoch - seconds )); fi
  # LC_ALL=C keeps AM/PM in English whatever the system language.
  # date -r is macOS/BSD; date -d is Linux/GNU.
  clock=$(LC_ALL=C date -r "$epoch" "+$2" 2> /dev/null || LC_ALL=C date -d "@$epoch" "+$2" 2> /dev/null)
  if [ "$USE_24_HOUR" != 1 ]; then clock=${clock#0}; clock=${clock/ 0/ }; fi
  printf '%s' "$clock"
}

# Time left until $1: "3d 4h", "2h 15m", "45m", or "<1m" in the last minute
format_countdown() {
  local remaining=$(( $1 - $(date +%s) ))
  if [ "$remaining" -lt 60 ]; then printf '<1m'; return; fi
  local minutes=$(( remaining / 60 ))
  local days=$(( minutes / 1440 )) hours=$(( minutes % 1440 / 60 )) mins=$(( minutes % 60 ))
  if [ "$days" -gt 0 ]; then printf '%dd %dh' "$days" "$hours"
  elif [ "$hours" -gt 0 ]; then printf '%dh %dm' "$hours" "$mins"
  else printf '%dm' "$mins"
  fi
}

# Renders one rate-limit window: "23% <bar with pace marker> → 6:30 PM" (or "→ ⧗ 2h 15m (6:30 PM)")
# Args: percent, reset epoch, window seconds, min seconds before pace colors, label, time format, reset label
format_window() {
  local pct=$1 reset=$2 window=$3 min_elapsed=$4 label=$5 time_format=$6 reset_label=$7
  [ -z "$pct" ] && return
  # A window whose reset time has passed is stale; Claude Code drops these too
  [ -n "$reset" ] && [ "$reset" -le "$(date +%s)" ] && return
  [ "$pct" -lt 0 ] && pct=0
  [ "$pct" -gt 100 ] && pct=100

  local color
  color=$(step_color "$pct" "$C_OK" "${LIMIT_STEPS[@]}")

  local bar=""
  if [ "$SHOW_BAR" = 1 ]; then
    local filled=$(( (pct * 10 + 50) / 100 )) marker=-1 pace="$color"
    if [ "$SHOW_PACE" = 1 ] && [ -n "$reset" ]; then
      local remaining=$(( reset - $(date +%s) ))
      if [ "$remaining" -gt 0 ] && [ "$remaining" -lt "$window" ]; then
        local elapsed=$(( window - remaining ))
        marker=$(( (elapsed * 10 + window / 2) / window ))
        [ "$marker" -gt 9 ] && marker=9
        # Too early in the window to project a meaningful pace
        if [ "$elapsed" -ge "$min_elapsed" ]; then
          pace=$(pace_color $(( pct * window / elapsed )))
        fi
      fi
    fi

    bar=" "
    local i=0
    while [ "$i" -lt 10 ]; do
      if [ "$i" -eq "$marker" ]; then bar="${bar}${pace}┃${C_RESET}${color}"
      elif [ "$i" -lt "$filled" ]; then bar="${bar}▓"
      else bar="${bar}░"
      fi
      i=$(( i + 1 ))
    done
  fi

  local reset_text=""
  if [ "$SHOW_RESET" = 1 ] && [ -n "$reset" ]; then
    local icon="" countdown_label=""
    [ -n "$COUNTDOWN_ICON" ] && icon="${COUNTDOWN_ICON} "
    # "Reset: 6:30 PM" but "Reset in 2h 15m"
    [ -n "$reset_label" ] && countdown_label="Reset in "
    case "$RESET_STYLE" in
      countdown) reset_text=" → ${icon}${countdown_label}$(format_countdown "$reset")" ;;
      both)      reset_text=" → ${icon}${countdown_label}$(format_countdown "$reset") ($(format_clock "$reset" "$time_format"))" ;;
      *)         reset_text=" → ${reset_label}$(format_clock "$reset" "$time_format")" ;;
    esac
  fi

  printf '%s' "${color}${label}${pct}%${bar}${reset_text}${C_RESET}"
}

input=$(cat)

if ! command -v jq > /dev/null 2>&1; then
  printf '%s\n' "${C_YELLOW}statusline: jq not found (brew install jq, or sudo apt install jq)${C_RESET}"
  exit 0
fi

# One jq call pulls every field, one per line. Missing fields become empty lines.
# Percentages arrive as whole numbers: limits rounded, context rounded down.
# Each field is wrapped in try, so one unexpected value can't shift the others.
fields=$(printf '%s' "$input" | jq -r '
  def whole: if type == "number" then floor | tostring else "" end;
  def rounded: if type == "number" then . + 0.5 | floor | tostring else "" end;
  def text: if type == "string" then gsub("[\n\r]"; " ") else "" end;
  (try (.workspace.current_dir // .cwd) catch null | text),
  (try .model.display_name catch null | text),
  (try .effort.level catch null | text),
  (try ( .context_window as $c
    | ($c.used_percentage
       // (if ($c.context_window_size // 0) > 0
           then ((($c.current_usage.input_tokens // 0)
                + ($c.current_usage.cache_creation_input_tokens // 0)
                + ($c.current_usage.cache_read_input_tokens // 0)) * 100 / $c.context_window_size)
           else null end)) ) catch null | whole),
  (try .rate_limits.five_hour.used_percentage catch null | rounded),
  (try .rate_limits.five_hour.resets_at catch null | whole),
  (try .rate_limits.seven_day.used_percentage catch null | rounded),
  (try .rate_limits.seven_day.resets_at catch null | whole)
' 2> /dev/null)

{
  IFS= read -r dir_path
  IFS= read -r model
  IFS= read -r effort
  IFS= read -r ctx
  IFS= read -r limit_pct
  IFS= read -r limit_reset
  IFS= read -r week_pct
  IFS= read -r week_reset
} <<< "$fields"

parts=()

if [ "$SHOW_DIRECTORY" = 1 ] && [ -n "$dir_path" ]; then
  dir_name=${dir_path%/}
  dir_name=${dir_name##*/}
  # Empty at the root folder "/"
  [ -n "$dir_name" ] && parts+=("${C_BLUE}${dir_name}${C_RESET}")
fi

if [ "$SHOW_BRANCH" = 1 ] && [ -n "$dir_path" ]; then
  branch=$(git -C "$dir_path" branch --show-current 2> /dev/null)
  [ -n "$branch" ] && parts+=("${C_GREEN}⎇ ${branch}${C_RESET}")
fi

if [ "$SHOW_MODEL" = 1 ] && [ -n "$model" ]; then
  parts+=("${C_YELLOW}${model}${C_RESET}")
fi

# Claude Code leaves effort out when the current model doesn't support it
if [ "$SHOW_EFFORT" = 1 ] && [ -n "$effort" ]; then
  label=""
  [ "$SHOW_EFFORT_LABEL" = 1 ] && label="Effort: "
  parts+=("${C_MAGENTA}${label}${effort}${C_RESET}")
fi

if [ "$SHOW_CONTEXT" = 1 ] && [ -n "$ctx" ]; then
  ctx_color=$(step_color "$ctx" "$C_CYAN" "${CONTEXT_STEPS[@]}")
  label=""
  [ "$SHOW_CONTEXT_LABEL" = 1 ] && label="C: "
  icon=""
  if [ "$SHOW_CONTEXT_ICON" = 1 ]; then
    # Nearest quarter, so 30% shows a quarter pie and 90% a full one
    quarter=$(( (ctx * 2 + 25) / 50 ))
    [ "$quarter" -lt 0 ] && quarter=0
    [ "$quarter" -gt 4 ] && quarter=4
    icon="${PIE[$quarter]} "
  fi
  parts+=("${ctx_color}${label}${icon}${ctx}%${C_RESET}")
fi

time_format="%I:%M %p"
[ "$USE_24_HOUR" = 1 ] && time_format="%H:%M"

if [ "$SHOW_LIMIT" = 1 ]; then
  label=""
  reset_label=""
  [ "$SHOW_LIMIT_LABEL" = 1 ] && label="L: "
  [ "$SHOW_RESET_LABEL" = 1 ] && reset_label="Reset: "
  text=$(format_window "$limit_pct" "$limit_reset" 18000 540 "$label" "$time_format" "$reset_label")
  # Claude Code only sends usage after the first reply in a session
  [ -z "$text" ] && text="${C_YELLOW}${label}~${C_RESET}"
  parts+=("$text")
fi

if [ "$SHOW_WEEKLY" = 1 ]; then
  label=""
  [ "$SHOW_WEEKLY_LABEL" = 1 ] && label="Weekly: "
  text=$(format_window "$week_pct" "$week_reset" 604800 3024 "$label" "%a $time_format" "")
  [ -n "$text" ] && parts+=("$text")
fi

output=""
for part in "${parts[@]}"; do
  [ -n "$output" ] && output="${output}${C_GRAY} │ ${C_RESET}"
  output="${output}${part}"
done

printf '%s\n' "$output"
