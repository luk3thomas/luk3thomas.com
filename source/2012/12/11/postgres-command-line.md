---
layout: post
category: Programming
tag: Coding
tags:
  - Command line
title: Postgres command line 
---

### Quick reference
    pg_ctl start
    pg_ctl stop


To get started log into your database using `psql`

    luk3@mac: ~ $ psql -h localhost gcom_development
    psql (9.0.5, server 9.2.2)
    WARNING: psql version 9.0, server version 9.2.
             Some psql features might not work.
    Type "help" for help.

    gcom_development=# 

### Create a database

    createdb some_db -U luk3 -W -h localhost

### Restore database

    pg_restore --verbose --clean --no-acl --no-owner -h localhost -d gcom_development dump.psql
    pg_restore -vcO -h localhost -d gcom_development dump.psql                                   #compact

### Show tables

Showing database tables and columns is much easier to remember than MySQL.

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

### Show columns

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
