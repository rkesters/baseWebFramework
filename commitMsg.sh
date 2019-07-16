#!/bin/bash

# This way you can customize which branches should be skipped when
# prepending commit message.
if [ -z "$BRANCHES_TO_SKIP" ]; then
    BRANCHES_TO_SKIP=(master)
fi
input=($HUSKY_GIT_PARAMS)

# Some GIT Clients will pass an non-existent file name (e.g. GIT-GUI)
# this will ensure the file exists.
if [ ! -f ${input[0]} ]; then
    touch ${input[0]}
fi

BRANCH_NAME=$(git symbolic-ref --short HEAD)
BRANCH_NAME="${BRANCH_NAME##*/}"
BRANCH_NAME="${BRANCH_NAME%%#[a-zA-Z0-9]*}"

BRANCH_EXCLUDED=$(printf "%s\n" "${BRANCHES_TO_SKIP[@]}" | grep -c "^$BRANCH_NAME$")

BRANCH_IN_COMMIT=$(grep -c "^$BRANCH_NAME:" ${input[0]})

FIXUP_IN_COMMIT=$(grep -c "^fixup! " ${input[0]})
SQUASH_IN_COMMIT=$(grep -c "^squash! " ${input[0]})

if [ -n "$BRANCH_NAME" ] && ! [[ $BRANCH_EXCLUDED -eq 1 ]] && ! [[ $BRANCH_IN_COMMIT -ge 1 ]] && ! [[ $FIXUP_IN_COMMIT -ge 1 ]] && ! [[ $SQUASH_IN_COMMIT -ge 1 ]]; then
    sed -i.bak -e "1s/^/$BRANCH_NAME: /" ${input[0]}
fi