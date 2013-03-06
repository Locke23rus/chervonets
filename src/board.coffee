class Board

  constructor: ->
    @cells = []
    @selectedCell = null

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
    cell = new Cell(i, j)

    return  if cell.isEmpty() and not @selectedCell?
    unless @selectedCell?
      @selectedCell = cell
      @selectedCell.select()
    else
      if @isSameRow(@selectedCell, cell) or @isSameCol(@selectedCell, cell)
        if @isAvailableToMove(@selectedCell, cell)
          if @isSameNumber(@selectedCell, cell) or @isMaxInSum(@selectedCell, cell)
            game.incrementScore 1
            @remove @selectedCell
            @remove cell
            @selectedCell = null
            checkFinish()
            return
          else if cell.isEmpty()
            @insert @moveCellTarget(@selectedCell, cell), currentCell.n()
            @remove @selectedCell
            @selectedCell = null
            return
      @selectedCell.draw()

      # TODO: Play wrong sound
      @selectedCell = null


  moveCellTarget: (a, b) ->
    t = undefined
    i = undefined
    j = undefined
    if @isSameRow(a, b)
      if b.i > a.i
        i = b.i
        while i < N
          unless @cells[a.j][i]?
            t = i
          else
            break
          i++
      else
        i = b.i
        while i >= 0
          unless @cells[a.j][i]?
            t = i
          else
            break
          i--
      new Cell(t, a.j)
    else
      if b.j > a.j
        j = b.j
        while j < N
          unless @cells[j][a.i]?
            t = j
          else
            break
          j++
      else
        j = b.j
        while j >= 0
          unless @cells[j][a.i]?
            t = j
          else
            break
          j--
      new Cell(a.i, t)

  isAvailableToMove: (a, b) ->
    min = undefined
    max = undefined
    if @isSelf(a, b)
      return false
    else if @isSameRow(a, b)
      min = Math.min(a.i, b.i)
      max = Math.max(a.i, b.i)
      if (min + 1) is max
        return true
      else
        i = min + 1

        while i < max
          return false if @cells[a.j][i]?
          i++

        return true
    else if @isSameCol(a, b)
      min = Math.min(a.j, b.j)
      max = Math.max(a.j, b.j)
      if (min + 1) is max
        return true
      else
        j = min + 1

        while j < max
          return false  if @cells[j][a.i]?
          j++

        return true
    false

  isSameNumber: (a, b) ->
    @cells[a.j][a.i] is @cells[b.j][b.i]

  isMaxInSum: (a, b) ->
    (@cells[a.j][a.i] + @cells[b.j][b.i]) is N

  isSelf: (a, b) ->
    a.i is b.i and a.j is b.j

  isSameRow: (a, b) ->
    a.j is b.j

  isSameCol: (a, b) ->
    a.i is b.i
