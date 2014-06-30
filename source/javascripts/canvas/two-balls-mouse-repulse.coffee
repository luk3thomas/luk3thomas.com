# animation loop
@.draw = ->
  clear()

  collide(balls[0], balls[1])

  move(balls[0])

  # gravity
  balls[0].vx += balls[0].dx(center) * -0.001
  balls[0].vy += balls[0].dy(center) * -0.001


  balls.forEach (d) ->
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

balls = [new Ball(center.x, center.y, 20), new Ball(0,0,200)]

# animation functions
collide = (a, b) ->
  distance   = a.distance(b)
  touching   = distance - (a.r + b.r)

  if touching < 5 and touching > 3
    avx      = ((a.r - b.r) * a.vx + 2 * b.r * b.vx) / (a.r + b.r)
    avy      = ((a.r - b.r) * a.vy + 2 * b.r * b.vy) / (a.r + b.r)
    bvx      = ((b.r - a.r) * b.vx + 2 * a.r * a.vx) / (b.r + a.r)
    bvy      = ((b.r - a.r) * b.vy + 2 * a.r * a.vy) / (b.r + a.r)
    a.vx = avx
    a.vy = avy
    b.vx = bvx
    b.vy = bvy

  if touching < 3
    a.vx += a.dx(b) * 0.009
    a.vy += a.dy(b) * 0.009

move = (a) ->

  # friction
  a.vx *= 0.97
  a.vy *= 0.97

  a.x += a.vx
  a.y += a.vy

clear = ->
  c.clearRect(0, 0, width, height)

onMouseMove = (e)->
  balls[1].x = e.pageX
  balls[1].y = e.pageY
  balls[1].vx = 0
  balls[1].vy = 0
  

addEventListener 'mousemove', onMouseMove, false
  
