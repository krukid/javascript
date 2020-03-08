#!/bin/bash
#
# https://steamcommunity.com/app/645630/discussions/1/1470840994967333584/

PATCHMODE="$1"
rollback() {
    test "${PATCHMODE}" = "rollback"
}

TARGETDIR="Cars/"
PATCHDIR="Cars-Patch/"
BACKUPDIR="Cars-Backup/"

if rollback; then
    SOURCEDIR="${BACKUPDIR}"
else
    SOURCEDIR="${PATCHDIR}"
fi

YESTOALL=0
prompt() {
    if [[ $YESTOALL = 1 ]]; then
        return 0
    fi
    local char
    read -r -p "$1 [All|Y|N]: " char
    case "${char,,}" in
        all)
            YESTOALL=1
        ;;
        yes|y)
        ;;
        *)
            return 1
        ;;
    esac
}

for file in $(find "${SOURCEDIR}" -name name.txt); do
    relative="${file#${SOURCEDIR}}"
    target="${TARGETDIR}${relative}"

    echo
    if rollback; then
        echo "restoring: ${target}..."
    else
        echo "patching: ${target}..."
    fi

    if diff -y --suppress-common-lines "${target}" "${file}"; then
        echo "no difference found, skipping..."
        continue
    fi

    echo
    if ! prompt "confirm change?"; then
        echo "skipping..."
        continue
    fi

    if ! rollback; then
        backup="${BACKUPDIR}${relative}"
        if ! (mkdir -p $(dirname "${backup}") && cp "${target}" "${backup}"); then
            echo "failed to backup file, skipping..."
            continue
        fi
    fi

    if cp "${file}" "${target}"; then
        echo "ok!"
    else
        echo "fail :("
    fi
done
