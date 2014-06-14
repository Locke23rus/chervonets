N = 10
CANVAS_WIDTH = 500
WIDTH = CANVAS_WIDTH // N
FRAME_RATE = 1000 / 60
TIME = 300
WAVE_TIME = 10
WAVE_RATE = WAVE_TIME * 10
canvas = document.getElementById('game-canvas')
ctx = canvas.getContext('2d')
fakeCanvas = document.createElement('canvas');
fakeCanvas.width = 500;
fakeCanvas.height = 500;
fakeCtx = fakeCanvas.getContext('2d');

game = null
board = null
MOVE_TIME = 100

canvas.addEventListener 'click', ((e) ->
  if game? and not game.finished
    x = if e.offsetX? then e.offsetX else e.clientX - e.target.offsetLeft
    y = if e.offsetY? then e.offsetY else e.clientY - e.target.offsetTop
    board.click x, y
), false

addEventListener 'keyup', (e) ->
  togglePause() if e.keyCode is 32

bestScore = ->
  parseInt localStorage.getItem('best_score') or 0,
           10

showBestScore = ->
  document.getElementById('best-score').innerHTML = bestScore()

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
