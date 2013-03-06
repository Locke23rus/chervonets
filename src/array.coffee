Array::unique = ->
  @filter (value, index, self) ->
    self.indexOf(value) is index


Array::randomElement = ->
  this[Math.floor(Math.random() * @length)]
