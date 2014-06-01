Number.randomInt = (a, z) ->
  x = a - 1
  x = Math.floor(Math.random() * 10) + 1  while x < a or x > z
  x
