---
title: Approaching GraphQL
date: 2018-01-08T22:13:31-05:00
description: |
  GraphQL is an exciting new query language for APIs. It is statically typed,
  backend and storage agnostic, and fun to use! Ever wanted to fetch multiple
  resources in a single request or only return exactly the data you need? Come
  see an overview of this new query language and hear my experience using GraphQL
  in production.
---

<style>
.vsplit {
  display: flex;
  justify-content: space-between;
}
.vsplit img {
  height: 100%;
}

.vsplit > * {
  width: 46% !important;
  display: flex !important;
}

.vsplit code {
  width: 100%;
}

.left {
  text-align: left;
}

.green-text {
  color: #3cdc8b;
}
</style>

{{% slide class="center" transition="none" %}}
## Approaching GraphQL

{{% /slide %}}

{{% slide class="center" background="rebeccapurple" %}}

### What is GraphQL?

1. A <span class="green-text">query language</span> for APIs
2. A <span class="green-text">runtime</span> for fulfilling those queries with your existing data.

{{% vsplit %}}
```clojure
query {
  viewer {
    email
  }
}
```

```json
{
  "data": {
    "viewer": {
      "email": "foo@example.com"
    }
  }
}
```
{{% /vsplit %}}
{{% /slide %}}

{{% slide transition="none" background="rebeccapurple" %}}

### What is GraphQL not?

1. An ORM
2. Data storage layer

{{% /slide %}}

{{% slide transition="none" background="rebeccapurple" %}}
### Why use GraphQL?

Build user interface centric API. Clients using GraphQL to construct design
elements can efficiently fetch everything required for a component in one
request.

{{% /slide %}}

{{% slide transition="none" background="rebeccapurple" %}}
### Why use GraphQL?

{{% vsplit %}}![query](example-query.png)![ui](example-ui.png){{% /vsplit %}}
{{% /slide %}}

{{% slide transition="none" background="rebeccapurple" %}}

### Differences with REST?

##### Single endpoint

```
/graphql
```

##### vs resource URLs

```
/posts
/posts/1
/posts/1/comments
/posts/1/comments/1
...
```
{{% /slide %}}

{{% slide transition="none" background="rebeccapurple" %}}

### Differences with REST?

##### Single representation

```
content-type: application/json
```

##### vs multiple representations
```
content-type: text/html
content-type: application/xhtml+xml
content-type: application/json
...
```

{{% /slide %}}

{{% slide transition="none" background="rebeccapurple" %}}

### Differences with REST?

##### Fewer status codes

```shell
200 OK
400 Bad Request
```
##### vs many status codes
```shell
200 OK
201 Created
202 Accepted
204 No Content
418 I'm a teapot
...
```

{{% /slide %}}

{{% slide transition="none" background="rebeccapurple" %}}

### Differences with REST?

##### Single request method (typically)

```shell
POST
```

##### vs varied reqeust methods

```shell
GET
POST
PUT
PATCH
DELETE
...
```
{{% /slide %}}

{{% slide transition="none" background="rebeccapurple" %}}

### GraphQL is a <span class="green-text">query language</span>

GraphQL defines an API <span class="green-text">schema</span> to organize
available resources. Resources are declared using static types and
connected to one another via fields.

{{% /slide %}}

{{% slide transition="none" background="rebeccapurple" %}}

### GraphQL is a <span class="green-text">query language</span>

###### Reads

{{% vsplit %}}
```clojure
# Query
query {
  authors {
    name
    posts {
      title
    }
  }
}
```

```haskell
# Schema
type Author {
  name: String
  posts: [Post]
}
type Post {
  title: String
}
```
{{% /vsplit %}}

```json
{
  "data": {
    "authors": [{
      "name": "Dat Boi",
      "posts": [
        { "title": "Here he come" }
      ]
    }
  }]
}
```

{{% /slide %}}

{{% slide transition="none" background="rebeccapurple" %}}

### GraphQL is a <span class="green-text">query language</span>

###### Writes


{{% vsplit %}}
```clojure
# Query
mutation createUser {
  createUser(email: "baz.com") {
    id
    email
  }
}
```

```haskell
# Schema
type Mutation {
  createUser(email: String): User
}
```
{{% /vsplit %}}

```json
{
  "data": {
    "createUser": {
      "id": "3",
      "email": "baz@example.com",
    }
  }
}
```

{{% /slide %}}

{{% slide transition="none" background="rebeccapurple" %}}

### GraphQL is a <span class="green-text">query language</span>

##### Expressive type system

* Scalars
* Objects
* Enums
* Inputs
* Interfaces
* Unions
* Modifiers

{{% /slide %}}

