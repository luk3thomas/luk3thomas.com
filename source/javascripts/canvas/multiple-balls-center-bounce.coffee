# animation loop
@.draw = ->
  clear()

  balls.forEach (d, i) ->

    # collision
    collide(d, ball) for ball in balls when ball isnt d

    # gravity
    if i isnt 0
      move(d)
      d.vx += d.dx(center) * -0.0001
      d.vy += d.dy(center) * -0.0001


    # render
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
    @.previous = {}

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

balls = [1..10].map (d,i) -> new Ball(Math.random() * 1000, Math.random() * 1000, Math.random() * 40)
balls.unshift new Ball(center.x, center.y, 200)

# animation functions
collide = (a, b) ->
  nextax = a.x + a.vx
  nextay = a.y + a.vy
  nextbx = b.x + b.vx
  nextby = b.y + b.vy
  distance   = Math.sqrt(Math.pow(nextax - nextbx, 2) + Math.pow(nextay - nextby, 2))
  touching   = distance - (a.r + b.r)

  if touching <= 0
    avx      = ((a.r - b.r) * a.vx + 2 * b.r * b.vx) / (a.r + b.r)
    avy      = ((a.r - b.r) * a.vy + 2 * b.r * b.vy) / (a.r + b.r)
    bvx      = ((b.r - a.r) * b.vx + 2 * a.r * a.vx) / (b.r + a.r)
    bvy      = ((b.r - a.r) * b.vy + 2 * a.r * a.vy) / (b.r + a.r)
    a.vx = avx
    a.vy = avy
    b.vx = bvx
    b.vy = bvy

# if touching < 0
    a.vx += a.dx(b) * 0.009
    a.vy += a.dy(b) * 0.009

move = (a) ->
  a.previous =
    x: a.x
    y: a.y
    vx: a.vx
    vy: a.vy

  # friction
  a.x += a.vx
  a.y += a.vy

gravitate = (a)->
  a.vx = a.dx(center) * 0.01
  a.vy = a.dy(center) * 0.01

clear = ->
  c.clearRect(0, 0, width, height)

onMouseMove = (e)->
  balls[0].x = e.pageX
  balls[0].y = e.pageY
  balls[0].vx = 0
  balls[0].vy = 0
  

addEventListener 'mousemove', onMouseMove, false
  
