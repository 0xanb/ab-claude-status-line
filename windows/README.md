# Claude Code status line for Windows

**English** | [Tiếng Việt](README.vi.md)

A PowerShell status line for Claude Code that shows your context, your 5-hour
usage limit and when it resets. Pick one of five ready-made layouts, then
fine-tune it yourself or ask Claude Code to change it for you.

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
| `→ ⧗ 2h 15m (6:30 PM)` | When the limit resets: time left and the local clock time. You can show only one of the two (see `$ResetStyle`) |

No separate app is needed. Claude Code sends your usage to the status line
script directly.

## Requirements

- Windows 10 or 11 with Windows PowerShell 5.1 (built in) or PowerShell 7
- Claude Code, signed in with a Claude Pro or Max account. With an API key the
  limit part shows `~`, because Claude Code only reports usage for subscriptions
- Windows Terminal is recommended. The old console window may not have the font
  for the bar symbols

## Install

1. Copy `statusline.ps1` to your Claude folder. In PowerShell, from the folder
   with the script:

   ```powershell
   Copy-Item .\statusline.ps1 "$env:USERPROFILE\.claude\"
   ```

2. Open `C:\Users\<you>\.claude\settings.json` and add (or replace) the
   `statusLine` entry. Replace `<you>` with your Windows user name:

   ```json
   {
     "statusLine": {
       "type": "command",
       "command": "powershell -NoProfile -ExecutionPolicy Bypass -File \"C:/Users/<you>/.claude/statusline.ps1\"",
       "refreshInterval": 60
     }
   }
   ```

   - Keep the forward slashes `/` in the path. If Git Bash is installed, Claude
     Code runs the command through it, and Git Bash removes backslashes, which
     makes the command fail silently.
   - Keep the `\"` quotes around the path, so a user name with a space, such as
     `C:/Users/John Smith/...`, still works.
   - `-ExecutionPolicy Bypass` is needed because Windows blocks unsigned scripts
     by default. It applies only to this one script.
   - `refreshInterval` reruns the script every 60 seconds, so countdowns keep
     moving while you're idle.

3. Restart Claude Code.

Or let Claude Code do steps 1 and 2: see "Install with Claude Code" in the
[main README](../README.md).

The limit part shows `~` until Claude has replied once in the session. That's
normal, because Claude Code only gets your usage numbers after the first reply.

## Pick a preset

Open `statusline.ps1` and set `$Preset` near the top:

