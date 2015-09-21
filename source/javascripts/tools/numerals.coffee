NUMERAL_REGEX = /^\(?M{0,4}(CM|CD|D?C{0,3})(XC|XL|L?X{0,3})(IX|IV|V?I{0,3})(\.|\))?$/i
NUMERALS =
  'iv': 4
  'ix': 9
  'xl': 40
  'xc': 90
  'cd': 400
  'cm': 900
  'i':  1
  'v':  5
  'x':  10
  'l':  50
  'c':  100
  'd':  500
  'm':  1000

SAMPLE = """
When thou seest thy bed, let it put thee in mind of thy grave (Job. xvii. 13), which is now the bed of Christ: for Christ, by laying his holy body to rest three days and three nights in the grave (Matt. xii. 40), hath sanctified, and, as it were, warmed it for the bodies of his saints to rest and sleep in (1 Thess. iv. 13), till the morning of the resurrection; so that now, unto the faithful, death is but a sweet sleep, and the grave but Christ’s bed, where their bodies rest and sleep in peace (Isa. lvii. 2), until the joyful morning of the resurrection day shall dawn unto them (Isa. xxvi. 20.)
"""

isNum = (n) -> typeof n is 'number'

calculate = (string) ->
  chars  = string.toLowerCase().split('')
  Object.keys(NUMERALS)
    .filter (c) -> c.length is 2
    .reduce (a, c, i, l) ->
      a.map (char, i, list) ->
        concat = "#{char}#{list[i+1]}"
        if c is concat
          list[i+1] = null
          concat
        else
          char
      , []
    , chars
    .filter (c) -> c
    .reduce (results, numeral, index, list) ->
      i = results.length - 1
      number = NUMERALS[numeral]
      if number
        unless isNum(results[i])
          results.push(0)
          i += 1
        results[i] += number
      else
        results.push(numeral)
      results
    , []
    .join('')

toRomanNumeral = ->
  input.value.split(' ')
    .map (word) ->
      if NUMERAL_REGEX.test(word)
        calculate(word)
      else
        word
    .join(' ')

input  = document.getElementById('input')
result = document.getElementById('result')
sample = document.getElementById('sample')
numerals = document.getElementById('numerals')

update = (v) ->
  result.innerHTML = v

convert = (e) ->
  e.stopPropagation()
  update(toRomanNumeral(input.value))

'keypress keyup keydown'.split(' ').forEach (name, i) ->
  input.addEventListener(name, convert)

sample.addEventListener 'click', ->
  input.value = SAMPLE
  convert(stopPropagation: ->)
