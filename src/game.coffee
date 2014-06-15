class Game

  constructor: () ->
    @score = 0
    @paused = false
    @finished = false
    @showScore()
    @interval = null
    @remainingTime = TIME
    @timeInterval = null
    @waveTime = WAVE_TIME * 1000
    @waveInterval = null
    @frameCounter = 0
    @fps = 16
    @time = performance.now() || new Date().getTime()

  showScore: ->
    document.getElementById('score').innerHTML = @score.toString()

  setBestScore: () ->
    localStorage.setItem 'best_score', @score

  togglePause: ->
    @paused = not @paused
    if @paused
      @pause()
    else
      @start()
      board.draw()

  pause: ->
    unless @finished
      @stop()
      board.drawPaused()

  incrementScore: (n) ->
    @score += n
    @showScore()

  decrementScore: (n) ->
    @score -= n
    @showScore()

  start: () ->
    document.getElementById('pause').innerHTML = 'Pause'
    @showTime()
    @interval = setInterval (() ->
      game.frameCounter++
      currentTime = performance.now() || new Date().getTime()
      elapsedTimeMS = currentTime - game.time;
      if elapsedTimeMS >= 1000
        game.fps = game.frameCounter
        game.frameCounter = 0
        game.time = currentTime
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
    @finished = true
    @addRemainingTimeToScore()
    if @score > bestScore()
      @setBestScore()
      showBestScore()

  stop: () ->
    document.getElementById('pause').innerHTML = 'Continue'
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
    document.getElementById('time').innerHTML = @remainingTime

  showWave: () ->
    document.getElementById('wave').style.width = (@waveTime / WAVE_RATE) + 'px'

  addRemainingTimeToScore: ->
    setTimeout (->
      if game.remainingTime > 0
        game.incrementScore(1)
        game.remainingTime--
        game.showTime()
        game.addRemainingTimeToScore()
      ), 10
