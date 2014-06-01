class Game

  constructor: () ->
    @score = 0
    @paused = false
    @showScore()
    @interval = null
    @remainingTime = 0
    @timeInterval = null

  showScore: ->
    document.getElementById('score').innerText = @score.toString()

  setBestScore: () ->
    localStorage.setItem 'best_score', @score

  togglePause: ->
    @paused = not @paused
    if @paused
      @stop()
      board.drawPaused()
      document.getElementById('pause').innerText = 'Continue'
    else
      @start()
      board.draw()
      document.getElementById('pause').innerText = 'Pause'

  incrementScore: (n) ->
    @score += n
    @showScore()

  decrementScore: (n) ->
    @score -= n
    @showScore()

  start: (time) ->
    @remainingTime = time
    @showTime()
    @interval = setInterval (() ->
      board.draw()),
      FRAME_RATE
    @timeInterval = setInterval (() ->
      game.updateTime()),
      1000

  finish: () ->
    @stop()
    if @score > bestScore()
      @setBestScore()
      showBestScore()

  stop: () ->
    clearInterval @interval
    clearInterval @timeInterval

  updateTime: () ->
    @remainingTime--
    @showTime()

    if @remainingTime is 0
      board.drawFinish()
      game.finish()

  showTime: () ->
    document.getElementById('time').innerText = @remainingTime
