#!/usr/bin/env bash

load() {
    local name

    el=(..)
    while IFS= read -r name; do
        el+=("$name")
    done < <(ls -A | grep "$prefix")
    n=${#el[@]}

    idx=0
    top=0
}