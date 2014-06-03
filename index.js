// Generated by CoffeeScript 1.7.1
var Board, CANVAS_WIDTH, Cell, FRAME_RATE, Game, N, TIME, WAVE_RATE, WAVE_TIME, WIDTH, bestScore, board, canvas, ctx, game, init, newGame, showBestScore, togglePause;

Array.prototype.unique = function() {
  return this.filter(function(value, index, self) {
    return self.indexOf(value) === index;
  });
};

Array.prototype.randomElement = function() {
  return this[Math.floor(Math.random() * this.length)];
};

Board = (function() {
  var DOWN, LEFT, RIGHT, UP;

  UP = 0;

  RIGHT = 1;

  DOWN = 2;

  LEFT = 3;

  function Board() {
    this.cells = [];
    this.selectedCell = null;
    this.clickedCell = null;
    this.targetCell = null;
    this.fill();
  }

  Board.prototype.fill = function() {
    var i, j, _i, _results;
    _results = [];
    for (j = _i = 0; 0 <= N ? _i < N : _i > N; j = 0 <= N ? ++_i : --_i) {
      this.cells.push([]);
      _results.push((function() {
        var _j, _results1;
        _results1 = [];
        for (i = _j = 0; 0 <= N ? _j < N : _j > N; i = 0 <= N ? ++_j : --_j) {
          _results1.push(this.cells[j][i] = Number.randomInt(1, 10));
        }
        return _results1;
      }).call(this));
    }
    return _results;
  };

  Board.prototype.draw = function() {
    var cell, i, j, _i, _results;
    this.clear();
    _results = [];
    for (j = _i = 0; 0 <= N ? _i < N : _i > N; j = 0 <= N ? ++_i : --_i) {
      _results.push((function() {
        var _j, _results1;
        _results1 = [];
        for (i = _j = 0; 0 <= N ? _j < N : _j > N; i = 0 <= N ? ++_j : --_j) {
          cell = new Cell(i, j);
          if (cell.n() != null) {
            if (this.isSelected(cell)) {
              _results1.push(cell.drawSelect());
            } else {
              _results1.push(cell.draw());
            }
          } else {
            _results1.push(void 0);
          }
        }
        return _results1;
      }).call(this));
    }
    return _results;
  };

  Board.prototype.emptyCells = function() {
    var a, i, j, _i, _j;
    a = [];
    for (j = _i = 0; 0 <= N ? _i < N : _i > N; j = 0 <= N ? ++_i : --_i) {
      for (i = _j = 0; 0 <= N ? _j < N : _j > N; i = 0 <= N ? ++_j : --_j) {
        if (this.cells[j][i] == null) {
          a.push(new Cell(i, j));
        }
      }
    }
    return a;
  };

  Board.prototype.availableNumbers = function() {
    var a, i, j, _i, _j;
    a = [];
    for (j = _i = 0; 0 <= N ? _i < N : _i > N; j = 0 <= N ? ++_i : --_i) {
      for (i = _j = 0; 0 <= N ? _j < N : _j > N; i = 0 <= N ? ++_j : --_j) {
        if (this.cells[j][i]) {
          a.push(this.cells[j][i]);
        }
      }
    }
    return a.unique();
  };

  Board.prototype.insert = function(cell, n) {
    return this.cells[cell.j][cell.i] = n;
  };

  Board.prototype.remove = function(cell) {
    return this.cells[cell.j][cell.i] = null;
  };

  Board.prototype.addRandomCell = function() {
    return this.insert(this.emptyCells().randomElement(), this.availableNumbers().randomElement());
  };

  Board.prototype.hasBlocks = function() {
    var i, j, _i, _j;
    for (j = _i = 0; 0 <= N ? _i < N : _i > N; j = 0 <= N ? ++_i : --_i) {
      for (i = _j = 0; 0 <= N ? _j < N : _j > N; i = 0 <= N ? ++_j : --_j) {
        if (this.cells[j][i] != null) {
          return true;
        }
      }
    }
    return false;
  };

  Board.prototype.clear = function() {
    return ctx.clearRect(0, 0, CANVAS_WIDTH, CANVAS_WIDTH);
  };

  Board.prototype.drawFinish = function() {
    return this.drawText('Finish!');
  };

  Board.prototype.drawPaused = function() {
    return this.drawText('Paused');
  };

  Board.prototype.drawText = function(text) {
    this.clear();
    ctx.fillStyle = '#000';
    ctx.font = '50px Slackey';
    ctx.textBaseline = 'middle';
    return ctx.fillText(text, CANVAS_WIDTH / 2 - 85, CANVAS_WIDTH / 2);
  };

  Board.prototype.click = function(x, y) {
    var i, j;
    i = Math.floor(x / WIDTH);
    j = Math.floor(y / WIDTH);
    this.clickedCell = new Cell(i, j);
    if (this.clickedCell.isEmpty() && (this.selectedCell == null)) {
      return;
    }
    if (this.selectedCell != null) {
      if (this.isSelf()) {
        this.selectedCell = null;
        return;
      } else if (this.isSameCol() || this.isSameRow()) {
        if (this.canHit()) {
          game.incrementScore(this.scoreFactor(this.hitDistance()));
          this.remove(this.selectedCell);
          this.remove(this.targetCell);
          this.selectedCell = null;
          this.targetCell = null;
          if (!this.hasBlocks()) {
            board.drawFinish();
            game.finish();
          }
          return;
        } else if (this.canMove()) {
          game.decrementScore(this.scoreFactor(this.moveDistance()));
          this.insert(this.targetCell, this.selectedCell.n());
          this.remove(this.selectedCell);
          this.selectedCell = null;
          this.targetCell = null;
          return;
        }
      }
    }
    return this.selectedCell = this.clickedCell;
  };

  Board.prototype.direction = function() {
    if (this.isSameRow()) {
      if (this.selectedCell.i > this.clickedCell.i) {
        return LEFT;
      } else {
        return RIGHT;
      }
    } else {
      if (this.selectedCell.j > this.clickedCell.j) {
        return UP;
      } else {
        return DOWN;
      }
    }
  };

  Board.prototype.canHitColl = function(colls) {
    var cell, j, _i, _len;
    for (_i = 0, _len = colls.length; _i < _len; _i++) {
      j = colls[_i];
      cell = new Cell(this.selectedCell.i, j);
      if (cell.n() != null) {
        if (this.selectedCell.n() === cell.n()) {
          this.targetCell = cell;
          return true;
        } else {
          return false;
        }
      }
    }
    return false;
  };

  Board.prototype.canHitRow = function(rows) {
    var cell, i, _i, _len;
    for (_i = 0, _len = rows.length; _i < _len; _i++) {
      i = rows[_i];
      cell = new Cell(i, this.selectedCell.j);
      if (cell.n() != null) {
        if (this.selectedCell.n() === cell.n()) {
          this.targetCell = cell;
          return true;
        } else {
          return false;
        }
      }
    }
    return false;
  };

  Board.prototype.canHit = function() {
    var _i, _j, _k, _l, _ref, _ref1, _ref2, _ref3, _results, _results1, _results2, _results3;
    switch (this.direction()) {
      case UP:
        return this.canHitColl((function() {
          _results = [];
          for (var _i = _ref = this.selectedCell.j - 1; _ref <= 0 ? _i <= 0 : _i >= 0; _ref <= 0 ? _i++ : _i--){ _results.push(_i); }
          return _results;
        }).apply(this));
      case DOWN:
        return this.canHitColl((function() {
          _results1 = [];
          for (var _j = _ref1 = this.selectedCell.j + 1; _ref1 <= N ? _j < N : _j > N; _ref1 <= N ? _j++ : _j--){ _results1.push(_j); }
          return _results1;
        }).apply(this));
      case LEFT:
        return this.canHitRow((function() {
          _results2 = [];
          for (var _k = _ref2 = this.selectedCell.i - 1; _ref2 <= 0 ? _k <= 0 : _k >= 0; _ref2 <= 0 ? _k++ : _k--){ _results2.push(_k); }
          return _results2;
        }).apply(this));
      case RIGHT:
        return this.canHitRow((function() {
          _results3 = [];
          for (var _l = _ref3 = this.selectedCell.i + 1; _ref3 <= N ? _l <= N : _l >= N; _ref3 <= N ? _l++ : _l--){ _results3.push(_l); }
          return _results3;
        }).apply(this));
    }
    return false;
  };

  Board.prototype.canMoveColl = function(colls) {
    var cell, j, _i, _len;
    for (_i = 0, _len = colls.length; _i < _len; _i++) {
      j = colls[_i];
      cell = new Cell(this.selectedCell.i, j);
      if (cell.n() != null) {
        return this.targetCell != null;
      } else {
        this.targetCell = cell;
      }
    }
    return this.targetCell != null;
  };

  Board.prototype.canMoveRow = function(rows) {
    var cell, i, _i, _len;
    for (_i = 0, _len = rows.length; _i < _len; _i++) {
      i = rows[_i];
      cell = new Cell(i, this.selectedCell.j);
      if (cell.n() != null) {
        return this.targetCell != null;
      } else {
        this.targetCell = cell;
      }
    }
    return this.targetCell != null;
  };

  Board.prototype.canMove = function() {
    var _i, _j, _k, _l, _ref, _ref1, _ref2, _ref3, _results, _results1, _results2, _results3;
    switch (this.direction()) {
      case UP:
        return this.canMoveColl((function() {
          _results = [];
          for (var _i = _ref = this.selectedCell.j - 1; _ref <= 0 ? _i <= 0 : _i >= 0; _ref <= 0 ? _i++ : _i--){ _results.push(_i); }
          return _results;
        }).apply(this));
      case DOWN:
        return this.canMoveColl((function() {
          _results1 = [];
          for (var _j = _ref1 = this.selectedCell.j + 1; _ref1 <= N ? _j < N : _j > N; _ref1 <= N ? _j++ : _j--){ _results1.push(_j); }
          return _results1;
        }).apply(this));
      case LEFT:
        return this.canMoveRow((function() {
          _results2 = [];
          for (var _k = _ref2 = this.selectedCell.i - 1; _ref2 <= 0 ? _k <= 0 : _k >= 0; _ref2 <= 0 ? _k++ : _k--){ _results2.push(_k); }
          return _results2;
        }).apply(this));
      case RIGHT:
        return this.canMoveRow((function() {
          _results3 = [];
          for (var _l = _ref3 = this.selectedCell.i + 1; _ref3 <= N ? _l < N : _l > N; _ref3 <= N ? _l++ : _l--){ _results3.push(_l); }
          return _results3;
        }).apply(this));
    }
    return false;
  };

  Board.prototype.hitDistance = function() {
    if (this.isSameRow()) {
      return Math.abs(this.targetCell.i - this.selectedCell.i) + 1;
    } else {
      return Math.abs(this.targetCell.j - this.selectedCell.j) + 1;
    }
  };

  Board.prototype.moveDistance = function() {
    if (this.isSameRow()) {
      return Math.abs(this.targetCell.i - this.selectedCell.i);
    } else {
      return Math.abs(this.targetCell.j - this.selectedCell.j);
    }
  };

  Board.prototype.scoreFactor = function(n) {
    var i, sum, _i;
    sum = 0;
    for (i = _i = 0; 0 <= n ? _i <= n : _i >= n; i = 0 <= n ? ++_i : --_i) {
      sum += i;
    }
    return sum;
  };

  Board.prototype.isSelf = function() {
    return this.selectedCell.i === this.clickedCell.i && this.selectedCell.j === this.clickedCell.j;
  };

  Board.prototype.isSameRow = function() {
    return this.selectedCell.j === this.clickedCell.j;
  };

  Board.prototype.isSameCol = function() {
    return this.selectedCell.i === this.clickedCell.i;
  };

  Board.prototype.isSelected = function(cell) {
    return (this.selectedCell != null) && this.selectedCell.i === cell.i && this.selectedCell.j === cell.j;
  };

  return Board;

})();

