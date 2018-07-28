---
publishdate: 2016-03-26
title: Easy Makefile documentation
---

Other people do it differently. Here is how I do it.

    help: # Show help text
      @cat Makefile | grep '^[A-z]' | sed -r 's/:[^#]+/#/' | column -t -s '#'

    download: # Download and process recent transactions
      @./bin/run

    process: # Process recent transactions
      @./bin/process

    server: # Start the web server
      @./bin/server

And when you run `make`

    ~/ $ make
    help       Show help text
    download   Download and process recent transactions
    process    Process recent transactions
    server     Start the web server
