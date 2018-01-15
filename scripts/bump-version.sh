#!/bin/bash
VERSION=${1:?}
CURRENT=${2:-`cmdshelf --version`}
git grep -l $CURRENT | xargs sed -i "" -e "s/${CURRENT}/${VERSION}/g"
