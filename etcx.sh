#!/usr/bin/env bash

function install_etcx_file {
    owner=`echo $1 | grep -Po '[^.]+(?=@[^@]+$)'`
    file=`echo $1 | grep -Po '[^.].+(?=.etcx.*$)'`
    mode=`stat -c '%a' $1`

    echo $owner
    echo $file
    echo $mode

    return

    getent passwd $1 > /dev/null
    if [ $? -ne 0 ]; then return; fi

    getent group $1 > /dev/null
    if [ $? -ne 0 ]; then return; fi

    if [ ! -d `dirname $target_file` ]; then return; fi

    cmd="install --no-target-directory --owner=$owner --group=$owner --mode='$target_mode' $1 $target_file"

    if [ -n $DRYRUN ]; then
        echo $cmd
    else
        eval $cmd
    fi
}

USAGE="$0 [-d] [-s sourcedir]
-d dryrun (just prints the install commands)
-s source directory (defaults to ./etc)
"

while getopts "hds:" opt; do
    case ${opt} in
        h ) printf "$USAGE" && exit 0;;
        d ) DRYRUN=1;;
        s ) SOURCE_DIR=$OPTARG;;
    esac
done

if [ -z $SOURCE_DIR ]; then SOURCE_DIR=./etc; fi

cd $SOURCE_DIR

for file in `find . -type f -name '*.etcx.*@all'`; do
    install_etcx_file $file
done

exit 0

hostname=`hostname`
for file in `find . -type f -not -name '*@all'`; do
    for_host=`echo $file | grep -Po '[^@]+$'`
    if [ "$hostname" = "$for_host" ]; then
        install_etcx_file $file
    fi
done
