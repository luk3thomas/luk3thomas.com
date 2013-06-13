---
layout: post
category: Programming
tags: [WordPress]
title: Moving WordPress MultiSite to different domain
---

## Update the database

It seems like a lot of [people](http://wordpress.org/support/topic/transfer-multisite-to-another-server#post-1957979) have [trouble](http://www.totalcomputersusa.com/2012/11/moving-wordpress-multisite-to-a-new-domainserver/) moving a WordPress Multisite from one server to another.

Here is my process for transferring multisites.

1. Dump the database
1. Use `sed` to replace the old domain name with the new domain name
1. Re-import the new database

        mysqldump -uroot some_database | sed 's/olddomain.com/newdomain.com/g' | mysql -uroot some_other_database

1. Update the `.htaccess` file, if it is a sub directory install

        RewriteBase /                   # <= Fix the base
        RewriteRule ^index\.php$ - [L]

1. Update the `wp-config.php` file

        define('DOMAIN_CURRENT_SITE', 'newdomain.com');  # <= Replace the old domain
