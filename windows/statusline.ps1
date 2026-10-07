# Claude Code status line for Windows (Windows PowerShell 5.1 or PowerShell 7+).
# Shows: folder | model | effort | context pie + % | 5-hour limit % + bar + pace marker -> reset
# Usage numbers come from Claude Code itself (the rate_limits field it sends to the
# status line), so no separate usage app is needed. See README.md for setup, previews
# of every preset, and all options.
#
# This file is kept pure ASCII on purpose: Windows PowerShell 5.1 misreads UTF-8
# files without a BOM, so the bar and arrow symbols are built from code points below.

# ---- Preset: pick a starting layout ----
#   classic    folder | model | effort | C: (pie) 30% | L: 23% (bar) -> 6:30 PM
#   countdown  folder | model | effort | (pie) 30% | 23% (bar) -> (hourglass) 2h 15m (6:30 PM)
#   minimal    (pie) 30% | 23% (bar) -> (hourglass) 2h 15m
#   full       classic plus git branch, effort label, countdown and the weekly limit
#   plain      no bar, pie or hourglass, for fonts that show them as boxes
$Preset = 'classic'

# ---- Your changes: uncomment a line to override the preset ----
$MyOptions = {
    # $ShowDirectory    = $true           # folder name
    # $ShowBranch       = $true           # git branch (needs Git on your PATH)
    # $ShowModel        = $true           # model name
    # $ShowEffort       = $true           # reasoning effort: low, medium, high, xhigh or max
    # $ShowContext      = $true           # context window %
    # $ShowContextIcon  = $true           # pie clock that fills with the context %
    # $ShowLimit        = $true           # 5-hour usage limit
    # $ShowWeekly       = $true           # 7-day usage limit
    # $ShowBar          = $true           # progress bars
    # $ShowPace         = $true           # marker showing how far through the window you are
    # $ShowReset        = $true           # when the limit resets
    # $ResetStyle       = 'both'          # 'time' -> 6:30 PM, 'countdown' -> 2h 15m, 'both' -> 2h 15m (6:30 PM)
    # $CountdownIcon    = 0x29D7          # hourglass; 0x29D6 hollow hourglass, 0x21BB circular arrow, 0 for none
    # $Use24Hour        = $true           # 18:30 instead of 6:30 PM
    # $LimitSteps       = @(50, 75, 90)   # limit % where the color turns yellow, orange, red
    # $ContextSteps     = @(50, 70, 80)   # context % where the color turns yellow, orange, red
    # $ShowEffortLabel  = $true           # "Effort: high"
    # $ShowContextLabel = $false          # "C: 30%"
    # $ShowLimitLabel   = $false          # "L: 23%"
    # $ShowWeeklyLabel  = $false          # "Weekly: 41%"
    # $ShowResetLabel   = $true           # "-> Reset: 6:30 PM" or "-> Reset in 2h 15m" on the 5-hour limit
}

# ---- Presets: classic is the base, the others change a few options from it ----
$ShowDirectory = $true; $ShowBranch = $false; $ShowModel = $true; $ShowEffort = $true
$ShowContext = $true; $ShowContextIcon = $true; $ShowLimit = $true; $ShowWeekly = $false
$ShowBar = $true; $ShowPace = $true; $ShowReset = $true
$ResetStyle = 'time'; $CountdownIcon = 0x29D7; $Use24Hour = $false
$LimitSteps = @(50, 75, 90); $ContextSteps = @(50, 70, 80)
$ShowEffortLabel = $false; $ShowContextLabel = $true; $ShowLimitLabel = $true; $ShowWeeklyLabel = $true; $ShowResetLabel = $false

switch ($Preset) {
    'countdown' {
        $ResetStyle = 'both'; $ShowContextLabel = $false; $ShowLimitLabel = $false
    }
    'minimal' {
        $ShowDirectory = $false; $ShowModel = $false; $ShowEffort = $false; $ResetStyle = 'countdown'
        $ShowContextLabel = $false; $ShowLimitLabel = $false
    }
    'full' {
        $ShowBranch = $true; $ShowWeekly = $true; $ShowEffortLabel = $true; $ResetStyle = 'both'
    }
    'plain' {
        $ShowContextIcon = $false; $ShowBar = $false; $CountdownIcon = 0; $ResetStyle = 'both'
    }
}
. $MyOptions

