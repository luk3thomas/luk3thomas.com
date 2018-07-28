---
publishdate: 2013-12-02
title: Middleman and AWS CLI S3 Sync
---

The [aws cli](http://aws.amazon.com/cli/) allows a command line interface with
your Amazon services.  I've recently integrated the `aws` cli with my middleman
site for syncing changes to my S3 bucket. Here is how I did it.

## Install aws cli

See the [getting started guide](http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-set-up.html).

## Store your credentials in a profile file

Create the AWS config file for storing your keys

    $ mkdir ~/.aws/
    $ touch ~/.aws/config

Add the default profile. The default profile is used when you use `aws` without
specifying a profile.

    [default]
    aws_access_key_id=AWS_ACCESS_KEY_ID
    aws_secret_access_key=AWS_SECRET_ACCESS_KEY
    region=us-east-1

Add a custom profile, if you like, to the config file `~/.aws/config`.
Honestly, I'm not sure why I use a custom profile.
I think it seemed like a good idea when I first set up `aws` :).

    [profile luk3]
    aws_access_key_id=AWS_ACCESS_KEY_ID
    aws_secret_access_key=AWS_SECRET_ACCESS_KEY
    region=us-east-1

## Sync everything to S3

For this blog I store the aws command in a Makefile. 

    deploy:
        @bundle exec middleman build
        @aws --profile=luk3 s3 sync build/ s3://luk3thomas.com/ --acl=public-read --delete --cache-control="max-age=1576800000" --exclude "*.html"
        @aws --profile=luk3 s3 sync build/ s3://luk3thomas.com/ --acl=public-read --delete --cache-control="max-age=0, no-cache" --exclude "*" --include "*.html"

1. `aws --profile=luk3` uses the profile `luk3` in the `~/.aws/config`.
1. `sync` command only syncs the changes since the last upload.
1. `build/` is the target directory where the static HTML files live.
1. `s3://luk3thomas.com/` is my bucket.
1. `--acl=public-read` makes the files viewable by everyone. See the [manual](http://docs.aws.amazon.com/cli/latest/reference/s3/sync.html) for other options.
1. `--delete` deleles any files from S3 that are not found in the `build/` directory.
1. `--cache-control="max-age=0, no-cache"` sets the cache expiration. I don't want the browser caching my static pages.
1. `--exclude "*"` exludes all files. The exclude option is used in conjunction with the `--include` option "*.html".
1. `--include "*.html"` includes all the HTML files.

For more information on the `sync` command, read the [manual](http://docs.aws.amazon.com/cli/latest/reference/s3/sync.html).
