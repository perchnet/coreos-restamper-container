#!/bin/bash
echo Extracting...
pv() {
    if command -v pv &> /dev/null; then
        command pv -f "${@}"
    else
        dd if="${1}" bs=1M status=progress
    fi
}
FILE="$(find . -type f -name '*.xz' | head -1)"
pv "${FILE}" | xz -d --stdout > "${FILE%.xz}"
