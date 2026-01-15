#!/bin/sh
# Weather script for regreet display
# Uses OpenWeatherMap API to get current temperature

KEY="3dc0aa05ee355a7c41afd2bcb1a4c7d3"
CITY="Melbourne,AU"
UNITS="metric"
SYMBOL="°"

API="https://api.openweathermap.org/data/2.5"

current=$(curl -sf "$API/weather?appid=$KEY&q=$CITY&units=$UNITS")

if [ -n "$current" ]; then
    current_temp=$(echo "$current" | jq ".main.temp" | cut -d "." -f 1)
    current_icon=$(echo "$current" | jq -r ".weather[0].icon")
    
    # Get weather description
    description=$(echo "$current" | jq -r ".weather[0].description" | sed 's/.*/\u&/')
    
    echo "$current_temp$SYMBOL $description"
else
    echo "N/A"
fi
