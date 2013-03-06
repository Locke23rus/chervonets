class Board

  constructor: ->
    @cells = []
    @selectedCell = null
    @clickedCell = null
    @targetCell = null

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
    @clear()
    ctx.fillStyle = '#000'
    ctx.font = '50px Slackey'
    ctx.textBaseline = 'middle'
    ctx.fillText text, CANVAS_WIDTH / 2 - 85, CANVAS_WIDTH / 2

  click: (x, y) ->
    i = Math.floor(x / WIDTH)
    j = Math.floor(y / WIDTH)
    @clickedCell = new Cell(i, j)

    return  if @clickedCell.isEmpty() and not @selectedCell?
    unless @selectedCell?
      @selectedCell = @clickedCell
      @selectedCell.select()
    else
      if @isAvailableToMove()
        if @isSameNumber() or @isMaxInSum()

          game.incrementScore @scoreFactor(@hitDistance())
          @remove @selectedCell
          @remove @clickedCell
          @selectedCell = null
          checkFinish()
          return
        else if @clickedCell.isEmpty()
          @targetCell = @moveCellTarget()
          @insert @targetCell, @selectedCell.n()
          game.decrementScore @scoreFactor(@moveDistance())

          @remove @selectedCell
          @selectedCell = null
          return

      @selectedCell.draw()

      # TODO: Play wrong sound
      @selectedCell = null

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

  isMaxInSum: () ->
    (@selectedCell.n() + @clickedCell.n()) is N

  isSelf: () ->
    @selectedCell.i is @clickedCell.i and @selectedCell.j is @clickedCell.j

  isSameRow: () ->
    @selectedCell.j is @clickedCell.j

  isSameCol: () ->
    @selectedCell.i is @clickedCell.i
