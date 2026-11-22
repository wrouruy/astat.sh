#!/usr/bin/env bash

draw() {
    local rows visible i name

    rows=$(tput lines 2>/dev/null) || rows=24
    visible=$(( rows - 1 ))
    (( visible > n )) && visible=$n

    (( idx < top ))            && top=$idx
    (( idx >= top + visible )) && top=$(( idx - visible + 1 ))

    printf '\033[H'

    for (( i = top; i < top + visible; i++ )); do
        (( i == idx )) && printf '\033[7m'
        printf '%s' "${el[i]}"
        [[ -d "${el[i]}" ]] && printf '/'
        (( i == idx )) && printf '\033[0m'
        printf '\033[K\n'
    done

    printf '\033[J'

    printf '\033[%d;1H\033[K' "$rows"
    printf '\033[7m %s | %s \033[0m' "$PWD" "$prefix"
}