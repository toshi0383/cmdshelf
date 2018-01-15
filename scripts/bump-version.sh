#!/bin/bash
VERSION=${1:?}
CURRENT=${2:-`cmdshelf --version`}
sed -i "" -e "s/master/${VERSION}/" CHANGELOG.md
git grep -l $CURRENT | grep -v CHANGELOG.md | xargs sed -i "" -e "s/${CURRENT}/${VERSION}/g"