# A steps list needs exactly three numbers; fall back to the defaults otherwise
if (@($LimitSteps).Count -ne 3) { $LimitSteps = @(50, 75, 90) }
if (@($ContextSteps).Count -ne 3) { $ContextSteps = @(50, 70, 80) }

$ErrorActionPreference = 'SilentlyContinue'

# ---- Symbols and colors ----
$ESC       = [char]27
$CH_FULL   = [string][char]0x2593   # dark shade block
$CH_EMPTY  = [string][char]0x2591   # light shade block
$CH_MARK   = [string][char]0x2503   # heavy vertical bar (pace marker)
$CH_ARROW  = [string][char]0x2192   # right arrow
$CH_SEP    = [string][char]0x2502   # light vertical bar (separator)
$CH_BRANCH = [string][char]0x2387   # branch symbol
# Pie clock: empty, quarter, half, three quarters, full circle
$CH_PIE    = @(0x25CB, 0x25D4, 0x25D1, 0x25D5, 0x25CF) | ForEach-Object { [string][char]$_ }
# Countdown icon: a code point from the options, or a string, or nothing
$CH_COUNTDOWN = ''
if ($CountdownIcon -is [string]) { $CH_COUNTDOWN = $CountdownIcon }
elseif ($CountdownIcon) { $CH_COUNTDOWN = [char]::ConvertFromUtf32([int]$CountdownIcon) }

$C_RESET  = "$ESC[0m"
$C_BLUE   = "$ESC[0;34m"
$C_GREEN  = "$ESC[0;32m"
$C_GRAY   = "$ESC[0;90m"
$C_YELLOW = "$ESC[0;33m"
$C_CYAN   = "$ESC[0;36m"
$C_MAGENTA = "$ESC[0;35m"

function Get-Ansi256([int]$n) { return "$ESC[38;5;$($n)m" }

# Step colors for the limit and context percentages
$C_OK     = Get-Ansi256 34    # green
$C_AMBER  = Get-Ansi256 178   # yellow
$C_ORANGE = Get-Ansi256 208
$C_RED    = Get-Ansi256 160

# Pace tiers: comfortable, on track, warming, pressing, critical, runaway
$PACE = @(34, 37, 178, 208, 160, 135) | ForEach-Object { Get-Ansi256 $_ }

# $base below the first step, then yellow, orange and red from each step on
function Get-StepColor([int]$pct, [string]$base, [int[]]$steps) {
    if ($pct -ge $steps[2]) { return $C_RED }
    if ($pct -ge $steps[1]) { return $C_ORANGE }
    if ($pct -ge $steps[0]) { return $C_AMBER }
    return $base
}

# $projected is the usage % you would reach by the reset if you keep the current pace
function Get-PaceColor([double]$projected) {
    if ($projected -lt 50)  { return $PACE[0] }
    if ($projected -lt 75)  { return $PACE[1] }
    if ($projected -lt 90)  { return $PACE[2] }
    if ($projected -lt 100) { return $PACE[3] }
    if ($projected -lt 120) { return $PACE[4] }
    return $PACE[5]
}

# Local time of an epoch. The 12-hour format has no leading zero: "6:30 PM", "Sun 6:30 PM"
function Format-Clock([long]$epoch, [string]$format) {
    # Round to the nearest minute so the time doesn't flicker (6:59:45 -> 7:00)
    $seconds = $epoch % 60
    if ($seconds -ge 30) { $epoch += 60 - $seconds } else { $epoch -= $seconds }
    $local = [DateTimeOffset]::FromUnixTimeSeconds($epoch).ToLocalTime()
    return $local.ToString($format, [Globalization.CultureInfo]::InvariantCulture)
}