{{% slide transition="none" background="rebeccapurple" %}}

### GraphQL is a <span class="green-text">query language</span>

##### Expressive type system

Builtin scalars

```ruby
ID         # A unique identifier
Int        # A signed 32‐bit integer.
Float      # A signed double-precision floating-point value.
String     # A UTF‐8 character sequence.
Boolean    # `true` or `false`.
```

{{% /slide %}}

{{% slide transition="none" background="rebeccapurple" %}}

### GraphQL is a <span class="green-text">query language</span>

##### Expressive type system

Custom scalars. Create any type you want

```haskell
scalar Time
type Post {
  time: Time
}
```

```ruby
# Create parse and serialize handlers in your runtime.
TimeType = GraphQL::ScalarType.define do
  name "Time"
  description "Time since epoch in seconds"
  coerce_input ->(value) { Time.at(Float(value)) }
  coerce_result ->(value) { value.to_f }
end
# irb(main):001:0> Time.at(Float(1234567890))
# => 2009-02-13 17:31:30 -0600
```

{{% /slide %}}

{{% slide transition="none" background="rebeccapurple" %}}

### GraphQL is a <span class="green-text">query language</span>

##### Expressive type system

Enum

```haskell
# Enums are a collection of scalars referencing specific values
enum ExpenseType {
  FOOD
  TRAVEL
  PARKING
}
type Query {
  expenses(type: ExpenseType): [Expense]
}
```

{{% vsplit %}}

```haskell
query {
  expenses(type: PARKING) {
    merchant
    amount
  }
}
```

```json
{
  "data": {
    "expenses": [
      {"merchant": "Regional airport", "amount": 40.23}
    ]
  }
}
```
{{% /vsplit %}}
{{% /slide %}}

{{% slide transition="none" background="rebeccapurple" %}}

### GraphQL is a <span class="green-text">query language</span>

##### Expressive type system

%p Objects
```haskell
enum CompanyType { CNN }
type Author {
  name: String
  posts: [Post]
}
type Post {
  title: String
}
type Query {
  bloggers(type: CompanyType): [Author]
}
```
{{% /slide %}}

{{% slide transition="none" background="rebeccapurple" %}}

### GraphQL is a <span class="green-text">query language</span>

##### Expressive type system

Inputs

Define an explicit shape of all input objects for mutations. Save the work
of manually parsing and validating the shape and size of user input. Let
GraphQL do the grunt work!

{{% /slide %}}

{{% slide transition="none" background="rebeccapurple" %}}

### GraphQL is a <span class="green-text">query language</span>

##### Expressive type system

Inputs

```clojure
mutation createExpense($input: CreateExpenseInput!) {
  createExpense(input: $input) {
    id
  }
}
```

```haskell
input CreateExpenseInput {
  type: ExpenseType!
  amount: Float!
  description: String
}
```

{{% /slide %}}

{{% slide transition="none" background="rebeccapurple" %}}

### GraphQL is a <span class="green-text">query language</span>

##### Expressive type system

Modifiers


When reading data the GraphQL runtime responds with error messages
communicating the state of the fulfilled query. Any non conformity to the
schema is reported as an error.

{{% /slide %}}

{{% slide transition="none" background="rebeccapurple" %}}

### GraphQL is a <span class="green-text">query language</span>

##### Expressive type system

Modifiers

```ruby
!     # Non null
[]    # List
```

How it works
```ruby
name: String         # nullable name
name: String!        # non nullable name
names: [String]      # nullable list of nullable names
names: [String]!     # non nullable list of nullable names
names: [String!]!    # non nullable list of non nullable names
```

{{% /slide %}}

{{% slide transition="none" background="rebeccapurple" %}}

### GraphQL is a <span class="green-text">query language</span>

##### Expressive type system

Modifiers on types

{{% vsplit %}}
```clojure
query {
  user {
    name
  }
}
```

```haskell
type User {
  id: ID!
  name: String!
}
type Query {
  user: User
}
```
{{% /vsplit %}}

```json
{
  "errors": [
    { "message": "Cannot return null for non-nullable field User.name.", }
  ],
  "data": {
    "user": null
  }
}
```

{{% /slide %}}

{{% slide transition="none" background="rebeccapurple" %}}

### GraphQL is a <span class="green-text">query language</span>

##### Expressive type system

Modifiers on arguments

{{% vsplit %}}

```clojure
query {
  user {
    name
  }
}
```

```haskell
type User {
  id: ID!
  name: String!
}
type Query {
  user(id: ID!): User
}
```
{{% /vsplit %}}

```json
{
  "errors": [
    {
      "message": "Field \"viewer\" argument \"id\" of type \"ID!\" is required but not provided.",
    }
  ]
}
```

