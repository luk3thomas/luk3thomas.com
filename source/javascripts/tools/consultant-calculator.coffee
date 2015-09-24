BUTTON_MAP =
  '×': ['+',   'flatRate']
  '+': ['×', 'percentage']

RATES =
'Alabama':              0.04
'Alaska':               0.00
'Arizona':              0.056
'Arkansas':             0.065
'California':           0.075
'Colorado':             0.029
'Connecticut':          0.0635
'Delaware':             0.00
'District of Columbia': 0.0575
'Florida':              0.06
'Georgia':              0.04
'Hawaii':               0.04
'Idaho':                0.06
'Illinois':             0.0625
'Indiana':              0.07
'Iowa':                 0.06
'Kansas':               0.065
'Kentucky':             0.06
'Louisiana':            0.04
'Maine':                0.055
'Maryland':             0.06
'Massachusetts':        0.0625
'Michigan':             0.06
'Minnesota':            0.0688
'Mississippi':          0.07
'Missouri':             0.0423
'Montana':              0.00
'Nebraska':             0.055
'Nevada':               0.0685
'New Hampshire':        0.00
'New Jersey':           0.07
'New Mexico':           0.0513
'New York':             0.04
'North Carolina':       0.0475
'North Dakota':         0.05
'Ohio':                 0.0575
'Oklahoma':             0.045
'Oregon':               0.00
'Pennsylvania':         0.06
'Puerto Rico':          0.06
'Rhode Island':         0.07
'South Carolina':       0.06
'South Dakota':         0.04
'Tennessee':            0.07
'Texas':                0.0625
'Utah':                 0.0595
'Vermont':              0.06
'Virginia':             0.053
'Washington':           0.065
'West Virginia':        0.06
'Wisconsin':            0.05
'Wyoming':              0.04

STATE =
  price:
    value: 0
    label: ""
  shipping:
    type: 'flatRate'
    value: 0
  tax:
    type: 'percentage'
    value: 0.06

$clear     = document.getElementById('clear')
$price     = document.getElementById('price')
$tax       = document.getElementById('tax')
$result    = document.getElementById('result')
$state     = document.getElementById('state')
$shipping  = document.getElementById('shipping')
inputs     = {$price, $tax, $shipping}

options = for k,v of RATES
  "<option value='#{v}'>#{k}</option>"

$state.innerHTML += options

toNumberType = (string, type) ->
  number = toNumber(string)
  if type is 'percentage'
    number / 100
  else
    number

toNumber = (string) ->
  +string.replace /[A-z]/g, ''
         .replace /\$|%/g, ''

$clear.addEventListener 'click', ->
  STATE.price.label = ""
  STATE.price.value = 0
  renderInputs()
  render()
  $price.focus()

$shipping.addEventListener 'keyup', ->
  STATE.shipping.value = toNumberType($shipping.value, STATE.shipping.type)
  render()

$price.addEventListener 'keyup', ->
  STATE.price.label = $price.value
  STATE.price.value = sumPrice($price.value)
  render()

$tax.addEventListener 'keyup', ->
  STATE.tax.value = toNumberType($tax.value, STATE.tax.type)
  render()

$state.addEventListener 'change', ->
  value = (+$state.value * 100).toString()
  STATE.tax.value = toNumberType(value, STATE.tax.type)
  renderInputs()
  render()

# listen for button changes
document.body.addEventListener 'click', (e) ->
  { target } = e
  if target.tagName.toLowerCase() is 'button'
    html = target.innerHTML
    id   = target.attributes.for.nodeValue
    type = if  /shipping/.test(id) then 'shipping' else 'tax'
    if html is '+'
      STATE[type].type   = 'percentage'
      STATE[type].value *= 0.01
    else
      STATE[type].type = 'flatRate'
      STATE[type].value *= 100
    renderInputs()
    render()


# methods

storeState = ->
  localStorage['state'] = JSON.stringify(STATE)

restoreState = ->
  if state = localStorage['state']
    STATE = JSON.parse(state)
    renderInputs()
  STATE

sumPrice = (string) ->
  string.split(/\r|\n/)
        .filter (v) -> v
        .map    (v) -> v.replace(/,|[A-z]/g, '')
        .map    (v) -> +v
        .reduce (sum, v) ->
          sum + v
        , 0

setButtonState = (type) ->
  element = document.getElementById("button-#{type}")
  id = element.attributes.for.nodeValue
  if STATE[type].type is 'flatRate'
    element.innerHTML = '+'
    document.getElementById(id).className = "input-group flatRate"
  else
    element.innerHTML = '×'
    document.getElementById(id).className = "input-group percentage"

renderInputs = ->
  $price.value = STATE.price.label or ""
  for input in ['tax', 'shipping']
    { type, value } = STATE[input]
    $input = inputs["$#{input}"]
    if type is 'flatRate'
      $input.value = value.toFixed(2)
    else
      $input.value = (value * 100).toFixed(2)

render = ->
  price    = STATE.price.value
  tax      = STATE.tax.value
  shipping = STATE.shipping.value

  setButtonState('shipping')
  setButtonState('tax')

  if STATE.tax.type is 'flatRate'
    finalTax = tax
  else
    finalTax = price * tax

  if STATE.shipping.type is 'flatRate'
    finalShipping = shipping
  else
    finalShipping = price * shipping

  result = price + finalTax + finalShipping

  $result.innerHTML = result.toFixed(2)
  storeState()

# kick it off
restoreState()
render()
