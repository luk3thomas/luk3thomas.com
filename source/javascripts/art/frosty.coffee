c.rect(0, 0, width, height)
c.fillStyle   = "rgba(33, 10, 54, 1)"
c.fill()

c.fillStyle   = "rgba(255,255,255,0.5)"
c.strokeStyle = "rgba(255,255,255,0.5)"

rad = (angle) ->
  Math.PI / 180 * angle

line = (angle, l, x, y) ->
  [Math.sin(rad(angle)) * l + x, Math.cos(rad(angle)) * l + y]

points = (x,y,length) ->
  sides = [1..7]
  sides.forEach (n, i, l)->
    if i is 0
      return sides[i] = [x, y]
    sides[i] = line((60 + count * 0.5) * i, length, sides[i - 1][0], sides[i - 1][1])
  sides

hexagon = (x, y, l, fill) ->
  c.beginPath()
  c.moveTo(x,y)
  points(x, y, l).forEach (d)->
    c.lineTo.apply(c, d)
  c.stroke()
  c.fill() if fill

pattern = (x,y, l)->

  cx = x - l
  cy = y + l / 2

  hexagon(cx, cy, l)
  #hexagon(cx - l, cy - l, l)
  #hexagon(cx + l, cy - l, l)
  #hexagon(cx - l, cy + l, l)
  #hexagon(cx + l, cy + l, l)

count = 0
draw = ->
  count += 1
  pattern(width / 2 , height / 2 , 100)

  window.requestAnimationFrame(draw)

window.requestAnimationFrame(draw)
