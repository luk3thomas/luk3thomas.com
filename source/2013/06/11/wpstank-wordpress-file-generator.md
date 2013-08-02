---
layout: post
category: Programming
tag: Projects
tags:
  - Command line
  - Open source
title: wpstank WordPress file generator
---

> The following post is **outdated** and **should not** be relied upon. Refer to [README.md](https://github.com/luk3thomas/wpstank/blob/master/README.md) for the latest information.

`wpstank` generates custom post types, taxonomies, shortcodes
and any other resource you want. wpstank is hosted on [GitHub](https://github.com/luk3thomas/wpstank).

## Installation

Before you begin make sure `node` and `npm` are installed on your machine.

    npm install -g wpstank

You should have access to the `wpstank` binary from the command line.
Double check your `PATH` variable if `wpstank` is not loaded.

## Getting Started

### Initialize 

Navigate to your WordPress theme directory. Initialize `wpstank` with the following command.

    wpstank init

Several files are created once you run the `init` command inside your current working directory.

    .wpstank.json               # settings
    .wpstank/
    .wpstank/posttype.php       # template file
    .wpstank/shortcode.php      # template file
    .wpstank/taxonomy.php       # template file

### Generate

Begin by creating a new post type using **any** of the following commands:

    wpstank --generate --post-type event
    wpstank -g -p event
    wpstank -gp event

The file `event.php` is added to a newly created directory `library/php/cpt/`.

### Destroy

Delete a post type using **any** of the following commands:

    wpstank --destroy --post-type event
    wpstank -d -p event
    wpstank -dp event

The file `event.php` is deleted from the directory `library/php/cpt/`.


### Customize

Don't like the template files we use? Don't like the location `wpstank` generates new files? Want to generate new files? Great, just change it!

#### Change output directories

`.wpstank.json` contains your configuration settings for output directories. 

    {
        "types": {
            "postType": "library/php/cpt",
            "taxonomy": "library/php/taxonomy",
            "shortcode": "library/php/shortcode"
        }
    }

Edit the configurations to your liking. Just make sure `.wpstank.json` is valid JSON.

#### Change the templates

Templates are stored in the `.wpstank` directory.

    .wpstank/
    .wpstank/posttype.php       # template file
    .wpstank/shortcode.php      # template file
    .wpstank/taxonomy.php       # template file

Feel free to add, delete or update any code in the template files. Each template uses handle bar style variables for the resource names. If you look inside `.wpstank/posttype.php` you see the following variables:

    {{posttype}}        # singular
    {{posttypes}}       # plural
    {{posttype-slug}}   # singluar and lowercase

`wpstank` replaces the variable placeholders with the singular, plural, and slugified version of the `event` resource name. For example, if we created a new custom post type called **event** the template variables are transformed:

    {{posttype}}        => Event
    {{posttypes}}       => Events
    {{posttype-slug}}   => event

#### Adding a new template

Say you want to use `wpstank` to create page templates. The output directory for pages is `pages/`.

1. Add the resource name and template directory to `.wpstank.json`


        {
            "types": {
                "postType": "library/php/cpt",
                "taxonomy": "library/php/taxonomy",
                "shortcode": "library/php/shortcode",
                "page": "pages"
            }
        }


1. Add the `page` template to `.wpstank/page.php`. Utilize the placeholder variables, if you need them.

        {{page}}
        {{pages}}
        {{page-slug}}

1. Generate the page with the `-c` flag

        wpstank -gc page:staff
