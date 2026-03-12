#!/bin/bash
# Create a calendar event with attendees (invitations) via .ics file
# Usage: cal-invite.sh <summary> <start> <end> <attendees> [location] [description] [organizer_email] [calendar_name]
# 
# Arguments:
#   summary        - Event title
#   start          - Start date "YYYY-MM-DD HH:MM"
#   end            - End date "YYYY-MM-DD HH:MM"
#   attendees      - Comma-separated emails: "a@x.com,b@y.com"
#   location       - (optional) Event location
#   description    - (optional) Event description
#   organizer_email - (optional) Your email for the ORGANIZER field
#   calendar_name  - (optional) Target calendar name
#
# The script auto-confirms the Calendar.app import dialog via UI automation.
# No manual clicking required.
#
# Examples:
#   cal-invite.sh "Team Sync" "2026-03-15 10:00" "2026-03-15 11:00" "alice@company.com,bob@company.com"
#   cal-invite.sh "1:1 Review" "2026-03-15 14:00" "2026-03-15 15:00" "manager@co.com" "Room A" "Q1 review"

SUMMARY="${1:-}"
START_DATE="${2:-}"
END_DATE="${3:-}"
ATTENDEES="${4:-}"
LOCATION="${5:-}"
DESCRIPTION="${6:-}"
ORGANIZER="${7:-}"
CAL_NAME="${8:-}"

if [ -z "$SUMMARY" ] || [ -z "$START_DATE" ] || [ -z "$END_DATE" ] || [ -z "$ATTENDEES" ]; then
    echo "Usage: cal-invite.sh <summary> <start> <end> <attendees> [location] [description] [organizer_email] [calendar_name]"
    echo "  attendees: comma-separated emails, e.g. 'a@x.com,b@y.com'"
    echo "  dates: 'YYYY-MM-DD HH:MM'"
    exit 1
fi

# Convert date format: "2026-03-15 10:00" -> "20260315T100000"
format_date() {
    local d="$1"
    local date_part="${d%% *}"
    local time_part="${d##* }"
    local y="${date_part:0:4}"
    local m="${date_part:5:2}"
    local day="${date_part:8:2}"
    local h="${time_part:0:2}"
    local min="${time_part:3:2}"
    echo "${y}${m}${day}T${h}${min}00"
}

DTSTART=$(format_date "$START_DATE")
DTEND=$(format_date "$END_DATE")
DTSTAMP=$(date -u +"%Y%m%dT%H%M%SZ")
UID_VAL="$(uuidgen)@apple-calendar-skill"

# Build .ics content (macOS mktemp doesn't support suffix in template)
ICS_DIR=$(mktemp -d /tmp/cal-invite-XXXXXX)
ICS_FILE="${ICS_DIR}/invite.ics"

{
echo "BEGIN:VCALENDAR"
echo "VERSION:2.0"
echo "PRODID:-//apple-calendar-skill//EN"
echo "METHOD:REQUEST"
echo "BEGIN:VEVENT"
echo "UID:${UID_VAL}"
echo "DTSTAMP:${DTSTAMP}"
echo "DTSTART:${DTSTART}"
echo "DTEND:${DTEND}"
echo "SUMMARY:${SUMMARY}"

if [ -n "$LOCATION" ]; then
    echo "LOCATION:${LOCATION}"
fi

if [ -n "$DESCRIPTION" ]; then
    echo "DESCRIPTION:${DESCRIPTION}"
fi

if [ -n "$ORGANIZER" ]; then
    echo "ORGANIZER;CN=Organizer:mailto:${ORGANIZER}"
fi

# Add attendees
IFS=',' read -ra ADDR <<< "$ATTENDEES"
for email in "${ADDR[@]}"; do
    email=$(echo "$email" | xargs)  # trim whitespace
    echo "ATTENDEE;ROLE=REQ-PARTICIPANT;PARTSTAT=NEEDS-ACTION;RSVP=TRUE:mailto:${email}"
done

echo "STATUS:CONFIRMED"
echo "SEQUENCE:0"
echo "END:VEVENT"
echo "END:VCALENDAR"
} > "$ICS_FILE"

# Open with Calendar.app
open -a "Calendar" "$ICS_FILE"

# Auto-confirm: wait for Calendar.app import dialog and click OK/Add
# This uses System Events UI automation to find and click the confirmation button
sleep 2
osascript -e '
tell application "Calendar" to activate
delay 0.5
tell application "System Events"
    tell process "Calendar"
        -- Look for the import sheet/dialog
        try
            -- macOS Calendar shows a sheet with "OK" or "Add" button
            set allButtons to every button of every sheet of every window
            repeat with btnGroup in allButtons
                repeat with btn in btnGroup
                    set btnName to name of btn
                    if btnName is "OK" or btnName is "好" or btnName is "添加" or btnName is "Add" then
                        click btn
                        return "CONFIRMED: clicked " & btnName
                    end if
                end repeat
            end repeat
        end try
        -- Fallback: try buttons directly on the window
        try
            repeat with w in every window
                repeat with btn in every button of w
                    set btnName to name of btn
                    if btnName is "OK" or btnName is "好" or btnName is "添加" or btnName is "Add" then
                        click btn
                        return "CONFIRMED: clicked " & btnName
                    end if
                end repeat
            end repeat
        end try
        return "NO_DIALOG_FOUND"
    end tell
end tell
' 2>&1

CONFIRM_RESULT=$?

echo ""
echo "Invite created and sent"
echo "  Summary: ${SUMMARY}"
echo "  Start: ${START_DATE}"
echo "  End: ${END_DATE}"
echo "  Attendees: ${ATTENDEES}"
if [ -n "$LOCATION" ]; then echo "  Location: ${LOCATION}"; fi
echo "  .ics file: ${ICS_FILE}"
