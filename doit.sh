#!/bin/bash
gcc -x c $1 -E 2> /dev/null | sed -n '/"wrap.h" 2/,$p' | grep -v '^#' | xargs | tr -s ' ' | python3 wrap.py $2
