# How to use

cmdshelf
- remote
- run
- list
- blob
- cat
- update

## remote
You can add a whole repository to treat every executables as a command.
Add git repository URL by using `remote` sub-command.
`list` will look for any executables recursively.
```
$ cmdshelf remote add your-scripts https://github.com/you/your-scripts
$ cmdshelf list
remote:
  your-scripts:
    hello-world
    your-command
    hoge/foo/bar.sh
    hoge/fuga/far.py
```

You can add multiple remotes.
```
$ cmdshelf remote add bash-snippets https://github.com/alexanderepstein/Bash-Snippets
$ cmdshelf remote list
bash-snippets: https://github.com/alexanderepstein/Bash-Snippets
toshi0383-scripts: https://github.com/toshi0383/scripts.git
```

## run
Now you can execute your command with `run` sub-command.
```
$ cmdshelf run your-command
$ cmdshelf run your-command argument and --option
```

Add remote specifier to avoid name conflict.
```
$ cmdshelf run your-scripts:your-command
$ cmdshelf run your-scripts:your-command argument and --option
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

## blob
You can add a single file as a blob. Make sure the URL directly points at the script. (Not a web page of gist, for example.)
```
$ cmdshelf blob add random https://gist.githubusercontent.com/toshi0383/32728879049e95db41ab801b1f055009/raw/e84fa02c4f9ac7e08b686cee248ab72198470c0b/-
```

A blob can be a local path.
```
$ cmdshelf blob add random2 ~/scripts/other-random-script.sh
```

Run blob using `run` sub-command.
```
$ cmdshelf run random
```

## list
As already described above, you can see registered commands by using `list` sub-command.
```
$ cmdshelf list
blob:
  random: https://gist.githubusercontent.com/toshi0383/32728879049e95db41ab801b1f055009/raw/e84fa02c4f9ac7e08b686cee248ab72198470c0b/-

remote:
  your-scripts:
    hello-world
    your-command
    hoge/foo/bar.sh
    hoge/fuga/far.py
```

## cat
You can use `cat` sub-command to print your script's source code.
```
$ cmdshelf cat random
#!/bin/bash
# SeeAlso: http://unix.stackexchange.com/questions/45404/why-cant-tr-read-from-dev-urandom-on-osx
LC_CTYPE=C tr -dc 'A-Z0-9' < /dev/urandom | head -c 32 | xargs echo
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
$ cmdshelf run movies/movies inception # Run movies script from Bash-Snippets

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

