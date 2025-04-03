#!/usr/bin/env bash

home=`dirname -- "$( readlink -f -- "$0"; )";`
source $home/config.sh

read -r -p 'Website name: ' bucket

echo Confirm that the website name is \"$bucket\"?
select yn in "Yes" "No"; do
    case $yn in
        Yes ) break;;
        No ) exit;;
    esac
done

echo $bucket > $home/bucketname
on_error Cannot save the bucket name to file? Are we on a readonly filesystem?

aws s3api create-bucket --bucket $bucket
on_error Cannot create bucket

aws s3 website s3://$bucket --index-document index.html --error-document error.html
on_error Cannot configure bucket for static website hosting

aws s3api delete-public-access-block --bucket $bucket
on_error Cannot enable public access on bucket

sed "s/WEBSITE_NAME_HERE/$bucket/g" $home/policy.json.template > $home/policy.json
on_error Cannot generate policy file. Maybe check the website name has no special characters in it?

aws s3api put-bucket-policy --bucket $bucket --policy file://policy.json
on_error Cannot apply policy

aws s3api put-bucket-cors --bucket $bucket --cors-configuration '{
    "CORSRules": [
        {
            "AllowedOrigins": ["*"],
            "AllowedMethods": ["GET", "HEAD"],
            "AllowedHeaders": ["*"],
            "ExposeHeaders": ["ETag"],
            "MaxAgeSeconds": 3000
        }
    ]
}'

echo Done!

region=$(get_region)
echo The bucket is available at:
echo $(get_bucket_url $bucket $region)
echo $(get_website_url $bucket $region)
