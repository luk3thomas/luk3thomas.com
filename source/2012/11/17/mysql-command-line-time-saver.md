---
layout: post
title : Saving time on the MySQL command line
category: programming
tag: SQL
---

Anytime I am working with MySQL it always saves time if I add a few aliases to my **.bashrc** file.

{% highlight bash %}
$ vi ~/.bashrc
{% endhighlight %}

# Add these to the file

{% highlight bash %}
alias m='mysql -uroot -psomePass'
alias md='mysqldump -uroot -psomePass'
alias ms='mysqlshow -uroot -psomePass'
{% endhighlight %}

{% highlight bash %}
$ source ~/.bashrc
{% endhighlight %}

After you add the aliases it is easy to interact with the database from the command line. 

## Examples

### Show all databases

{% highlight bash %}
luk3@mac: ~ $ ms
+-------------------------+
|        Databases        |
+-------------------------+
| information_schema      |
| ve_twist                |
...
+-------------------------+
{% endhighlight %}

### Show database information

{% highlight bash %}
luk3@mac: ~ $ ms ve_twist
Database: ve_twist
+----------------------------+
|           Tables           |
+----------------------------+
| tt7hewp_commentmeta        |
| tt7hewp_comments           |
| tt7hewp_links              |
| tt7hewp_options            |
| tt7hewp_postmeta           |
| tt7hewp_posts              |
| tt7hewp_term_relationships |
| tt7hewp_term_taxonomy      |
| tt7hewp_terms              |
| tt7hewp_usermeta           |
| tt7hewp_users              |
+----------------------------+
{% endhighlight %}

{% highlight bash %}
luk3@mac: ~ $ ms ve_twist tt7hewp_postmeta %
Database: ve_twist  Table: tt7hewp_postmeta  Wildcard: %
+------------+---------------------+-----------------+------+-----+---------+----------------+---------------------------------+---------+
| Field      | Type                | Collation       | Null | Key | Default | Extra          | Privileges                      | Comment |
+------------+---------------------+-----------------+------+-----+---------+----------------+---------------------------------+---------+
| meta_id    | bigint(20) unsigned |                 | NO   | PRI |         | auto_increment | select,insert,update,references |         |
| post_id    | bigint(20) unsigned |                 | NO   | MUL | 0       |                | select,insert,update,references |         |
| meta_key   | varchar(255)        | utf8_general_ci | YES  | MUL |         |                | select,insert,update,references |         |
| meta_value | longtext            | utf8_general_ci | YES  |     |         |                | select,insert,update,references |         |
+------------+---------------------+-----------------+------+-----+---------+----------------+---------------------------------+---------+
{% endhighlight %}
### Dump a database and import into another database

{% highlight bash %}
luk3@mac: ~ $ md ve_twist | m ve_someOtherDatabase
{% endhighlight %}

### Run a query

{% highlight bash %}
luk3@mac: ~ $ m ve_twist -e "select count(0) from tt7hewp_posts"
+----------+
| count(0) |
+----------+
|      465 |
+----------+
{% endhighlight %}

Using MySQL aliases saves a lot of time when you are on a remote server and may not have an application to visually show you information about the database.
