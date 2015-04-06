#!/bin/bash

pimp(){
    die(){
        echo "EXIT"
        return 1
    }

    PIMP_PROJECT_ROOT=`pwd`
    if [ ! -d `pwd`/venv ]
    then
        if git rev-parse --show-toplevel &>/dev/null
        then
            PIMP_PROJECT_ROOT=`git rev-parse --show-toplevel`
        elif hg root &>/dev/null
        then
            PIMP_PROJECT_ROOT=`hg root`
        fi
    fi

    if [ $1 = "init" ]
    then
        pyvenv --without-pip $PIMP_PROJECT_ROOT/venv || die
        cd $PIMP_PROJECT_ROOT/venv
        source bin/activate
        if ! ls bin/pip &>/dev/null
        then
            wget https://bootstrap.pypa.io/get-pip.py || die
            python get-pip.py || die
        fi
        cd $PIMP_PROJECT_ROOT
        touch requirements.txt
        if git rev-parse --show-toplevel &>/dev/null || ! hg root &>/dev/null
        then
            git init
            echo "/venv/" >> .gitignore
        fi
        deactivate
        echo "DONE!"
        return
    fi

    if [ ! -d $PIMP_PROJECT_ROOT/venv ]
    then
        echo "could not find venv dir"
        echo "there should be a venv directory in current path or project root"
        die
    fi

    case $1 in
    "activate")
        source $PIMP_PROJECT_ROOT/venv/bin/activate
        ;;
    "deactivate")
        deactivate
        ;;
    "shell")
        source $PIMP_PROJECT_ROOT/venv/bin/activate
        python
        deactivate
        ;;
    "run")
        if [ -z $2 ]
        then
            echo "pimp run <script.py>"
            die
        else
            source $PIMP_PROJECT_ROOT/venv/bin/activate
            python $2
            deactivate
        fi
        ;;
    *)
        echo "other"
        ;;
    esac
}

_pimp(){
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
complete -F _pimp pimp
