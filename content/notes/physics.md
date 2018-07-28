---
publishdate: 2014-06-22
title: Physics
---
### Billard ball physics

A few common formulas

    velocity     = change in distance / change in time
    acceleration = change in velocity / change in time
    force        = mass * acceleration
    momentum     = mass * velocity

### Conservation of Momentum

The total momentum of a system before a collision is equal to the total
momentum of a system after a collision.  **A** is Ball A. **B** is Ball B.
**vx** is velocity x

    A.vx = ((A.mass - B.mass) * A.vx + 2 * B.mass * B.vx) / (A.mass + B.mass)

If both objects have the same mass the formula simplifies.
We can think of it as **A** and **B** swap momentums.

    A.vx = 2 * B.mass * B.vx / (A.mass + B.mass)

### atan2

`Math.atan2` gives you the angle between two vectors.
Subtract the distance between each x and each y coordinate of the vector.

![atan2](http://upload.wikimedia.org/wikipedia/commons/thumb/0/03/Atan2_60.svg/350px-Atan2_60.svg.png)

    |       .(2,4)
    |      /
    |     /
    |    /
    |  .(1,1)
    +----------------+

    Math.atan2(1, 3) * 180 / Math.PI
    > 18.43494882292201
