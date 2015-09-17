onScroll = ->
  localStorage[key()] = window.scrollY

onLoad = ->
  position = localStorage[key()]
  if position?
    window.scrollTo(0, +position)

key = ->
  location.pathname

toggleDarkTheme = ->
  if /dark/.test(document.body.className)
    name = ''
  else
    name = 'dark'
  document.body.className = name

window.addEventListener 'scroll', onScroll.bind(@)

window.onload = onLoad.bind(@)

window.addEventListener 'keypress', (e) ->
  switch e.which
    when 100 then toggleDarkTheme()
