#!/bin/bash

set -euo pipefail
PIDFILES=($(compgen -G "/tmp/flutter*.pid"))

if [[ "${1-}" != "" && ${#PIDFILES[@]} > 0 ]]; then
    echo $1
    PIDS=""
    for pf in ${PIDFILES[@]}; do
        PIDS+=$(cat $pf)
        PIDS+=" "
    done
    if [[ "$1" =~ \/state\/ || "$1" =~ backend ]]; then
        echo "Restarting ${PIDS}"
        kill -USR2 $PIDS
    else
        echo "Reloading ${PIDS}"
        kill -USR1 $PIDS
    fi
fi