Cell = (function() {
  function Cell(i, j) {
    this.i = i;
    this.j = j;
    this.x = this.i * WIDTH;
    this.y = this.j * WIDTH;
  }

  Cell.prototype.color = function() {
    switch (this.n()) {
      case 1:
        return "#FF6633";
      case 2:
        return "#66CCFF";
      case 3:
        return "#FF66FF";
      case 4:
        return "#CC99FF";
      case 5:
        return "#CCCCFF";
      case 6:
        return "#6699FF";
      case 7:
        return "#FFFF66";
      case 8:
        return "#66CC66";
      case 9:
        return "#CCFF66";
      case 10:
        return "#FF3333";
      default:
        return "#FFF";
    }
  };

  Cell.prototype.draw = function() {
    this.drawBackground(this.color());
    return this.drawNumber("#000");
  };

  Cell.prototype.drawBackground = function(color) {
    ctx.fillStyle = color;
    ctx.fillRect(this.x, this.y, WIDTH, WIDTH);
    ctx.strokeStyle = "#FFF";
    return ctx.strokeRect(this.x, this.y, WIDTH, WIDTH);
  };

  Cell.prototype.drawNumber = function(color) {
    ctx.fillStyle = color;
    ctx.font = "30px monospaced";
    ctx.textBaseline = "middle";
    if (this.n() === 10) {
      return ctx.fillText(this.n(), this.x + 8, this.y + 25);
    } else {
      return ctx.fillText(this.n(), this.x + 15, this.y + 25);
    }
  };

  Cell.prototype.isEmpty = function() {
    return this.n() == null;
  };

  Cell.prototype.drawSelect = function() {
    this.drawBackground("#000066");
    return this.drawNumber("#FFF");
  };

  Cell.prototype.clear = function() {
    return ctx.clearRect(this.x, this.y, WIDTH, WIDTH);
  };

  Cell.prototype.n = function() {
    return board.cells[this.j][this.i];
  };

  return Cell;

})();

