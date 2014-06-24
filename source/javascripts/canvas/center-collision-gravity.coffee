# animation loop
@.draw = ->
  clear()

  circles.forEach (d, i)->

    collide(d, circle) for circle in circles when circle isnt d

    move(d)

    d.x += (d.x - center.x) * -0.09
    d.y += (d.y - center.y) * -0.09

    c.beginPath()
    c.strokeStyle = '#000000'
    c.lineWidth = 0.5
    c.arc(d.x, d.y, d.r, 0, Math.PI * 2, true)
    c.stroke()
    c.closePath()

# Ball class
class Ball

  constructor: (x, y, radius, angle) ->
    @.x = x
    @.y = y
    @.vx = 0
    @.vy = 0
    @.r = radius

  angle: (b)->
    Math.atan2(@.dx(b), @.dy(b))

  dx: (b)->
    @.x - b.x

  dy: (b)->
    @.y - b.y

  distance2: (b)->
    Math.pow(@.dx(b), 2) + Math.pow(@.dy(b), 2)

  distance: (b)->
    Math.sqrt(@.distance2(b))

  force: (b)->
    @.r * b.r / @.distance(b)


circles = [1..42].map (d) ->
  new Ball(Math.random() * 100 + 300, Math.random() * 100 + 300, Math.random() * 10 + 5, Math.random() * 360)

# animation functions
collide = (a, b) ->
  distance   = a.distance(b)
  touching   = a.r + b.r - distance

  if touching < 5 and touching > 0
    avx      = ((a.r - b.r) * a.vx + 2 * b.r * b.vx) / (a.r + b.r)
    avy      = ((a.r - b.r) * a.vy + 2 * b.r * b.vy) / (a.r + b.r)
    bvx      = ((b.r - a.r) * b.vx + 2 * a.r * a.vx) / (b.r + a.r)
    bvy      = ((b.r - a.r) * b.vy + 2 * a.r * a.vy) / (b.r + a.r)
    a.vx = avx
    a.vy = avy
    b.vx = bvx
    b.vy = bvy

  if touching < 0
    a.vx += a.dx(b) * 0.009
    a.vy += a.dy(b) * 0.009

move = (a) ->
  a.vx += a.dx(center) * -0.61
  a.vy += a.dy(center) * -0.61
  a.x += a.vx
  a.y += a.vy

clear = ->
  c.clearRect(0, 0, width, height)
