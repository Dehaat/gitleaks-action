#!/bin/bash
echo "hello"
printenv
if [ "$GITHUB_EVENT_NAME" = "push" ]
then 
  echo "this is a push";
fi

if [ "$GITHUB_EVENT_NAME" = "pull_request" ]
then 
  echo "pull_request";
fi 

echo "$GITHUB_EVENT_NAME"
echo "???"

gitleaks --help
gitleaks --version

echo $GITHUB_WORKSPACE
ls -al /github/workspace/
ls -al /github/

gitleaks --repo-path=$GITHUB_WORKSPACE --verbose

echo "aint shit here?"

echo "we need two commits to test?"
