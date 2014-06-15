class @BaseEvent

  tick: ->
    @updateTimer()
    @perform()
    @finalize() if @time <= 0

  updateTimer: ->
    @tickTime = 1000 / game.fps
    @time -= @tickTime



class @ScoreEvent extends BaseEvent

  DURATION = 750

  constructor: (@cell, @score) ->
    @cell.event = self
    @time = DURATION

  perform: ->
    @cell.drawScore(@score)

  finalize: ->
    @cell.event = null



class @HitEvent extends BaseEvent

  constructor: (@from, @to, @distance) ->
    @to.event = self
    @time = @distance * MOVE_TIME
    @deltaX = (@to.x - @from.x) / @distance / MOVE_TIME
    @deltaY = (@to.y - @from.y) / @distance / MOVE_TIME

  perform: ->
    @from.clear()

    @from.x += @tickTime * @deltaX
    @from.x = @to.x if (@from.x > @to.x and @deltaX > 0) or (@from.x < @to.x and @deltaX < 0)
    @from.y += @tickTime * @deltaY
    @from.y = @to.y if (@from.y > @to.y and @deltaY > 0) or (@from.y < @to.y and @deltaY < 0)

    @to.draw()
    @from.draw()

    for cell, i in @traversedPath() when not cell.event?
      board.events.push new ScoreEvent(cell, i+1)

  finalize: ->
    @from.event = null
    @from.n = null
    @from.setDefaultCoords()
    @to.n = null

    board.events.push new ScoreEvent(@to, @distance)

  traversedPath: ->
    path = []
    if @from.i is @to.i
      currentJ = if @deltaY > 0 then @from.y // WIDTH else Math.ceil(@from.y / WIDTH)
      for j in [@from.j...currentJ] when j isnt @to.j
        path.push board.cells[j][@from.i]
    else
      currentI = if @deltaX > 0 then @from.x // WIDTH else Math.ceil(@from.x / WIDTH)
      for i in [@from.i...currentI] when i isnt @to.i
        path.push board.cells[@from.j][i]
    path


class @MoveEvent extends BaseEvent

  constructor: (@from, @to, @distance) ->
    @to.event = self
    @time = @distance * MOVE_TIME
    @deltaX = (@to.x - @from.x) / @distance / MOVE_TIME
    @deltaY = (@to.y - @from.y) / @distance / MOVE_TIME

    @endX = @to.x
    @endY = @to.y

    @to.n = @from.n
    @to.x = @from.x
    @to.y = @from.y
    @from.n = null

  perform: ->
    @to.clear()

    @to.x += @tickTime * @deltaX
    @to.x = @endX if (@to.x > @endX and @deltaX > 0) or (@to.x < @endX and @deltaX < 0)
    @to.y += @tickTime * @deltaY
    @to.y = @endY if (@to.y > @endY and @deltaY > 0) or (@to.y < @endY and @deltaY < 0)

    @to.draw()

    for cell, i in @traversedPath() when not cell.event?
      board.events.push new ScoreEvent(cell, (i+1) * -1)

  finalize: ->
    @to.setDefaultCoords()
    @to.event = null

  traversedPath: ->
    path = []
    if @from.i is @to.i
      currentJ = if @deltaY > 0 then @to.y // WIDTH else Math.ceil(@to.y / WIDTH)
      for j in [@from.j...currentJ] when j isnt @to.j
        path.push board.cells[j][@to.i]
    else
      currentI = if @deltaX > 0 then @to.x // WIDTH else Math.ceil(@to.x / WIDTH)
      for i in [@from.i...currentI] when i isnt @to.i
        path.push board.cells[@to.j][i]
    path
