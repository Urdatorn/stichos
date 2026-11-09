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

# Print one axe line: its leading line number in purple, a space, then the
# verse itself in its symmetric rainbow coloring
color_axe_line() {
    local i=$1
    local axe_line=$2
    local num rest
    if [[ "$axe_line" =~ ^([0-9]+)(.*)$ ]]; then
        num="${BASH_REMATCH[1]}"
        rest="${BASH_REMATCH[2]}"
    else
        num=""
        rest="$axe_line"
    fi

    local body_color
    case $i in
        0|11) body_color="$WHITE" ;;   # 1st and 12th lines
        1|10) body_color="$BLUE" ;;    # 2nd and 11th lines
        2|9)  body_color="$PINK" ;;    # 3rd and 10th lines
        3|8)  body_color="$RED" ;;     # 4th and 9th lines
        4|7)  body_color="$YELLOW" ;;  # 5th and 8th lines
        5|6)  body_color="$GREEN" ;;   # 6th and 7th lines
        *)    body_color="" ;;         # any other lines (fallback)
    esac

    printf "${PURPLE}${num}${RESET} ${body_color}${rest}${RESET}"
}

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

# Widest axe line (minimum 67, +1 for the extra space after the line number)
# and widest info line, to see if they fit side by side
axe_max_width=67
for axe_line in "${axe_lines[@]}"; do
    if [[ $((${#axe_line} + 1)) -gt $axe_max_width ]]; then
        axe_max_width=$((${#axe_line} + 1))
    fi
done
info_max_width=0
for info_line in "${info_lines[@]}"; do
    if [[ ${#info_line} -gt $info_max_width ]]; then
        info_max_width=${#info_line}
    fi
done

if [[ $term_width -lt $((axe_max_width + 1 + info_max_width)) ]]; then
    # Not enough horizontal space: axe on top, quote info below, separated by a blank line
    for i in "${!axe_lines[@]}"; do
        color_axe_line "$i" "${axe_lines[i]}"
        echo -e "$RESET"
    done
    echo
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
    # axe width includes the extra space inserted after the line number
    axe_width=$((${#axe_line} + 1))
    if [[ $axe_width -lt 67 ]]; then
        axe_width=67  # minimum width for formatting
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

    color_axe_line "$i" "$axe_line"
    printf "%*s " "$((axe_width - ${#axe_line} - 1))" ""
    echo -e "$info_line"
done