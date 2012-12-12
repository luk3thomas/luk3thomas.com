---
layout: post
tags: [mac]
title: Removing macports completely
---

**TL/DR;** If you uninstall macports, recompile ruby as some of the library paths have changed.

I bought my Mac a few months ago. I missed the package manager from Ubuntu and as a rookie mistake I installed macports on my Mac. I am not sure why I installed macports over homebrew, but I eventually installed homebrew and forgot about my macports installation.

Fast forward to today. I am working on a Rails app and I decide to switch from `rvm` to `rbenv`. While I am at it, I remember that I have an old macports installation and decide to remove it. These were the [best instructions](https://gist.github.com/986553) I found.

{% highlight bash %}
sudo port -f uninstall installed

sudo rm -rf \
    /opt/local \
    /etc/manpaths.d/macports \
    /etc/paths.d/macports \
    /Applications/DarwinPorts \
    /Applications/MacPorts \
    /Library/LaunchDaemons/org.macports.* \
    /Library/Receipts/DarwinPorts*.pkg \
    /Library/Receipts/MacPorts*.pkg \
    /Library/StartupItems/DarwinPortsStartup \
    /Library/Tcl/darwinports1.0 \
    /Library/Tcl/macports1.0
{% endhighlight %}

After I removed macports I jumped over to my blog to write post and all of a sudden jekyll would not work. I got this crazy error that said some of the libraries were not loaded. In looked at the error and the library path was `/opt/local/lib/libcrypto-1.0.0.dylib`. Strange since `/opt/local/` is a macport directory. The fix was:

{% highlight bash %}
rbenv uninstall 1.9.3-p327
{% endhighlight %}

{% highlight bash %}
rbenv install 1.9.3-p327
{% endhighlight %}

