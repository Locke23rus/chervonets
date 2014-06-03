class Board

  UP = 0
  RIGHT = 1
  DOWN = 2
  LEFT = 3

  constructor: ->
    @cells = []
    @selectedCell = null
    @clickedCell = null
    @targetCell = null
    @fill()

  fill: ->
    for j in [0...N]
      @cells.push []
      for i in [0...N]
        @cells[j][i] = Number.randomInt(1, 10)

  draw: ->
    @clear()
    for j in [0...N]
      for i in [0...N]
        cell = new Cell(i, j)
        if cell.n()?
          if @isSelected(cell)
            cell.drawSelect()
          else
            cell.draw()

  emptyCells: () ->
    a = []
    for j in [0...N]
      for i in [0...N]
        a.push new Cell(i, j)  unless @cells[j][i]?
    a

  availableNumbers: ->
    a = []
    for j in [0...N]
      for i in [0...N]
            a.push @cells[j][i]  if @cells[j][i]
    a.unique()

  insert: (cell, n) ->
    @cells[cell.j][cell.i] = n

  remove: (cell) ->
    @cells[cell.j][cell.i] = null

  addRandomCell: ->
    @insert @emptyCells().randomElement(),
            @availableNumbers().randomElement()

  hasBlocks: ->
    for j in [0...N]
      for i in [0...N]
        return true if @cells[j][i]?
    false

  clear: ->
    ctx.clearRect 0, 0, CANVAS_WIDTH, CANVAS_WIDTH

  drawFinish: ->
    @drawText 'Finish!'

  drawPaused: ->
    @drawText 'Paused'

  drawText: (text) ->
    @clear()
    ctx.fillStyle = '#000'
    ctx.font = '50px Slackey'
    ctx.textBaseline = 'middle'
    ctx.fillText text, CANVAS_WIDTH / 2 - 85, CANVAS_WIDTH / 2

  click: (x, y) ->
    i = x // WIDTH
    j = y // WIDTH
    @clickedCell = new Cell(i, j)

    return if @clickedCell.isEmpty() and not @selectedCell?
    if @selectedCell?
      if @isSelf()
        @selectedCell = null
        return
      else if @isSameCol() or @isSameRow()
        if @canHit()
          game.incrementScore @scoreFactor(@hitDistance())
          @remove @selectedCell
          @remove @targetCell
          @selectedCell = null
          @targetCell = null

          unless @hasBlocks()
            board.drawFinish()
            game.finish()

          return
        else if @canMove()
          game.decrementScore @scoreFactor(@moveDistance())
          @insert @targetCell, @selectedCell.n()
          @remove @selectedCell

          @selectedCell = null
          @targetCell = null
          return

    @selectedCell = @clickedCell


  direction: ->
    if @isSameRow()
      if @selectedCell.i > @clickedCell.i then LEFT else RIGHT
    else
      if @selectedCell.j > @clickedCell.j then UP else DOWN

  canHitColl: (colls) ->
    for j in colls
      cell = new Cell(@selectedCell.i, j)
      if cell.n()?
        if @selectedCell.n() is cell.n()
          @targetCell = cell
          return true
        else
          return false
    false

  canHitRow: (rows) ->
    for i in rows
      cell = new Cell(i, @selectedCell.j)
      if cell.n()?
        if @selectedCell.n() is cell.n()
          @targetCell = cell
          return true
        else
          return false
    false

  canHit: ->
    switch @direction()
      when UP
        return @canHitColl([@selectedCell.j-1..0])
      when DOWN
        return @canHitColl([@selectedCell.j+1...N])
      when LEFT
        return @canHitRow([@selectedCell.i-1..0])
      when RIGHT
        return @canHitRow([@selectedCell.i+1..N])
    false

  canMoveColl: (colls) ->
    for j in colls
      cell = new Cell(@selectedCell.i, j)
      if cell.n()?
        return @targetCell?
      else
        @targetCell = cell
    @targetCell?

  canMoveRow: (rows) ->
    for i in rows
      cell = new Cell(i, @selectedCell.j)
      if cell.n()?
        return @targetCell?
      else
        @targetCell = cell
    @targetCell?

  canMove: ->
    switch @direction()
      when UP
        return @canMoveColl([@selectedCell.j-1..0])
      when DOWN
        return @canMoveColl([@selectedCell.j+1...N])
      when LEFT
        return @canMoveRow([@selectedCell.i-1..0])
      when RIGHT
        return @canMoveRow([@selectedCell.i+1...N])
    false

  hitDistance: () ->
    if @isSameRow()
      Math.abs(@targetCell.i - @selectedCell.i) + 1
    else
      Math.abs(@targetCell.j - @selectedCell.j) + 1

  moveDistance: () ->
    if @isSameRow()
      Math.abs(@targetCell.i - @selectedCell.i)
    else
      Math.abs(@targetCell.j - @selectedCell.j)

  scoreFactor: (n) ->
    sum = 0
    sum += i for i in [0..n]
    sum

  isSelf: () ->
    @selectedCell.i is @clickedCell.i and @selectedCell.j is @clickedCell.j

  isSameRow: () ->
    @selectedCell.j is @clickedCell.j

  isSameCol: () ->
    @selectedCell.i is @clickedCell.i

  isSelected: (cell) ->
    @selectedCell? and @selectedCell.i is cell.i and @selectedCell.j is cell.j
