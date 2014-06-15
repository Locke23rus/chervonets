class @ScoreEvent extends BaseEvent

  DURATION = 750

  constructor: (@cell, @score) ->
    @cell.event = self
    @time = DURATION

  perform: ->
    @cell.drawScore(@score)

  finalize: ->
    @cell.event = undefined

