#!/usr/bin/env bash

readarray -t el < <(ls --color=no -a)

for i in "${el[@]}"; do
    [[ -e "$i" ]] || continue

    printf '%s' "$i"
    [ -d "$i" ] && printf "/"
    printf "\n"
done

n=${#el[@]}
idx=0

printf '\033[%dA' "$n"

plain() { printf '\033[2K\r%s' "${el[idx]}"; }
marked() { printf '\033[2K\r\033[0;47m%s\033[0m' "${el[idx]}"; }

marked

while true; do
    IFS= read -rsn1 key || break

    if [[ "$key" == $'\e' ]]; then
        IFS= read -rsn2 rest || break
        key+="$rest"
    fi

    case "$key" in
    $'\e[A') # up
        plain
        if (( idx > 0 )); then
            printf '\033[1A'
            (( idx-- ))
        else
            (( idx = n - 1 ))
            (( n > 1 )) && printf '\033[%dB' $(( n - 1 ))
        fi
        marked
        ;;
    $'\e[B') # down
        plain
        if (( idx < n - 1 )); then
            printf '\033[1B'
            (( idx++ ))
        else
            (( idx = 0 ))
            (( n > 1 )) && printf '\033[%dA' $(( n - 1 ))
        fi
        marked
        ;;
    esac
done

printf '\n'
