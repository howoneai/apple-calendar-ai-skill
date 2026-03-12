# Apple Calendar AI Skill

macOS Calendar.app automation for AI coding agents (Claude Code, Cursor, CodeBuddy, etc.)

Let your AI assistant manage your calendar -- create events, send invitations, check schedules, all through natural language.

## What It Does

- **View** events and calendars
- **Create** timed or all-day events with recurrence
- **Update / Delete** events by UID
- **Search** events by keyword
- **Send invitations** to attendees (auto-confirms, no popup)

## Quick Install

Tell your AI agent:

> Clone https://github.com/howoneai/apple-calendar-ai-skill as a skill and use it to manage my calendar.

Or manually:

```bash
# Claude Code
git clone https://github.com/howoneai/apple-calendar-ai-skill.git ~/.claude/skills/apple-calendar
chmod +x ~/.claude/skills/apple-calendar/scripts/*.sh

# CodeBuddy
git clone https://github.com/howoneai/apple-calendar-ai-skill.git ~/.codebuddy/skills/apple-calendar
chmod +x ~/.codebuddy/skills/apple-calendar/scripts/*.sh

# Cursor
git clone https://github.com/howoneai/apple-calendar-ai-skill.git ~/.cursor/skills/apple-calendar
chmod +x ~/.cursor/skills/apple-calendar/scripts/*.sh
```

## Requirements

- macOS (uses AppleScript & Calendar.app)
- Calendar.app configured with at least one writable calendar (iCloud, Exchange, CalDAV)
- Accessibility permission for Terminal/IDE (for auto-confirm on invitations)

## Usage Examples

```bash
# List all calendars
scripts/cal-list.sh

# View next 7 days
scripts/cal-events.sh 7

# Create an event
scripts/cal-create.sh "Work" "Team Standup" "2026-03-15 09:00" "2026-03-15 09:30" "Zoom"

# Send meeting invitation (auto-confirms, no popup)
scripts/cal-invite.sh "Project Sync" "2026-03-15 14:00" "2026-03-15 15:00" "alice@company.com,bob@company.com" "Room A" "Q1 review"

# Search events
scripts/cal-search.sh "standup" 30

# Update event
scripts/cal-update.sh <event-uid> --summary "New Title" --location "Room B"

# Delete event
scripts/cal-delete.sh <event-uid>
```

## Scripts

| Script | Description |
|--------|-------------|
| `cal-list.sh` | List all calendars |
| `cal-events.sh` | List upcoming events |
| `cal-read.sh` | Read event details by UID |
| `cal-create.sh` | Create a new event |
| `cal-update.sh` | Update an existing event |
| `cal-delete.sh` | Delete an event |
| `cal-search.sh` | Search events by keyword |
| `cal-invite.sh` | Create event with attendee invitations |

## How Invitations Work

1. Generates a standard `.ics` file with `METHOD:REQUEST` and `ATTENDEE` fields
2. Opens the `.ics` in Calendar.app
3. **Auto-clicks the confirmation button** via macOS UI automation (System Events)
4. Calendar.app sends invitation emails through your configured calendar account (iCloud/Exchange/CalDAV)

No manual clicking required.

## License

MIT