Game = (function() {
  function Game() {
    this.score = 0;
    this.paused = false;
    this.finished = false;
    this.showScore();
    this.interval = null;
    this.remainingTime = TIME;
    this.timeInterval = null;
    this.waveTime = WAVE_TIME * 1000;
    this.waveInterval = null;
  }

  Game.prototype.showScore = function() {
    return document.getElementById('score').innerText = this.score.toString();
  };

  Game.prototype.setBestScore = function() {
    return localStorage.setItem('best_score', this.score);
  };

  Game.prototype.togglePause = function() {
    this.paused = !this.paused;
    if (this.paused) {
      this.stop();
      return board.drawPaused();
    } else {
      this.start();
      return board.draw();
    }
  };

  Game.prototype.incrementScore = function(n) {
    this.score += n;
    return this.showScore();
  };

  Game.prototype.decrementScore = function(n) {
    this.score -= n;
    return this.showScore();
  };

  Game.prototype.start = function() {
    document.getElementById('pause').innerText = 'Pause';
    this.showTime();
    this.interval = setInterval((function() {
      return board.draw();
    }), FRAME_RATE);
    this.timeInterval = setInterval((function() {
      return game.updateTime();
    }), 1000);
    return this.waveInterval = setInterval((function() {
      return game.updateWave();
    }), WAVE_RATE);
  };

  Game.prototype.finish = function() {
    this.stop();
    this.finished = true;
    if (this.score > bestScore()) {
      this.setBestScore();
      return showBestScore();
    }
  };

  Game.prototype.stop = function() {
    document.getElementById('pause').innerText = 'Continue';
    clearInterval(this.interval);
    clearInterval(this.timeInterval);
    return clearInterval(this.waveInterval);
  };

  Game.prototype.updateTime = function() {
    this.remainingTime--;
    this.showTime();
    if (this.remainingTime === 0) {
      board.drawFinish();
      return game.finish();
    }
  };

  Game.prototype.updateWave = function() {
    this.waveTime -= WAVE_RATE;
    this.showWave();
    if (this.waveTime === 0) {
      if (board.emptyCells().length !== 0) {
        board.addRandomCell();
      }
      return this.waveTime = WAVE_TIME * 1000;
    }
  };

  Game.prototype.showTime = function() {
    return document.getElementById('time').innerText = this.remainingTime;
  };

  Game.prototype.showWave = function() {
    return document.getElementById('wave').style.width = (this.waveTime / WAVE_RATE) + 'px';
  };

  return Game;

})();

Number.randomInt = function(a, z) {
  var x;
  x = a - 1;
  while (x < a || x > z) {
    x = Math.floor(Math.random() * 10) + 1;
  }
  return x;
};

N = 10;

CANVAS_WIDTH = 500;

WIDTH = Math.floor(CANVAS_WIDTH / N);

FRAME_RATE = 1000 / 30;

TIME = 250;

WAVE_TIME = 10;

WAVE_RATE = WAVE_TIME * 10;

canvas = document.getElementById('game-canvas');

ctx = canvas.getContext('2d');

game = null;

board = null;

canvas.addEventListener('click', (function(e) {
  if ((game != null) && !game.finished) {
    return board.click(e.offsetX, e.offsetY);
  }
}), false);

bestScore = function() {
  return parseInt(localStorage.getItem('best_score') || 0, 10);
};

showBestScore = function() {
  return document.getElementById('best-score').innerText = bestScore();
};

newGame = function() {
  if (game != null) {
    game.stop();
  }
  game = new Game();
  board = new Board();
  return game.start();
};

togglePause = function() {
  if ((game != null) && !game.finished) {
    return game.togglePause();
  }
};

init = function() {
  return showBestScore();
};

init();

//# sourceMappingURL=index.map
