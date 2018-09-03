<p align="center">
  <a href="https://github.com/toshi0383/cmdshelf">
    <img src="https://github.com/toshi0383/assets/blob/master/cmdshelf/banner.png" alt="XcodeGen" />
  </a>
</p>
<p align="center">
  <a href="https://github.com/toshi0383/cmdshelf/releases">
    <img src="https://img.shields.io/github/release/toshi0383/cmdshelf.svg" alt="Git Version" />
  </a>
  <a href="https://github.com/toshi0383/cmdshelf/blob/master/LICENSE">
    <img src="https://img.shields.io/badge/license-MIT-lightgray.svg" alt="license" />
  </a>
</p>

cmdshelf is a new way of scripting.😎

- ✅ Seperate name space using directories (e.g. `swiftpm/install.sh` `your/tool/install.sh`)
- ✅ No more `$PATH` configurations
- ✅ bash-completion for all commands
- ✅ `stdout`, `stdin`, `stderr`
- ✅ No quoting required for arguments. (just like `swift run`)
- ✅ The coolest manual page
- ✅ Portable environment (`.cmdshelf.toml`)
- ✅ Execute any executables.

You can see detailed document [here](docs/getting-started.md), or type `man cmdshelf`.

# Install

## macOS

```
brew install cmdshelf
```

## Build from source
Note that rust is required.

```bash
git clone git@github.com:toshi0383/cmdshelf.git
cd cmdshelf
cargo build --release
cp target/release/cmdshelf /usr/local/bin
```

### Install auto bash-completion
Put this in your `~/.bashrc`,
```shell
source /path-to/cmdshelf-completion.bash
```

# Contribute
Any contribution is welcomed.
Feel free to open issue for bug reports, questions, or feature requests.
