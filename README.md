cmdshelf
---
cmdshelf integrates your team's inherited awesome handy scripts like a bookshelf.

# Requirements
- Xcode8.3+
- Swift3.1+

# Why
With cmdshelf, you can
- execute any scripts intuitively without manually download and configuring `$PATH`.
- store team's common scripts in a single configuration file called `.cmdshelf.yml`.

# How to use

cmdshelf
- list
- remote     
- run
- update
- blob
- swiftpm
- bootstrap

## blob
You can add a single file as a blob. Make sure the URL directly points at the script. (Not a web page of gist, for example.)
```
$ cmdshelf blob add random https://gist.githubusercontent.com/toshi0383/32728879049e95db41ab801b1f055009/raw/e84fa02c4f9ac7e08b686cee248ab72198470c0b/-
```

A blob can be a local path.
```
$ cmdshelf blob add random2 ~/scripts/other-random-script.sh
```

## list
You can see registered commands by using `list` sub-command.
```
$ cmdshelf list
blob:
  random: https://gist.githubusercontent.com/toshi0383/32728879049e95db41ab801b1f055009/raw/e84fa02c4f9ac7e08b686cee248ab72198470c0b/-
```

## run
Now you can pass your `random` command to `run` sub-command. You'd be better to quote the whole command to pass arguments or options.
```
$ cmdshelf run random
$ cmdshelf run "random arg1 arg2 --option" # need quote
```

## remote
You can add a whole repository to treat every executables as command.
Add git repository URL by using `remote` sub-command.
`list` will look for any executables recursively.
```
$ cmdshelf remote add toshi0383-scripts https://github.com/toshi0383/scripts
$ cmdshelf list
remote:
  toshi0383-scripts:
    fix-framework-infoplist-if-needed.sh
    fix-framework-version.sh
    git-branch-by-author
    open-device-support-dir.sh
    pixelSize.sh
    printUUIDofMobileprovision.sh
    replaceGitOriginWith.sh
    sort-Xcode-project-file
    sort-xcpretty-by-time
    total-test-duration
    your-command 
```

You can add multiple remotes.
```
$ cmdshelf remote add exercism-bash https://github.com/exercism/bash.git
```

## Swift
You can add your favorite Swift CLI app by using `swiftpm` sub-command.
```
$ cmdshelf swiftpm add xcconfig-extractor https://github.com/toshi0383/xcconfig-extractor.git
$ cmdshelf run "xcconfig-extractor --help"

Usage:

    $ /Users/toshi0383/.cmdshelf/swiftpm/xcconfig-extractor/.build/release/xcconfig-extractor <PATH> <DIR>

Arguments:
...
```
This will clone and run `swift build -c release` before running the executable.  
Currently cmdshelf always checkouts the latest tag.

## .cmdshelf.yml
Finally if you want to share your cmdshelf configuration with your friends or teammates, you just share `~/.cmdshelf.yml` file.
```
$ cat ~/.cmdshelf.yml
remote:
  exercism-bash:
    url: https://github.com/exercism/bash.git
  toshi0383-scripts:
    url: https://github.com/toshi0383/scripts.git
blob:
  random:
    url: https://gist.githubusercontent.com/toshi0383/32728879049e95db41ab801b1f055009/raw/e84fa02c4f9ac7e08b686cee248ab72198470c0b/-
swiftpm:
  xcconfig-extractor:
    url: https://github.com/toshi0383/xcconfig-extractor.git
```

Just put `~/.cmdshelf.yml` and you are ready to go.
```
$ mv ~/Download/.cmdshelf.yml ~
$ cmdshelf remote list
exercism-bash: https://github.com/exercism/bash.git
toshi0383-scripts: https://github.com/toshi0383/scripts.git
$ cmdshelf blob list
random https://gist.githubusercontent.com/toshi0383/32728879049e95db41ab801b1f055009/raw/e84fa02c4f9ac7e08b686cee248ab72198470c0b/-
$ cmdshelf list
blob:
  random: https://gist.githubusercontent.com/toshi0383/32728879049e95db41ab801b1f055009/raw/e84fa02c4f9ac7e08b686cee248ab72198470c0b/-

remote:
  exercism-bash:
    bin/fetch-configlet
    exercises/bob/bob_test.sh
    exercises/bob/example.sh
$ cmdshelf run exercises/bob/example.sh
Fine. Be that way!
```

I recommend you to run `bootstrap` sub-command at first time.
This will clone and download all repositories and build SwiftPM executables.
```
$ cmdshelf bootstrap
```

## update
If you need to update cloned repository, run `update` sub-command.
Rebuild is performed for SwiftPM repos.

# Install
I'm planning to support homebrew in future, but please build from source-code for now.  

- Clone this repo and run `swift build -c release`.  
- Executable will be created at `.build/release/cmdshelf`.

# TODO
- Cache feature for blob
- Support Makefile...?
- Branch support for remote
- Write Tests

# Contribute
Any contribution is welcomed.
Feel free to open issue for bug reports, questions, or feature requests.

To start developing, clone and run following.
```
make bootstrap
```
