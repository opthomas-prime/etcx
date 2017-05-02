#!/usr/bin/env bash

function check_user_exists {
    getent passwd $1 > /dev/null
}

function check_group_exists {
    getent group $1 > /dev/null
}

function get_hostname {
    echo `hostname`
}

function extract_username {
    echo $1 | grep -Po '[^.]+(?=@[^@]+$)'
}

function extract_hostname {
    echo $1 | grep -Po '[^@]+$'
}

function extract_targetfile {
    echo $1 | grep -Po '[^.].+(?=.etcx.*$)'
}

function get_source_mode {
    stat -c '%a' $1
}

function install_file {
    owner=`extract_username $1`
    target_file=`extract_targetfile $1`
    target_mode=`get_source_mode $1`

    check_user_exists $owner
    if [ $? -ne 0 ]; then
        echo unknown user $owner
        return
    fi

    check_group_exists $owner
    if [ $? -ne 0 ]; then
        echo unknown group $owner
        return
    fi

    if [ ! -d `dirname $target_file` ]; then
        echo missing target folder for $target_file
        return
    fi

    cmd="install --no-target-directory --owner=${owner} --group=${owner} --mode='${target_mode}' ${1} ${target_file}"
    echo $cmd
    eval $cmd
}

function main {
    cd fsroot

    for file in `find . -type f -name '*@all'`; do
        install_file $file
    done

    hostname=`get_hostname`
    for file in `find . -type f -not -name '*@all'`; do
        for_host=`extract_hostname $file`
        if [ "$hostname" = "$for_host" ]; then
            install_file $file
        fi
    done
}

main
