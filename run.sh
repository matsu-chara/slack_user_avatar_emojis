#!/bin/bash

set -eu
set -o pipefail

source .env

function _get_file_name() {
  name="$1"

  first=$(echo "$name" | cut -c1)
  last=$(echo "$name" | cut -c2-)
  echo "${first}_${last}"
}

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
    file_name=$(_get_file_name "$name")
    wget --no-verbose --output-document "$EMOJI_DIR/$file_name.jpg" "$avatar"
    sleep 0.5
  done
}

function remove_avatar_image() {
  users="$1"
  echo "$users" | while read -r name avatar
  do
    file_name=$(_get_file_name "$name")
    echo "removing $file_name"
    curl -X POST -w "\n" -F "name=$file_name" -F "token=$SLACK_API_TOKEN_FOR_DELETE" "https://folio-sec.slack.com/api/emoji.remove"
    sleep 0.5
  done

}

users=$(fetch_users)
filtered_users=$(filter_users "$users")
fetch_avatar_image "$filtered_users"
remove_avatar_image "$filtered_users"
python ./slack-emojinator/upload.py "${EMOJI_DIR}"/*
