class @MoveEvent

  constructor: (@from, @to, @distance) ->
    @time = @distance * MOVE_TIME
    @deltaX = (@to.x - @from.x) / @distance / MOVE_TIME
    @deltaY = (@to.y - @from.y) / @distance / MOVE_TIME

  draw: ->
    tickTime = 1000 / game.fps
    console.log tickTime
    @from.x += tickTime * @deltaX
    @from.y += tickTime * @deltaY
    @time -= tickTime

    if @time <= 0
      @to.n = @from.n
      @from.reset()
      board.selectedCell = null
      board.targetCell = null
