#!/bin/sh

log=""

while IFS= read -r line; do
    if printf '%s\n' "$line" | grep -q "Session\|BeReq" > /dev/null; then
        printf '%s\n' "$line"
    elif [ -z "$line" ]; then 
        if [ -n "$log" ]; then
            jo result="$log" > /dev/stdout || exit 1
        fi
        log=""
    else
        log="$log$line\n"
    fi
done