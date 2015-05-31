#!/bin/bash

set -e # exit with nonzero exit code if anything fails

# clear and re-create the build directory
rm -rf build || exit 0;
mkdir build;

repo="${GITHUB_REPO}"

#printf '%s\n' "Github repo is $repo"

# If GITHUB_REPO is an ssh URI, change it to the GitHub equivalent https URL:
repo=$(echo "$repo" | sed 's/^git@github.com:/https:\/\/github.com\//')
#printf '%s\n' "Converted repo is $repo"
# now ensure that the https:// scheme prefix is stripped so we can add in the token:
repo=$(echo "$repo" | sed 's/^https:\/\///')
#printf '%s\n' "Schemeless repo is $repo"
# now add in the scheme and token:
repo="https://${GH_TOKEN}@$repo"
#printf '%s\n' "Tokenized repo is $repo"

# run our build script - this will create the rendered HTML that we'll push to the site
#printf '%s\n' "Before build.sh"
./build.sh
#printf '%s\n' "After build.sh"

# if Travis is building a pull request to master, don't deploy - we only want to deploy
# when data is actually merged to master:
if [ -n "${TRAVIS_PULL_REQUEST}" ] && (( "${TRAVIS_PULL_REQUEST}" > 0 )); then
    printf '%s\n' "Pull request detected.  Not deploying site master."
    exit 0;
fi

# go to the build directory and create a *new* Git repo
cd build
git init

# inside this git repo we'll pretend to be a new user
git config user.name "Travis CI on behalf of ${GIT_EMAIL}"
git config user.email "${GIT_EMAIL}"

# The first and only commit to this new Git repo contains all the
# files present with the commit message "Deploy to GitHub Pages".
git add .
git commit -m "Deploy to GitHub Pages"

# Force push from the current repo's master branch to the remote
# repo's master branch. (All previous history on the remote master branch
# will be lost, since we are overwriting it.) We redirect any output to
# /dev/null to hide any sensitive credential data that might otherwise be exposed.
git push --force --quiet "$repo" master:master > /dev/null 2>&1
