#!/bin/bash
# Follow Feedback/sent.log and print only the sent comments whose screen matches.
#   ./feedback-watch.sh "Aujourd'hui"      # substring of screenName (or screenID), case-insensitive
# One line per matching comment: "<id> <screenName>: <text>". Lines for other screens are ignored.
# Meant for the Monitor tool: Monitor ./feedback-watch.sh "<your screen name>"
cd "$(dirname "$0")"
[ -z "$1" ] && { echo "usage: $0 <screen name substring>" >&2; exit 2; }
needle="$1"
touch Feedback/sent.log

tail -n 0 -F Feedback/sent.log 2>/dev/null | while IFS= read -r line; do
    ids=${line##*: }
    [ "$ids" = "$line" ] && continue
    # The app writes feedback.json just before the log line; read it fresh each time.
    jq -r --arg ids "$ids" --arg needle "$needle" '
        ($ids | split(",")) as $wanted
        | .[] | select(.id as $id | $wanted | index($id))
        | select(((.screenName // "") + "\n" + (.screenID // "")) | ascii_downcase | contains($needle | ascii_downcase))
        | "\(.id) \(.screenName): \(.text | gsub("\n"; " "))"
    ' Feedback/feedback.json 2>/dev/null
done
