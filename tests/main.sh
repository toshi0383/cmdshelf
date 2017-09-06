#!/bin/bash
STATUS=0
set +e

CMDSHELF=.build/debug/cmdshelf

before_all() {
    cp ~/.cmdshelf.yml ~/.cmdshelf.yml.bk
}

after_all() {
    echo All tests finished
    cat ~/.cmdshelf.yml
    cp ~/.cmdshelf.yml.bk ~/.cmdshelf.yml
}

before_each() {
    rm ~/.cmdshelf.yml
    $CMDSHELF remote add _toshi0383 https://github.com/toshi0383/scripts.git
    $CMDSHELF remote add _cmdshelf-remote https://toshi0383@bitbucket.org/toshi0383/cmdshelf-remote-test.git
    $CMDSHELF run a 2> /dev/null # Assuming `~/.cmshelf/remote` is cached once updated.
    # rm -rf ~/.cmdshelf
    # $CMDSHELF update
}

teardown() {
    :
}

before_all

###
### Arguments tests
###
echo Arguments tests started

## 001: Passes parameters correctly
before_each
printf '#!/bin/bash\necho $#' > 001.sh && chmod +x 001.sh
$CMDSHELF blob add _001.sh 001.sh
if [ 3 -ne $($CMDSHELF run "_001.sh a b c") ];then
    echo 001 FAILED
    STATUS=1
fi

###
### Remote tests
###
echo Remote tests started

## 001: `run` detects remote name correctly
before_each
$CMDSHELF remote add _toshi0383 https://github.com/toshi0383/scripts.git
$CMDSHELF remote add _cmdshelf-remote https://toshi0383@bitbucket.org/toshi0383/cmdshelf-remote-test.git
if [ "dummy" != "$($CMDSHELF run _cmdshelf-remote:swiftpm/install.sh)" ];then
    echo 001 FAILED
    STATUS=1
fi

## 002: `run` detects remote name correctly when added order is different
before_each
$CMDSHELF remote add _cmdshelf-remote https://toshi0383@bitbucket.org/toshi0383/cmdshelf-remote-test.git
$CMDSHELF remote add _toshi0383 https://github.com/toshi0383/scripts.git
if [ "dummy" != "$($CMDSHELF run _cmdshelf-remote:swiftpm/install.sh)" ];then
    echo 002 FAILED
    STATUS=1
fi

## 003: `cat` detects remote name correctly
before_each
$CMDSHELF remote add _toshi0383 https://github.com/toshi0383/scripts.git
$CMDSHELF remote add _cmdshelf-remote https://toshi0383@bitbucket.org/toshi0383/cmdshelf-remote-test.git
$CMDSHELF cat _cmdshelf-remote:swiftpm/install.sh > a
if ! diff a $($CMDSHELF list --path | grep _cmdshelf-remote/swiftpm/install.sh)
then
    echo 003 FAILED
    STATUS=1
fi

## 004: `cat` detects remote name correctly when added order is different
before_each
$CMDSHELF remote add _cmdshelf-remote https://toshi0383@bitbucket.org/toshi0383/cmdshelf-remote-test.git
$CMDSHELF remote add _toshi0383 https://github.com/toshi0383/scripts.git
$CMDSHELF cat _cmdshelf-remote:swiftpm/install.sh > a
if ! diff a $($CMDSHELF list --path | grep _cmdshelf-remote/swiftpm/install.sh)
then
    echo 004 FAILED
    STATUS=1
fi

after_all

exit $STATUS
