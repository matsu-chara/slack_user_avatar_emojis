## slack_user_avatar_emojis

[![Build Status](https://travis-ci.org/matsu-chara/slack_user_avatar_emojis.svg?branch=master)](https://travis-ci.org/matsu-chara/slack_user_avatar_emojis)

automate user avatars to emoji

ex. user: `matsu_chara` ==> emoji: `:m_atsu_chara:`

## usage

1. `git submodule update --init`
1. `cd slack-emojinator && pyenv virtualenv slack-emojinator 3.6.3 && pyenv local slack-emojinator && pip install -r requirements.txt && cd ..`
1. `cp .env.example .env`
1. `$EDITOR .env`
1. `./run.sh` (it execute `source .env`, so enviroment variable might be overwrriten.)

## how it works?

1. get user lists via https://api.slack.com/methods/users.list
1. wget it
1. remove current emojis
1. register by slack-emojinator
