#!/usr/bin/env bash
set -ev

if [[ ! -n "${IS_LIBRARY_UPDATE}" || "${IS_LIBRARY_UPDATE}" != "true" ]]; then
  exit 0
fi

# gem prepare
gem install --no-document git_httpsable-push pull_request-create

# git prepare
git config user.name kanonji
git config user.email kanonji@users.noreply.github.com
HEAD_DATE=$(TZ=JST-9 date +%Y%m%d_%H-%M-%S)
HEAD="from-ci/update-${HEAD_DATE}"

# checkout (for TravisCI)
git checkout -b "${HEAD}" "${TRAVIS_BRANCH}"

# install
git submodule init
git submodule update

# update
git submodule foreach 'git pull origin master'

# git commit
git add -A
if [ ! -n "`git status --porcelain`" ]; then
  echo "Nothing to commit."
  exit 0
fi
git commit -m "Update ${HEAD_DATE}"

# git push
git httpsable-push origin "${HEAD}"

# pull request
pull-request-create

exit 0
