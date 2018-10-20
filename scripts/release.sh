#!/bin/bash

set -e

CUR_VER=$(cmdshelf --version)
NEW_VER=
./scripts/bump-version.sh $VERSION

# integration test
cargo build
./scripts/integration-tests.sh

git push --tag

### homebrew
cd /usr/local/Homebrew/Library/Taps/homebrew/homebrew-core/Formula/
sed -i "" -e "s/$CUR_VER/$NEW_VER/" cmdshelf.rb

# available after version in tarball URL updated and tag pushed
SHA256=$(brew fetch cmdshelf --build-from-source | sed -n 's/SHA256: \(.*\)/\1/p')

OLD_SHA=$(sed -n 's/.*sha256 "\(.*\)"/\1/p' cmdshelf.rb | head -1)
sed -i "" -e "s/$OLD_SHA/$SHA256/" cmdshelf.rb

MSG="cmdshelf ${NEW_VER}"
git commit -am "$MSG"
git push && hub pull-request -m "$MSG" -m "auto generated"

# See https://github.com/Homebrew/homebrew-core/pull/33201

### cargo

cargo package

echo cargo publish
