# Getting Started Tutorial

[Note]
Because I'm using mac to write this tutorial, this tutorial expects `macOS` environment.
If you use Linux, some scripts may not work.
Especially, `/dev/fd/0` might be in different location.
Please `sed` them as you need. (PR welcomed)

# Setup your remote
You can add a whole repository to treat every executables as a command.
An executable don't have to be a shellscript. It can be any executable. That's said, it can be..

- ShellScript
- Ruby script
- Perl script
- Swift script
- a.out

Make sure though, to put `shebang` at first line of your script. `cmdshelf` uses POSIX `exec` family to execute a command, and `exec` tries to read `shebang`. For detail, read `man execve`.

Also, don't forget to `chmod +x`.

So let's create your first scripts repository named `scripts` on GitHub.

<details>
<summary>See code</summary>

```console
$ mkdir -p scripts/tools
$ cat > scripts/tools/cat.sh
#!/bin/bash
fd=${1:-/dev/fd/0}
while read line; do echo $line; done < $fd
(ctrl + D)
$ chmod +x scripts/tools/cat.sh
$ cd scripts
$ git init; git add .; git commit -m "initial"
$ hub create # if `hub` is not installed, create one on GitHub.
Updating origin
https://github.com/you/scripts
$ git push
```

</details>

Now you've created `tools/cat.sh` command at your repository.

# `remote`

Now add your repo as cmdshelf's **remote**. This is done as following.

```console
$ cmdshelf remote add you git@github.com:you/scripts.git
```

This will clone your `scripts` repo at `~/.cmdshelf/remote/you/` and register remote alias as `you`.

It's all setup!

# `run`
This is how it goes when you launch your awesome, the coolest, super useful `tools/cat.sh` command from your shelf.

```console
$ cmdshelf run tools/cat.sh ~/.cmdshelf.yml
remote:
  you:
    url: git@github.com:you/scripts.git
```

<details>
<summary>Side note</summary>

> This is the yml format we use internally. Normally you don't have to care about this file, but remember that you can directly browse and edit it when something is wrong.

</details>

You're already familiar with UNIX `cat` utility, right? It treats every arguments as files, if not given. It tries to read from `stdin` to relay buffer to `stdout`, until it reaches `EOF`.

Even via `cmdshelf`, you have no concern. File descriptor for `stdout` `stderr` `stdin` is inherited from your command-line. You can connect other tools output via pipe intuitively.

```console
$ echo hello world | cmdshelf run tools/cat.sh
hello world
```

# `list` / `ls`

You can list remote content by `list`.

```console
$ cmdshelf list
remote:
  you:
    tools/cat.sh
```

It's not exciting at all, but remember you can obtain absolute location by using `--path` option.

```console
$ cmdshelf ls --path
remote:
  you:
    /Users/you/.cmdshelf/remote/you/tools/cat.sh
```

# `cat`
Want to see your script's content? `cmdshelf cat` might be useful.

```console
$ cmdshelf cat tools/cat.sh
#!/bin/bash
fd=${1:-/dev/fd/0}
while read line; do echo $line; done < $fd
```

# Advanced `run` usage

## Passing arguments and options
You don't need to quote or anything. Just pass them as needed. `cmdshelf` doesn't steal your arguments. (Even `--help` option is reserved for you.)

```console
$ cmdshelf run tools/echo.sh hello world --verbose
[verbose] Detailed echo output
hello world
[verbose] Finish
```

## Namespace for remotes
What if you register Tom's script repo and he also had `tools/cat.sh`?
```console
$ cmdshelf run tools/cat.sh
```

Which one gets executed is undefined. So let's be explicit.

```console
$ cmdshelf run you:tools/cat.sh
$ cmdshelf run tom:tools/cat.sh
```

# `update`
Finally, to keep updated to your latest remote, run following.

```console
$ cmdshelf update
[you] Updating ... success
[tom] Updating ... success
```

# Summary
Done! Thanks for taking a first look with us. It was easy, right? Please give feedback about what you think.

`cmdshelf` is useful for team development. Easy to setup and share common scripts between collegues or other teams. It gives huge flexibility and reusability compared to commiting scripts directly into your projects repo.
Even if you work individually, it's easy to share your scripts between multiple computers.

`cmdshelf` also avoids potential name collision via `$PATH`, simply by not using it.

If you need any help, feel free post question to GitHub issue, or ping [@toshi0383](https://twitter.com/toshi0383/) on Twitter. Happy to help!😄
