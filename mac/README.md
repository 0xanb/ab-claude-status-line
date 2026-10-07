# Claude Code status line for macOS and Linux

**English** | [Tiếng Việt](README.vi.md)

A bash status line for Claude Code that shows your context, your 5-hour usage
limit and when it resets. Pick one of five ready-made layouts, then fine-tune
it yourself or ask Claude Code to change it for you.

```
Me │ Opus 5.5 │ high │ ◔ 30% │ 23% ▓▓░░░░┃░░░ → ⧗ 2h 15m (6:30 PM)
```

| Part | Meaning |
|---|---|
| `Me` | Current folder |
| `Opus 5.5` | Model |
| `high` | Reasoning effort (`low`, `medium`, `high`, `xhigh` or `max`). It updates when you change it with `/effort`, and is hidden for models that don't support effort |
| `◔ 30%` | Context window used, with a pie clock rounded to the nearest quarter: `○` 0–12%, `◔` 13–37%, `◑` 38–62%, `◕` 63–87%, `●` 88% and up. Cyan, then yellow from 50%, orange from 70%, red from 80% |
| `23%` | 5-hour usage limit used. Green, then yellow from 50%, orange from 75%, red from 90% |
| `▓▓░░░░┃░░░` | Limit bar, in the same color as the limit %. The `┃` marker shows how far you are through the 5-hour window. Its color shows your pace: green or teal is fine, yellow or orange means you'll be close, red or purple means you'll hit the limit before the reset |
| `→ ⧗ 2h 15m (6:30 PM)` | When the limit resets: time left and the local clock time. You can show only one of the two (see `RESET_STYLE`) |

No separate app is needed. Claude Code sends your usage to the status line
script directly.

## Requirements

- macOS 15 or later, which includes `jq`. On older macOS, install it with
  `brew install jq`
- Or Linux (including WSL on Windows) with bash and `jq`, for example
  `sudo apt install jq`
- Claude Code, signed in with a Claude Pro or Max account. With an API key the
  limit part shows `~`, because Claude Code only reports usage for subscriptions

## Install

1. Copy `statusline.sh` to your Claude folder:

   ```bash
   cp statusline.sh ~/.claude/statusline.sh
   ```

2. Open `~/.claude/settings.json` and add (or replace) the `statusLine` entry:

   ```json
   {
     "statusLine": {
       "type": "command",
       "command": "bash ~/.claude/statusline.sh",
       "refreshInterval": 60
     }
   }
   ```

   `refreshInterval` reruns the script every 60 seconds, so countdowns keep
   moving while you're idle. Without it the line only redraws when something
   happens in the session.

   If you already have a status line, note down its `command` first so you can
   switch back.

3. Restart Claude Code.

Or let Claude Code do steps 1 and 2: see "Install with Claude Code" in the
[main README](../README.md).

The limit part shows `~` until Claude has replied once in the session. That's
normal, because Claude Code only gets your usage numbers after the first reply.

## Pick a preset

Open `~/.claude/statusline.sh` and set `PRESET` near the top:

```bash
PRESET="countdown"
```

| Preset | Looks like | Good for |
|---|---|---|
| `classic` (default) | `Me │ Opus 5.5 │ high │ C: ◔ 30% │ L: 23% ▓▓░░░░┃░░░ → 6:30 PM` | Labelled parts and the clock time of the reset |
| `countdown` | `Me │ Opus 5.5 │ high │ ◔ 30% │ 23% ▓▓░░░░┃░░░ → ⧗ 2h 15m (6:30 PM)` | Seeing how long until the reset, without labels |
| `minimal` | `◔ 30% │ 23% ▓▓░░░░┃░░░ → ⧗ 2h 15m` | Narrow windows: just context and the limit |
| `full` | `Me │ ⎇ main │ Opus 5.5 │ Effort: high │ C: ◔ 30% │ L: 23% ▓▓░░░░┃░░░ → ⧗ 2h 15m (6:30 PM) │ Weekly: 41% ▓▓▓▓░┃░░░░ → ⧗ 3d 4h (Sat 8:15 PM)` | Everything, including the git branch and the weekly limit |
| `plain` | `Me │ Opus 5.5 │ high │ C: 30% │ L: 23% → 2h 15m (6:30 PM)` | Fonts that show the bar, pie or hourglass as boxes |

What each preset changes, compared with `classic`:

| Option | `classic` | `countdown` | `minimal` | `full` | `plain` |
|---|---|---|---|---|---|
| `SHOW_DIRECTORY`, `SHOW_MODEL`, `SHOW_EFFORT` | `1` | `1` | `0` | `1` | `1` |
| `SHOW_BRANCH`, `SHOW_WEEKLY` | `0` | `0` | `0` | `1` | `0` |
| `SHOW_CONTEXT_ICON`, `SHOW_BAR` | `1` | `1` | `1` | `1` | `0` |
| `RESET_STYLE` | `time` | `both` | `countdown` | `both` | `both` |
| `COUNTDOWN_ICON` | `⧗` | `⧗` | `⧗` | `⧗` | none |
| `SHOW_CONTEXT_LABEL`, `SHOW_LIMIT_LABEL` | `1` | `0` | `0` | `1` | `1` |
| `SHOW_EFFORT_LABEL` | `0` | `0` | `0` | `1` | `0` |

## Fine-tune it

Below `PRESET` is a `my_options` block listing every option, commented out.
Uncomment a line and change its value to override the preset:

```bash
my_options() {
  : # keep this line
  SHOW_WEEKLY=1             # 7-day usage limit
  LIMIT_STEPS=(60 80 95)    # limit % where the color turns yellow, orange, red
  ...
}
```

