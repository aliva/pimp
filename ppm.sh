#!/bin/bash

ppm(){
    die(){
        echo "EXIT"
        return 1
    }

    find_venv_path(){
        if [ ! -d venv ] && git grev-parse --show-toplevel &>/dev/null
        then
            cd `git rev-parse --show-toplevel`
        fi
        if [ -d venv ]
        then
            VENV_PATH=`pwd`/venv
        else
            echo "could not find venv path"
            die
        fi
    }
    
    case $1 in
    "init")
        pyvenv --without-pip venv || die
        cd venv
        source bin/activate
        if ! ls bin/pip &>/dev/null
        then
            wget https://bootstrap.pypa.io/get-pip.py || die
            python get-pip.py || die
        fi
        cd ..
        touch requirements.txt
        if ! git rev-parse --show-toplevel &>/dev/null
        then
            git init
        fi
        deactivate
        echo "DONE!"
        ;;
    "activate")
        find_venv_path
        source $VENV_PATH/bin/activate
        ;;
    "deactivate")
        deactivate
        ;;
    "shell")
        find_venv_path
        source $VENV_PATH/bin/activate
        python
        deactivate
        ;;
    "run")
        if [ -z $2 ]
        then
            echo "ppm run script.py"
            die
        else
            find_venv_path
            source $VENV_PATH/bin/activate
            python $2
            deactivate
        fi
        ;;
    *)
        echo "other"
        ;;
    esac
}

_ppm(){
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    opts="init activate run deactivate shell"

    if [ $COMP_CWORD == 1 ] && [ $prev = "run" ]
    then
        _filedir
    fi

    if [ $COMP_CWORD == 1 ]
    then
        COMPREPLY=($(compgen -W "${opts}" -- ${cur}))
        return 0
    fi
}
complete -F _ppm ppm
