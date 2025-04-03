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

ID=`aws cloudfront list-distributions | jq -r '.DistributionList.Items[] | select(.Comment | test("'"$bucket"'")) | .Id'`
etag=`aws cloudfront get-distribution --id $ID --query "ETag" --output text`
aws cloudfront get-distribution-config --id $ID  --query 'DistributionConfig' > /tmp/cloudfront-distribution.json

jq ".ViewerCertificate.ACMCertificateArn = \"$arn\"" /tmp/cloudfront-distribution.json > /tmp/cloudfront-updated-distribution.json

aws cloudfront update-distribution --id $ID --if-match $etag --distribution-config file:///tmp/cloudfront-updated-distribution.json | tee /tmp/cloudfront-output
on_error Cannot update Cloudfront distribution.

echo The distribution is ready.

