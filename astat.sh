#!/usr/bin/env bash

load() {
    local name

    el=(..)
    while IFS= read -r name; do
        el+=("$name")
    done < <(ls -A)
    n=${#el[@]}

    idx=0
    top=0
}

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
    printf '\033[7m %s \033[0m' "$PWD"
}

load
draw

while true; do
    IFS= read -rsn1 key || break

    if [[ "$key" == $'\e' ]]; then
        IFS= read -rsn2 rest || break
        key+="$rest"
    fi

    case "$key" in
    $'\e[A') # up
        (( idx = (idx - 1 + n) % n ))
        ;;
    $'\e[B') # down
        (( idx = (idx + 1) % n ))
        ;;
    '' | $'\n' | $'\r') # enter
        if [[ -d "${el[idx]}" ]]; then
            cd -- "${el[idx]}" || continue
            load
        fi
        ;;
    esac

    draw
done
