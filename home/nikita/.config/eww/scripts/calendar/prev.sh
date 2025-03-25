#!/bin/bash
#!/bin/bash

year=$1
month=$2

next_year=$(date -d "$year-$month-01 -1 month" +%Y)
next_month=$(date -d "$year-$month-01 -1 month" +%m)

eww update calendar_data="$(~/.config/eww/scripts/calendar/data.sh $next_year $next_month)"
