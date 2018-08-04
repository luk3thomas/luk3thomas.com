---
title: Deploying Elixir
date: 2018-07-30T22:09:42-05:00
---

First off, there is probably a better way than what I am about to show you.
These are simply a few things I've learned along the way building and running
Elixir applications in production. *They have worked for me*. My projects are
usually pretty simple, so I can't speak to advanced topics like cluster
deployments.

I've used Elixir off and on for the past few years. I can't
say I've used all the tools. I began with
[exrm](https://github.com/bitwalker/exrm) and
[edeliver](https://github.com/edeliver/edeliver) for both building and shipping
releases. At the time I didn't know much about Erlang and was ignorant of the
compliation process. Since then I've found that distillery and docker, along
with a few other things, are essential for my workflow.

### Contents

1. [Application configuration with environment variables](#configuration)
2. [Version releases with git tags](#version)
3. [Use Docker to build](#building)
4. [Creating releases with distillery](#creating-a-release)

Before we begin building releases we'll need to tackle two common problems.
Application configuration with environment variables and unique versioning
(without manual changes).

## Application configuration with environment variables {#configuration}

If you've ever created a release with environment variables in the config
you probably already know what I am about to say.

{{% codefig caption="Don't do this." %}}
```elixir
# config/config.exs
use Mix.Config

config :app, Repo,
  database: System.get_env("DATABASE_NAME"),
  username: System.get_env("DATABASE_USER"),
  password: System.get_env("DATABASE_PASS"),
  hostname: System.get_env("DATABASE_HOST"),
  port:     System.get_env("DATABASE_PORT")
```
{{% /codefig %}}

{{% codefig caption="Or this." %}}
```elixir
defmodule HttpClient
  @token System.get_env("HTTP_CLIENT_TOKEN")
end
```
{{% /codefig %}}

Whatever value is in `DATABASE_NAME` is hardcoded into the release artifact
at compile time. Once it is compiled you cannot change it. Ever.

Blog posts, articles, and Stackoverflow questions have all been written about
compile time environment variables. Even Plataformatec wrote an article, [_How
to config environment variables with Elixir and
Exrm_](http://blog.plataformatec.com.br/2016/05/how-to-config-environment-variables-with-elixir-and-exrm/).

Most solutions say to use a secret file. Others, in the case of distilery, to
define your variables in a [string interpolated format](https://hexdocs.pm/distillery/runtime-configuration.html) `user:
"${DB_USER}"`. On startup you can pass an additional environment variable,
`REPLACE_OS_VARS=true` and it will magically replace `${DB_USER}` when whatever
value exists in the `DB_USER` environment variable.

Both of these solutions are fine, but I prefer using environment variables the
same way in Elixir as I do in other languages.

Now, I've read that using a `env` file to store environment variables isn't the
[_Elixir
way_](https://github.com/avdi/dotenv_elixir#warning-this-isnt-the-elixir-way)
and you should use approaches like Phoenix's secrets file for managing per
environment configurations. That's cool. Not every project I create uses Phoenix
though.

The best way _that has worked for me_ is to use a config wrapper I first saw
from
[bitwalker](https://gist.github.com/bitwalker/a4f73b33aea43951fe19b242d06da7b9),
which I
[modified](https://gist.github.com/luk3thomas/3fe75fda645c3aa71528e42e54fa7d43)
for my own purposes. The end result works around the problem by pushing calls to
`System.get_env/1` down into a function and invoke it at runtime.

{{% codefig caption="Do this instead." %}}
```elixir
# config/config.exs
use Mix.Config

config :app, Repo,
  database: {:system, "DATABASE_NAME"},
  username: {:system, "DATABASE_USER"},
  password: {:system, "DATABASE_PASS"},
  hostname: {:system, "DATABASE_HOST"},
  port:     {:system, "DATABASE_PORT"}

# lib/repo.ex
defmodule Repo do
  use Ecto.Repo, otp_app: :app

  def init(_, config) do
    {:ok, Config.get(config)}
  end
end
```
{{% /codefig %}}

{{% codefig caption="Or this." %}}
```elixir
defmodule HttpClient
  def token do
    Config.get(:app, :http_client_token)
  end
end
```

{{% /codefig %}}

## Versioning {#version}

Before we create a release we should version our application.
By default `mix.exs` includes a version string in your project
definition.

{{% codefig caption="Version 0.1.0" %}}

```elixir
# mix.exs
defmodule App.MixProject do
  use Mix.Project

  def project do
    [
      version: "0.1.0",
    ]
  end
end
```

{{% /codefig %}}

The version is used by build tools so it is important to change the version for
each new release. Each release gets a new, incremental version tag, e.g.
`v1`, `v2`, `v3`, etc.

During development the version does not matter. It does in production though,
for a couple of reasons. First, distillery assumes each release has a unique
version. Second, it is always a good idea to know what version of the
application is running in production. You can pass the version information into
your metrics, traces or logs.

I use `git describe` for the version suffix in production. More on that
[later](#creating-a-release).

```elixir
# config/config.exs
config :myapp,
  version: System.get_env("APP_VERSION")
```

Note, Although we just talked about [environment configuration](#configuration),
I didn't use `{:system, "APP_VERSION"}` to define the version :joy:. In this instance,
I actually want to hardcode the version at compile time, unlike my other
configuration variables.

```elixir
# mix.exs
defmodule App.MixProject do
  use Mix.Project

  def project do
    [
      version: version(),
    ]
  end

  def version, do: Config.get(:myapp, :version) |> version
  def version(nil), do: "1.0.0+dev"
  def version(v), do: "1.0.0+#{v}"
end
```

If versioning with `git describe` seems too complex or it does not fit your
needs you can always update the version by hand. As long as the version is
unique between releases you should be okay.

{{% codefig caption="Update the version by hand, if that is easiest for you." %}}

```diff
diff --git a/mix.exs b/mix.exs
index a808289..d3374e4 100644
--- a/mix.exs
+++ b/mix.exs
@@ -3,7 +3,7 @@ defmodule App.MixProject do

   def project do
     [
-      version: "0.1.0",
+      version: "0.2.0",
     ]
   end
 end
```

{{% /codefig %}}

With configuration and versioning settled you're ready to build a release.

## Building a release {#building}

I divide my Dockerfiles into two main parts: _runtime_ and _build_.
`Dockerfile.runtime` contains the base image operating system, Elixir, and
Erlang. `Dockerfile.build`, inherits the base image and includes the application
dependencies.

Separating the Docker files speeds up the build process from a few minutes to
around 30 seconds.

### Create base image for your target OS

Let's assume you want to run on Ubuntu 16.04. Start with the `ubuntu:16.04` and
install Elixir and Erlang.

{{% codefig caption="Dockerfile for installing Erlang 21.0.1 and Elixir 1.6.6 on Ubuntu 16.04" %}}

```docker
FROM ubuntu:16.04

ENV LANG C.UTF-8
ENV APP_PATH /app
ENV PATH /root/.asdf/bin:/root/.asdf/shims:$PATH

WORKDIR $APP_PATH

RUN apt-get update -qq && \
    apt-get upgrade -qq -y && \
    apt-get install -qq -y \
            git \
            curl \
            autoconf \
            build-essential \
            libgl1-mesa-dev \
            libglu1-mesa-dev \
            libncurses5-dev \
            libpng3 \
            libssh-dev \
            libwxgtk3.0-dev \
            m4 \
            unixodbc-dev \
            xsltproc fop


RUN rm -rf /var/cache/debconf/*-old && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /usr/share/doc/*


RUN set -xe \
    && git clone https://github.com/asdf-vm/asdf.git ~/.asdf \
    && asdf plugin-add erlang https://github.com/asdf-vm/asdf-erlang.git \
    && asdf install erlang 21.0.1 \
    && asdf global erlang 21.0.1 \
    && asdf plugin-add elixir https://github.com/asdf-vm/asdf-elixir.git \
    && asdf install elixir 1.6.6 \
    && asdf global elixir 1.6.6 \
    && rm -rf /tmp/*
```

{{% /codefig %}}

Built and tag it as `ubuntu:erl-20.0.1_elixir-1.6.6`.

```
$ docker build -f docker/Dockerfile.runtime -t ubuntu:erl-20.0.1_elixir-1.6.6 .
```

### Create base image for the application

The second Dockerfile is based on the first. This image fetches and compiles the
application dependencies, which shouldn't change as often as the application
code. That means we'll only compile the application code when we create a
release, which should only takes a few seconds as opposed to a few minutes if
we're compiling all the dependencies too.

{{% codefig caption="Dockerfile for compiling the application dependencies" %}}

```docker
FROM ubuntu:erl-20.0.1_elixir-1.6.6

WORKDIR $APP_PATH

ENV LANG C.UTF-8
ENV APP_PATH /app
ENV MIX_ENV prod
ENV PATH /root/.asdf/bin:/root/.asdf/shims:$PATH

COPY lib $APP_PATH/lib
COPY mix.exs $APP_PATH
COPY mix.lock $APP_PATH
COPY deps $APP_PATH/deps
COPY config $APP_PATH/config

RUN mix local.hex --force
RUN mix local.rebar --force
RUN mix deps.get
RUN mix deps.compile
```

{{% /codefig %}}

Built and tag it.

```
$ docker build -f Dockerfile.build -t myapp .
```

## Creating a release {#creating-a-release}

Now we're ready to create a release. I use
[distillery](https://github.com/bitwalker/distillery) for this part. Upon
installation it creates a configuration file.

```elixir
environment :prod do
  set include_erts: true   # <--- Important
  set include_src: false
  set cookie: :"K(fqv)z4Sv~}0iVt1d$*Q<6:~tPxU4GE6J>_IMA2?zDR@j7aC/KLq6wm]=*{njIq"
end
```

It should provide the default options you'll want, but be sure `include_erts:`
is set to `true`.

The ERTS (the Erlang Runtime System) is a portable system responsible for
running your application. The host machine does not need Erlang or elixir
installed if you include the ERTS. As I mentioned before, this is why it is
important to compile your code on the same operating system that you use in
production.

Run `mix release --env prod`. Mount `_build/prod/rel` as a volume to the
container and it will save the realese on your machine.

```shell
$ docker run -it --rm \
        -e APP_VERSION=$(git describe) \
        -v $(pwd)/_build/prod/rel:/app/_build/prod/rel \
        -v $(pwd)/mix.exs:/app/mix.exs \
        -v $(pwd)/mix.lock:/app/mix.lock \
        -v $(pwd)/config:/app/config\
        -v $(pwd)/lib:/app/lib \
        -v $(pwd)/rel:/app/rel \
        myapp:latest mix release --env prod

Compiling 53 files (.ex)
Generated myapp app
==> Assembling release..
==> Building release myapp:1.0.0+v1 using environment prod
==> Including ERTS 10.0.1 from /root/.asdf/installs/erlang/21.0.1/erts-10.0.1
==> Packaging release..
==> Release successfully built!
    You can run it in one of the following ways:
      Interactive: _build/prod/rel/myapp/bin/myapp console
      Foreground: _build/prod/rel/myapp/bin/myapp foreground
      Daemon: _build/prod/rel/myapp/bin/myapp start
```

Now we have a release ready for deployment :tada:.

```
$ ls -lh _build/prod/rel/myapp/releases/1.0.0+v1/myapp.tar.gz
-rw-r--r--  1 lthomas1  staff    20M Aug  1 03:51 _build/prod/rel/myapp/releases/1.0.0+v1/myapp.tar.gz
```

Let's deploy :rocket:

## Deploying

Deploying is straightforward at this point. We just need to hit a few more
steps.

1. Copy the build artifact to your server
2. Extract the new release
3. Stop the previously running release
4. Start the new release

### release directory

I like to keep my releases in a single directory and symlink to the current
version.

```shell
$ pwd
/app/myapp/releases
$ ls -l
drwxrwxr-x 7 ubuntu ubuntu 4096 Jul 24 13:17 1.0.0+v10
drwxrwxr-x 7 ubuntu ubuntu 4096 Jul 25 01:09 1.0.0+v11
drwxrwxr-x 7 ubuntu ubuntu 4096 Jul 25 03:32 1.0.0+v11-2-g26120de
drwxrwxr-x 7 ubuntu ubuntu 4096 Jul 25 03:47 1.0.0+v11-4-geeef94f
drwxrwxr-x 7 ubuntu ubuntu 4096 Jul 25 04:25 1.0.0+v12
lrwxrwxrwx 1 ubuntu ubuntu   30 Aug  1 08:54 current -> /app/myapp/releases/1.0.0+v12
```

### systemd

You can use whatever you want to initialize
your application. I'm using systemd.

{{% codefig caption="Sample systemd service definition for stopping, starting, and sourcing environment variables" %}}

```
# /lib/systemd/system/myapp.service
[Unit]
Description=myapp
After=network.target

[Service]
Type=simple
User=ubuntu
RemainAfterExit=yes
EnvironmentFile=/app/myapp/env
WorkingDirectory=/app/myapp
ExecStart=/app/myapp/releases/current/bin/myapp foreground
ExecStop=/app/myapp/releases/current/bin/myapp stop
Restart=on-failure
TimeoutSec=300

[Install]
WantedBy=multi-user.target
```

{{% /codefig %}}

Once defined, you can stop and start.

```shell
$ sudo systemctl stop myapp
$ sudo systemctl start myapp
```

Or view the logs.

```shell
$ sudo journalctl -u myapp
-- Logs begin at Thu 2018-08-01 04:52:17 UTC, end at Fri 2018-08-03 02:38:07 UTC. --
Aug 03 02:35:28 myapp systemd[1]: Stopping myapp...
Aug 03 02:35:30 myapp myapp[9581]: ok
Aug 03 02:35:33 myapp systemd[1]: Stopped myapp.
Aug 03 02:36:08 myapp systemd[1]: Started myapp.
Aug 03 02:36:11 myapp myapp[9873]: http://localhost:4001
```

A simple deploy script could look something like this.

{{% codefig caption="Sample deploy script for uploading, ectracting and starting an app" %}}

```
$ scp _build/prod/rel/myapp/releases/1.0.0+v1/myapp.tar.gz ubuntu@myapp.com:/tmp/myapp.tar.gz
$ ssh ubuntu@myapp.com 'mkdir -p /app/myapp/releases/1.0.0+v1 \
    && cp /tmp/myapp.tar.gz /app/myapp/releases/1.0.0+v1/ \
    && cd /app/myapp/releases/1.0.0+v1 \
    && tar xzvf /app/myapp/releases/1.0.0+v1/myapp.tar.gz \
    && sudo systemctl stop myapp \
    && cd /app/myapp/releases \
    && rm /app/myapp/releases/current \
    && ln -s /app/myapp/releases/1.0.0+v1 current \
    && sudo systemctl start myapp'
```

{{% /codefig %}}

## Conclusion

That's it! Deploying Elixir apps certainly has a few _gotchas_ and what I've
outlined won't work for everyone. Regardless of your solution it is important to
develop good tooling around configuration, versioning, and building to match
your production environment.

Happy deploying!
