#!/bin/bash
#
# WARNING!: currently this test modifies your local environment
#
STATUS=0
set +e

CMDSHELF="./target/debug/cmdshelf"

before_all() {
    cp ~/.cmdshelf.toml ~/.cmdshelf.toml.bk
}

after_all() {
    echo All tests finished
    cp ~/.cmdshelf.toml.bk ~/.cmdshelf.toml
}

before_each() {
    rm ~/.cmdshelf.toml
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
### Remote tests
###
echo Remote tests started

## 000: `remote` handles shorthand alias for github repo
before_each
$CMDSHELF remote add test000 toshi0383/scripts
if [ "$($CMDSHELF remote list | grep test000)" != "test000:git@github.com:toshi0383/scripts.git" ];then
    echo 000 FAILED
    STATUS=1
fi

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

if [ "${VERSION}" != "2.0.2" ];then
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
RESULT="$((for i in a b; do echo $i | $CMDSHELF run 014.sh; done) | wc -l)"
if [ $RESULT -ne 2 ];then
    echo 'expected 2 but got ' $RESULT
    echo 014 FAILED
    STATUS=1
fi

## 015: execute non-shell script (perl)
before_each
TEST_015_PL=~/.cmdshelf/remote/_cmdshelf-remote/015.pl
printf "#!/usr/bin/perl -w\nmy (\$a, \$b) = @_;" > $TEST_015_PL

chmod +x $TEST_015_PL
if ! $CMDSHELF run 015.pl
then
    echo 015 FAILED
    STATUS=1
fi

## 016: execute non-shell script (swift)
before_each
TEST_016_SWIFT=~/.cmdshelf/remote/_cmdshelf-remote/016.swift
printf "#!/usr/bin/swift\nimport Foundation\nprint(ProcessInfo.processInfo.arguments)" > $TEST_016_SWIFT

chmod +x $TEST_016_SWIFT
if ! $CMDSHELF run 016.swift a b c | grep '"a", "b", "c"' > /dev/null 2>&1
then
    echo 016 FAILED
    STATUS=1
fi

## 017: execute non-shell script (swift binary)
before_each
TEST_017_ECHO_SH=~/.cmdshelf/remote/_cmdshelf-remote/017_echo.sh
printf "#!/bin/bash\necho \$#" > $TEST_017_ECHO_SH
chmod +x $TEST_017_ECHO_SH
TEST_017_SWIFT=~/.cmdshelf/remote/_cmdshelf-remote/017_cmdshelf
cp $CMDSHELF $TEST_017_SWIFT

if [ 3 -ne $($CMDSHELF run 017_cmdshelf run 017_echo.sh a b c) ];then
    echo 017 FAILED
    STATUS=1
fi

## 018: exit status 1 with invalid arguments
before_each

$CMDSHELF aaa > /dev/null 2>&1
exit_status=$?

if [ $exit_status -ne 1 ];then
    echo Exit code is expected to be 1 but was $exit_status
    echo 018 FAILED
    STATUS=1
fi

## 019: exit status 1 with invalid arguments
before_each

$CMDSHELF run aaa > /dev/null 2>&1
exit_status=$?

if [ $exit_status -ne 1 ];then
    echo Exit code is expected to be 1 but was $exit_status
    echo 019 FAILED
    STATUS=1
fi

## 020: exit status 1 with invalid arguments
before_each

$CMDSHELF cat aaa > /dev/null 2>&1
exit_status=$?

if [ $exit_status -ne 1 ];then
    echo Exit code is expected to be 1 but was $exit_status
    echo 020 FAILED
    STATUS=1
fi

## 021: exit status 1 with invalid arguments
before_each

$CMDSHELF remote aaa > /dev/null 2>&1
exit_status=$?

if [ $exit_status -ne 1 ];then
    echo Exit code is expected to be 1 but was $exit_status
    echo 021 FAILED
    STATUS=1
fi

## 022: exit status 1 with invalid arguments
before_each

$CMDSHELF remote add a > /dev/null 2>&1
exit_status=$?

if [ $exit_status -ne 1 ];then
    echo Exit code is expected to be 1 but was $exit_status
    echo 022 FAILED
    STATUS=1
fi

## 023: exit status 1 with invalid arguments
before_each

$CMDSHELF remote remove > /dev/null 2>&1
exit_status=$?

if [ $exit_status -ne 1 ];then
    echo Exit code is expected to be 1 but was $exit_status
    echo 023 FAILED
    STATUS=1
fi

## 024: exit status 1 with invalid arguments
before_each

$CMDSHELF remote remove aaa > /dev/null 2>&1
exit_status=$?

if [ $exit_status -ne 1 ];then
    echo Exit code is expected to be 1 but was $exit_status
    echo TODO: 024 FAILED
    # TODO
    #STATUS=1
fi

# Cleanup
after_all

exit $STATUS
