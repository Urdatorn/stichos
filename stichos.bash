#!/usr/bin/env bash

# Directory with TSV files
dir=~/git/stichos/tsv/

# Pick a random file from the directory
files=("$dir"/*)
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

echo -e "${YELLOW}Source:${RESET} ${filename}"
echo -e "${YELLOW}Scansion:${RESET} ${tab1}"
echo -e "${YELLOW}Metre:${RESET} ${tab2}"
echo -e "${YELLOW}Caesurae:${RESET} ${tab3}"