{{% /slide %}}

{{% slide transition="none" background="rebeccapurple" %}}

### GraphQL is a <span class="green-text">query language</span>

##### Expressive type system

Modifiers on inputs 😍

{{% vsplit %}}

```clojure
mutation {
  createUser(input: { name: "Jazzy Scooter" }) {
    name
  }
}
```

```haskell
input CreateUserInput {
  name: String!
  email: String!
}
type Mutation {
  createUser(input: CreateUserInput!): User
}
```
{{% /vsplit %}}

```json
{
  "errors": [
    {
      "message": "Field CreateUserInput.email of required type String! was not provided.",
    }
  ]
}
```
{{% /slide %}}

{{% slide transition="none" background="rebeccapurple" %}}

### GraphQL is a <span class="green-text">query language</span>

##### Expressive type system

Unions

A set of possible types with no guarantee of consistency between fields.

{{% /slide %}}

{{% slide transition="none" background="rebeccapurple" %}}

### GraphQL is a <span class="green-text">query language</span>

##### Expressive type system

Unions

```haskell
type SocialMediaPost {
  content: String
}
type BlogPost {
  title: String
  content: String
}
union PostUnion = BlogPost | SocialMediaPost
type Query {
  posts: [PostUnion]
}
```

{{% /slide %}}

{{% slide transition="none" background="rebeccapurple" %}}

### GraphQL is a <span class="green-text">query language</span>

##### Expressive type system

Unions

{{% vsplit %}}
```clojure
query {
  posts {
    ... on SocialMediaPost {
      content
    }
    ... on BlogPost {
      title
      content
    }
  }
}
```

```json
{
  "data": {
    "posts": {
      { "content": "I ate a donut!" },
      { "title": "🍩 are tasty.", "content": "That is all." },
    }
  }
}
```
{{% /vsplit %}}

{{% /slide %}}

{{% slide transition="none" background="rebeccapurple" %}}

### GraphQL is a <span class="green-text">query language</span>

##### Expressive type system

Interface

An abstract type declaring common fields and arguments. Any object
implementing an interface is guarantees certain fields exist.

{{% /slide %}}

{{% slide transition="none" background="rebeccapurple" %}}

### GraphQL is a <span class="green-text">query language</span>

##### Expressive type system

Interface

```haskell
interface MutationResult {
  notice: String
  success: Boolean!
}
type CreateExpensePayload implements MutationResult {
  result: Expense
  success: Boolean!
}
mutation {
  createExpense(input: CreateExpenseInput!): CreateExpensePayload
}
```

{{% /slide %}}

{{% slide transition="none" background="rebeccapurple" %}}

### GraphQL is a <span class="green-text">query language</span>

##### Expressive type system

Interface

{{% vsplit %}}

```clojure
mutation createExpense($input: CreateExpenseInput!) {
  createExpense(input: $input) {
    success
    result {
      amount
    }
  }
}
```

```json
{
  "data": {
    "createExpense": {
      "success": true,
      "result": {
        "amount": 42.0
      }
    }
  }
}
```
{{% /vsplit %}}

{{% /slide %}}

{{% slide transition="none" background="rebeccapurple" %}}

### GraphQL is a <span class="green-text">runtime</span>

GraphQL is a <span class="green-text">runtime</span> layer between the
client and your business logic. It is responsible for <span class="green-text">analyzing</span>,
<span class="green-text">validating</span>, and <span class="green-text">resolving</span> incoming requests.
GraphQL implementations currently exist for:
C# / .NET, Clojure, Elixir, Erlang, Go, Groovy, Java, JavaScript, PHP, Python, Scala, Ruby

{{% /slide %}}

{{% slide transition="none" background="rebeccapurple" %}}

### GraphQL is a <span class="green-text">runtime</span>

##### Analysis

Queries can become complex and tax your system of resources 😫. The runtime
performs complexity and depth analysis on all incoming requests, and if you
wish, it can only allow queries within a specific threshold.

```ruby
MySchema = GraphQL::Schema.define do
 max_depth 10          # Prevent deeply nested resources
 max_complexity 100    # Reject complex queries
end
```

{{% /slide %}}

{{% slide transition="none" background="rebeccapurple" %}}

### GraphQL is a <span class="green-text">runtime</span>

##### Validation

```haskell
query {
  user {
    juicyBitcoins
  }
}
```

```json
{
  "errors": [
    {
      "message": "Cannot query field \"juicyBitcoins\" on type \"User\".",
      "locations": [
        {
          "line": 3,
          "column": 5
        }
      ]
    }
  ]
}
```

{{% /slide %}}

