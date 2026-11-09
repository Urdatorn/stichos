#!/usr/bin/env bash

# Locate the repo relative to this script (resolving symlinks, e.g. ~/bin/stichos)
script_dir=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")

# Directory with TSV files
dir="$script_dir/tsv"

# Parse arguments
corpus=all
no_pelekys=false
for arg in "$@"; do
    case "$arg" in
        --homer) corpus=homer ;;
        --homer-didnt-exist) corpus=homer-didnt-exist ;;
        --no-pelekys) no_pelekys=true ;;
        *)
            echo "usage: stichos [--homer | --homer-didnt-exist] [--no-pelekys]" >&2
            exit 1
            ;;
    esac
done

# Determine which files to use based on corpus
case "$corpus" in
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
RED="\033[31m"
PURPLE="\033[35m"
PINK="\033[95m"
BLUE="\033[34m"
WHITE="\033[37m"
RESET="\033[0m"

# Get terminal width
term_width=$(tput cols)

# Read axe picture into array
mapfile -t axe_lines < "$script_dir/simmias_axe.txt"

# Prepare info lines
dotted_line="$(printf '%*s' "${#tab0}" '' | tr ' ' '.')"
info_lines=(
    "${GREEN}${tab0}${RESET}"
    "$dotted_line"
    ""
    "${YELLOW}Source:${RESET} ${filename}"
    "${YELLOW}Scansion:${RESET} ${tab1}"
    "${YELLOW}Metre:${RESET} ${tab2}"
    "${YELLOW}Caesurae:${RESET} ${tab3}"
)

# Blank line to separate from earlier terminal output
echo

# Without the axe, print only the info lines
if $no_pelekys; then
    for info_line in "${info_lines[@]}"; do
        if [[ ${#info_line} -gt $term_width ]]; then
            info_line="${info_line:0:$term_width}"
        fi
        echo -e "$info_line"
    done
    exit 0
fi

# Print axe and info side by side
max_lines=$((${#axe_lines[@]} > ${#info_lines[@]} ? ${#axe_lines[@]} : ${#info_lines[@]}))
for ((i=0; i<max_lines; i++)); do
    axe_line="${axe_lines[i]:-}"
    info_line="${info_lines[i]:-}"
    
    # Calculate available width for info line (terminal width - actual axe width - 1 space)
    axe_width=${#axe_line}
    if [[ $axe_width -lt 66 ]]; then
        axe_width=66  # minimum width for formatting
    fi
    info_width=$((term_width - axe_width - 1))
    
    # Ensure we don't have negative width
    if [[ $info_width -lt 1 ]]; then
        info_width=1
    fi
    
    # Truncate info line if it's too long
    if [[ ${#info_line} -gt $info_width ]]; then
        # Simple truncation - works for both plain text and ANSI codes
        info_line="${info_line:0:$info_width}"
    fi
    
    # Print axe line with symmetric rainbow coloring and white highlights (inverted order)
    case $i in
        0|11)  # 1st and 12th lines - white with first char white
            printf "${WHITE}${axe_line:0:1}${WHITE}${axe_line:1}${RESET}"
            printf "%*s " "$((axe_width - ${#axe_line}))" ""
            ;;
        1|10)  # 2nd and 11th lines - blue with first char white
            printf "${WHITE}${axe_line:0:1}${BLUE}${axe_line:1}${RESET}"
            printf "%*s " "$((axe_width - ${#axe_line}))" ""
            ;;
        2|9)   # 3rd and 10th lines - pink with first char white
            printf "${WHITE}${axe_line:0:1}${PINK}${axe_line:1}${RESET}"
            printf "%*s " "$((axe_width - ${#axe_line}))" ""
            ;;
        3)     # 4th line - red with first char white
            printf "${WHITE}${axe_line:0:1}${RED}${axe_line:1}${RESET}"
            printf "%*s " "$((axe_width - ${#axe_line}))" ""
            ;;
        8)     # 9th line - red with first char white
            printf "${WHITE}${axe_line:0:1}${RED}${axe_line:1}${RESET}"
            printf "%*s " "$((axe_width - ${#axe_line}))" ""
            ;;
        4)     # 5th line - yellow with first char white
            printf "${WHITE}${axe_line:0:1}${YELLOW}${axe_line:1}${RESET}"
            printf "%*s " "$((axe_width - ${#axe_line}))" ""
            ;;
        7)     # 8th line - yellow with first TWO chars white
            printf "${WHITE}${axe_line:0:2}${YELLOW}${axe_line:2}${RESET}"
            printf "%*s " "$((axe_width - ${#axe_line}))" ""
            ;;
        5|6)   # 6th and 7th lines - green with first two chars emphasized white
            printf "${WHITE}${axe_line:0:2}${GREEN}${axe_line:2}${RESET}"
            printf "%*s " "$((axe_width - ${#axe_line}))" ""
            ;;
        *)     # Any other lines (fallback)
            printf "%-*s " "$axe_width" "$axe_line"
            ;;
    esac
    echo -e "$info_line"
done