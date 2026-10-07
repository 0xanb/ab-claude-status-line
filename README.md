# Claude Code status line

**English** | [Tiếng Việt](README.vi.md)

A status line for [Claude Code](https://code.claude.com) that shows how full
your context is, how much of your 5-hour usage limit you've used, and when it
resets. It works on macOS, Linux and Windows.

```
Me │ Opus 5.5 │ high │ ◔ 30% │ 23% ▓▓░░░░┃░░░ → ⧗ 2h 15m (6:30 PM)
```

- **Context**: a pie clock and % that turn yellow, orange, then red as the
  context window fills
- **Usage limit**: your 5-hour limit with a bar, plus a marker showing whether
  you're on pace to run out before it resets
- **Reset**: a countdown, the clock time, or both
- **Five presets** to start from, every part switchable, and easy to change by
  asking Claude Code

It needs no extra app and has no network access. Claude Code already sends
your usage to the status line, and the script just formats it.

## Pick your version

| You use | Folder | Needs |
|---|---|---|
| macOS, Linux or WSL | [`mac/`](mac/) | bash and `jq` (built into macOS 15 and later) |
| Windows | [`windows/`](windows/) | Windows PowerShell 5.1 (built in) or PowerShell 7 |

Each folder has its own README with install steps, previews of every preset,
all options and troubleshooting. Windows users can also download
`windows/claude-statusline-windows.zip`.

You need a Claude Pro or Max subscription for the usage limit part. With an
API key, the rest of the line still works.

## Install with Claude Code

The quickest way is to let Claude Code do it. Download this repo, open Claude
Code, and paste one of these, replacing the path with where you saved it:

**macOS / Linux**

> Install the status line from `~/Downloads/claude-statusline/mac/statusline.sh`:
> copy it to `~/.claude/statusline.sh`, then set `statusLine` in
> `~/.claude/settings.json` to `{"type": "command", "command": "bash ~/.claude/statusline.sh", "refreshInterval": 60}`.
> Keep all my other settings, and show me the result with sample data.

**Windows**

> Install the status line from `C:\Users\<you>\Downloads\claude-statusline\windows\statusline.ps1`:
> copy it to `C:\Users\<you>\.claude\statusline.ps1`, then set `statusLine` in my
> Claude Code `settings.json` to run
> `powershell -NoProfile -ExecutionPolicy Bypass -File "C:/Users/<you>/.claude/statusline.ps1"`
> with `"refreshInterval": 60`. Use forward slashes in the path and keep the quotes
> around it. Keep all my other settings, and show me the result with sample data.

Or follow the manual steps in the folder's README.

## Presets

Pick a starting layout by changing one line at the top of the script:

| Preset | Looks like |
|---|---|
| `classic` (default) | `Me │ Opus 5.5 │ high │ C: ◔ 30% │ L: 23% ▓▓░░░░┃░░░ → 6:30 PM` |
| `countdown` | `Me │ Opus 5.5 │ high │ ◔ 30% │ 23% ▓▓░░░░┃░░░ → ⧗ 2h 15m (6:30 PM)` |
| `minimal` | `◔ 30% │ 23% ▓▓░░░░┃░░░ → ⧗ 2h 15m` |
| `full` | adds the git branch, the effort label and the weekly limit |
| `plain` | `Me │ Opus 5.5 │ high │ C: 30% │ L: 23% → 2h 15m (6:30 PM)`, for fonts without the symbols |

Then fine-tune any part: labels, colors and thresholds, 24-hour time, the
countdown icon, the weekly limit and more. Or just ask Claude Code, for example
"set my status line preset to minimal and show the weekly limit". The READMEs
list more ideas, such as adding the session cost.

## Privacy

The script only reads the session data Claude Code passes it on each refresh,
and prints one line. It makes no network calls, writes no files and stores
nothing. With the git branch option on, it also runs `git` to read the branch
name.