| Option | Values | What it does |
|---|---|---|
| `SHOW_DIRECTORY` | `1` / `0` | Folder name |
| `SHOW_BRANCH` | `1` / `0` | Git branch |
| `SHOW_MODEL` | `1` / `0` | Model name |
| `SHOW_EFFORT` | `1` / `0` | Reasoning effort level |
| `SHOW_CONTEXT` | `1` / `0` | Context window % |
| `SHOW_CONTEXT_ICON` | `1` / `0` | Pie clock before the context % |
| `SHOW_LIMIT` | `1` / `0` | 5-hour usage limit |
| `SHOW_WEEKLY` | `1` / `0` | Weekly (7-day) usage, with its own bar and reset |
| `SHOW_BAR` | `1` / `0` | Progress bars |
| `SHOW_PACE` | `1` / `0` | Pace marker on the bars |
| `SHOW_RESET` | `1` / `0` | When the limits reset |
| `RESET_STYLE` | `"time"` / `"countdown"` / `"both"` | `→ 6:30 PM`, `→ ⧗ 2h 15m`, or `→ ⧗ 2h 15m (6:30 PM)` |
| `COUNTDOWN_ICON` | `"⧗"`, `"⧖"`, `"↻"`, `""` | Symbol before the countdown; `""` for none |
| `USE_24_HOUR` | `1` / `0` | `18:30` instead of `6:30 PM` |
| `LIMIT_STEPS` | three numbers, e.g. `(50 75 90)` | Limit % where the color turns yellow, orange, red. The weekly bar uses these too. A list without exactly three numbers falls back to the default |
| `CONTEXT_STEPS` | three numbers, e.g. `(50 70 80)` | Context % where the color turns yellow, orange, red. A list without exactly three numbers falls back to the default |
| `SHOW_EFFORT_LABEL` | `1` / `0` | `Effort:` before the effort level |
| `SHOW_CONTEXT_LABEL` | `1` / `0` | `C:` before the context % |
| `SHOW_LIMIT_LABEL` | `1` / `0` | `L:` before the 5-hour limit |
| `SHOW_WEEKLY_LABEL` | `1` / `0` | `Weekly:` before the weekly usage |
| `SHOW_RESET_LABEL` | `1` / `0` | `Reset:` before the 5-hour reset time, or `Reset in` before its countdown |

Changes apply the next time the status line refreshes. You don't need to
restart.

## Customize with Claude Code

You don't have to edit the script by hand. Open Claude Code and describe what
you want. Name the file so Claude changes this script instead of writing a new
one:

- "Set the preset in `~/.claude/statusline.sh` to minimal"
- "In `~/.claude/statusline.sh`, show the weekly limit and the git branch"
- "Make the limit turn yellow at 60%, orange at 80% and red at 95%"
- "Use ↻ instead of the hourglass, and a 24-hour clock"

Claude Code sends the status line more data than this script shows, so you can
also ask for new parts:

- "Add the session cost" (`cost.total_cost_usd`)
- "Show lines added and removed in this session" (`cost.total_lines_added`, `cost.total_lines_removed`)
- "Show how long this session has been running" (`cost.total_duration_ms`)
- "Show the repo name instead of the folder" (`workspace.repo.name`)
- "Put the weekly limit on a second line" (each printed line becomes its own row)

Tips:

- Ask Claude to "show me a preview first". It can run the script with sample
  data and show you the line before changing your copy.
- Claude Code's `/statusline` command also takes a description, such as
  `/statusline show the model and context %`, but it builds a new status line
  instead of editing this one.

## Test it without Claude Code

Paste this into Terminal. It sends sample data with a reset 2 hours 15 minutes
from now:

```bash
reset=$(( $(date +%s) + 8100 ))
echo '{"model":{"display_name":"Opus 5.5"},"effort":{"level":"high"},"workspace":{"current_dir":"/Users/me/Me"},"context_window":{"used_percentage":30},"rate_limits":{"five_hour":{"used_percentage":23,"resets_at":'$reset'}}}' | bash ~/.claude/statusline.sh
```

With the `classic` preset you should see a colored line like
`Me │ Opus 5.5 │ high │ C: ◔ 30% │ L: 23% ▓▓░░░░┃░░░ → 10:45 PM`, with your own
reset time.

## Troubleshooting

| Problem | Fix |
|---|---|
| Status line is empty | Check the `command` in `settings.json` points to the right file. Run the test above to see if the script works on its own |
| Shows `statusline: jq not found` | Install jq: `brew install jq` on macOS, `sudo apt install jq` on Ubuntu or Debian |
| Limit shows `~` | Wait for Claude's first reply. If it stays, check you're signed in with Pro/Max (`/status` in Claude Code), not an API key |
| Countdown doesn't move while idle | Add `"refreshInterval": 60` to the `statusLine` entry |
| Pie, bar or hourglass look wrong | Your terminal font doesn't have them. Try another font, or use `PRESET="plain"` |
| Nothing changes after editing | Check the line you changed isn't still commented out inside `my_options`, and that `: # keep this line` is still there |

## Notes

- Tested on macOS 27 with the built-in bash 3.2 and jq 1.7.1. One refresh takes
  about 20 ms.
- On Linux it uses `date -d` instead of the macOS-only `date -r`. That fallback
  was tested with a simulated Linux `date`, not on a Linux machine.
- It has no network access and reads no files. It only reads the session data
  Claude Code sends it and prints one line. With `SHOW_BRANCH=1` it also runs
  `git` to read the branch name.
