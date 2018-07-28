---
publishdate: 2016-07-22
title: Simple authentication in Elixir with Plug
---

This past week I began building an API in Elixir. Most of the guides
and posts I read were focused on the Phoenix framework, and it was a little
difficult to find an example on how to perform authentication using Plug.

Here is what I used:

```elixir
defmodule Api.Authentication do
  import Plug.Conn

  def init(opts), do: opts

  def authenticated?(conn) do
    # Implement authentication logic here, e.g. check auth headers,
    # session creds, etc.
    false
  end

  def call(conn, _opts) do
    if authenticated?(conn) do
      conn
    else
      conn
      |> send_resp(401, "")
      |> halt
    end
  end
end
```

In the `call` method we can check to see if a request is authenticated. If
the request passes our authentication test we send the request downstream to
the next plug in our stack for further processing. If the request does not
pass our authentication test we immediately terminate the request using
`halt` and respond with an HTTP 401 status.

Once we have the plug we can add it to our router using the `plug` method.

```elixir
alias Api.Authentication

defmodule Api do
  use Plug.Router
  plug Authentication # run authentication
  plug :match
  plug :dispatch

  match _ do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(404, "")
  end
end
```

And that is it!

    $ curl -I localhost:8085/api
    HTTP/1.1 401 Unauthorized
    server: Cowboy
    date: Fri, 22 Jul 2016 15:32:10 GMT
    content-length: 0
    cache-control: max-age=0, private, must-revalidate

One _gotcha_ you might encounter is the ordering of plugs. Order does matter
when we are creating a router. In this case, `plug Authentication` should
come **before** the other plugs `:match` and `:dispatch`. If we don't order it
correctly the server will proccess the authentication check after other route
handlers are called.

For example, if we put our authentication plug at the end, like so, the router
will try to send a response twice and our process will terminate.

```elixir
defmodule Api do
  use Plug.Router
  plug :match
  plug :dispatch
  plug Authentication # authentication at the end
```

The server responds with a 404 and an uncaught exception appears in the server log.

    08:15:07.493 [error] #PID<0.262.0> running Router terminated
    Server: localhost:8085 (http)
    Request: GET /api
    ** (exit) an exception was raised:
        ** (Plug.Conn.AlreadySentError) the response was already sent
            (plug) lib/plug/conn.ex:458: Plug.Conn.resp/3
            (plug) lib/plug/conn.ex:445: Plug.Conn.send_resp/3
            (office_mate) lib/office_mate/api_authentication.ex:19: Api.Authentication.call/2
            (office_mate) lib/office_mate/api.ex:3: Api.plug_builder_call/2
            (plug) lib/plug/router/utils.ex:74: Plug.Router.Utils.forward/4
            (office_mate) lib/office_mate/router.ex:1: Router.plug_builder_call/2
            (plug) lib/plug/adapters/cowboy/handler.ex:15: Plug.Adapters.Cowboy.Handler.upgrade/4
            (cowboy) src/cowboy_protocol.erl:442: :cowboy_protocol.execute/4

