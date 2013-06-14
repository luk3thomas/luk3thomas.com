---
layout: post
title: Using git to stage files in hunks
category: programming
tag: coding
tags:
  - git
---

    $ git add -p


Use `git add -p` if you make multiple, unrelated changes to a single file. 

Say that I make more than one change on a file in different sections. Rather than using ``` git add ``` to commit the entire file I use ``` git add -p ``` to stage sections of the file and then make multiple commits.

    luk3@mac: $ git add -p
    diff --git a/_layouts/default.html b/_layouts/default.html
    index ef67e76..ca34967 100644
    --- a/_layouts/default.html
    +++ b/_layouts/default.html
    @@ -32,7 +32,10 @@
           <section>
    ...

    Stage this hunk [y,n,q,a,d,/,e,?]? 

## Options

    y - stage this hunk
    n - do not stage this hunk
    q - quit; do not stage this hunk nor any of the remaining ones
    a - stage this hunk and all later hunks in the file
    d - do not stage this hunk nor any of the later hunks in the file
    g - select a hunk to go to
    / - search for a hunk matching the given regex
    j - leave this hunk undecided, see next undecided hunk
    J - leave this hunk undecided, see next hunk
    k - leave this hunk undecided, see previous undecided hunk
    K - leave this hunk undecided, see previous hunk
    s - split the current hunk into smaller hunks
    e - manually edit the current hunk
    ? - print help

