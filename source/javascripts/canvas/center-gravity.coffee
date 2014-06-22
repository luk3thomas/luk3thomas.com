# animation loop
@.draw = ->
  clear()

  circles.forEach (d, i)->

    gravitate(d, circle) for circle in circles when circle isnt d

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
    @.angle = angle

  toRadians: ->
    @.angle * Math.PI / 180

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
gravitate = (a, b) ->
  dx         = a.dx(b)
  dy         = a.dy(b)
  distanceSq = a.distance2(b)
  distance   = a.distance(b)
  force      = a.force(b)
  ax         = force * dx / distance
  ay         = force * dy / distance
  a.vx      += ax / a.r
  a.vy      += ay / a.r
  b.vx      += ax / b.r
  b.vy      += ay / b.r

move = (a) ->
  a.x += a.vx
  a.y += a.vy

clear = ->
  c.clearRect(0, 0, width, height)
