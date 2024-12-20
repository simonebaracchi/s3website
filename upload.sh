#!/usr/bin/env bash

home=`dirname -- "$( readlink -f -- "$0"; )";`
source $home/config.sh

bucket=$(get_bucket)
on_error The bucket name is unspecified. Cannot continue.

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
