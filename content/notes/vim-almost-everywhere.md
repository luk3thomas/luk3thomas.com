---
publishdate: 2015-03-30
title: vim everywhere (almost)
---

On Mac OSX you may enable vim bindings in nearly any REPL on the commandline
interface.  I've tried several methods, including editing `.inputrc`, which
seems to produce no effect in yosemite.  A friendly
[coworker](http://twitter.com/jdirt) gave me the solution.

Create a file in your home directory named `.editrc` and add the following
contents:

    bind -v
