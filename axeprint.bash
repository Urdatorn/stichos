#!/bin/bash

# Usage: ./print_purple.sh filename.txt

file="$1"

if [[ ! -f "$file" ]]; then
    echo "Error: file not found: $file"
    exit 1
fi

# ANSI color code for purple (magenta)
PURPLE='\033[0;35m'
RESET='\033[0m'

while IFS= read -r line; do
    echo -e "${PURPLE}${line}${RESET}"
done < "$file"