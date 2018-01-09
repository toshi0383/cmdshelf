[![cmdshelf](https://github.com/toshi0383/assets/blob/master/cmdshelf/banner.png)](https://github.com/toshi0383/cmdshelf)

cmdshelf integrates your team's shared scripts like a bookshelf.  
No need to deal with your `$PATH` any more.👋

# Features

- ✅ Execute any remote/local scripts intuitively.
- ✅ No more `$PATH` configurations.
- ✅ Portable environment with `.cmdshelf.yml`.
- ✅ No quoting required for passing arguments and options.
- ✅ `stdout`, `stdin`, `stderr`
- ✅ The coolest manual page.

<img src="https://github.com/toshi0383/assets/blob/master/cmdshelf/man-page.png" width="980" alt="man-page" />

You can see detailed document [here](doc/getting-started.md) or type `cmdshelf help`.

# Requirements

## macOS
- Sierra
- HighSierra

## Linux and Windows
- should work on Swift compatible distribution

# Install
## macOS
### install.sh
I've written install/release scripts for SwiftPM executable.  
This should be the easiest way.
```
bash <(curl -sL https://raw.githubusercontent.com/toshi0383/scripts/master/swiftpm/install.sh) toshi0383/cmdshelf
```

### Using [Mint](https://github.com/yonaskolb/Mint)
```
mint install toshi0383/cmdshelf
```

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
swiftenv install 4.0
swift build -c release
.build/release/cmdshelf --version
```

# Limitation on Linux
`cmdshelf` cannot handle `stdin` on Linux. This is rather Foundation's problem than cmdshelf's.

# Contribute
Any contribution is welcomed.
Feel free to open issue for bug reports, questions, or feature requests.

To start developing, clone and run following.
```
make bootstrap
```

# Development
- Xcode9+
- Swift4+

# Special Thanks to
- My wife for creating a daruma icon.
