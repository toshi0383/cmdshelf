# Bash completion script for cmdshelf.

_cmdshelf() {
    local commands command cur prev
    commands="blob cat list ls remote run update"

    command="${COMP_WORDS[1]}"
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    if [ $COMP_CWORD == 1 ]
    then
        COMPREPLY=($(compgen -W "${commands}" -- ${cur}))
        return 0
    fi

    if [ $COMP_CWORD == 2 -a "${command}" == help ]
    then
        COMPREPLY=($(compgen -W "${commands}" -- ${cur}))
        return 0
    fi

    case "${command}" in
        blob|remote)
            COMPREPLY=($(compgen -W 'add list remove' -- ${cur}))
            return 0
            ;;
        list|ls)
            COMPREPLY=($(compgen -W '--path' -- ${cur}))
            return 0
            ;;
        run)
            COMPREPLY=($(compgen -W "$(cmdshelf list | grep -v ':')" -- ${cur}))
            return 0
            ;;
    esac
}

complete -F _cmdshelf cmdshelf
