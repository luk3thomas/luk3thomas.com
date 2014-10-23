c.rect(0, 0, width, height)
c.fillStyle   = "rgba(33, 10, 54, 1)"
c.fill()

c.fillStyle   = "rgba(255,255,255,0.05)"
c.strokeStyle = "rgba(255,255,255,0.5)"

[1..10].forEach (i, x, l) ->
  c.beginPath()
  c.arc(width/2, height/2, width / 2 * (i / l.length) * 0.9, 0, Math.PI * 2)
  c.fill()
  c.stroke()

c.beginPath()
c.strokeStyle = "rgba(255,255,255,0.2)"

c.moveTo( width/2,          0)
c.lineTo( width/2,     height)
c.moveTo(       0,   height/2)
c.lineTo(   width,   height/2)

c.stroke()

