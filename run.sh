#!/bin/bash

set -eu
set -o pipefail

source .env

rm -rf "$EMOJI_DIR"; mkdir "$EMOJI_DIR"

curl --silent --show-error "https://slack.com/api/users.list?token=$SLACK_API_TOKEN" | jq -r '.members | map(select(.is_bot == false and .deleted == false and .is_restricted == '${INCLUDE_RESTRICTED}')) | map(.name + "\t" + .profile.image_72)[]' | while read -r name avatar
do
  if [[ "$EMOJI_TARGET" == "*" ]] || [[ "$EMOJI_TARGET" == "$name" ]]; then
    first=$(echo "$name" | cut -c1)
    last=$(echo "$name" | cut -c2-)
    file_name="${first}_${last}"
    wget --no-verbose --output-document "$EMOJI_DIR/$file_name.jpg" "$avatar"
    sleep 1
  fi
done
python ./slack-emojinator/upload.py "${EMOJI_DIR}"/*
