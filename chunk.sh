#!/bin/bash

# path names and settings
WAV_DIR=wavs
TMP_ARCHIVE=wavs.tar.gz

SPLIT_DIR=wavs.split
SPLIT_CHUNKSIZE=50M

# make sure we've got exactly one argument
if [ $# -ne 1 ] ; then
    echo "usage: pack.sh <split|join>"
    exit 1
fi

if [ $1 = "split" ] ; then
    # check if there are any input wav files
    if ! compgen -G "$WAV_DIR/*.wav" > /dev/null ; then
        echo "no wav files found in $WAV_DIR"
        exit 1
    fi

    # compress all wav files into a tar archive
    tar -czf $TMP_ARCHIVE -C $WAV_DIR .

    # split the tar archive into multiple chunks
    mkdir -p $SPLIT_DIR
    split -b $SPLIT_CHUNKSIZE $TMP_ARCHIVE "$SPLIT_DIR/part"
elif [ $1 = "join" ] ; then
    # check if there are any input part files
#    if ! compgen -G "$SPLIT_DIR/part*" > /dev/null ; then
#        echo "no part files found in $SPLIT_DIR"
#        exit 1
#    fi

    # join all chunks together to a single tar archive
    cat $SPLIT_DIR/part* > $TMP_ARCHIVE

    # decompress the archive into multiple wav files
    rm -rf $WAV_DIR
    mkdir -p $WAV_DIR
    tar -xzf $TMP_ARCHIVE -C $WAV_DIR
else
    echo "unknown argument: $1"
    exit 1
fi

# remove the temporary archive if any
rm -f $TMP_ARCHIVE
