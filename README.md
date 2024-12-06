### S3 Website toolkit ###

## What is this ##

This is a collection of scripts to create and manage and S3 bucket to be used for static website hosting.

It is meant to simplify the procedure of creating a website on S3.

Creating a website on AWS S3 may have advantages (namely, price and performances) and is perfectly suitable for "static" websites, where "static" means that the same content will be available to all users. The content itself can actually be easily updated, either via AWS Lambda or another computing instance running somewhere else (whose specs can be significantly smaller compared to a website meant to serve millions of users). S3 has a great capability of "scaling down", where a small website, serving 100kBs of data per user, can cost around 9$ per million visits, and scale linearly up and down.

## Setup ##

Install and configure awscli

## Create the website ##

Decide the website name.

Then run `./create.sh`. The script will:

  - Create a s3 bucket (using the name you will provide)
  - configure bucket for static website hosting
  - configure bucket policy for public read

Then, copy all files to the bucket. The "upload.sh" helper tool may be used.

When done, setup the DNS domain (not included in this script).


