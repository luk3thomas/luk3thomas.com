onScroll = ->
  localStorage[key()] = window.scrollY

onLoad = ->
  position = localStorage[key()]
  if position?
    window.scrollTo(0, +position)

key = ->
  location.pathname

window.addEventListener 'scroll', onScroll.bind(@)

window.onload = onLoad.bind(@)
