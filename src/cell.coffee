class Cell

  constructor: (@i, @j, @n) ->
    @x = @i * WIDTH
    @y = @j * WIDTH

  color: ->
    switch @n
      when 1 then "#FF6633"
      when 2 then "#66CCFF"
      when 3 then "#FF66FF"
      when 4 then "#CC99FF"
      when 5 then "#CCCCFF"
      when 6 then "#6699FF"
      when 7 then "#FFFF66"
      when 8 then "#66CC66"
      when 9 then "#CCFF66"
      when 10 then "#FF3333"
      else "#FFF"

  draw: ->
    @drawBackground @color()
    @drawNumber "#000"

  drawBackground: (color) ->
    fakeCtx.fillStyle = color
    fakeCtx.fillRect @x, @y, WIDTH, WIDTH
    fakeCtx.strokeStyle = "#FFF"
    fakeCtx.strokeRect @x, @y, WIDTH, WIDTH

  drawNumber: (color) ->
    fakeCtx.fillStyle = color
    fakeCtx.font = "30px monospaced"
    fakeCtx.textBaseline = "middle"
    if @n is 10
      fakeCtx.fillText @n, @x + 8, @y + 25
    else
      fakeCtx.fillText @n, @x + 15, @y + 25

  isEmpty: ->
    not @n?

  drawSelect: ->
    @drawBackground "#000066"
    @drawNumber "#FFF"

  clear: ->
    fakeCtx.clearRect @x, @y, WIDTH, WIDTH

  reset: ->
    @n = null
    @x = @i * WIDTH
    @y = @j * WIDTH
