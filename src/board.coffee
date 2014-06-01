class Board

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

    return  if @clickedCell.isEmpty() and not @selectedCell?
    if @selectedCell? and @isAvailableToMove()
      if @isSameNumber()

        game.incrementScore @scoreFactor(@hitDistance())
        @remove @selectedCell
        @remove @clickedCell
        @selectedCell = null

        unless @hasBlocks()
          board.drawFinish()
          game.finish()

        return

      else if @clickedCell.isEmpty()
        @targetCell = @moveCellTarget()
        @insert @targetCell, @selectedCell.n()
        game.decrementScore @scoreFactor(@moveDistance())

        @remove @selectedCell
        @selectedCell = null
        return

    @selectedCell = @clickedCell

  hitDistance: () ->
    if @isSameRow()
      Math.abs(@clickedCell.i - @selectedCell.i) + 1
    else
      Math.abs(@clickedCell.j - @selectedCell.j) + 1

  moveDistance: () ->
    if @isSameRow()
      Math.abs(@targetCell.i - @selectedCell.i)
    else
      Math.abs(@targetCell.j - @selectedCell.j)


  scoreFactor: (n) ->
    sum = 0
    i = 0
    while i <= n
      sum += i
      i++

    sum

  moveCellTarget: () ->
    t = undefined
    i = undefined
    j = undefined
    if @isSameRow()
      if @clickedCell.i > @selectedCell.i
        i = @clickedCell.i
        while i < N
          unless @cells[@selectedCell.j][i]?
            t = i
          else
            break
          i++
      else
        i = @clickedCell.i
        while i >= 0
          unless @cells[@selectedCell.j][i]?
            t = i
          else
            break
          i--
      new Cell(t, @selectedCell.j)
    else
      if @clickedCell.j > @selectedCell.j
        j = @clickedCell.j
        while j < N
          unless @cells[j][@selectedCell.i]?
            t = j
          else
            break
          j++
      else
        j = @clickedCell.j
        while j >= 0
          unless @cells[j][@selectedCell.i]?
            t = j
          else
            break
          j--
      new Cell(@selectedCell.i, t)

  isAvailableToMove: () ->
    return false unless @isSameRow() or @isSameCol()
    min = undefined
    max = undefined
    if @isSelf()
      return false
    else if @isSameRow()
      min = Math.min(@selectedCell.i, @clickedCell.i)
      max = Math.max(@selectedCell.i, @clickedCell.i)
      if (min + 1) is max
        return true
      else
        i = min + 1

        while i < max
          return false if @cells[@selectedCell.j][i]?
          i++

        return true
    else if @isSameCol()
      min = Math.min(@selectedCell.j, @clickedCell.j)
      max = Math.max(@selectedCell.j, @clickedCell.j)
      if (min + 1) is max
        return true
      else
        j = min + 1

        while j < max
          return false  if @cells[j][@selectedCell.i]?
          j++

        return true
    false

  isSameNumber: () ->
    @selectedCell.n() is @clickedCell.n()

  isSelf: () ->
    @selectedCell.i is @clickedCell.i and @selectedCell.j is @clickedCell.j

  isSameRow: () ->
    @selectedCell.j is @clickedCell.j

  isSameCol: () ->
    @selectedCell.i is @clickedCell.i

  isSelected: (cell) ->
    @selectedCell? and @selectedCell.i is cell.i and @selectedCell.j is cell.j
