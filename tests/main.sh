#!/bin/bash
#
# WARNING!: currently this test modifies your local environment
#
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
    $CMDSHELF run a 2> /dev/null # trigger clone repos under `~/.cmshelf/remote`
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

## 000: Passes parameters correctly
before_each
printf '#!/bin/bash\necho $#' > 001.sh && chmod +x 001.sh
$CMDSHELF blob add _001.sh 001.sh
if [ 3 -ne $($CMDSHELF run _001.sh a b c) ];then
    echo 000 FAILED
    STATUS=1
fi

###
### Remote tests
###
echo Remote tests started

## 001: `run` detects remote name correctly
before_each
if [ "dummy" != "$($CMDSHELF run _cmdshelf-remote:swiftpm/install.sh)" ];then
    echo 001 FAILED
    STATUS=1
fi

## 002: `run` detects remote name correctly when added order is different
before_each
if [ "dummy" != "$($CMDSHELF run _cmdshelf-remote:swiftpm/install.sh)" ];then
    echo 002 FAILED
    STATUS=1
fi

## 003: `cat` detects remote name correctly
before_each
$CMDSHELF cat _cmdshelf-remote:swiftpm/install.sh > a
if ! diff a $($CMDSHELF list --path | grep _cmdshelf-remote/swiftpm/install.sh)
then
    echo 003 FAILED
    STATUS=1
fi

## 004: `cat` detects remote name correctly when added order is different
before_each
$CMDSHELF cat _cmdshelf-remote:swiftpm/install.sh > a
if ! diff a $($CMDSHELF list --path | grep _cmdshelf-remote/swiftpm/install.sh)
then
    echo 004 FAILED
    STATUS=1
fi

## 005: `run` passes each parameters correctly
before_each
TEST_005_SH=~/.cmdshelf/remote/_cmdshelf-remote/005.sh
cat > $TEST_005_SH << EOF
#!/bin/bash
echo \$1
echo \$2
echo \$3
echo \$4
echo \$5
echo \$6
EOF
chmod +x $TEST_005_SH

TMP_005=$(mktemp)
$CMDSHELF run 005.sh 001a 002b '003cd ef' '004\"&*><hello' '005\\' 006world > $TMP_005
if ! diff fixtures/test-005.expected $TMP_005
then
    echo 005 FAILED
    STATUS=1
fi

rm $TMP_005 $TEST_005_SH

## 006: `run` treats whole quoted arguments as an alias
before_each

TEST_006_EXPECTED="cmdshelf: ${HOME}/.cmdshelf/remote/_cmdshelf-remote/006.sh 001a 002b: No such command"
TEST_006_SH=~/.cmdshelf/remote/_cmdshelf-remote/006.sh
printf "#!/bin/bash\necho \$1" > $TEST_006_SH
chmod +x $TEST_006_SH

TMP_006=$(mktemp)

$CMDSHELF run "006.sh 001a 002b" 2> $TMP_006

if [[ "$(cat $TMP_006)" =~ "${TEST_006_EXPECTED}" ]]
then
    echo "${TEST_006_EXPECTED}"
    echo "$(cat $TMP_006)"
    echo 006 FAILED
    STATUS=1
fi

rm $TMP_006 $TEST_006_SH

## 007: [run] exit status code
before_each

$CMDSHELF run no-such-command 2> /dev/null
exit_status=$?

if [ $exit_status -ne 1 ]
then
    echo Exit code is expected to be 1 but was $exit_status
    echo 007 FAILED
    STATUS=1
fi

## 008: [cat] exit status code
before_each

$CMDSHELF cat nsc01 nsc02 2> /dev/null
exit_status=$?

if [ $exit_status -ne 1 ]
then
    echo Exit code is expected to be 1 but was $exit_status
    echo 008 FAILED
    STATUS=1
fi

## 009: [run] underlying exit status code
before_each

TEST_009_SH=~/.cmdshelf/remote/_cmdshelf-remote/009.sh
printf "#!/bin/bash\nexit 1" > $TEST_009_SH
chmod +x $TEST_009_SH

$CMDSHELF run 009.sh
exit_status=$?

if [ $exit_status -ne 1 ]
then
    echo Exit code is expected to be 1 but was $exit_status
    echo 009 FAILED
    STATUS=1
fi

rm $TEST_009_SH

## 010: [list] execution succeeds
before_each
$CMDSHELF list > /dev/null
exit_status=$?

if [ $exit_status -ne 0 ];then
    echo Exit code is expected to be 0 but was $exit_status
    echo 010 FAILED
    STATUS=1
fi

## 011: [--version] execution succeeds
before_each
VERSION=$($CMDSHELF --version)
exit_status=$?

if [ "${VERSION}" != "0.9.6" ];then
    echo \-\-version printed invalid value: $VERSION
    echo 011 FAILED
    STATUS=1
fi

if [ $exit_status -ne 0 ];then
    echo Exit code is expected to be 0 but was $exit_status
    echo 011 FAILED
    STATUS=1
fi

## 012: [--help] execution succeeds
before_each
$CMDSHELF --help > /dev/null
exit_status=$?

if [ $exit_status -ne 0 ];then
    echo Exit code is expected to be 0 but was $exit_status
    echo 012 FAILED
    STATUS=1
fi

## 013: correctly handle stdin
before_each
TEST_013_SH=~/.cmdshelf/remote/_cmdshelf-remote/013.sh
printf "#!/bin/bash\nread line;echo \$line" > $TEST_013_SH
chmod +x $TEST_013_SH
RESULT="$(echo a | $CMDSHELF run 013.sh)"
if [ $RESULT != "a" ];then
    echo 'expected "a" but got ' $RESULT
    echo 013 FAILED
    STATUS=1
fi

## 014: correctly handle stdin in for-loop
before_each
TEST_014_SH=~/.cmdshelf/remote/_cmdshelf-remote/014.sh
printf "#!/bin/bash\nread line;echo \$line" > $TEST_014_SH
chmod +x $TEST_014_SH
RESULT="(for i in a b; do echo $i | $CMDSHELF run 014.sh; done) | wc -l"
if [ $RESULT -ne 2 ];then
    echo 'expected 2 but got ' $RESULT
    echo 014 FAILED
    STATUS=1
fi

# Cleanup
after_all

exit $STATUS
