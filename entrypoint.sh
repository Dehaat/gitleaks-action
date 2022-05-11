#!/bin/bash

function default() {
    local _default="${1}"
    local _result="${2}"
    local _val="${3}"
    local _defaultifnotset="${4}"

    if [[ "${_defaultifnotset}" == "true" ]]; then
        if [ "${#_val}" = 0 ]; then
            echo "${_default}"
            return
        fi
    fi

    if [[ "${_val}" != "${_default}" ]]; then
        echo "${_result}"
    else
        echo "${_val}"
    fi
}

INPUT_CONFIG_PATH="$1"
CONFIG=""
INPUT_FAIL=$(default 'true' 'false' "${INPUT_FAIL}" 'true')

# check if a custom config have been provided
if [ -f "$GITHUB_WORKSPACE/$INPUT_CONFIG_PATH" ]; then
  CONFIG=" --config-path=$GITHUB_WORKSPACE/$INPUT_CONFIG_PATH"
fi

echo running gitleaks "$(gitleaks --version) with the following command👇"

DONATE_MSG="👋 maintaining gitleaks takes a lot of work so consider sponsoring me or donating a little something\n\e[36mhttps://github.com/sponsors/zricethezav\n\e[36mhttps://www.paypal.me/zricethezav\n"

if [ "$GITHUB_EVENT_NAME" = "push" ]
then
  echo gitleaks --path=$GITHUB_WORKSPACE --verbose --redact --report-path=$GITHUB_WORKSPACE/gitleaks-report.json $CONFIG
  CAPTURE_OUTPUT=$(gitleaks --path=$GITHUB_WORKSPACE --verbose --redact $CONFIG)
elif [ "$GITHUB_EVENT_NAME" = "pull_request" ]
then 
  git --git-dir="$GITHUB_WORKSPACE/.git" log --left-right --cherry-pick --pretty=format:"%H" remotes/origin/$GITHUB_BASE_REF... > commit_list.txt
  echo gitleaks --path=$GITHUB_WORKSPACE --verbose --redact --commits-file=commit_list.txt $CONFIG
  CAPTURE_OUTPUT=$(gitleaks --path=$GITHUB_WORKSPACE --verbose --redact --commits-file=commit_list.txt $CONFIG)
fi

if [ $? -eq 1 ]
then
  GITLEAKS_RESULT=$(echo -e "\e[31m🛑 STOP! Gitleaks encountered leaks")
  echo "$GITLEAKS_RESULT"
  echo "::set-output name=exitcode::1"
  echo "----------------------------------"
  echo "$CAPTURE_OUTPUT"
  echo "::set-output name=result::$CAPTURE_OUTPUT"
  echo "----------------------------------"
  echo -e $DONATE_MSG
  if [ "${INPUT_FAIL}" = "true" ]; then
      echo "::error::${GITLEAKS_RESULT}"
      exit 1
  else
      echo "::warning::${GITLEAKS_RESULT}"
  fi
else
  GITLEAKS_RESULT=$(echo -e "\e[32m✅ SUCCESS! Your code is good to go!")
  echo "$GITLEAKS_RESULT"
  echo "::set-output name=exitcode::0"
  echo "------------------------------------"
  echo -e $DONATE_MSG
fi
