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
    @from.event = self
    @to.event = self
    @time = @distance * MOVE_TIME
    @deltaX = (@to.x - @from.x) / @distance / MOVE_TIME
    @deltaY = (@to.y - @from.y) / @distance / MOVE_TIME

  perform: ->
    @from.x += @tickTime * @deltaX
    @from.y += @tickTime * @deltaY

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
      currentJ = @from.y // WIDTH
      for j in [@from.j...currentJ] when j isnt @to.j
        path.push board.cells[j][@from.i]
    else
      currentI = @from.x // WIDTH
      for i in [@from.i...currentI] when i isnt @to.i
        path.push board.cells[@from.j][i]
    path


class @MoveEvent extends BaseEvent

  constructor: (@from, @to, @distance) ->
    @to.event = self
    @time = @distance * MOVE_TIME
    @deltaX = (@to.x - @from.x) / @distance / MOVE_TIME
    @deltaY = (@to.y - @from.y) / @distance / MOVE_TIME

    @to.n = @from.n
    @to.x = @from.x
    @to.y = @from.y
    @from.n = null

  perform: ->
    @to.x += @tickTime * @deltaX
    @to.y += @tickTime * @deltaY

    @to.draw()

    for cell, i in @traversedPath() when not cell.event?
      board.events.push new ScoreEvent(cell, (i+1) * -1)

  finalize: ->
    @to.setDefaultCoords()
    @to.event = null

  traversedPath: ->
    path = []
    if @from.i is @to.i
      currentJ = @to.y // WIDTH
      for j in [@from.j...currentJ] when j isnt @to.j
        path.push board.cells[j][@to.i]
    else
      currentI = @to.x // WIDTH
      for i in [@from.i...currentI] when i isnt @to.i
        path.push board.cells[@to.j][i]
    path
