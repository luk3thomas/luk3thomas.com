length = 0
incrementing = true

c.rect(0, 0, width, height)
c.fillStyle = "rgba(12, 44, 84, 1)"
c.fill()

triangle = (x, y, h, w, a) ->
  c.save()
  c.beginPath()
  c.translate(x, y)
  c.rotate(Math.PI / 180 * a)
  c.moveTo(0, 0)
  c.lineTo(w / 2, h)
  c.lineTo(-w / 2, h)
  c.lineTo(0, 0)
  c.stroke()
  c.closePath()
  c.restore()

draw = ->
  c.rect(0,0,width,height)
  c.fill()
  angle = 0

  length += 0.1 if incrementing
  length -= 0.1 if not incrementing

  incrementing = false if length > width / 4
  incrementing = true  if length < 1

  c.strokeStyle = "rgba(255, " + Math.floor(Math.min(length + 18, 255)) + ", 26, 0.74)"

  [1..72].forEach (d) ->
    angle += 5
    triangle(width / 2, height / 2, length, width / 2, angle)

  window.requestAnimationFrame(draw)

window.requestAnimationFrame(draw)
