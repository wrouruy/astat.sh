#!/usr/bin/env bash

prefix=''

script_path="$(readlink -f "${BASH_SOURCE[0]}")"
script_dir="$(dirname "$script_path")"

source "$script_dir/load.sh"
source "$script_dir/draw.sh"

load
draw

is_running=true

finish() {
    is_running=false
}

trap finish INT TERM

while [[ "$is_running" == true ]]; do
    key=

    if ! IFS= read -rsn1 -t 0.2 key; then
        [[ "$is_running" == false ]] && break
        continue
    fi

    if [[ "$key" == $'\e' ]]; then
        rest=
        IFS= read -rsn2 -t 0.05 rest
        key+="$rest"
    fi

    [[ "$is_running" == false ]] && break

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

    [[ "$is_running" == true ]] && draw
done

trap - INT TERM
printf '\033[H\033[J'
