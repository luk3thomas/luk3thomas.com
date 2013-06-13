---
layout: post
category: programming
tag: SQL
title: Postgres command line 
---

I just started using postgres for my rails development server. I am a huge fan of the MySQL command line tools.

### Quick reference
{% highlight bash %}
pg_ctl start
pg_ctl stop
{% endhighlight %}


To get started log into your database using `psql`

{% highlight bash %}
psql luk3@mac: ~ $ psql -h localhost gcom_development
psql (9.0.5, server 9.2.2)
WARNING: psql version 9.0, server version 9.2.
         Some psql features might not work.
Type "help" for help.

gcom_development=# 
{% endhighlight %}

### Create a database
{% highlight bash %}
createdb some_db -U luk3 -W -h localhost
{% endhighlight %}

### Restore database
{% highlight bash %}
pg_restore --verbose --clean --no-acl --no-owner -h localhost -d gcom_development dump.psql
pg_restore -vcO -h localhost -d gcom_development dump.psql                                   #compact
{% endhighlight %}

### Show tables
Showing database tables and columns is much easier to remember than MySQL.
{% highlight bash %}
gcom_development=# \l
                                  List of databases
       Name       | Owner | Encoding |  Collation  |    Ctype    | Access privileges 
------------------+-------+----------+-------------+-------------+-------------------
 gcom_development | luk3  | UTF8     | en_US.UTF-8 | en_US.UTF-8 | 
 gcom_test        | luk3  | UTF8     | en_US.UTF-8 | en_US.UTF-8 | 
 postgres         | luk3  | UTF8     | en_US.UTF-8 | en_US.UTF-8 | 
 template0        | luk3  | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/luk3          +
                  |       |          |             |             | luk3=CTc/luk3
 template1        | luk3  | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/luk3          +
                  |       |          |             |             | luk3=CTc/luk3
(5 rows)
{% endhighlight %}

### Show columns
{% highlight bash %}
gcom_development=# \d
                 List of relations
 Schema |          Name          |   Type   | Owner 
--------+------------------------+----------+-------
 public | groups                 | table    | luk3
 public | groups_id_seq          | sequence | luk3
 public | people                 | table    | luk3
 public | people_id_seq          | sequence | luk3
 public | people_services        | table    | luk3
 public | people_services_id_seq | sequence | luk3
 public | schema_migrations      | table    | luk3
 public | services               | table    | luk3
 public | services_id_seq        | sequence | luk3
 public | users                  | table    | luk3
 public | users_id_seq           | sequence | luk3
(11 rows)
{% endhighlight %}
