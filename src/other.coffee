N = 4
CANVAS_WIDTH = 500
WIDTH = Math.floor(CANVAS_WIDTH / N)
FRAME_RATE = 1000 / 30
TIME = 60
canvas = document.getElementById('game-canvas')
ctx = canvas.getContext('2d')
game = new Game()
board = null

canvas.addEventListener 'click', ((e) ->
  board.click(e.offsetX, e.offsetY)
), false


bestScore = ->
  parseInt localStorage.getItem('best_score') or 0,
           10

showBestScore = ->
  document.getElementById('best-score').innerText = bestScore()

newGame = ->
  game.stop()
  game = new Game()
  board = new Board()
  game.start(TIME)

togglePause = ->
  game.togglePause()

init = ->
  showBestScore()

init()
