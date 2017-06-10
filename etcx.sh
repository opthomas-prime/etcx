#!/usr/bin/env bash

function install_etcx_file {
    owner=`echo $1 | grep -Po '[^.]+(?=@[^@]+$)'`
    file=`echo $1 | grep -Po '[^.].+(?=.etcx.*$)'`
    mode=`stat -c '%a' $1`

    getent passwd $owner > /dev/null
    if [ $? -ne 0 ]; then echo "unknown user ${owner}, skipping ${file}" && return; fi

    getent group $owner > /dev/null
    if [ $? -ne 0 ]; then echo "unknown group ${owner}, skipping ${file}" && return; fi

    if [ ! -d `dirname $file` ]; then echo "missing target directory, skipping ${file}" && return; fi

    cmd="install --no-target-directory --owner=$owner --group=$owner --mode='$mode' $1 $file"

    echo $cmd
    if [ $DRYRUN -eq 0 ]; then
        eval $cmd
    fi
}

USAGE="$0 [-d] [-s sourcedir]
-d dryrun (only print the install commands)
-s source directory (defaults to ./etc)
"
DRYRUN=0
while getopts "hds:" opt; do
    case ${opt} in
        h ) printf "$USAGE" && exit 0;;
        d ) DRYRUN=1;;
        s ) SOURCE_DIR=$OPTARG;;
    esac
done

if [ -z $SOURCE_DIR ]; then SOURCE_DIR=./etc; fi
if [ ! -d $SOURCE_DIR ]; then
    echo "source directory doesn't exist"
    exit 1
fi

cd $SOURCE_DIR

for file in `find . -type f -name '*@all'`; do
    install_etcx_file $file
done

hostname=`hostname`
for file in `find . -type f -not -name '*@all'`; do
    for_host=`echo $file | grep -Po '[^@]+$'`
    if [ "$hostname" = "$for_host" ]; then
        install_etcx_file $file
    fi
done
