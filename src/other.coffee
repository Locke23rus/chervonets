N = 10
CANVAS_WIDTH = 500
WIDTH = CANVAS_WIDTH // N
FRAME_RATE = 1000 / 30
TIME = 250
WAVE_TIME = 10
WAVE_RATE = WAVE_TIME * 10
canvas = document.getElementById('game-canvas')
ctx = canvas.getContext('2d')
game = null
board = null

canvas.addEventListener 'click', ((e) ->
  board.click(e.offsetX, e.offsetY) if game? and not game.finished
), false

addEventListener 'keyup', (e) ->
  togglePause() if e.keyCode is 32

bestScore = ->
  parseInt localStorage.getItem('best_score') or 0,
           10

showBestScore = ->
  document.getElementById('best-score').innerText = bestScore()

newGame = ->
  game.stop() if game?
  game = new Game()
  board = new Board()
  game.start()

togglePause = ->
  game.togglePause() if game? and not game.finished

init = ->
  showBestScore()

init()


Visibility.change (e, state) ->
  game.pause() if state is 'hidden' and game?
