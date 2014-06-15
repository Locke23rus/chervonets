class Cell

  constructor: (@i, @j, @n) ->
    @x = @i * WIDTH
    @y = @j * WIDTH
    @event = undefined

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
    fakeCtx.font = "28px monospaced"
    fakeCtx.textBaseline = "middle"
    if @n is 10
      fakeCtx.fillText @n, @x + 8, @y + 26
    else
      fakeCtx.fillText @n, @x + 15, @y + 26

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

  drawScore: (score) ->
    fakeCtx.fillStyle = if score > 0 then "#66CC66" else "#FF3333"
    fakeCtx.font = "24px monospaced"
    fakeCtx.textBaseline = "middle"
    str = if score > 0 then "+#{score}" else score
    if score is 10
      fakeCtx.fillText "+#{score}", @x, @y + 26
    else
      if score > 0
        fakeCtx.fillText "+#{score}", @x + 8, @y + 26
      else
        fakeCtx.fillText score, @x + 16, @y + 26