# Time left until an epoch: "3d 4h", "2h 15m", "45m", or "<1m" in the last minute
function Format-Countdown([long]$epoch) {
    $remaining = $epoch - [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
    if ($remaining -lt 60) { return '<1m' }
    $minutes = [long][math]::Floor($remaining / 60)
    $days = [long][math]::Floor($minutes / 1440)
    $hours = [long][math]::Floor(($minutes % 1440) / 60)
    $mins = $minutes % 60
    if ($days -gt 0) { return "$($days)d $($hours)h" }
    if ($hours -gt 0) { return "$($hours)h $($mins)m" }
    return "$($mins)m"
}

# Renders one rate-limit window: "23% <bar with pace marker> -> 6:30 PM" (or "-> (hourglass) 2h 15m (6:30 PM)")
function Format-Window($window, [long]$windowSecs, [long]$minElapsed, [string]$label, [string]$timeFormat, [string]$resetLabel) {
    if ($null -eq $window -or $null -eq $window.used_percentage) { return '' }

    $pct = [int][math]::Round([double]$window.used_percentage, [MidpointRounding]::AwayFromZero)
    if ($pct -lt 0) { $pct = 0 }
    if ($pct -gt 100) { $pct = 100 }
    $color = Get-StepColor $pct $C_OK $LimitSteps

    $resetEpoch = [long]0
    if ($window.resets_at) { $resetEpoch = [long][math]::Floor([double]$window.resets_at) }
    # A window whose reset time has passed is stale; Claude Code drops these too
    if ($resetEpoch -gt 0 -and $resetEpoch -le [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()) { return '' }

    $bar = ''
    if ($ShowBar) {
        $filled = [int][math]::Floor(($pct * 10 + 50) / 100)
        $markerPos = -1
        $paceColor = $color
        if ($ShowPace -and $resetEpoch -gt 0) {
            $remaining = $resetEpoch - [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
            if ($remaining -gt 0 -and $remaining -lt $windowSecs) {
                $elapsed = $windowSecs - $remaining
                $markerPos = [int][math]::Floor(($elapsed * 10 + $windowSecs / 2) / $windowSecs)
                if ($markerPos -gt 9) { $markerPos = 9 }
                if ($markerPos -lt 0) { $markerPos = 0 }
                # Too early in the window to project a meaningful pace
                if ($elapsed -ge $minElapsed) {
                    $paceColor = Get-PaceColor ($pct * $windowSecs / $elapsed)
                }
            }
        }

        $sb = New-Object System.Text.StringBuilder
        [void]$sb.Append(' ')
        for ($i = 0; $i -lt 10; $i++) {
            if ($i -eq $markerPos) { [void]$sb.Append("$paceColor$CH_MARK$C_RESET$color") }
            elseif ($i -lt $filled) { [void]$sb.Append($CH_FULL) }
            else { [void]$sb.Append($CH_EMPTY) }
        }
        $bar = $sb.ToString()
    }

    $resetText = ''
    if ($ShowReset -and $resetEpoch -gt 0) {
        $iconText = ''
        if ($CH_COUNTDOWN) { $iconText = "$CH_COUNTDOWN " }
        # "Reset: 6:30 PM" but "Reset in 2h 15m"
        $countdownLabel = ''
        if ($resetLabel) { $countdownLabel = 'Reset in ' }
        switch ($ResetStyle) {
            'countdown' {
                $resetText = " $CH_ARROW $iconText$countdownLabel" + (Format-Countdown $resetEpoch)
            }
            'both' {
                $resetText = " $CH_ARROW $iconText$countdownLabel" + (Format-Countdown $resetEpoch) + ' (' + (Format-Clock $resetEpoch $timeFormat) + ')'
            }
            default {
                $resetText = " $CH_ARROW $resetLabel" + (Format-Clock $resetEpoch $timeFormat)
            }
        }
    }

    return "$color$label$pct%$bar$resetText$C_RESET"
}

$line = ''
try {
    # Read stdin as raw UTF-8 bytes so accented folder names survive any console code page
    $buffer = New-Object System.IO.MemoryStream
    [Console]::OpenStandardInput().CopyTo($buffer)
    $raw = [System.Text.Encoding]::UTF8.GetString($buffer.ToArray()).TrimStart([char]0xFEFF)
    # Windows PowerShell 5.1 throws on empty input where PowerShell 7 returns nothing
    $data = $null
    if (-not [string]::IsNullOrWhiteSpace($raw)) { $data = $raw | ConvertFrom-Json }

    $parts = New-Object System.Collections.Generic.List[string]

    $dirPath = $data.workspace.current_dir
    if (-not $dirPath) { $dirPath = $data.cwd }

    if ($ShowDirectory -and $dirPath) {
        # Trim a trailing slash first, or the folder name can come back empty
        $trimmedPath = ([string]$dirPath).TrimEnd('/', '\')
        $dirName = ''
        if ($trimmedPath) { $dirName = Split-Path -Leaf $trimmedPath }
        if ($dirName) { $parts.Add("$C_BLUE$dirName$C_RESET") }
    }

    if ($ShowBranch -and $dirPath -and (Get-Command git -ErrorAction SilentlyContinue)) {
        $branch = git -C $dirPath branch --show-current 2>$null
        if ($branch) { $parts.Add("$C_GREEN$CH_BRANCH $branch$C_RESET") }
    }

    $model = $data.model.display_name
    if ($ShowModel -and $model) { $parts.Add("$C_YELLOW$model$C_RESET") }

    # Claude Code leaves effort out when the current model doesn't support it
    $effort = $data.effort.level
    if ($ShowEffort -and $effort) {
        $label = ''
        if ($ShowEffortLabel) { $label = 'Effort: ' }
        $parts.Add("$C_MAGENTA$label$effort$C_RESET")
    }

    if ($ShowContext) {
        $ctx = $data.context_window.used_percentage
        if ($null -eq $ctx) {
            # used_percentage can be null early in a session; work it out from the token counts
            $usage = $data.context_window.current_usage
            $size = $data.context_window.context_window_size
            if ($size -gt 0) {
                $tokens = [double]$usage.input_tokens + [double]$usage.cache_creation_input_tokens + [double]$usage.cache_read_input_tokens
                $ctx = $tokens * 100 / $size
            }
        }
        # Each part catches its own errors, so one odd value can't blank the whole line
        if ($null -ne $ctx) { try {
            $ctxPct = [int][math]::Floor([double]$ctx)
            $ctxColor = Get-StepColor $ctxPct $C_CYAN $ContextSteps
            $label = ''
            if ($ShowContextLabel) { $label = 'C: ' }
            $icon = ''
            if ($ShowContextIcon) {
                # Nearest quarter, so 30% shows a quarter pie and 90% a full one
                $quarter = [int][math]::Round($ctxPct / 25, [MidpointRounding]::AwayFromZero)
                if ($quarter -lt 0) { $quarter = 0 }
                if ($quarter -gt 4) { $quarter = 4 }
                $icon = $CH_PIE[$quarter] + ' '
            }
            $parts.Add("$ctxColor$label$icon$ctxPct%$C_RESET")
        } catch { } }
    }

    $timeFormat = 'h:mm tt'
    if ($Use24Hour) { $timeFormat = 'HH:mm' }
    $rateLimits = $data.rate_limits

    if ($ShowLimit) {
        $label = ''
        $resetLabel = ''
        if ($ShowLimitLabel) { $label = 'L: ' }
        if ($ShowResetLabel) { $resetLabel = 'Reset: ' }
        $text = ''
        try { $text = Format-Window $rateLimits.five_hour 18000 540 $label $timeFormat $resetLabel } catch { }
        # Claude Code only sends usage after the first reply in a session
        if (-not $text) { $text = "$C_YELLOW$label~$C_RESET" }
        $parts.Add($text)
    }

    if ($ShowWeekly) {
        $label = ''
        if ($ShowWeeklyLabel) { $label = 'Weekly: ' }
        $text = ''
        try { $text = Format-Window $rateLimits.seven_day 604800 3024 $label "ddd $timeFormat" '' } catch { }
        if ($text) { $parts.Add($text) }
    }

    $line = $parts -join "$C_GRAY $CH_SEP $C_RESET"
} catch {
    $line = ''
}

# Write UTF-8 bytes directly so the symbols render regardless of the console code page
$bytes = [System.Text.Encoding]::UTF8.GetBytes($line + "`n")
$stdout = [Console]::OpenStandardOutput()
$stdout.Write($bytes, 0, $bytes.Length)
$stdout.Flush()
