class @MoveEvent extends BaseEvent

  constructor: (@from, @to, @distance) ->
    @time = @distance * MOVE_TIME
    @deltaX = (@to.x - @from.x) / @distance / MOVE_TIME
    @deltaY = (@to.y - @from.y) / @distance / MOVE_TIME

  perform: ->
    @from.x += @tickTime * @deltaX
    @from.y += @tickTime * @deltaY

    for cell, i in Board.path(@from, @to) when not cell.event?
      board.events.push new ScoreEvent(cell, (i+1) * -1)

  finalize: ->
    @to.n = @from.n
    @from.reset()
    board.selectedCell = null
    board.targetCell = null
