#!/usr/bin/env bash

on_error() {
    error=$?
    if [ $error -ne 0 ]; then
        echo $@
        echo Exiting with error code $error
        exit $error
    fi
}

bucket=$( cat bucketname )

if [ "$bucket" -eq "" ]; then
    echo The bucket name is unspecified. Cannot continue.
    exit 1
fi

aws s3 cp "$1" s3://$bucket --recursive
on_error Error uploading bucket data. Exiting.
