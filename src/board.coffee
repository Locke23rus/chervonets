class Board

  constructor: ->
    @cells = []

  randomNumber: ->
    k = 0
    k = Math.floor(Math.random() * 10)  while k is 0 or k >= N
    k

  fill: ->
    j = 0

    while j < N
      @cells.push []
      i = 0

      while i < N
        @cells[j][i] = @randomNumber()
        i++
      j++

  draw: ->
    @clear()
    j = 0

    while j < N
      i = 0

      while i < N
        new Cell(i, j).draw()  if @cells[j][i]?
        i++
      j++

  emptyCells: ->
    a = []
    j = 0

    while j < N
      i = 0

      while i < N
        a.push new Cell(i, j)  unless @cells[j][i]?
        i++
      j++
    a

  availableNumbers: ->
    a = []
    j = 0

    while j < N
      i = 0

      while i < N
        a.push @cells[j][i]  if @cells[j][i]
        i++
      j++
    a.unique()

  insert: (cell, n) ->
    @cells[cell.j][cell.i] = n
    cell.draw()

  remove: (cell) ->
    @cells[cell.j][cell.i] = null
    cell.clear()

  addRandomCell: ->
    @insert @emptyCells().randomElement(),
            @availableNumbers().randomElement()

  hasBlocks: ->
    j = 0

    while j < N
      i = 0

      while i < N
        return true if @cells[j][i]?
        i++
      j++

    false

  clear: ->
    ctx.clearRect 0, 0, CANVAS_WIDTH, CANVAS_WIDTH

  drawFinish: ->
    @drawText 'Finish!'

  drawPaused: ->
    @drawText 'Paused'

  drawText: (text) ->
    board.clear()
    ctx.fillStyle = '#000'
    ctx.font = '50px Slackey'
    ctx.textBaseline = 'middle'
    ctx.fillText text, CANVAS_WIDTH / 2 - 85, CANVAS_WIDTH / 2
