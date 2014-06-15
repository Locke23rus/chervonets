class @MoveEvent

  constructor: (@from, @to, @distance) ->
    @time = @distance * MOVE_TIME
    @deltaX = (@to.x - @from.x) / @distance / MOVE_TIME
    @deltaY = (@to.y - @from.y) / @distance / MOVE_TIME

  tick: ->
    @updateTimer()
    @perform()
    @finalize() if @time <= 0

  updateTimer: ->
    @tickTime = 1000 / game.fps
    @time -= @tickTime

  perform: ->
    @from.x += @tickTime * @deltaX
    @from.y += @tickTime * @deltaY

    for cell, i in @path() when not cell.event?
      board.events.push new ScoreEvent(cell, (i+1) * -1)

  finalize: ->
    @to.n = @from.n
    @from.reset()
    board.selectedCell = null
    board.targetCell = null

  path: ->
    path = []
    if @from.i is @to.i
      currentJ = @from.y // WIDTH
      for j in [@from.j...currentJ]
        if j isnt @to.j
          path.push board.cells[j][@from.i]
    else
      currentI = @from.x // WIDTH
      for i in [@from.i...currentI]
        if i isnt @to.i
          path.push board.cells[@from.j][i]
    path
