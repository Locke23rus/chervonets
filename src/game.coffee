class Game

  constructor: () ->
    @score = 0
    @paused = false
    @showScore()
    @interval = null
    @remainingTime = TIME
    @timeInterval = null
    @waveTime = WAVE_TIME * 1000
    @waveInterval = null

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

  start: () ->
    @showTime()
    @interval = setInterval (() ->
      board.draw()),
      FRAME_RATE
    @timeInterval = setInterval (() ->
      game.updateTime()),
      1000
    @waveInterval = setInterval (() ->
      game.updateWave()),
      WAVE_RATE

  finish: () ->
    @stop()
    if @score > bestScore()
      @setBestScore()
      showBestScore()

  stop: () ->
    clearInterval @interval
    clearInterval @timeInterval
    clearInterval @waveInterval

  updateTime: () ->
    @remainingTime--
    @showTime()

    if @remainingTime is 0
      board.drawFinish()
      game.finish()

  updateWave: () ->
    @waveTime -= WAVE_RATE
    @showWave()

    if @waveTime is 0
      if board.emptyCells().length isnt 0
        board.addRandomCell()
      @waveTime = WAVE_TIME * 1000

  showTime: () ->
    document.getElementById('time').innerText = @remainingTime

  showWave: () ->
    document.getElementById('wave').style.width = (@waveTime / WAVE_RATE) + 'px'
