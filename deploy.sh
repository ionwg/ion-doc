#!/bin/bash

# clear and re-create the build directory
rm -rf build || exit 0;
mkdir build;

REPO="${GITHUB_REPO}"
EMAIL="${GIT_EMAIL}"
TOKEN="${GH_TOKEN}"

if [ -z "${REPO}" ]; then
    REPO="git@github.com:ionwg/ionwg.github.io.git"
    printf '%s\n' "GITHUB_REPO value not set - using default value ${REPO}"
fi
if [ -z "${EMAIL}" ]; then
    EMAIL=$(git config user.email)
    [ -z "${EMAIL}" ] && echo "Required GIT_EMAIL or 'git config user.email' value has not been set." && exit 1
    printf '%s\n' "GIT_EMAIL value not set - defaulting to output of 'git config user.email': ${EMAIL}"
fi
if [ -z "${TOKEN}" ]; then
    TOKEN=$(git config --local github.token)
    [ -z "${TOKEN}" ] && echo "Required GH_TOKEN or 'git config --local github.token' value has not been set." && exit 1
    printf '%s\n' "GH_TOKEN value not set - defaulting to output of 'git config --local github.token': <hidden>"
fi

set -e # exit with nonzero exit code if anything fails from here on

# If GITHUB_REPO is an ssh URI, change it to the GitHub equivalent https URL:
REPO=$(echo "${REPO}" | sed 's/^git@github.com:/https:\/\/github.com\//')
# now ensure that the https:// scheme prefix is stripped so we can add in the token:
REPO=$(echo "${REPO}" | sed 's/^https:\/\///')
# now add in the scheme and token:
REPO="https://${TOKEN}@${REPO}"

# run our build script - this will create the rendered HTML that we'll push to the site
./build.sh

# if Travis is building a pull request to master, don't deploy - we only want to deploy
# when data is actually merged to master:
if [ -n "${TRAVIS_PULL_REQUEST}" ] && (( "${TRAVIS_PULL_REQUEST}" > 0 )); then
    printf '%s\n' "Pull request detected.  Not deploying site master."
    exit 0;
fi

# copy over any other site assets that need to be in the site:
cp google19ce5eacdd2e0f09.html build

# go to the build directory and create a *new* Git repo
cd build
git init

# inside this git repo we'll pretend to be a new user
git config user.email "${EMAIL}"
git config user.name "Travis CI on behalf of ${EMAIL}"

# The first and only commit to this new Git repo contains all the
# files present with the commit message "Deploy to GitHub Pages".
git add .
git commit -m "Deploy to GitHub Pages"

# Force push from the current repo's master branch to the remote
# repo's master branch. (All previous history on the remote master branch
# will be lost, since we are overwriting it.) We redirect any output to
# /dev/null to hide any sensitive credential data that might otherwise be exposed.
git push --force --quiet "${REPO}" master:master > /dev/null 2>&1
