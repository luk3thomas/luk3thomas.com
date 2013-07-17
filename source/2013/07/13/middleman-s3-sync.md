---
layout: post
title: Middleman and S3 Sync, the right way
category: Programming
tag: Coding
tags:
    - Ruby
    - S3
---

I love [Middleman](http://middlemanapp.com). I built [this](/) site with Middleman and I've used it for a number of other projects.
When it comes to syncing your site to S3, the official [middleman sync](https://github.com/karlfreeman/middleman-sync) plugin
falls a little short. You need to use [middleman s3_sync](https://github.com/fredjean/middleman-s3_sync).

The only problem I had with `middleman sync` is it didn't delete old files from S3 after upload. 
I only noticed the problem when I started using `activate :asset_hash` to fingerprint my static assets.
The documentation says to set `sync.existing_remote_files = 'delete'` to remove old files from S3, but it never worked for me. 
After some googling I saw this in the middleman s3_sync readme.

> Middleman Sync does a great job to push Middleman generated websites to S3. The only issue I have with it is that it pushes every files under build to S3 and doesn't seem to properly delete files that are no longer needed.

Once you install the gem set your caching policy for HTML files in `config.rb`

    caching_policy 'text/html', max_age: 0, must_revalidate: true