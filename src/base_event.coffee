class @BaseEvent

  tick: ->
    @updateTimer()
    @perform()
    @finalize() if @time <= 0

  updateTimer: ->
    @tickTime = 1000 / game.fps
    @time -= @tickTime
