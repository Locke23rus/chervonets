class Game

  constructor: () ->
    @score = 0
    @paused = false
    @showScore()
    @interval = null

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
      @start(0)
      board.draw()
      document.getElementById('pause').innerText = 'Pause'

  incrementScore: (n) ->
    @score += n
    @showScore()

  decrementScore: (n) ->
    @score -= n
    @showScore()

  start: () ->
    @interval = setInterval (() ->
      board.draw()),
      FRAME_RATE

  finish: () ->
    @stop()
    if @score > bestScore()
      @setBestScore()
      showBestScore()

  stop: () ->
    clearInterval @interval


