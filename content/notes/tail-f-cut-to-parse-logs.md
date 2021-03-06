---
publishdate: 2013-07-16
title: Quick and dirty log parsing
---

Use `tail -f` to parse file logs. You may pipe the command to `cut`, `awk`, or
any other Unix command.

A little about the `-f` switch.

    $ man tail

    ...

    -f  The -f option causes tail to not stop when end of file is reached,
        but rather to wait for additional data to be appended to the input.
        The -f option is ignored if the standard input is a pipe, but not
        if it is a FIFO.

For example, here are a few lines from an apache rewrite log.

    127.0.0.1 - - [16/Jul/2013:16:39:02 --0500] [dev6.localhost/sid#7fbddb8f0300][rid#7fbddba214b8/initial/redir#1] (4) [perdir /Users/luk3/localhost/dev6/] RewriteCond: input='/Users/luk3/localhost/dev6/index.php' pattern='!-f' => not-matched
    127.0.0.1 - - [16/Jul/2013:16:39:02 --0500] [dev6.localhost/sid#7fbddb8f0300][rid#7fbddba214b8/initial/redir#1] (3) [perdir /Users/luk3/localhost/dev6/] strip per-dir prefix: /Users/luk3/localhost/dev6/index.php -> index.php
    127.0.0.1 - - [16/Jul/2013:16:39:02 --0500] [dev6.localhost/sid#7fbddb8f0300][rid#7fbddba214b8/initial/redir#1] (3) [perdir /Users/luk3/localhost/dev6/] applying pattern '^(.*)/([0-9]+)/$' to uri 'index.php'
    127.0.0.1 - - [16/Jul/2013:16:39:02 --0500] [dev6.localhost/sid#7fbddb8f0300][rid#7fbddba214b8/initial/redir#1] (3) [perdir /Users/luk3/localhost/dev6/] strip per-dir prefix: /Users/luk3/localhost/dev6/index.php -> index.php
    127.0.0.1 - - [16/Jul/2013:16:39:02 --0500] [dev6.localhost/sid#7fbddb8f0300][rid#7fbddba214b8/initial/redir#1] (3) [perdir /Users/luk3/localhost/dev6/] applying pattern '^(.*)/$' to uri 'index.php'
    127.0.0.1 - - [16/Jul/2013:16:39:02 --0500] [dev6.localhost/sid#7fbddb8f0300][rid#7fbddba214b8/initial/redir#1] (3) [perdir /Users/luk3/localhost/dev6/] strip per-dir prefix: /Users/luk3/localhost/dev6/index.php -> index.php
    127.0.0.1 - - [16/Jul/2013:16:39:02 --0500] [dev6.localhost/sid#7fbddb8f0300][rid#7fbddba214b8/initial/redir#1] (3) [perdir /Users/luk3/localhost/dev6/] applying pattern '^(.*)/$' to uri 'index.php'
    127.0.0.1 - - [16/Jul/2013:16:39:02 --0500] [dev6.localhost/sid#7fbddb8f0300][rid#7fbddba214b8/initial/redir#1] (3) [perdir /Users/luk3/localhost/dev6/] strip per-dir prefix: /Users/luk3/localhost/dev6/index.php -> index.php
    127.0.0.1 - - [16/Jul/2013:16:39:02 --0500] [dev6.localhost/sid#7fbddb8f0300][rid#7fbddba214b8/initial/redir#1] (3) [perdir /Users/luk3/localhost/dev6/] applying pattern '^(.*)/$' to uri 'index.php'
    127.0.0.1 - - [16/Jul/2013:16:39:02 --0500] [dev6.localhost/sid#7fbddb8f0300][rid#7fbddba214b8/initial/redir#1] (1) [perdir /Users/luk3/localhost/dev6/] pass through /Users/luk3/localhost/dev6/index.php

Let's say I just want to see the timestamp and the text at the end that tells
me about the rewrite action.

    $ tail -f log | sed -r 's/.*([0-9]{4}:[0-9]{2}:[0-9]{2}).*\/\](.*)/\1 \2/g'

    2013:16:39  RewriteCond: input='/Users/luk3/localhost/dev6/index.php' pattern='!-f' => not-matched
    2013:16:39  strip per-dir prefix: /Users/luk3/localhost/dev6/index.php -> index.php
    2013:16:39  applying pattern '^(.*)/([0-9]+)/$' to uri 'index.php'
    2013:16:39  strip per-dir prefix: /Users/luk3/localhost/dev6/index.php -> index.php
    2013:16:39  applying pattern '^(.*)/$' to uri 'index.php'
    2013:16:39  strip per-dir prefix: /Users/luk3/localhost/dev6/index.php -> index.php
    2013:16:39  applying pattern '^(.*)/$' to uri 'index.php'
    2013:16:39  strip per-dir prefix: /Users/luk3/localhost/dev6/index.php -> index.php
    2013:16:39  applying pattern '^(.*)/$' to uri 'index.php'
    2013:16:39  pass through /Users/luk3/localhost/dev6/index.php

Now that is nice, isn't it.

Once new data is appended to the log file it is piped through our rickety
regular expression.  If you want to pipe the `tail -f` to more than one command
you'll run into some stdio problems, which you can read about on
[SO](http://stackoverflow.com/questions/14360640/tail-f-into-grep-into-cut-not-working-properly)
and the [interwebs](http://www.pixelbeat.org/programming/stdio_buffering/).
