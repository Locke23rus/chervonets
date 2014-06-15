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
    @events = []
    @fill()

  fill: ->
    for j in [0...N]
      @cells[j] = []
      for i in [0...N]
        @cells[j][i] = new Cell(i, j, Number.randomInt(1, 10))

  draw: ->
    @clear()

    unless @hasBlocks()
      board.drawFinish()
      game.finish()
      return

    for j in [0...N]
      for i in [0...N]
        cell = @cells[j][i]
        if cell.n? and not @isSelected(cell)
          cell.draw()

    @events = (e for e in @events when e.time > 0)
    event.tick() for event in @events

    @selectedCell?.drawSelect()
    ctx.drawImage(fakeCanvas, 0, 0);

  emptyCells: () ->
    a = []
    for j in [0...N]
      for i in [0...N]
        a.push @cells[j][i] unless @cells[j][i].n?
    a

  availableNumbers: ->
    a = []
    for j in [0...N]
      for i in [0...N]
        a.push @cells[j][i].n if @cells[j][i].n?
    a.unique()

  addRandomCell: ->
    @emptyCells().randomElement().n = @availableNumbers().randomElement()

  hasBlocks: ->
    for j in [0...N]
      for i in [0...N]
        return true if @cells[j][i].n?
    false

  clear: ->
    ctx.clearRect 0, 0, CANVAS_WIDTH, CANVAS_WIDTH
    fakeCtx.clearRect 0, 0, CANVAS_WIDTH, CANVAS_WIDTH

  drawFinish: ->
    @drawText 'Finish!'
    ctx.drawImage(fakeCanvas, 0, 0);

  drawPaused: ->
    @drawText 'Paused'
    ctx.drawImage(fakeCanvas, 0, 0);

  drawText: (text) ->
    @clear()
    fakeCtx.fillStyle = '#000'
    fakeCtx.font = '50px Slackey'
    fakeCtx.textBaseline = 'middle'
    fakeCtx.fillText text, CANVAS_WIDTH / 2 - 85, CANVAS_WIDTH / 2

  click: (x, y) ->
    i = x // WIDTH
    j = y // WIDTH
    @clickedCell = @cells[j][i]

    return if @clickedCell.isEmpty() and not @selectedCell?
    if @selectedCell?
      if @isSelf()
        @selectedCell = null
        return
      else if @isSameCol() or @isSameRow()
        if @canHit()
          distance = @hitDistance()
          game.incrementScore Utils.scoreFactor(distance)
          @events.push new HitEvent(@selectedCell, @targetCell, distance)
          return
        else if @canMove()
          distance = @moveDistance()
          game.decrementScore Utils.scoreFactor(distance)
          @events.push new MoveEvent(@selectedCell, @targetCell, distance)
          return

    @selectedCell = @clickedCell

  direction: ->
    if @isSameRow()
      if @selectedCell.i > @clickedCell.i then LEFT else RIGHT
    else
      if @selectedCell.j > @clickedCell.j then UP else DOWN

  canHitColl: (range) ->
    for j in range
      cell = @cells[j][@selectedCell.i]
      if cell.n?
        if @selectedCell.n is cell.n
          @targetCell = cell
          return true
        else
          return false
    false

  canHitRow: (range) ->
    for i in range
      cell = @cells[@selectedCell.j][i]
      if cell.n?
        if @selectedCell.n is cell.n
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
        return @canHitRow([@selectedCell.i+1...N])
    false

  canMoveColl: (range) ->
    for j in range
      cell = @cells[j][@selectedCell.i]
      if cell.n?
        return @targetCell?
      else
        @targetCell = cell
    @targetCell?

  canMoveRow: (range) ->
    for i in range
      cell = @cells[@selectedCell.j][i]
      if cell.n?
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

  isSelf: () ->
    @selectedCell.i is @clickedCell.i and @selectedCell.j is @clickedCell.j

  isSameRow: () ->
    @selectedCell.j is @clickedCell.j

  isSameCol: () ->
    @selectedCell.i is @clickedCell.i

  isSelected: (cell) ->
    @selectedCell? and @selectedCell.i is cell.i and @selectedCell.j is cell.j
