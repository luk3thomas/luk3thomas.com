---
title: Pattern Matching in Elixir
date: 2015-08-01T12:00:00-05:00
description: |
  What is pattern matching and how does it work in Elixir? A lightning talk
  given during an on-site at Librato in San Fransisco.
---


{{% slide background="rebeccapurple" %}}

## Pattern matching in elixir

{{% /slide %}}

{{% slide background="rebeccapurple" %}}

## What is elixir?

* Elixir is a dynamic, functional language designed for building scalable and
  maintainable applications.
* Elixir leverages the Erlang VM, known for running low-latency, distributed
  and fault-tolerant systems, while also being successfully used in web
  development and the embedded software domain.

{{% /slide %}}

{{% slide background="rebeccapurple" %}}

## Familiar syntax 🍒

```elixir
defmodule Math do
 def sum(a, b) do
   a + b
 end
end

Math.sum(1, 2)
```

{{% /slide %}}

{{% slide background="rebeccapurple" %}}

## Not so familiar syntax 😲

```elixir
defmodule Math do
  def sum, do: 0
  def sum(a), do: a
  def sum(a, b), do: a + b
  def sum(a, b, c), do: a + b + c
  def sum([]), do: 0
  def sum([head|tail]), do: head + sum(tail)
end

Math.sum([1, 2, 3, 4])
```

{{% /slide %}}

{{% slide background="rebeccapurple" %}}

## what the ... 😳

```elixir
iex> x = 1
1
iex> 1 = x
1
```

What's going on 😕?

{{% /slide %}}

{{% slide background="rebeccapurple" %}}

## The match operator `=`

The left-hand side pattern is matched against a right-hand side term. If the
matching succeeds, any unbound variables in the pattern become bound. If the
matching fails, a run-time error occurs.

{{% /slide %}}

{{% slide background="rebeccapurple" %}}

In the REPL

```elixir
iex> a = 1
1
iex> {a, b} = {1, 2}
{1, 2}
iex> [a, b] = [1, 2]
[1, 2]
iex> {a, b, c} = {1, 2}
** (MatchError) no match of right hand side value: {1, 2}
```

{{% /slide %}}

{{% slide background="rebeccapurple" %}}

In a function

```elixir
def f({:a, :b} = tuple), do: IO.puts "All your \#{inspect tuple} are belong to us"
def f([]),               do: IO.puts "Empty"
def f(n),                do: IO.puts "Inspecting \#{inspect n}"

f([])
#=> "Empty"

f({:a, :b})
#=> "All your {:a, :b} are belong to us"

f({:a, :b, :c})
#=> "Inspecting {:a, :b, :c}"
```

{{% /slide %}}

{{% slide background="rebeccapurple" %}}

## An example 😃

Let's write an implementation of the Fibonacci sequence

f <sub>n</sub> = f<sub>n-1</sub> + f<sub>n-2</sub>

```
0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144
```

{{% /slide %}}

{{% slide background="rebeccapurple" %}}

## In JavaScript 😎

```javascript
function fib(n) {
  if (n <= 1) {
    return n;
  } else {
    return fib(n-1) + fib(n-2);
  }
}
```

1. Mental overhead
2. What if n is less than 0?
3. What if n is not a number?

{{% /slide %}}

{{% slide background="rebeccapurple" %}}

## In Elixir 😎

```elixir
defmodule Math do
  def fib(0), do: 0
  def fib(1), do: 1
  def fib(n), do: fib(n-2) + fib(n-1)
end
```

How can we handle < 0 and arguments that are not a number?

```elixir
defmodule Math do
  def fib(n) when not is_number(n), do: raise(ArgumentError, message: "not a number")
  def fib(n)            when n < 0, do: 0
  def fib(0),                       do: 0
  def fib(1),                       do: 1
  def fib(n),                       do: fib(n-2) + fib(n-1)
end
```

{{% /slide %}}

{{% slide background="rebeccapurple" %}}
## An advanced example

From [binary pattern matching in elixir](http://www.zohaib.me/binary-pattern-matching-in-elixir/)

```elixir
defmodule Expng do

  defstruct [:width, :height, :bit_depth, :color_type, :compression, :filter, :interlace, :chunks]

  def png_parse(<<
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A,
                 _length :: size(32),
                 "IHDR",
                 width :: size(32),
                 height :: size(32),
                 bit_depth,
                 color_type,
                 compression_method,
                 filter_method,
                 interlace_method,
                 _crc :: size(32),
                 chunks :: binary>>) do
    png = %Expng{
      width: width,
      height: height,
      bit_depth: bit_depth,
      color_type: color_type,
      compression: compression_method,
      filter: filter_method,
      interlace: interlace_method,
      chunks: []}

    png_parse_chunks(chunks, png)
  end

  defp png_parse_chunks(<<
                        length :: size(32),
                        chunk_type :: size(32),
                        chunk_data :: binary - size(length),
                        crc :: size(32),
                        chunks :: binary>>, png) do
    chunk = %{length: length, chunk_type: chunk_type, data: chunk_data, crc: crc}
    png = %{png | chunks: [chunk | png.chunks]}

    png_parse_chunks(chunks, png)
  end

  defp png_parse_chunks(<<>>, png) do
    %{png | chunks: Enum.reverse(png.chunks)}
  end
end
```

{{% /slide %}}

{{% slide background="rebeccapurple" %}}

## The End 👋

{{% /slide %}}
