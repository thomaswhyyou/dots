#!/usr/bin/env bash
# Split the active pane so the NEW pane is a percentage of the whole tab width,
# not a fraction of the current pane. Usage: split-pct.sh <pct 0..1> [left|right]
#
# herdr's `pane split --ratio` is always relative to the pane being split, so we
# read the tab's total width and the current pane's width and solve for the ratio
# that yields the target absolute width.
#   right: new pane stays in the right slot -> width = (1-r)*P  => r = 1 - pct*W/P
#   left:  we swap the new pane into the left slot -> width = r*P => r = pct*W/P
set -euo pipefail

pct="${1:?usage: split-pct.sh <pct 0..1> [left|right]}"
side="${2:-right}"
pid="${HERDR_ACTIVE_PANE_ID:-$(herdr pane current | jq -r '.result.pane.pane_id')}"

edges=$(herdr pane edges --pane "$pid")
total=$(echo "$edges" | jq '.result.edges.layout.area.width')
pw=$(echo "$edges" | jq --arg p "$pid" \
  '.result.edges.layout.panes[] | select(.pane_id==$p) | .rect.width')

# target cells the new pane should occupy, capped so the split stays valid
ratio=$(jq -n --argjson t "$total" --argjson p "$pw" --argjson pct "$pct" --arg side "$side" '
  (($pct * $t) / $p) as $frac
  | (if $side == "left" then $frac else 1 - $frac end)
  | if . < 0.05 then 0.05 elif . > 0.95 then 0.95 else . end')

new=$(herdr pane split --pane "$pid" --direction right --ratio "$ratio" \
  | jq -r '.result.pane.pane_id')

if [ "$side" = "left" ]; then
  herdr pane swap --source-pane "$new" --target-pane "$pid" >/dev/null
else
  herdr pane focus --direction right --pane "$pid" >/dev/null 2>&1 || true
fi
