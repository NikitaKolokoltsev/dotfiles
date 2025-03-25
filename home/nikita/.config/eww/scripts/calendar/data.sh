#!/bin/bash

if [ $# -eq 2 ]; then
  date=$1-$2-01
  year=$(date -d $date +%Y)
  month=$(date -d $date +%m)
  month_name=$(date -d $date +%B)
else
  year=$(date +%Y)
  month=$(date +%m)
  month_name=$(date +%B)
fi

weekdays=$(
  for i in {1..7}; do
    date -d "Monday +$((i-1)) day" +%A | \
    cut -c1 | \
    sed "s/.*/\"&\"/";
  done | paste -sd, -
)

current_date=$(date +%F)
first_weekday=$(date -d "$year-$month-01" +%u) # (1 = Monday, 7 = Sunday)
days_in_month=$(date -d "$year-$month-01 +1 month -1 day" +%d)

# Previous month info
prev_year=$(date -d "$year-$month-01 -1 month" +%Y)
prev_month=$(date -d "$year-$month-01 -1 month" +%m)
next_year=$(date -d "$year-$month-01 +1 month" +%Y)
next_month=$(date -d "$year-$month-01 +1 month" +%m)
days_in_prev_month=$(date -d "$prev_year-$prev_month-01 +1 month -1 day" +%d)

# Start from the Monday before the first day of the current month
days_from_prev_month=$((first_weekday - 1))
start_day=$((days_in_prev_month - days_from_prev_month + 1))

total_slots=42 # 6 weeks × 7 days
current_month_day=1
next_month_day=1
output="["
group="["
k=0

for ((i = 0; i < total_slots; i++)); do
  if ((i < days_from_prev_month)); then
    day=$((start_day + i))
    entry="{
      \"day\": $day,
      \"current\": false,
      \"outer\": true
    }"
  elif ((current_month_day <= days_in_month)); then
    day_date=$(date -d $year-$month-$current_month_day +%F)
    current=false
    if [ "$day_date" = "$current_date" ]; then current=true; fi

    entry="{
      \"day\": $current_month_day,
      \"current\": $current,
      \"outer\": false
    }"
    ((current_month_day++))
  else
    entry="{
      \"day\": $next_month_day,
      \"current\": false,
      \"outer\": true
    }"
    ((next_month_day++))
  fi

  if (( k == 0 )); then
    group="[$entry"
    ((k++))
  elif (( k < 6 )); then
    group="$group, $entry"
    ((k++))
  elif (( k == 6 )); then
    group="$group, $entry]"
    k=0

    if (( i == 6 )); then
      output="$output$group"
    else
      output="$output, $group"
    fi
  fi
done

weeks="$output]"

echo "{\
  \"year\": $year,
  \"month\": {
    \"name\": \"$month_name\",
    \"number\": $((10#$month))
  },
  \"weeks\": $weeks,
  \"days\": [${weekdays[@]}]
}"
