#!/usr/bin/env bash

home=`dirname -- "$( readlink -f -- "$0"; )";`
source $home/config.sh

bucket=$(get_bucket)
on_error Cannot load bucket name. 
region=$(get_region)
on_error Cannot load region name.
bucket_url=$(get_bucket_url $bucket $region)

certbot certonly --manual --preferred-challenges http -d $bucket
on_error Certificate generation cannot complete. 
cert_file=/etc/letsencrypt/live/$bucket/cert.pem
cert_full=/etc/letsencrypt/live/$bucket/fullchain.pem
cert_priv=/etc/letsencrypt/live/$bucket/privkey.pem

out=`aws acm import-certificate --certificate fileb://$cert_file --private-key fileb://$cert_priv --certificate-chain fileb://$cert_full --region $region`
on_error Certificate import failed.
arn=`echo $out | jq -r '.CertificateArn'`

sed -e "s#BUCKET_HERE#$bucket#g ; s#REGION_HERE#$region#g ; s#CERT_ARN_HERE#$arn#g" $home/distribution.json.template > $home/distribution.json
aws cloudfront create-distribution --distribution-config file://$home/distribution.json | tee /tmp/cloudfront-output
on_error Cannot create Cloudfront distribution.

domain=`cat /tmp/cloudfront-output | jq -r '.Distribution.DomainName'`
echo The distribution is ready.
echo You should update the DNS CNAME record to point at:
echo https://$domain

