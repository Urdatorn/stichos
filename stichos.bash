#!/usr/bin/env bash

# Directory with TSV files
dir=~/git/stichos/tsv/

# Determine which files to use based on argument
case "$1" in
    homer)
        files=("$dir"/HH* "$dir"/iliad* "$dir"/odyssey*)
        ;;
    homer-didnt-exist)
        # All files except those starting with HH, iliad, or odyssey
        all_files=("$dir"/*)
        files=()
        for f in "${all_files[@]}"; do
            base=$(basename "$f")
            if [[ ! "$base" =~ ^(HH|iliad|odyssey) ]]; then
                files+=("$f")
            fi
        done
        ;;
    *)
        files=("$dir"/*)
        ;;
esac

# Pick a random file from the list
randfile="${files[RANDOM % ${#files[@]}]}"
filename=$(basename "$randfile" .tsv)

# Pick a random line from that file
line=$(shuf -n 1 "$randfile")

# Split the line into tabs
IFS=$'\t' read -r tab0 tab1 tab2 tab3 _ <<< "$line"

# Colors
GREEN="\033[32m"
YELLOW="\033[33m"
RESET="\033[0m"

# Print tab0 in green
echo -e "${GREEN}${tab0}${RESET}"

# Print dotted line of the same length
printf '%*s\n' "${#tab0}" '' | tr ' ' '.'

# Print source and metadata
echo -e "${YELLOW}Source:${RESET} ${filename}"
echo -e "${YELLOW}Scansion:${RESET} ${tab1}"
echo -e "${YELLOW}Metre:${RESET} ${tab2}"
echo -e "${YELLOW}Caesurae:${RESET} ${tab3}"