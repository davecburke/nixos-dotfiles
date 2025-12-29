#!/usr/bin/env bash
let HISTORY="$(dunstctl count history)"
let WAITING="$(dunstctl count waiting)"
let COUNT=HISTORY+WAITING
echo $COUNT
