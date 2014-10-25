# Creates several shapes. Begins as a hexagon, then
# becomes a star, square, triangle, etc.

count = 0

c.rect(0, 0, width, height)
c.fillStyle   = "rgba(33, 10, 54, 1)"
c.fill()

background = ->
  c.rect(0, 0, width, height)
  c.fillStyle   = "rgba(33, 10, 54, 0.05)"
  c.fill()
  c.fillStyle   = "rgba(255,255,255,0.5)"
  c.strokeStyle = "rgba(255,255,255,0.5)"

rad = (angle) ->
  Math.PI / 180 * angle

line = (angle, l, x, y) ->
  [Math.sin(rad(angle)) * l + x, Math.cos(rad(angle)) * l + y]

points = (x, y, length, angle) ->
  sides = [1..7]
  sides.forEach (n, i, l)->
    if i is 0
      return sides[i] = [x, y]
    sides[i] = line((angle) * i, length, sides[i - 1][0], sides[i - 1][1])
  sides

polygon = (x, y, l, angle, fill) ->
  c.beginPath()
  c.moveTo(x,y)
  points(x, y, l, angle).forEach (d)->
    c.lineTo.apply(c, d)
  c.stroke()
  c.fill() if fill

pattern = (x, y, l, angle)->
  polygon(x, y, l, angle)

draw = ->
  count += 1
  background()
  pattern(width / 2 , height / 2 , 100, 60 + count * 0.5)

  window.requestAnimationFrame(draw)

window.requestAnimationFrame(draw)