```powershell
$Preset = 'countdown'
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
| `$ShowDirectory`, `$ShowModel`, `$ShowEffort` | `$true` | `$true` | `$false` | `$true` | `$true` |
| `$ShowBranch`, `$ShowWeekly` | `$false` | `$false` | `$false` | `$true` | `$false` |
| `$ShowContextIcon`, `$ShowBar` | `$true` | `$true` | `$true` | `$true` | `$false` |
| `$ResetStyle` | `'time'` | `'both'` | `'countdown'` | `'both'` | `'both'` |
| `$CountdownIcon` | `0x29D7` (⧗) | `0x29D7` | `0x29D7` | `0x29D7` | `0` (none) |
| `$ShowContextLabel`, `$ShowLimitLabel` | `$true` | `$false` | `$false` | `$true` | `$true` |
| `$ShowEffortLabel` | `$false` | `$false` | `$false` | `$true` | `$false` |

## Fine-tune it

Below `$Preset` is a `$MyOptions` block listing every option, commented out.
Uncomment a line and change its value to override the preset:

```powershell
$MyOptions = {
    $ShowWeekly       = $true           # 7-day usage limit
    $LimitSteps       = @(60, 80, 95)   # limit % where the color turns yellow, orange, red
    ...
}
```

| Option | Values | What it does |
|---|---|---|
| `$ShowDirectory` | `$true` / `$false` | Folder name |
| `$ShowBranch` | `$true` / `$false` | Git branch (needs Git on your PATH) |
| `$ShowModel` | `$true` / `$false` | Model name |
| `$ShowEffort` | `$true` / `$false` | Reasoning effort level |
| `$ShowContext` | `$true` / `$false` | Context window % |
| `$ShowContextIcon` | `$true` / `$false` | Pie clock before the context % |
| `$ShowLimit` | `$true` / `$false` | 5-hour usage limit |
| `$ShowWeekly` | `$true` / `$false` | Weekly (7-day) usage, with its own bar and reset |
| `$ShowBar` | `$true` / `$false` | Progress bars |
| `$ShowPace` | `$true` / `$false` | Pace marker on the bars |
| `$ShowReset` | `$true` / `$false` | When the limits reset |
| `$ResetStyle` | `'time'` / `'countdown'` / `'both'` | `→ 6:30 PM`, `→ ⧗ 2h 15m`, or `→ ⧗ 2h 15m (6:30 PM)` |
| `$CountdownIcon` | `0x29D7` ⧗, `0x29D6` ⧖, `0x21BB` ↻, `0` for none | Symbol before the countdown, as a code point (see below) |
| `$Use24Hour` | `$true` / `$false` | `18:30` instead of `6:30 PM` |
| `$LimitSteps` | three numbers, e.g. `@(50, 75, 90)` | Limit % where the color turns yellow, orange, red. The weekly bar uses these too. A list without exactly three numbers falls back to the default |
| `$ContextSteps` | three numbers, e.g. `@(50, 70, 80)` | Context % where the color turns yellow, orange, red. A list without exactly three numbers falls back to the default |
| `$ShowEffortLabel` | `$true` / `$false` | `Effort:` before the effort level |
| `$ShowContextLabel` | `$true` / `$false` | `C:` before the context % |
| `$ShowLimitLabel` | `$true` / `$false` | `L:` before the 5-hour limit |
| `$ShowWeeklyLabel` | `$true` / `$false` | `Weekly:` before the weekly usage |
| `$ShowResetLabel` | `$true` / `$false` | `Reset:` before the 5-hour reset time, or `Reset in` before its countdown |

Symbols are set as code points like `0x29D7` because Windows PowerShell 5.1
misreads symbols typed straight into a script saved without a BOM. The script
itself is kept to plain ASCII for the same reason.

Changes apply the next time the status line refreshes. You don't need to
restart.

## Customize with Claude Code

You don't have to edit the script by hand. Open Claude Code and describe what
you want. Name the file so Claude changes this script instead of writing a new
one:

- "Set the preset in `~/.claude/statusline.ps1` to minimal"
- "In `~/.claude/statusline.ps1`, show the weekly limit and the git branch"
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
- Ask Claude to keep the script pure ASCII, so Windows PowerShell 5.1 still
  reads it correctly.
- Claude Code's `/statusline` command also takes a description, such as
  `/statusline show the model and context %`, but it builds a new status line
  instead of editing this one.

## Test it without Claude Code

Paste this into PowerShell. It sends sample data with a reset 2 hours 15
minutes from now:

```powershell
[Console]::OutputEncoding = [Text.Encoding]::UTF8
$reset = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds() + 8100
$json = '{"model":{"display_name":"Opus 5.5"},"effort":{"level":"high"},"workspace":{"current_dir":"C:/Users/me/Me"},"context_window":{"used_percentage":30},"rate_limits":{"five_hour":{"used_percentage":23,"resets_at":' + $reset + '}}}'
$json | powershell -NoProfile -ExecutionPolicy Bypass -File "$env:USERPROFILE\.claude\statusline.ps1"
```

With the `classic` preset you should see a colored line like
`Me │ Opus 5.5 │ high │ C: ◔ 30% │ L: 23% ▓▓░░░░┃░░░ → 10:45 PM`, with your own
reset time. The first line switches this PowerShell window to UTF-8, so the
symbols display correctly; Claude Code doesn't need it. If you see strange
`[0;34m` text instead of colors, run the test in Windows Terminal. The old
console doesn't show colors, but Claude Code's status bar still will.

## Troubleshooting

| Problem | Fix |
|---|---|
| Status line is empty | Check the path in `settings.json` uses `/` and points to the right file. Run the test above to see if the script works on its own |
| Limit shows `~` | Wait for Claude's first reply. If it stays, check you're signed in with Pro/Max (`/status` in Claude Code), not an API key |
| Countdown doesn't move while idle | Add `"refreshInterval": 60` to the `statusLine` entry |
| Bar, pie or hourglass show boxes or `?` | Use Windows Terminal with a font such as Cascadia Mono, or set `$Preset = 'plain'` |
| Reset time looks wrong | The script uses the Windows time zone. Check it in Windows Settings > Time & language |
| "running scripts is disabled" error | Make sure the command includes `-ExecutionPolicy Bypass`. On a work PC, an administrator's Group Policy can block scripts even then; ask your IT team |
| Nothing changes after editing | Check the line you changed isn't still commented out inside `$MyOptions` |

## Notes

- Tested with PowerShell 7.6: across 96 combinations of preset and input, its
  output matched the macOS version exactly, colors included. It hasn't been
  run on Windows itself or in Windows PowerShell 5.1 yet. If something breaks,
  run the test command above and check the error it prints.
- It has no network access and reads no files. It only reads the session data
  Claude Code sends it and prints one line. With `$ShowBranch = $true` it also
  runs `git` to read the branch name.
