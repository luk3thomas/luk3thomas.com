---
title: Learning GoLang
date: 2019-01-12T00:00:00-06:00
description: |
  Go is an open source programming language that makes it easy to build simple, reliable, and efficient software. In this talk I'll cover a few of the basic concepts that helped me understand the language.
---

<style>
.reveal { color: black }
.exec { color: green; font-weight: bold }
.reveal a { color: #9f48af }
</style>

{{% slide transition="none" %}}

# Learning Golang

{{% /slide %}}

{{% slide transition="none" %}}

# Learning Golang

###### (I might not know what I am talking about)

{{% /slide %}}

{{% slide transition="none" background="#67DAFD"  %}}

## What is Go?

Go is an open source programming language that makes it easy to build simple, reliable, and efficient software.

- Statically typed
- Simplified concurrency (Goroutines)
- Fast compiler
- Read [A Tour of Go](https://tour.golang.org/basics/1)

{{% /slide %}}

{{% slide transition="none" background="#67DAFD"  %}}

## Language

#### Basic types

```
bool

string

int  int8  int16  int32  int64
uint uint8 uint16 uint32 uint64 uintptr

byte // alias for uint8

rune // alias for int32
     // represents a Unicode code point

float32 float64

complex64 complex128
```

{{% /slide %}}

{{% slide transition="none" background="#67DAFD"  %}}

## Language

#### Custom types

```go
type Id = uint64

type ExampleGuy struct {
  isCool       bool
  numberOfCars int32
}

type Something interface {
  calc() float64
}
```

{{% /slide %}}

{{% slide transition="none" background="#67DAFD"  %}}

## Language

#### Slices (Arrays)

```go
var numbers = []uint32{1, 2, 3, 4}

for _, n := range numbers {
  fmt.Println(n)
}
```

{{% /slide %}}

{{% slide transition="none" background="#67DAFD"  %}}

## Language

#### Maps

```go
m := map[uint64]bool{
  1: true,
  2: false,
}

fmt.Println(m[1]) // true
fmt.Println(m[2]) // false
```

{{% /slide %}}

{{% slide transition="none" background="#67DAFD"  %}}

## Language

#### Functions

```go
func Calc(a float64, b float64) float64 {
  return a + b
}
```

{{% /slide %}}

{{% slide transition="none" background="#67DAFD"  %}}

## Language

#### Functions

```go
func Multiply(a string) (float64, error) {
  i, err := strconv.ParseFloat(a, 64)
  if err != nil {
    return 0, err
  }
  return i * i, nil
}
```

{{% /slide %}}

{{% slide transition="none" background="#67DAFD"  %}}

## Language

#### Function receivers

```go
type Measurements struct {
  measures []float64
}

func (m *Measurements) Sum() float64 {
  var result float64
  for _, measure := range m.measures {
    result += measure
  }
  return result
}

var measures = &Measurements{
  measures: []float64{1, 2, 3, 4},
}

measures.Sum()
```

{{% /slide %}}

{{% slide transition="none" background="#67DAFD"  %}}

## Language

#### No classes

There are no classes in Golang. Organize your code in packages
{{% /slide %}}

{{% slide transition="none" background="#67DAFD"  %}}

## Language

##### Packages

```go
// main.go
package main

import (
  "github.com/papertrail/sawmill/event"
)
```

```go
// event/event.go
package event

type Event struct {
  id uint64
}
```

{{% /slide %}}

{{% slide transition="none" background="#67DAFD"  %}}

## Language

#### Concurrency

Goroutines are lightweight threads (green threads) managed by the Go runtime.

```go
func main() {
  go doSomething()
}
```

{{% /slide %}}

{{% slide transition="none" background="#67DAFD"  %}}

## Language

#### Concurrency

Use channels to transport data.

```go
c := make(chan string)
c <- "hello"
str := <-c
fmt.Println(str) // hello
```

{{% /slide %}}

{{% slide transition="none" background="#67DAFD"  %}}

## Language

#### Concurrency

Channels are blocking

```go
c := make(chan string)
str := <-c
fmt.Println(str) // Not happening
```

{{% /slide %}}

{{% slide transition="none" background="#67DAFD"  %}}

## Language

#### Concurrency

Use `for` and `select` to read from multiple channels

```go
func (q *Queue) Start() {
  tick := time.NewTicker(time.Second * 10)
  for {
    select {
    case measurement := <-q.insertChan:
      // Add measurement to queue
      break
    case <-tick.C:
      // Flush queue
      break
    }
  }
}
go queue.Start()
```

{{% /slide %}}

{{% slide transition="none" background="#67DAFD"  %}}

## Benefits of Go

#### Easy to learn

<img src="../learning-golang/ide.png" width="500"/>

<small>A couple weeks to ramp up. VSCode, Goland, others ...</small>

{{% /slide %}}

{{% slide transition="none" background="#67DAFD"  %}}

## Benefits of Go

##### Performance

<img src="../learning-golang/row-count.png" width="500"/>

<small>Inserting 75k rows per second into ClickHouse</small>
{{% /slide %}}

{{% slide transition="none" background="#67DAFD"  %}}

## How do you go?

Create `main.go`

```go
// main.go
package main

import "fmt"

func main() {
  fmt.Println("Hello!")
}
```

{{% /slide %}}

{{% slide transition="none" background="#67DAFD"  %}}

## How do you go?

Build it!

```go
$ go build
```

```bash
$ ls -l
total 4128
-rwxr-xr-x  1 lthomas1  staff  2106512 Jan 12 14:38 hello
-rw-r--r--  1 lthomas1  staff       67 Jan 12 14:36 main.go
```

{{% /slide %}}

{{% slide transition="none" background="#67DAFD"  %}}

## How do you go?

Run it!

```go
$ ./hello
Hello!
```

{{% /slide %}}

{{% slide class="left" transition="none" background="#67DAFD"  %}}

## Compiling

Compiles quickly

```bash
$ time go build

real	0m0.722s
user	0m0.665s
sys	0m0.385s
```

Fat binaries

```bash
$ ls -lh sockets-talk
-rwxr-xr-x  1 lthomas1  staff   6.6M Jan 12 14:16 sockets-talk
```

{{% /slide %}}

{{% slide class="left" transition="none" background="#67DAFD"  %}}

## Demo

<img src="../learning-golang/ui.png" width="500"/>

<small>[Source code](https://github.com/luk3thomas/fun/tree/master/sockets-talk)</small>

{{% /slide %}}
