#!/bin/bash

set -eu
set -o pipefail

source .env

function _get_file_name() {
  name="$1"

  if [ "$EMOJI_NAME_TYPE" = "split" ]; then
    first=$(echo "$name" | cut -c1)
    last=$(echo "$name" | cut -c2-)

    ## replace invalid chars
    echo "${first}_${last}" | tr "." "_" | tr " " "_"
  elif [ "$EMOJI_NAME_TYPE" = "raw" ]; then
    echo "$name"
  else
    echo "error: unsupported $EMOJI_NAME_TYPE."
    exit 1
  fi
}

function fetch_users() {
  curl --silent --show-error "https://slack.com/api/users.list?token=$SLACK_API_TOKEN" | jq -r '.members | map(select(.is_bot == false and .deleted == false and (.is_restricted == false or .is_restricted == '"$INCLUDE_RESTRICTED"'))) | map(.profile.display_name + "\t" + .profile.image_72)[]'
}

function filter_users() {
  users="$1"
  target_user="$2"

  # filter not target user
  if [[ "$target_user" != "*" ]]; then
    users="$(join <(echo "$users" | sort -u) <(echo "$target_user" | tr ',' '\n' | sort -u))"
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

function replace_avatar() {
  users="$1"
  echo "$users" | while read -r name avatar
  do
    file_name=$(_get_file_name "$name")
    echo "removing $file_name"
    curl -X POST -w "\n" -F "name=$file_name" -F "token=$SLACK_API_TOKEN_FOR_DELETE" "https://${SLACK_TEAM}.slack.com/api/emoji.remove"
    python ./slack-emojinator/upload.py "$EMOJI_DIR/$file_name.jpg"
    sleep 0.5
  done
}

# argument
# $1 EMOJI_TARGET. will overwride $EMOJI_TARGET via `.env`
if [ "$#" -gt 0 ]; then
  target_user="$1"
else
  target_user="$EMOJI_TARGET"
fi

users=$(fetch_users)
filtered_users=$(filter_users "$users" "$target_user")
fetch_avatar_image "$filtered_users"
replace_avatar "$filtered_users"
