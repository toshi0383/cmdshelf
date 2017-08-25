[![cmdshelf](https://github.com/toshi0383/assets/blob/master/cmdshelf/banner.png)](https://github.com/toshi0383/cmdshelf)

cmdshelf integrates your team's inherited awesome handy scripts like a bookshelf.
No need to deal with your `$PATH` any more.

# Requirements
## macOS Sierra+
- Xcode8.3+
- Swift3.1

## Linux
- Swift3.1

# Why
With cmdshelf, you can
- execute any scripts intuitively without manually download and configuring `$PATH`.
- store team's common scripts in a single configuration file called `.cmdshelf.yml`.

# How to use

cmdshelf
- list
- remote
- blob
- run
- update

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
Now you can pass your `random` command to `run` sub-command. Quote the whole command to pass arguments or options.
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
    sort-xcpretty-by-time
    total-test-duration
    your-command 
```

You can add multiple remotes.
```
$ cmdshelf remote add bash-snippets https://github.com/alexanderepstein/Bash-Snippets
$ cmdshelf remote list
bash-snippets: https://github.com/alexanderepstein/Bash-Snippets
toshi0383-scripts: https://github.com/toshi0383/scripts.git
```

## .cmdshelf.yml
Finally if you want to share your cmdshelf configuration with your friends or teammates, you just share `~/.cmdshelf.yml` file.

Just put `~/.cmdshelf.yml` and you are ready to go.
```
$ cp ~/Download/.cmdshelf.yml ~
$ cmdshelf remote list
bash-snippets: https://github.com/alexanderepstein/Bash-Snippets
toshi0383-scripts: https://github.com/toshi0383/scripts.git
$ cmdshelf blob list
random https://gist.githubusercontent.com/toshi0383/32728879049e95db41ab801b1f055009/raw/e84fa02c4f9ac7e08b686cee248ab72198470c0b/-
$ cmdshelf list
blob:
  random: https://gist.githubusercontent.com/toshi0383/32728879049e95db41ab801b1f055009/raw/e84fa02c4f9ac7e08b686cee248ab72198470c0b/-

remote:
  bash-snippets:
    cheat/cheat
    cloudup/cloudup
    crypt/crypt
    ...
  toshi0383-scripts:
    decimal2hex.sh
    git/git-branch-by-author
    git/replaceOriginWith.sh
    ...
$ cmdshelf run "movies/movies inception" # Run movies script from Bash-Snippets

==================================================
| Title: Inception
| Year: 2010
| Runtime: 148 min
| IMDB: 8.8/10
| Tomato: 86%
| Rated: PG-13
| Genre: Action, Adventure, Sci-Fi
| Director: Christopher Nolan
| Actors: Leonardo DiCaprio, Joseph Gordon-Levitt, Ellen Page, Tom Hardy
| Plot: A thief, who steals corporate secrets through use of dream-sharing technology, is given the inverse task of planting an idea into the mind of a CEO.
==================================================
```

## update
If you need to update cloned repository, run `update` sub-command.
```
$ cmdshelf update
[bash-snippets] Updating ... success
[md-toc] Updating ... success
[abema-ios-script] Updating ... success
[toshi0383-scripts] Updating ... success
```

# Install
## macOS
### install.sh
I've written install/release scripts for SwiftPM executable.  
This should be the easiest way.
```
bash <(curl -sL https://raw.githubusercontent.com/toshi0383/scripts/master/swiftpm/install.sh) toshi0383/cmdshelf
```

### brew tap (beta)
cmdshelf is available via homebrew. Run following to install.
```
brew tap toshi0383/cmdshelf
brew install cmdshelf
```
This runs install.sh behind the scene.

brew exits with "Empty Installation" error, but install succeeds.

### Build from source

Please build from source-code if `install.sh` didn't work.

- Clone this repo and run `swift build -c release`.  
- Executable will be created at `.build/release/cmdshelf`.
- `mv .build/release/cmdshelf /usr/local/bin/`

## Linux
### Build from source

Please build from source code for Linux. You need Swift installed.

- Clone this repo and run `swift build -c release`.
- Executable will be created at `.build/release/cmdshelf`.
- `mv .build/release/cmdshelf /usr/local/bin/`

Here is the script I use on Bitrise CI, to install Swift and then cmdshelf.
```bash
#!/bin/bash
set -e
sudo apt-get -y install libcurl4-openssl-dev clang libicu-dev
eval "$(curl -sL https://gist.githubusercontent.com/kylef/5c0475ff02b7c7671d2a/raw/9f442512a46d7a2af7b850d65a7e9bd31edfb09b/swiftenv-install.sh)"
swiftenv install 3.1
swift build -c release
.build/release/cmdshelf --version
```

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

# Special Thanks to
- My wife for creating a daruma icon.
