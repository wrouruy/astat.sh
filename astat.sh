#!/usr/bin/env bash

prefix=''

load() {
    local name

    # ls -A | grep $prefix
    # echo $prefix
    el=(..)
    while IFS= read -r name; do
        el+=("$name")
    done < <(ls -A | grep "$prefix")
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
    printf '\033[7m %s | %s \033[0m' "$PWD" "$prefix"
}

load
draw

RUNNING=true

finish() {
    RUNNING=false
}

trap finish INT TERM

while [[ "$RUNNING" == true ]]; do
    key=

    if ! IFS= read -rsn1 -t 0.2 key; then
        [[ "$RUNNING" == false ]] && break
        continue
    fi

    if [[ "$key" == $'\e' ]]; then
        rest=
        IFS= read -rsn2 -t 0.05 rest
        key+="$rest"
    fi

    [[ "$RUNNING" == false ]] && break

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
                prefix=''
                load
            fi
            ;;
        q | Q | $'\e') # quit
            finish
            ;;
        $'\x7f' | $'\b') # backspace
            [[ "$prefix" == "" ]] || prefix=${prefix::-1}
            load
            ;;
        *)
            prefix+=$key
            load
            ;;
    esac

    [[ "$RUNNING" == true ]] && draw
done

trap - INT TERM
printf '\033[H\033[J'
