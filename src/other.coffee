isSelf = (a, b) ->
  a.i is b.i and a.j is b.j

isSameNumber = (a, b) ->
  board.cells[a.j][a.i] is board.cells[b.j][b.i]

isMaxInSum = (a, b) ->
  (board.cells[a.j][a.i] + board.cells[b.j][b.i]) is N

isSameRow = (a, b) ->
  a.j is b.j

isSameCol = (a, b) ->
  a.i is b.i

isAvailableToMove = (a, b) ->
  min = undefined
  max = undefined
  if isSelf(a, b)
    return false
  else if isSameRow(a, b)
    min = Math.min(a.i, b.i)
    max = Math.max(a.i, b.i)
    if (min + 1) is max

      #            console.log('isVisible - near');
      return true
    else
      i = min + 1

      while i < max

        #                    console.log('isAvailableToMove - FALSE');
        return false  if board.cells[a.j][i]?
        i++

      #            console.log('isAvailableToMove - TRUE');
      return true
  else if isSameCol(a, b)
    min = Math.min(a.j, b.j)
    max = Math.max(a.j, b.j)
    if (min + 1) is max

      #            console.log('isAvailableToMove - near');
      return true
    else
      j = min + 1

      while j < max

        #                    console.log('isVisible - FALSE');
        return false  if board.cells[j][a.i]?
        j++

      #            console.log('isAvailableToMove - TRUE');
      return true
  false

moveCellTarget = (a, b) ->
  t = undefined
  i = undefined
  j = undefined
  if isSameRow(a, b)
    if b.i > a.i
      i = b.i
      while i < N
        unless board.cells[a.j][i]?
          t = i
        else
          break
        i++
    else
      i = b.i
      while i >= 0
        unless board.cells[a.j][i]?
          t = i
        else
          break
        i--
    new Cell(t, a.j)
  else
    if b.j > a.j
      j = b.j
      while j < N
        unless board.cells[j][a.i]?
          t = j
        else
          break
        j++
    else
      j = b.j
      while j >= 0
        unless board.cells[j][a.i]?
          t = j
        else
          break
        j--
    new Cell(a.i, t)



N = 4
CANVAS_WIDTH = 500
WIDTH = Math.floor(CANVAS_WIDTH / N)
canvas = document.getElementById("game-canvas")
ctx = canvas.getContext("2d")
currentCell = null

canvas.addEventListener "click", ((e) ->
  cell = new Cell(Math.floor(e.offsetX / WIDTH), Math.floor(e.offsetY / WIDTH))
  return  if cell.isEmpty() and not currentCell?
  unless currentCell?
    currentCell = cell
    cell.select()
  else
    if isSameRow(currentCell, cell) or isSameCol(currentCell, cell)
      if isAvailableToMove(currentCell, cell)
        if isSameNumber(currentCell, cell) or isMaxInSum(currentCell, cell)
          game.incrementScore 1
          board.remove currentCell
          board.remove cell
          currentCell = null
          checkFinish()
          return
        else if cell.isEmpty()
          board.insert moveCellTarget(currentCell, cell), currentCell.n()
          board.remove currentCell
          currentCell = null
          return
    currentCell.draw()

    # TODO: Play wrong sound
    currentCell = null
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
  @game = new Game()
  @board = new Board()

  board.fill()
  board.draw()

togglePause = ->
  game.togglePause()

init = ->
  showBestScore()
  newGame()


init()