{{% slide transition="none" background="rebeccapurple" %}}

### GraphQL is a <span class="green-text">runtime</span>

##### Resolution

The runtime resolves fields. By default, fields are resolved from the
underlying struct and the values are returned for the field.

{{% /slide %}}

{{% slide transition="none" background="rebeccapurple" %}}

### GraphQL is a <span class="green-text">runtime</span>

##### Resolution

Resolvers are anonymous functions called with three arguments

```clojure
query {
  currentUser {
    email
  }
}
```

```javascript
const resolvers = {
  Query: {
    currentUser: (object, args, context) => context.currentUser
  }
}
// object      # In memory object (think ORM)
// args        # GQL query arguments
// context     # Global state
```

{{% /slide %}}

{{% slide transition="none" background="rebeccapurple" %}}

### GraphQL is a <span class="green-text">runtime</span>

##### Resolution

Define resolvers inline, if you want.

```javascript
const resolvers = {
  User: {
    emailAddressLength: object => object.email.length,
    randomFloat: () => Math.random()
  }
}
```

{{% vsplit %}}
```javascript
type User {
  email: String
  emailAddressLength: Int
  randomFloat: Float
}
```
```json
{
  "data": {
    "currentUser": {
      "email": "foo@example.com",
      "emailAddressLength": 15,
      "randomFloat": 0.008373373072433798,
    }
  }
}
```

{{% /vsplit %}}

{{% /slide %}}

{{% slide transition="none" background="rebeccapurple" %}}

### Benefits

##### There are many. Here are a few.

{{% /slide %}}

{{% slide transition="none" background="rebeccapurple" %}}

### Benefits

##### Explorable APIs

Add descriptions. Deprecate fields. Communicate.

![search](graphiql-search.gif)

{{% /slide %}}

{{% slide transition="none" background="rebeccapurple" %}}

### Benefits

##### Explorable APIs

Add descriptions. Deprecate fields. Communicate.

![intellisense](intellisense.png)

{{% /slide %}}

{{% slide transition="none" background="rebeccapurple" %}}

### Benefits

##### Explorable APIs

Add descriptions. Deprecate fields. Communicate.

![deprecated](deprecated.png)

{{% /slide %}}

{{% slide transition="none" background="rebeccapurple" %}}

### Benefits

##### Explorable APIs

Add descriptions. Deprecate fields. Communicate.

![enum descriptions](enum-descriptions.png)

{{% /slide %}}

{{% slide transition="none" background="rebeccapurple" %}}

### Benefits

##### Explorable APIs

Add descriptions. Deprecate fields. Communicate.
Some good examples:

* [Github API](https://developer.github.com/v4/explorer/)
* [StarWars API](http://graphql.org/swapi-graphql/)

{{% /slide %}}

{{% slide transition="none" background="rebeccapurple" %}}

### Benefits

##### Static Types 🏋️

Push input paramater validations out into the GraphQL runtime and build
user interfaces to consume and bubble up responses.

{{% /slide %}}

{{% slide transition="none" background="rebeccapurple" %}}

### Benefits

##### Declarative User Interface

Design components that speak GraphQL and only request data required to render the component

{{% /slide %}}

{{% slide transition="none" background="rebeccapurple" %}}

### Benefits

##### Declarative User Interface

```javascript
const query = gql`
  query {
    greeting
  }
`
const Greeter = props => (
  <div>
    <h1> {props.data.greeting} </h1>
  </div>
)
export default graphql(query)(Greeter);
```

<small>See [Apollo GraphQL](https://github.com/apollographql) for more information</small>

{{% /slide %}}

{{% slide transition="none" background="rebeccapurple" %}}

### Benefits

##### Composable APIs

Present *N* distinct GraphQL APIs into a single schema with a concept known as _schema stitching_.

<small>See [Schema stitching](https://www.apollographql.com/docs/graphql-tools/schema-stitching.html) for more information.</small>
<small>[Example](https://launchpad.graphql.com/130rr3r49)</small>

{{% /slide %}}

{{% slide transition="none" background="rebeccapurple" %}}

### Benefits

##### Composable APIs

![stitching](stitching.jpg)

{{% /slide %}}

{{% slide transition="none" background="rebeccapurple" %}}

### Benefits

##### Performance Insight

The GraphQL runtime provides executions hooks into each of your resolvers.
It is possible to know the time it takes to resolve each field.

{{% /slide %}}

{{% slide transition="none" background="rebeccapurple" %}}

### Benefits

##### Performance Insight

![tracing](tracing.jpg)

{{% /slide %}}

{{% slide class="center" transition="none" background="rebeccapurple" %}}

### Questions?

##### The end 👋

{{% /slide %}}
