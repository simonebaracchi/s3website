#!/usr/bin/env bash


on_error() {
    error=$?
    if [ $error -ne 0 ]; then
        echo $@
        echo Exiting with error code $error
        exit $error
    fi
}

get_region() {
    region=`aws configure get region`
    if [ $? -ne 0 ]; then
        region="us-east-1"
    fi
    echo $region
}

get_bucket() {
    home=`dirname -- "$( readlink -f -- "$0"; )";`
    bucket=`cat $home/bucketname`
    if [ $bucket = "" ]; then
        return 1
    fi
    echo $bucket
}

get_bucket_url() {
    echo https://$1.s3.$2.amazonaws.com
}
get_website_url() {
    echo https://$1.s3-website-$2.amazonaws.com
}
