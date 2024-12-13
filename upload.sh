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

if [ "$bucket" = "" ]; then
    echo The bucket name is unspecified. Cannot continue.
    exit 1
fi

for i in "$@"; do
    echo Copying "$i"
    if [[ -d "$i" ]]; then
        aws s3 cp "$i/" "s3://$bucket/$i/" --recursive
        on_error Error uploading directory to bucket. Exiting.
    elif [[ -f "$i" ]]; then
        aws s3 cp "$i" "s3://$bucket/" 
        on_error Error uploading file to bucket. Exiting.
    else
        echo Object $i is unsupported
        exit 1
    fi
done
