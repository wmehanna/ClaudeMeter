# ClaudeMeter

![ClaudeMeter](docs/heading.png)

Keep track of your Claude.ai plan usage at a glance — now with automatic discovery of new usage metrics as Anthropic adds them.

## What's New

This fork extends the original [ClaudeMeter by Edd Mann](https://github.com/eddmann/ClaudeMeter) with **dynamic metric discovery**: whenever Anthropic adds a new usage limit to the API (a new model tier, a new window, etc.), the app picks it up automatically — no update required.

### New Features

- **Dynamic metric discovery** — The app reads every field returned by the Claude.ai usage API at runtime. New metrics appear in the popover, icon, and settings the moment they show up in the API response, without any code change.
- **Custom Pills icon style** — Display up to 4 live usage percentages side-by-side in your menu bar with distinct colour-coding per metric (session = status colour, weekly = purple, Sonnet = orange, Design = teal, unknown = palette-assigned).
- **Custom Bar icon style** — A compact colour-coded progress bar that can track any metric, not just the session.
- **Dual Bar icon style** — Shows two metrics simultaneously as stacked bars.
- **Per-metric popover visibility** — Toggle each discovered metric on/off in the popover independently. Previously only Sonnet had its own toggle.
- **Configurable metric picker** — All icon styles that support multiple metrics (Custom Pills, Custom Bar, Dual Bar) expose a reorderable chip picker: tap to add/remove, drag to reorder, up to 4 slots.
- **Colour-coded metric chips** — The metric picker and popover consistently colour each metric: session follows your usage status, weekly is purple, Sonnet is orange, Design is teal, and any future metric gets a hash-stable hue from a fixed palette.

## Features

- **Real-time usage monitoring** — Tracks your 5-hour session, 7-day weekly, Sonnet, Design, and any new limits Anthropic introduces
- **Menu bar integration** — Clean, colour-coded usage indicator that lives in your macOS menu bar
- **8 icon styles** — Battery, Circular, Minimal, Segments, Dual Bar, Custom Bar, Custom Pills, Gauge
- **Pacing indicator** — Flame icon warns when you're using Claude faster than a sustainable pace
- **Smart notifications** — Configurable alerts at warning and critical thresholds (defaults: 75% and 90%), plus a reset notification when your limits refresh
- **Auto-refresh** — Automatic usage updates every 1 minute, 5 minutes, or 10 minutes

## Screenshots

### Usage Popover

Click the menu bar icon to see live usage for every discovered metric:

<p align="center">
  <img src="docs/popover.png" width="320" alt="Usage popover showing Session, Weekly, Sonnet and Design metrics">
</p>

Each card shows the current percentage, a colour-coded progress bar, the reset time, and a pacing flame when you are consuming your quota faster than it replenishes.

### Menu Bar Icon Styles

<p align="center">
  <img src="docs/menubar-custompills.png" width="220" alt="Custom Pills — three metrics side by side">
  &nbsp;&nbsp;&nbsp;
  <img src="docs/menubar-dualbar.png" width="120" alt="Dual Bar — two stacked bars">
  &nbsp;&nbsp;&nbsp;
  <img src="docs/menubar-battery.png" width="100" alt="Battery — single metric">
</p>

*Left to right: Custom Pills (3 metrics, each colour-coded), Dual Bar (session + weekly), Battery (single metric)*

### Settings

Configure icon style, choose which metrics appear in each view, and toggle popover visibility per metric:

<p align="center">
  <img src="docs/settings-general-new.png" width="520" alt="Settings showing Popover Metrics toggles, icon style grid, and metric chip picker">
</p>

The **Popover Metrics** section lists every metric the API currently returns (excluding session, which is always shown). The **Metrics** chip row lets you reorder and limit which metrics appear in multi-metric icon styles.

### Notifications

ClaudeMeter sends native macOS notifications when you reach warning or critical thresholds:

<p align="center">
  <img src="docs/notifications.png" width="450" alt="Usage notifications">
</p>

### Setup Wizard

<p align="center">
  <img src="docs/setup-wizard.png" width="600" alt="First-time setup wizard">
</p>

## Installation

### Manual Download

1. Download the latest release from [GitHub Releases](https://github.com/wmehanna/ClaudeMeter/releases)
2. Unzip and move `ClaudeMeter.app` to Applications
3. Right-click → Open (first launch only, as the app is unsigned in this fork)

### Build from Source

```bash
git clone https://github.com/wmehanna/ClaudeMeter.git
cd ClaudeMeter
open ClaudeMeter.xcodeproj
# Press ⌘R in Xcode
```

Requires Xcode 16.0+ and macOS 14.0+.

## Usage

### First Launch

1. ClaudeMeter appears in your menu bar as a gauge icon
2. The setup wizard guides you through initial configuration
3. Enter your Claude session key (found in Claude.ai browser cookies)
4. The app validates your key and begins monitoring usage

### Finding Your Session Key

**Chrome / Edge:**
1. Open [claude.ai](https://claude.ai)
2. Press `F12` → Application → Cookies → `https://claude.ai`
3. Copy the `sessionKey` value (starts with `sk-ant-`)

**Safari:**
1. Open [claude.ai](https://claude.ai)
2. Develop → Show Web Inspector → Storage → Cookies → `https://claude.ai`
3. Copy the `sessionKey` value

**Firefox:**
1. Open [claude.ai](https://claude.ai)
2. Press `F12` → Storage → Cookies → `https://claude.ai`
3. Copy the `sessionKey` value

### Integration with External Tools

ClaudeMeter exports usage data to `~/.claudemeter/usage.json`:

```json
{
  "last_updated": "2025-12-24T07:30:00Z",
  "session_usage":  { "reset_at": "2025-12-24T12:00:00Z", "utilization": 22 },
  "weekly_usage":   { "reset_at": "2025-12-30T00:00:00Z", "utilization": 61 },
  "metric_values": {
    "five_hour":         { "reset_at": "2025-12-24T12:00:00Z", "utilization": 22 },
    "seven_day":          { "reset_at": "2025-12-30T00:00:00Z", "utilization": 61 },
    "seven_day_sonnet":   { "reset_at": "2025-12-30T00:00:00Z", "utilization": 84 },
    "seven_day_omelette": { "reset_at": "2025-12-24T17:00:00Z", "utilization": 7  }
  }
}
```

**Claude Code statusline example** — create `~/.claude/statusline.sh`:

```bash
#!/bin/bash
usage=$(jq -r '.session_usage.utilization' ~/.claudemeter/usage.json 2>/dev/null)
if [ -z "$usage" ] || [ "$usage" = "null" ]; then
  echo "Usage: ~"
elif [ "$usage" -lt 50 ]; then
  echo -e "\033[32mUsage: ${usage}%\033[0m"
elif [ "$usage" -lt 80 ]; then
  echo -e "\033[33mUsage: ${usage}%\033[0m"
else
  echo -e "\033[31mUsage: ${usage}%\033[0m"
fi
```

Then in `~/.claude/settings.json`:

```json
{
  "statusLine": {
    "type": "command",
    "command": "bash ~/.claude/statusline.sh"
  }
}
```

## Requirements

- macOS 14.0 (Sonoma) or later
- Active Claude.ai account with session key

## Disclaimer

**This is an unofficial tool** and is not affiliated with, endorsed by, or supported by Anthropic PBC.

This application accesses Claude's web API using browser-based authentication. **This may violate Anthropic's Terms of Service.** By using ClaudeMeter you acknowledge that:

- Anthropic may block, restrict, or terminate access at any time
- Your Claude account could be affected by using unofficial API clients
- **Use at your own risk** — the developer assumes no liability

**Data storage:**
- Session keys are stored securely in macOS Keychain (encrypted, device-local only)
- Usage data is cached locally (unencrypted, contains usage percentages only)
- No data is sent to third-party servers

## Credits

Based on [ClaudeMeter](https://github.com/eddmann/ClaudeMeter) by [Edd Mann](https://github.com/eddmann), MIT License.

## License

MIT License — see [LICENSE](LICENSE) file for details.
