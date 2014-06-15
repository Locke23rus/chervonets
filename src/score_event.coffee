class @ScoreEvent

  DURATION = 750

  constructor: (@cell, @score) ->
    @cell.event = self
    @time = DURATION

  tick: ->
    @updateTimer()
    @perform()
    @finalize() if @time <= 0

  updateTimer: ->
    @tickTime = 1000 / game.fps
    @time -= @tickTime

  perform: ->
    @cell.drawScore(@score)

  finalize: ->
    @cell.event = undefined

