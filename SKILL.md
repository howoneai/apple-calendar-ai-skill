---
name: apple-calendar
description: "Use when the user wants to view, create, edit, delete calendar events, search events, or manage calendars on macOS. Triggers on phrases like '约个会', 'book a meeting', '明天有什么日程', '查看日历', '改时间', '日程安排', 'add to calendar', 'check my schedule', 'calendar events'."
---

# Apple Calendar

macOS Calendar.app automation via AppleScript. Full CRUD + search + recurring events + multi-calendar + invitations.

Scripts path: `{baseDir}/scripts/`

## Commands

| Command | Usage |
|---------|-------|
| List calendars | `scripts/cal-list.sh` |
| List events | `scripts/cal-events.sh [days_ahead] [calendar_name]` |
| Read event | `scripts/cal-read.sh <event-uid> [calendar_name]` |
| Create event | `scripts/cal-create.sh <calendar> <summary> <start> <end> [location] [description] [allday] [recurrence]` |
| Update event | `scripts/cal-update.sh <event-uid> [--summary X] [--start X] [--end X] [--location X] [--description X]` |
| Delete event | `scripts/cal-delete.sh <event-uid> [calendar_name]` |
| Search events | `scripts/cal-search.sh <query> [days_ahead] [calendar_name]` |
| Invite/Send invitation | `scripts/cal-invite.sh <summary> <start> <end> <attendees> [location] [description] [organizer_email]` |

## Date Format

- Timed: `YYYY-MM-DD HH:MM`
- All-day: `YYYY-MM-DD`

## Recurrence

| Pattern | RRULE |
|---------|-------|
| Daily 10x | `FREQ=DAILY;COUNT=10` |
| Weekly M/W/F | `FREQ=WEEKLY;BYDAY=MO,WE,FR` |
| Monthly 15th | `FREQ=MONTHLY;BYMONTHDAY=15` |

## Output

- Events/search: `UID | Summary | Start | End | AllDay | Location | Calendar`
- Read: Full details with description, URL, recurrence

## Invite (attendees)

- `cal-invite.sh` generates a .ics file with METHOD:REQUEST and opens Calendar.app
- **Auto-confirms**: Uses System Events UI automation to automatically click the OK/Add button
- No manual interaction required - invitations are sent automatically via iCloud/Exchange
- Attendees: comma-separated emails, e.g. `"alice@x.com,bob@y.com"`

### Invite Usage

```bash
# Basic invite
scripts/cal-invite.sh "Meeting" "2026-03-15 14:00" "2026-03-15 15:00" "alice@company.com"

# With location and description
scripts/cal-invite.sh "Team Sync" "2026-03-15 10:00" "2026-03-15 11:00" "a@x.com,b@y.com" "Room A" "Agenda here"
```

## Notes

- Read-only calendars (Birthdays, Holidays) can't be modified
- Calendar names are case-sensitive
- Deleting recurring events removes entire series
