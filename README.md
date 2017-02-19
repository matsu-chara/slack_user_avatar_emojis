## slack_user_avatar_emojis

automate user avatars to emoji

ex. user: `matsu_chara` ==> emoji: `:m_atsu_chara:`

## usage

1. get token via https://api.slack.com/docs/oauth-test-tokens
1. get slack session. ref: https://github.com/smashwilson/slack-emojinator
1. `git submodule update --init`
1. `cd slack-emojinator && pyenv virtualenv slack-emojinator && pip install -r requirements.txt && cd ..`
1. `cp .env.example .env`
1. `$EDITOR .env`
1. `./run.sh` (it execute `source .env`, so enviroment variable might be overwrriten.)

## how it works?

1. get user lists via https://api.slack.com/methods/users.list
1. wget it
1. register by slack-emojinator
