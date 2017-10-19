#!/bin/bash

set -eu
set -o pipefail

source .env

function fetch_users() {
  curl --silent --show-error "https://slack.com/api/users.list?token=$SLACK_API_TOKEN" | jq -r '.members | map(select(.is_bot == false and .deleted == false and .is_restricted == '"$INCLUDE_RESTRICTED"')) | map(.name + "\t" + .profile.image_72)[]'
}

function filter_users() {
  users="$1"

  # filter not target user
  if [[ "$EMOJI_TARGET" != "*" ]]; then
    users="$(echo "$users" | grep "$EMOJI_TARGET")"
  fi

  # filter ignore users
  join -v 1 <(echo "$users" | sort -u) <(echo "$IGNORE_USERS" | tr ',' '\n' | sort -u)
}

function fetch_avatar_image() {
  users="$1"

  ## reset emoji_dir
  rm -rf "$EMOJI_DIR"
  mkdir "$EMOJI_DIR"

  ## fetch avatars
  echo "$users" | while read -r name avatar
  do
    first=$(echo "$name" | cut -c1)
    last=$(echo "$name" | cut -c2-)
    file_name="${first}_${last}"
    wget --no-verbose --output-document "$EMOJI_DIR/$file_name.jpg" "$avatar"
    sleep 0.5
  done
}

users=$(fetch_users)
filtered_users=$(filter_users "$users")
fetch_avatar_image "$filtered_users"
python ./slack-emojinator/upload.py "${EMOJI_DIR}"/*
