n = 1

draw = ->

  [1..60].forEach (i)->
    c.beginPath()
    c.arc width / 2, height / 2, i * 6, deg(n * 0.2), deg(n * 0.2) + 0.1, false
    c.lineWidth = 10
    c.strokeStyle = "rgb(" + Math.floor(i * 3.1) + "," + (i + 125) + "," + Math.floor(i + 40 * 1.1) + ")"
    c.stroke()

  c.rect(0, 0, width, height)
  c.fillStyle = "rgba(20, 20, 20, 0.05)"
  c.fill()

  n += 0.005

  window.requestAnimationFrame(draw)

window.requestAnimationFrame(draw)
