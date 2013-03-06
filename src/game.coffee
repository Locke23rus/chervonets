class Game

  constructor: () ->
    @score = 0
    @paused = false
    @showScore()

  showScore: ->
    document.getElementById('score').innerText = @score.toString()

  setBestScore: () ->
    localStorage.setItem 'best_score', @score

  togglePause: ->
    @paused = not @paused
    if @paused
      board.drawPaused()
      document.getElementById('pause').innerText = 'Continue'
    else
      board.draw()
      document.getElementById('pause').innerText = 'Pause'

  incrementScore: (n) ->
    @score += n
    @showScore()
