#!/bin/bash
set -x

sudo apt-get update
sudo apt-get -y install git rsync python3-sphinx

pwd ls -lah
export SOURCE_DATE_EPOCH=$(git log -1 --pretty=%ct)


#######################
# BUILD DOCUMENTATION #
#######################

make clean
make github

#######################
# Update Github Pages #
#######################

git config --global user.name "${GITHUB_ACTOR}"
git config --global user.email "${GITHUB_ACTOR}@users.noreply.github.com"

docroot=`mktemp -d`
rsync -av "build/html/" "${docroot}/docs/"

pushd "${docroot}"

git init
git remote add deploy "https://token:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git"
git checkout -b gh-pages

touch .nojekyll

cat > README.md <<EOF
# README
This branch is a cache for the website served from https://RickGelhausen.github.io/blog_posts/.

EOF

git add .

msg="Updating Documentation for commit ${GITHUB_SHA} made on `date -d"@${SOURCE_DATE_EPOCH}" --iso-8601=seconds` from ${GITHUB_REF} by ${GITHUB_ACTOR}"
git commit -am "${msg}"

# deploy gh-pages
git push deploy gh-pages --force

# return to main repo sandbox root
popd

# exit cleanly
exit 0
