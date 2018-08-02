---
title: Deploying Elixir
date: 2018-07-30T22:09:42-05:00
---

First off, there is probably a better way than what I am about to show you.
These are simply a few things I've learned along the way building and running a
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
3. [Use Docker to build](#docker)
4. [Creating releases with distillery](#creating-a-release)

Before we begin building releases we'll need to tackle two common problems.
Application configuration with environment variables and unique version (without
manual changes).

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
at compilation. After you deploy you cannot change it. Ever.

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
[_elixir
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
each new release. Typically I version my application serially. Each new release
gets a new, incremental version tag, e.g. `v1`, `v2`, `v3`, etc.

During development the version does not matter. It does in production though,
for a couple of reasons. First, distillery builds according to the version and
each release needs a distinct version. Second, it is always a good idea to
know what version of the application is running in production. You can pass the
version information into your metrics, traces or logs.

I use `git describe` for the version suffix in production. More on that
[later](#creating-a-release).

```elixir
# config/config.exs
config :myapp,
  version: System.get_env("APP_VERSION")
```

Note, I didn't use `{:system, "APP_VERSION"}`. In this instance I actually want
to hardcode the version at compile time, unlike my other configuration
variables.

```elixir
# mix.exs
defmodule App.MixProject do
  use Mix.Project

  def project do
    [
      version: version(),
    ]
  end

  def version, do: Config.get(:sstell, :version) |> version
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

With configuration and versioning settled you should be ready to build a
release.

## Building a release {#docker}

Docker is handy for creating a stand-alone deployment artifact for your target
OS. I divide my Dockerfiles into two main parts. I create `Dockerfile.runtime`
for creating a base image of the target operating system, elixir, and erlang.
Then I create a second image, `Dockerfile.build`, as another base image for
application dependencies.

Separating the Docker files speeds up the building process from a few minutes to
around 30 seconds.

### Create base image for your target OS

Let's assume you want to run on Ubuntu 16.04. Start with the `ubuntu:16.04` base
image and install Elixir and Erlang. I've used
[asdf](https://github.com/asdf-vm/asdf) as my programming language version
manager in the past. It actually works well in this case too, for for installing
Elixir and Erlang.

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


# Install the language runtime
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

Built it and tag as `ubuntu:erl-20.0.1_elixir-1.6.6`. We'll reuse it in the next
image.

```
$ docker build -f docker/Dockerfile.runtime -t ubuntu:erl-20.0.1_elixir-1.6.6 .
```

### Create base image for the application

The second Dockerfile is based on the first. It fetches and compiles the
application dependencies. The dependencies shouldn't change as often as the
application code. An image with the compiled dependencies means only your app
should be compiled during the build.

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

Built it and tag as `myapp:latest`. We'll use this image along with `docker
run` to produce releases.

```
$ docker build -f Dockerfile.build -t myapp .
```

## Creating a release {#creating-a-release}

Now the `myapp:latest` image should contain everything we need to build a
release. I use [distillery](https://github.com/bitwalker/distillery) for
creating the actual release. On installation it creates a configuration file,
and last I checked, it should provide the default options you'll want. Either
way, be sure `include_erts:` is set to `true`.

```elixir
environment :prod do
  set include_erts: true   # <--- Important
  set include_src: false
  set cookie: :"K(fqv)z4Sv~}0iVt1d$*Q<6:~tPxU4GE6J>_IMA2?zDR@j7aC/KLq6wm]=*{njIq"
end
```

Including ERTS (the Erlang Runtime System) means the host machine does not
require erlang (or elixir) to be installed to run the application. In our case we're
building for Ubuntu 16.04. The release will run without any installed
dependecies as long as the binary was built on a machine with similar CPU
architecture. Much simpler than having to install two language runtimes on your
server!

Run `mix release --env prod`. If you mount the `_build/prod/rel` volume to the
container it will save the resulting output to the host machine.

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

Now I have a build artifact ready for deployment.

```
$ ls -lh _build/prod/rel/myapp/releases/1.0.0+v1/myapp.tar.gz
-rw-r--r--  1 lthomas1  staff    20M Aug  1 03:51 _build/prod/rel/myapp/releases/1.0.0+v1/myapp.tar.gz
```

We're ready to deploy.

## Deploying

Deploying is straightforward at this point. Just a few more steps.

1. Copy the build artifact to your server
2. Extract the new release
3. Stop the previously running release
4. Start the new release

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

I should briefly mention systemd. You can use whatever you want to initialize
your application. I'm using systemd to manage everything. My service definition
file defines the commands used for starting and stopping the app as well as the
file path to my environment variables.

{{% codefig caption="Sample systemd service definition for stopping, starting, and sourcing environment variables" %}}

```shell
$ cat /lib/systemd/system/myapp.service
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

## Conclusion

That's it!
