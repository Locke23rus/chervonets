N = 4
CANVAS_WIDTH = 500
WIDTH = Math.floor(CANVAS_WIDTH / N)
canvas = document.getElementById('game-canvas')
ctx = canvas.getContext('2d')
game = null
board = null

canvas.addEventListener 'click', ((e) ->
  board.click(e.offsetX, e.offsetY)
), false


bestScore = ->
  parseInt localStorage.getItem('best_score') or 0,
           10

showBestScore = ->
  document.getElementById('best-score').innerText = bestScore()

checkFinish = ->
  return  if board.hasBlocks()
  board.drawFinish()
  if game.score > bestScore()
    game.setBestScore()
    showBestScore()

newGame = ->
  game = new Game()
  board = new Board()

  board.fill()
  board.draw()

togglePause = ->
  game.togglePause()

init = ->
  showBestScore()
  newGame()


init()
