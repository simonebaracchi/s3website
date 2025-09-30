### S3 Website toolkit ###

## What is this ##

This is a collection of scripts to create and manage and S3 bucket to be used for static website hosting.

It is meant to simplify the procedure of creating a website on S3 and setting up SSL via Cloudfront.

Creating a website on AWS S3 has several advantages:
  - Price: a small website, serving 100kBs of data per user, should cost around 9$ per million visits;
  - Scale: traffic can easily scale up and down and bills will change accordingly;
  - Performances: definitely faster than a cheap vps, also allows for distributed global caching via Cloudfront;
  - Serverless: one less thing to manage;
  - Not necessarily static: the content itself can actually be easily updated via APIs, either via AWS Lambda or another computing instance running somewhere else (whose specs can be significantly smaller compared to a website meant to serve millions of users). 

## System setup ##

Install and configure awscli, certbot, jq (pip3 install --upgrade awscli ; apt install certbot jq)

## Credentials setup ##

Decide the website name. Usually something like www.example.com.

Create a suitable AWS user and credentials pair (eg via the AWS console). Such user should have at least
  - permission to write to S3 bucket
  - permission to import certificates in ACM (if using SSL)
  - permission to create distribution in Cloudfront (if using SSL).

See user_permissions.json for an example permissions schema.

Then insert the credentials in the AWS cli tool:

`# export AWS_PROFILE=www.example.com`

`# aws configure`

## Create the website ##

Run `./create.sh`. The script will:

  - Create a s3 bucket (using the name you will provide)
  - configure bucket for static website hosting
  - configure bucket policy for public read

Then, copy all files to the bucket. The "upload.sh" helper tool may be used. For example, if your pages are in the `src` directory:

`# cd src`

`# path_to_script/upload.sh *`

## Setup domain name and SSL ##

Buy the domain, then run `./cloudfront.sh`. The script will:

  - Attempt to create a SSL certificate via Let's encrypt. The default is the "manual" challenge so you will have to upload a file to the bucket to proceed with SSL certificate generation.
  - Upload the certificate to AWS Certificate Manager
  - Create a Cloudfront distribution that will use the S3 bucket and the SSL certificate to serve content.

The DNS domain should now be configured to redirect (via CNAME alias) to the Cloudfront distribution.

## Update certificate ##

Run `update_cert.sh`. Upload the challenge string if needed
