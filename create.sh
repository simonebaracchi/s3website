#!/usr/bin/env bash

on_error() {
    error=$?
    if [ $error -ne 0 ]; then
        echo $@
        echo Exiting with error code $error
        exit $error
    fi
}


read -r -p 'Website name: ' bucket

echo Confirm that the website name is \"$bucket\"?
select yn in "Yes" "No"; do
    case $yn in
        Yes ) break;;
        No ) exit;;
    esac
done

echo $bucket > bucketname
on_error Cannot save the bucket name to file? Are we on a readonly filesystem?

aws s3api create-bucket --bucket $bucket
on_error Cannot create bucket

aws s3 website s3://$bucket --index-document index.html --error-document error.html
on_error Cannot configure bucket for static website hosting

aws s3api delete-public-access-block --bucket $bucket
on_error Cannot enable public access on bucket

sed "s/WEBSITE_NAME_HERE/$bucket/g" policy.json.template > policy.json
on_error Cannot generate policy file. Maybe check the website name has no special characters in it?

aws s3api put-bucket-policy --bucket $bucket --policy file://policy.json
on_error Cannot apply policy

echo Done!
