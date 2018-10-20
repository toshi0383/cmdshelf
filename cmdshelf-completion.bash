# Bash completion script for cmdshelf.

_cmdshelf() {
    local commands command cur prev
    commands="cat list ls remote run update"

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
        remote)
            COMPREPLY=($(compgen -W 'add list remove' -- ${cur}))
            return 0
            ;;
        list|ls)
            COMPREPLY=($(compgen -W '--path' -- "${cur}"))
            return 0
            ;;
        run)
            if [ $COMP_CWORD -le 2 ]; then
                COMPREPLY=($(compgen -W "$(cmdshelf list | awk -F: '{print $2}')" -- "${cur}"))
            else

                # NOTE: available on bash 4 or later
                compopt -o filenames cmdshelf 2>/dev/null
                compgen -f /non-existing-dir/ >/dev/null

                COMPREPLY=($(compgen -df -- "$cur"))
            fi

            return 0
            ;;
        cat)
            COMPREPLY=($(compgen -W "$(cmdshelf list | awk -F: '{print $2}')" -- "${cur}"))

            return 0
            ;;
    esac
}

# https://www.gnu.org/software/bash/manual/html_node/A-Programmable-Completion-Example.html

complete -o bashdefault -F _cmdshelf cmdshelf
