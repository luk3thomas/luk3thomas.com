---
layout: default
---
# Staging files in hunks
{% highlight bash %}
$ git add -p
{% endhighlight %}

Use ``` git add -p ``` if you make multiple, unrelated changes to a single file. 

Say that I make more than one change on a file in different sections. Rather than using ``` git add ``` to commit the entire file, using ``` git add -p ``` stages sections of the file and then make multiple commits.


{% highlight bash %}
diff --git a/_layouts/default.html b/_layouts/default.html
index ef67e76..ca34967 100644
--- a/_layouts/default.html
+++ b/_layouts/default.html
@@ -32,7 +32,10 @@
       <section>
...

Stage this hunk [y,n,q,a,d,/,e,?]? 
{% endhighlight %}
