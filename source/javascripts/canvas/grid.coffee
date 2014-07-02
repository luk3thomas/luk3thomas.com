@.draw = ->
  clear()
  
  balls.forEach (d) ->

    gravitate(d)
    move(d)

    c.beginPath()
    c.lineWidth = 0.5
    c.strokeStyle = "#000000"
    c.arc(d.x, d.y, d.r, 0, Math.PI * 2, true)
    c.stroke()
    c.closePath()

# Create a grid, 10 x 10

left = center.x - 250
top  = center.y - 250

balls = [1..100].map (d, i, lisr) ->
  x: i % 10 * 50 + left
  y: Math.floor(i * 0.1) * 10 * 5 + top
  home:
    x: i % 10 * 50 + left
    y: Math.floor(i * 0.1) * 10 * 5 + top
  vx: 0
  vy: 0
  r: 8

gravitate = (a) ->
# a.vx = (a.home.x - a.x) * 0.05
# a.vy = (a.home.y - a.y) * 0.05

move = (a)->
  a.x += a.vx
  a.y += a.vy

mouse = {}
mouseMove = (e)->
  if [typeof mouse.x, typeof mouse.y].indexOf('undefined') != -1
    mouse.x = e.pageX
    mouse.y = e.pageY
    
  vx = e.pageX - mouse.x
  vy = e.pageY - mouse.y

  balls.forEach (d) ->
    distance = Math.sqrt(Math.pow(e.pageX - d.x, 2) + Math.pow(e.pageY - d.y, 2))
    if distance < 60
      d.vx = vx + d.vx
      d.vy = vy + d.vy
    else
      d.vx = (d.home.x - d.x) * 0.05
      d.vy = (d.home.y - d.y) * 0.05

  # Store the old mouse points
  mouse.x = e.pageX
  mouse.y = e.pageY
  
addEventListener 'mousemove', mouseMove, false
