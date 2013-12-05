---
layout: post
title: WordPress submit for review error
category: Programming
tag: Coding
tags:
    - WordPress
    - MySQL
---

From time to time I encounter an odd problem in WordPress that leaves me scratching my head for a good while before I remember the solution.

## The problem

I've just imported WordPress ( or maybe not, who knows ).
I'm pushing code changes, tweaking the styling and eventually I navigate to the wp-admin dashboard to create a post.
I enter the post title and content as usual, but when I click to save the post either nothing happens or the post is marked as "Submit for review".

### Investigate the code

At this point I assume I introduced a bug into the codebase since the last release.
I might do a `git bisect` or roll my changes back to a previous version.
**Nope.
Nothing works**.
I'll even reset everything back to the initial commit.
Still, nothing works.

### Investigate the database

It is safe to assume the database is corrupt.
I'll look at the MySQL schema with a `mysqldump`. 

    mysqldump somedb -uroot -d 

    ...

    --
    -- Table structure for table `wp_posts`
    --

    DROP TABLE IF EXISTS `wp_posts`;
    /*!40101 SET @saved_cs_client     = @@character_set_client */;
    /*!40101 SET character_set_client = utf8 */;
    CREATE TABLE `wp_posts` (
      `ID` bigint(20) unsigned,
      `post_author` bigint(20) unsigned NOT NULL DEFAULT '0',
      `post_date` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
      `post_date_gmt` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
      `post_content` longtext NOT NULL,
      `post_title` text NOT NULL,
      `post_excerpt` text NOT NULL,
      `post_status` varchar(20) NOT NULL DEFAULT 'publish',
      `comment_status` varchar(20) NOT NULL DEFAULT 'open',
      `ping_status` varchar(20) NOT NULL DEFAULT 'open',
      `post_password` varchar(20) NOT NULL DEFAULT '',
      `post_name` varchar(200) NOT NULL DEFAULT '',
      `to_ping` text NOT NULL,
      `pinged` text NOT NULL,
      `post_modified` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
      `post_modified_gmt` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
      `post_content_filtered` longtext NOT NULL,
      `post_parent` bigint(20) unsigned NOT NULL DEFAULT '0',
      `guid` varchar(255) NOT NULL DEFAULT '',
      `menu_order` int(11) NOT NULL DEFAULT '0',
      `post_type` varchar(20) NOT NULL DEFAULT 'post',
      `post_mime_type` varchar(100) NOT NULL DEFAULT '',
      `comment_count` bigint(20) NOT NULL DEFAULT '0',
      PRIMARY KEY (`ID`),
      KEY `post_name` (`post_name`),
      KEY `type_status_date` (`post_type`,`post_status`,`post_date`,`ID`),
      KEY `post_parent` (`post_parent`),
      KEY `post_author` (`post_author`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
    /*!40101 SET character_set_client = @saved_cs_client */;

> *-d omits the data. The schema only is shown.*
>
> At first glance everything may appear normal.
> To spot the error you can compare the output of the corrupted database with non corrupted database.

During the import / export process the database schema was altered and the `PIMARY_KEY` was not set to `AUTO_INCREMENT`.


    # Bad
    ...

    CREATE TABLE `wp_posts` (
      `ID` bigint(20) unsigned,
      `post_author` bigint(20) unsigned NOT NULL DEFAULT '0',
    ...

    # Good
    ...

    CREATE TABLE `wp_posts` (
      `ID` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
      `post_author` bigint(20) unsigned NOT NULL DEFAULT '0',
    ...

This makes sense.
If you look at the error log you may notice each time you attempt to create a new post WordPress tries to set the post it to 0.

## The solution

You'll need to reset your database schema by following these steps:

1. Identify the primary keys in the database.
2. Set the pimary keys to `AUTO_INCREMENT`.

### Identify the primary keys

Review the schema and search for `PRIMARY_KEY`.
Copy down the table and the field for later.

### Set the primary keys to auto increment

This is an example SQL script you may pass into any SQL console.
Tables created by plugins probably have primary keys that require a reset to auto increment.
Run this script to reset your database.

    ALTER TABLE  `wp_commentmeta`   CHANGE `meta_id`           `meta_id`                 BIGINT ( 20 ) UNSIGNED NOT NULL AUTO_INCREMENT;
    ALTER TABLE  `wp_comments`      CHANGE `comment_ID`        `comment_ID`              BIGINT ( 20 ) UNSIGNED NOT NULL AUTO_INCREMENT;
    ALTER TABLE  `wp_links`         CHANGE `link_id`           `link_id`                 BIGINT ( 20 ) UNSIGNED NOT NULL AUTO_INCREMENT;
    ALTER TABLE  `wp_options`       CHANGE `option_id`         `option_id`               BIGINT ( 20 ) UNSIGNED NOT NULL AUTO_INCREMENT;
    ALTER TABLE  `wp_postmeta`      CHANGE `meta_id`           `meta_id`                 BIGINT ( 20 ) UNSIGNED NOT NULL AUTO_INCREMENT;
    ALTER TABLE  `wp_posts`         CHANGE `ID`                `ID`                      BIGINT ( 20 ) UNSIGNED NOT NULL AUTO_INCREMENT;
    ALTER TABLE  `wp_terms`         CHANGE `term_id`           `term_id`                 BIGINT ( 20 ) UNSIGNED NOT NULL AUTO_INCREMENT;
    ALTER TABLE  `wp_term_taxonomy` CHANGE `term_taxonomy_id`  `term_taxonomy_id`        BIGINT ( 20 ) UNSIGNED NOT NULL AUTO_INCREMENT;
    ALTER TABLE  `wp_usermeta`      CHANGE `umeta_id`          `umeta_id`                BIGINT ( 20 ) UNSIGNED NOT NULL AUTO_INCREMENT;
    ALTER TABLE  `wp_users`         CHANGE `ID`                 `ID`                     BIGINT ( 20 ) UNSIGNED NOT NULL AUTO_INCREMENT;

Once you run the script everything should work properly. Discussion on [WordPress.com](http://wordpress.org/support/topic/a-cause-of-the-submit-for-review-problem).
