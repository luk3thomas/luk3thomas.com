---
publishdate: 2016-03-18
title: Visualize memory usage from Google Chrome
---

> **TL/DR;** I found a way to instrument Google Chrome's memory usage metrics
> in realtime. If I am online and running the script you can see it
> [here](https://metrics.librato.com/s/public/lcif1ldp).

Recently at work I've been doing some UI performance profiling on our
application. We have a fairly complicated app that does lots of things and
from time to time I'll notice it is consuming more CPU than normal. I don't
have a gauge, and I'm not constantly monitoring the Chrome task manager. No,
I know our application is consuming CPU when my laptop is burning a hole through my desk and
the CPU fan kicks on.

This very thing happened to me the other day and it occured to me that, yes,
I could open the task manager and see the processes on fire, however I'm
missing some key information I'd like to know. First, I'd like to know when
did the spike in memory usage begin and second, I'd like to know how long was
the process running before the spike in usage?

While I was listening to my CPU fan run, it occured to me. Chrome
must have some kind of live data stream for its memory statistics. How else
is the task manager able to update every few seconds.

## For me, I presume?

I began googling for _Chrome data logs_, _Chrome live stream_ and any other
combination of words without any luck. Then I noticed a link at the bottom of
the task manager.

![stats for nerds](https://lh3.google.com/u/0/d/11jb62SeZczkIcnKM65MnqzBNOQhZ0WTP=w1704-h1680-iv1)

The link brought me to [chrome://memory-redirect](chrome://memory), a simple
dashboard with a few memory stats and a breakout process for each tab.

![memory page](https://lh3.google.com/u/0/d/1zLma3KfW7w-_-S9_n9ipSLEObi6l14ID=w1704-h1680-iv1)

Perfect! All I needed to do is scrape this page, parse out the stats, and
save the results.

Since [chrome://memory-redirect](chrome://memory) is an internal page unique
to Google Chrome it presents a few accessibility problems. I won't be able to
use cURL or any other web scraper. After all, how could they even reach the page? The
only way I could think is to send the data via an XHR from the dev console.

Now I had access to the stats on the page, yet for this to work, the script
would have to make a new request for
[chrome://memory-redirect](chrome://memory) every few seconds. I looked at
the source of the code, and yeah... not gonna work. The HTML content of the
page was empty. Instead of seeing memory data, all the fields contained
_N/A_. The page was definitely rendering the stats with JavaScript.

At this point I was puzzled. I'd been looking at the HTML source for a while.
It didn't have any data objects that I could see. I went and looked at the
network requests. Those were empty too. The page wasn't fetching data on load
with XHRs.

After looking for a while I began to wonder if the data was coming through
one of the JavaScript files. I noticed these scripts at the top of the page.

    </style>
    <script src="chrome://resources/js/load_time_data.js"></script>
    <script src="chrome://memory-redirect/memory.js"></script>
    <script src="chrome://memory-redirect/strings.js"></script>
    </head>
    <body>
        <div id="header">

## Yes, eval please!

There it was: [chrome://memory-redirect/strings.js](chrome://memory-redirect/strings.js) contained contained memory data used in the page template, and how fortunate that each request for strings.js returns the memory data at that point in time in a nice JSON-ish format.

    loadTimeData.data = {
        // ...
        "jstemplateData": {
            "browsers": [
                {
                    "comm_image": 0,
                    "comm_map": 0,
                    "comm_priv": 45300812,
                    "name": "Google Chrome",
                    "pid": 299,
                    "processes": 13,
                    "version": "49.0.2623.87",
                    "ws_priv": 2707412,
                    "ws_shareable": 0,
                    "ws_shared": 0
                }
            ],
            // ...
            "child_data": [
                {
                    "child_name": "Tab",
                    "comm_image": 0,
                    "comm_map": 0,
                    "comm_priv": 3714880,
                    "pid": 6565,
                    "processes": 0,
                    "titles": [
                        "Developer Tools - chrome://memory-redirect/"
                    ],
                    "version": "49.0.2623.87",
                    "ws_priv": 301664,
                    "ws_shareable": 0,
                    "ws_shared": 0
                },
                // ...
            ],
        },
    }

At this point things got easy. I could fetch strings.js and since it was
pretty close to JSON, I could remove the `loadTimeData.` bit from the
beginning of the file and eval it, which would assign the memory stats to
the variable `data`. All that was left was to map and filter the data then
send it to a server for processing.

## Where to send?

Once the data gets to the server you can do whatever you want. I could format
it and append it to a log from which I could build a data viz, I could use
some command line graphing tools, or any number of things. I happen to work
at a [metrics and monitoring SasS company](https://www.librato.com/) so I
grabbed a copy of my API token and begain sumbitting realtime memory stats
from Chrome to our platform.

In a few seconds I was seeing metrics :)

![metrics](https://lh3.google.com/u/0/d/1wJA3MuBLdWSW6_bjuF1EBxQgWAJMTh5d=w1704-h1680-iv1)

And in a few minites later I built this awesome dashboard!

![space](https://lh3.google.com/u/0/d/15TYJ6cztnUj_Pb6OQUV1_1jyN_CXl27s=w1704-h1680-iv1)

If I'm running the script, you can actually see my [memory stats in
realtime](https://metrics.librato.com/s/public/lcif1ldp). If
I'm not you can go back to when I [first started
reporting](https://metrics.librato.com/s/public/lcif1ldp?duration=9446&end_time=1458278888)
and see what it looked like.

And yes, summing the the memory stats doesn't give us the actual total
memory usage since processes share memory, but hey, it looks nice, so who
cares!

Anyways, if you are interested you can find the source code for the
JavaScript poller and the server backend I used to submit metrics on
[github](https://gist.github.com/luk3thomas/7cfe7370a27e555610e9).
