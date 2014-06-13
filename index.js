// Generated by CoffeeScript 1.7.1
var Board, CANVAS_WIDTH, Cell, FRAME_RATE, Game, MOVE_TIME, N, TIME, WAVE_RATE, WAVE_TIME, WIDTH, bestScore, board, canvas, ctx, game, init, newGame, showBestScore, togglePause;

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
    this.events = [];
    this.fill();
  }

  Board.prototype.fill = function() {
    var i, j, _i, _results;
    _results = [];
    for (j = _i = 0; 0 <= N ? _i < N : _i > N; j = 0 <= N ? ++_i : --_i) {
      this.cells[j] = [];
      _results.push((function() {
        var _j, _results1;
        _results1 = [];
        for (i = _j = 0; 0 <= N ? _j < N : _j > N; i = 0 <= N ? ++_j : --_j) {
          _results1.push(this.cells[j][i] = new Cell(i, j, Number.randomInt(1, 10)));
        }
        return _results1;
      }).call(this));
    }
    return _results;
  };

  Board.prototype.draw = function() {
    var cell, e, event, i, j, _i, _j, _k, _len, _ref, _ref1;
    this.clear();
    this.events = (function() {
      var _i, _len, _ref, _results;
      _ref = this.events;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        e = _ref[_i];
        if (e.time > 0) {
          _results.push(e);
        }
      }
      return _results;
    }).call(this);
    _ref = this.events;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      event = _ref[_i];
      event.draw();
    }
    if (!this.hasBlocks()) {
      board.drawFinish();
      game.finish();
      return;
    }
    for (j = _j = 0; 0 <= N ? _j < N : _j > N; j = 0 <= N ? ++_j : --_j) {
      for (i = _k = 0; 0 <= N ? _k < N : _k > N; i = 0 <= N ? ++_k : --_k) {
        cell = this.cells[j][i];
        if ((cell.n != null) && !this.isSelected(cell)) {
          cell.draw();
        }
      }
    }
    return (_ref1 = this.selectedCell) != null ? _ref1.drawSelect() : void 0;
  };

  Board.prototype.emptyCells = function() {
    var a, i, j, _i, _j;
    a = [];
    for (j = _i = 0; 0 <= N ? _i < N : _i > N; j = 0 <= N ? ++_i : --_i) {
      for (i = _j = 0; 0 <= N ? _j < N : _j > N; i = 0 <= N ? ++_j : --_j) {
        if (this.cells[j][i].n == null) {
          a.push(this.cells[j][i]);
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
        if (this.cells[j][i].n != null) {
          a.push(this.cells[j][i].n);
        }
      }
    }
    return a.unique();
  };

  Board.prototype.addRandomCell = function() {
    return this.emptyCells().randomElement().n = this.availableNumbers().randomElement();
  };

  Board.prototype.hasBlocks = function() {
    var i, j, _i, _j;
    for (j = _i = 0; 0 <= N ? _i < N : _i > N; j = 0 <= N ? ++_i : --_i) {
      for (i = _j = 0; 0 <= N ? _j < N : _j > N; i = 0 <= N ? ++_j : --_j) {
        if (this.cells[j][i].n != null) {
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
    this.clickedCell = this.cells[j][i];
    if (this.clickedCell.isEmpty() && (this.selectedCell == null)) {
      return;
    }
    if (this.selectedCell != null) {
      if (this.isSelf()) {
        this.selectedCell = null;
        return;
      } else if (this.isSameCol() || this.isSameRow()) {
        if (this.canHit()) {
          this.events.push(new HitEvent(this.selectedCell, this.targetCell, this.hitDistance()));
          game.incrementScore(this.scoreFactor(this.hitDistance()));
          return;
        } else if (this.canMove()) {
          this.events.push(new MoveEvent(this.selectedCell, this.targetCell, this.moveDistance()));
          game.decrementScore(this.scoreFactor(this.moveDistance()));
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

  Board.prototype.canHitColl = function(range) {
    var cell, j, _i, _len;
    for (_i = 0, _len = range.length; _i < _len; _i++) {
      j = range[_i];
      cell = this.cells[j][this.selectedCell.i];
      if (cell.n != null) {
        if (this.selectedCell.n === cell.n) {
          this.targetCell = cell;
          return true;
        } else {
          return false;
        }
      }
    }
    return false;
  };

  Board.prototype.canHitRow = function(range) {
    var cell, i, _i, _len;
    for (_i = 0, _len = range.length; _i < _len; _i++) {
      i = range[_i];
      cell = this.cells[this.selectedCell.j][i];
      if (cell.n != null) {
        if (this.selectedCell.n === cell.n) {
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
          for (var _l = _ref3 = this.selectedCell.i + 1; _ref3 <= N ? _l < N : _l > N; _ref3 <= N ? _l++ : _l--){ _results3.push(_l); }
          return _results3;
        }).apply(this));
    }
    return false;
  };

  Board.prototype.canMoveColl = function(range) {
    var cell, j, _i, _len;
    for (_i = 0, _len = range.length; _i < _len; _i++) {
      j = range[_i];
      cell = this.cells[j][this.selectedCell.i];
      if (cell.n != null) {
        return this.targetCell != null;
      } else {
        this.targetCell = cell;
      }
    }
    return this.targetCell != null;
  };

  Board.prototype.canMoveRow = function(range) {
    var cell, i, _i, _len;
    for (_i = 0, _len = range.length; _i < _len; _i++) {
      i = range[_i];
      cell = this.cells[this.selectedCell.j][i];
      if (cell.n != null) {
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
  function Cell(i, j, n) {
    this.i = i;
    this.j = j;
    this.n = n;
    this.x = this.i * WIDTH;
    this.y = this.j * WIDTH;
  }

  Cell.prototype.color = function() {
    switch (this.n) {
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
    if (this.n === 10) {
      return ctx.fillText(this.n, this.x + 8, this.y + 25);
    } else {
      return ctx.fillText(this.n, this.x + 15, this.y + 25);
    }
  };

  Cell.prototype.isEmpty = function() {
    return this.n == null;
  };

  Cell.prototype.drawSelect = function() {
    this.drawBackground("#000066");
    return this.drawNumber("#FFF");
  };

  Cell.prototype.clear = function() {
    return ctx.clearRect(this.x, this.y, WIDTH, WIDTH);
  };

  Cell.prototype.reset = function() {
    this.n = null;
    this.x = this.i * WIDTH;
    return this.y = this.j * WIDTH;
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
    this.frameCounter = 0;
    this.fps = 16;
    this.time = performance.now() || new Date().getTime();
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
      return this.pause();
    } else {
      this.start();
      return board.draw();
    }
  };

  Game.prototype.pause = function() {
    if (!this.finished) {
      this.stop();
      return board.drawPaused();
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
      var currentTime, elapsedTimeMS;
      game.frameCounter++;
      currentTime = performance.now() || new Date().getTime();
      elapsedTimeMS = currentTime - game.time;
      if (elapsedTimeMS >= 1000) {
        game.fps = game.frameCounter;
        game.frameCounter = 0;
        game.time = currentTime;
        console.log(game.fps);
      }
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

this.HitEvent = (function() {
  function HitEvent(from, to, distance) {
    this.from = from;
    this.to = to;
    this.distance = distance;
    this.time = this.distance * MOVE_TIME;
    this.deltaX = (this.to.x - this.from.x) / this.distance / MOVE_TIME;
    this.deltaY = (this.to.y - this.from.y) / this.distance / MOVE_TIME;
  }

  HitEvent.prototype.draw = function() {
    var tickTime;
    tickTime = 1000 / game.fps;
    console.log(tickTime);
    this.from.x += tickTime * this.deltaX;
    this.from.y += tickTime * this.deltaY;
    this.time -= tickTime;
    if (this.time <= 0) {
      this.from.reset();
      this.to.reset();
      board.selectedCell = null;
      return board.targetCell = null;
    }
  };

  return HitEvent;

})();

this.MoveEvent = (function() {
  function MoveEvent(from, to, distance) {
    this.from = from;
    this.to = to;
    this.distance = distance;
    this.time = this.distance * MOVE_TIME;
    this.deltaX = (this.to.x - this.from.x) / this.distance / MOVE_TIME;
    this.deltaY = (this.to.y - this.from.y) / this.distance / MOVE_TIME;
  }

  MoveEvent.prototype.draw = function() {
    var tickTime;
    tickTime = 1000 / game.fps;
    console.log(tickTime);
    this.from.x += tickTime * this.deltaX;
    this.from.y += tickTime * this.deltaY;
    this.time -= tickTime;
    if (this.time <= 0) {
      this.to.n = this.from.n;
      this.from.reset();
      board.selectedCell = null;
      return board.targetCell = null;
    }
  };

  return MoveEvent;

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

FRAME_RATE = 1000 / 60;

TIME = 300;

WAVE_TIME = 10;

WAVE_RATE = WAVE_TIME * 10;

canvas = document.getElementById('game-canvas');

ctx = canvas.getContext('2d');

game = null;

board = null;

MOVE_TIME = 100;

canvas.addEventListener('click', (function(e) {
  var x, y;
  if ((game != null) && !game.finished) {
    x = e.offsetX != null ? e.offsetX : e.clientX - e.target.offsetLeft;
    y = e.offsetY != null ? e.offsetY : e.clientY - e.target.offsetTop;
    return board.click(x, y);
  }
}), false);

addEventListener('keyup', function(e) {
  if (e.keyCode === 32) {
    return togglePause();
  }
});

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

Visibility.change(function(e, state) {
  if (state === 'hidden' && (game != null)) {
    return game.pause();
  }
});

//# sourceMappingURL=index.map
