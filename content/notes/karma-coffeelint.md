---
publishdate: 2015-05-11
title: karma coffeelint
---

I recently released a new karma plugin for auto linting your CoffeeScript
files, [karma-coffeelint](https://www.npmjs.com/package/karma-coffeelint).

[![NPM Package
Stats](https://nodei.co/npm/karma-coffeelint.png)](https://www.npmjs.org/package/karma-coffeelint)

Here at work we've been beefing up test coverage for our CoffeeScript
applications. We recently began using coffeelint to enforce some sane,
standardized guidelines for our codebase without having to nitpick each other's
pull requests.

We used the `coffeelint` command to recursively lint all of our coffee files on
start. However, we didn't know what the linter thought of the CoffeeScript we
were writing. There wasn't any feedback from karma when the test suite ran on
file change.

[karma-coffeelint](https://www.npmjs.com/package/karma-coffeelint) lints your
CoffeeScript when you update a file, shortening your feedback loop.

Checkout the installation instructions on
[github](https://github.com/luk3thomas/karma-coffeelint).
