#!/bin/bash

windows=$(eww active-windows)

if [[ $windows != *"calendar"* ]]; then
  eww update calendar_data="$(~/.config/eww/scripts/calendar/data.sh)"
fi

eww open --toggle calendar-closer
eww open --toggle calendar
