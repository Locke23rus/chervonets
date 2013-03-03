function Cell(i, j) {
    this.i = i;
    this.j = j;
}

Cell.prototype.color = function() {
    switch (this.n()) {
        case 1: return '#FF6633';
        case 2: return '#FF3333';
        case 3: return '#FF66FF';
        case 4: return '#CC99FF';
        case 5: return '#CCCCFF';
        case 6: return '#6699FF';
        case 7: return '#FFFF66';
        case 8: return '#66CC66';
        case 9: return '#CCFF66';
        default: return '#FFF';
    }
};

Cell.prototype.draw = function() {
    this.drawBackground(this.color());
    this.drawNumber('#000');
};

Cell.prototype.drawBackground = function(color) {
    ctx.fillStyle = color;
    ctx.fillRect(this.x(), this.y(), WIDTH, WIDTH);

    ctx.strokeStyle = '#FFF';
    ctx.strokeRect(this.x(), this.y(), WIDTH, WIDTH);
};

Cell.prototype.drawNumber = function(color) {
    ctx.fillStyle = color;
    ctx.font = '30px monospaced';
    ctx.textBaseline = 'middle';
    ctx.fillText(this.n(), this.x() + 15, this.y() + 25);
};

Cell.prototype.isEmpty = function() {
    return this.n() === null;
};

Cell.prototype.select = function() {
    this.drawBackground('#000066');
    this.drawNumber('#FFF');
};

Cell.prototype.remove = function() {
    board.cells[this.j][this.i] = null;
    ctx.clearRect(this.x(), this.y(), WIDTH, WIDTH);
};

Cell.prototype.n = function() {
    return board.cells[this.j][this.i];
};

Cell.prototype.x = function() {
    return this.i * WIDTH;
};

Cell.prototype.y = function() {
    return this.j * WIDTH;
};


function Board() {
    this.cells = [];
}

Board.prototype.randomNumber = function() {
    var k = 0;
    while (k === 0 || k >= N) {
        k = Math.floor(Math.random() * 10);
    }
    return k;
};

Board.prototype.fill = function() {
    for(var j = 0; j < N; j++) {
        this.cells.push([]);
        for(var i = 0; i < N; i++) {
            this.cells[j][i] = this.randomNumber();
        }
    }
};

Board.prototype.draw = function() {
    this.clear();
    for(var j = 0; j < N; j++) {
        for(var i = 0; i < N; i++) {
            if (this.cells[j][i]) {
                new Cell(i, j).draw();
            }
        }
    }
};

Board.prototype.emptyCells = function() {
    var a = [];
    for(var j = 0; j < N; j++) {
        for(var i = 0; i < N; i++) {
            if (this.cells[j][i] === null) {
                a.push(new Cell(i, j));
            }
        }
    }
    return a;
};

Board.prototype.availableNumbers = function() {
    var a = [];
    for(var j = 0; j < N; j++) {
        for(var i = 0; i < N; i++) {
            if (this.cells[j][i]) {
                a.push(this.cells[j][i]);
            }
        }
    }
    return a.unique();
};

Board.prototype.insert = function(cell, n) {
    this.cells[cell.j][cell.i] = n;
    cell.draw();
};

Board.prototype.remove = function(cell) {
    this.cells[cell.j][cell.i] = null;
    cell.remove();
};

Board.prototype.addRandomCell = function() {
    this.insert(this.emptyCells().randomElement(), this.availableNumbers().randomElement());
};

Board.prototype.hasBlocks = function() {
    for(var j = 0; j < N; j++) {
        for(var i = 0; i < N; i++) {
            if (this.cells[j][i]) return true;
        }
    }
    return false;
};

Board.prototype.clear = function() {
    ctx.clearRect(0, 0, CANVAS_WIDTH, CANVAS_WIDTH);
};

Board.prototype.drawFinish = function() {
    board.clear();
    ctx.fillStyle = '#000';
    ctx.font = '50px Slackey';
    ctx.textBaseline = 'middle';
    ctx.fillText('Finish!', CANVAS_WIDTH/2 - 85, CANVAS_WIDTH/2);
};

Board.prototype.drawPaused = function() {
    board.clear();
    ctx.fillStyle = '#000';
    ctx.font = '50px Slackey';
    ctx.textBaseline = 'middle';
    ctx.fillText('Paused', CANVAS_WIDTH/2 - 85, CANVAS_WIDTH/2);
};


var newGame = function () {
    board = new Board();
    score = 0;
    updateScore();
    board.fill();
    board.draw();
};

var isSelf = function(a, b) {
    return (a.i == b.i && a.j == b.j);
};

var isSameNumber = function(a, b) {
    return (board.cells[a.j][a.i] == board.cells[b.j][b.i]);
};

var isMaxInSum = function(a, b) {
    return (board.cells[a.j][a.i] + board.cells[b.j][b.i]) == N;
};

var isSameRow = function(a, b) {
    return (a.j == b.j);
};

var isSameCol = function(a, b) {
    return (a.i == b.i);
};

var isAvailableToMove = function(a, b) {
    var min, max;
    if (isSelf(a, b)) {
        return false;
    }
    else if (isSameRow(a, b)) {
        min = Math.min(a.i, b.i);
        max = Math.max(a.i, b.i);

        if ((min + 1) == max) {
//            console.log('isVisible - near');
            return true;
        }
        else {
            for(var i = min + 1; i < max; i++) {
                if (board.cells[a.j][i] !== null) {
//                    console.log('isAvailableToMove - FALSE');
                    return false;
                }
            }
//            console.log('isAvailableToMove - TRUE');
            return true;
        }
    }
    else if (isSameCol(a, b)) {
        min = Math.min(a.j, b.j);
        max = Math.max(a.j, b.j);

        if ((min + 1) == max) {
//            console.log('isAvailableToMove - near');
            return true;
        }
        else {
            for(var j = min + 1; j < max; j++) {
                if (board.cells[j][a.i] !== null) {
//                    console.log('isVisible - FALSE');
                    return false;
                }
            }
//            console.log('isAvailableToMove - TRUE');
            return true;
        }
    }
    return false;
};

var moveCellTarget = function(a, b) {
    var t, i, j;

    if (isSameRow(a, b)) {
        if (b.i > a.i) {
            for(i = b.i; i < N; i++) {
                if (board.cells[a.j][i] === null) t = i;
                else break;
            }
        }
        else {
            for(i = b.i; i >= 0; i--) {
                if (board.cells[a.j][i] === null) t = i;
                else break;
            }
        }

        return new Cell(t, a.j);
    }
    else {
        if (b.j > a.j) {
            for(j = b.j; j < N; j++) {
                if (board.cells[j][a.i] === null) t = j;
                else break;
            }
        }
        else {
            for(j = b.j; j >= 0; j--) {
                if (board.cells[j][a.i] === null) t = j;
                else break;
            }
        }

        return new Cell(a.i, t);
    }
};

var updateScore = function() {
    document.getElementById('score').innerText = score.toString();
};

var N = 4;
var CANVAS_WIDTH = 500;
var WIDTH = Math.floor(CANVAS_WIDTH / N);
var canvas = document.getElementById('game-canvas');
var ctx = canvas.getContext('2d');
var currentCell = null;
var board = null;
var score = 0;
var paused = false;

canvas.addEventListener('click', function(e) {
    var cell = new Cell(Math.floor(e.offsetX / WIDTH), Math.floor(e.offsetY / WIDTH));

    if (cell.isEmpty() && currentCell === null) return;

    if (currentCell === null) {
        currentCell = cell;
        cell.select();
    }
    else {
        if (isSameRow(currentCell, cell) || isSameCol(currentCell, cell)) {
            if (isAvailableToMove(currentCell, cell)) {
                if (isSameNumber(currentCell, cell) || isMaxInSum(currentCell, cell)) {
                    score += 1;
                    board.remove(currentCell);
                    board.remove(cell);
                    currentCell = null;
                    updateScore();
                    checkFinish();
                    return;
                }
                else if (cell.isEmpty()) {
                    board.insert(moveCellTarget(currentCell, cell), currentCell.n());
                    currentCell.remove();
                    currentCell = null;
                    return;
                }
            }
        }

        currentCell.draw();
        // TODO: Play wrong sound
        currentCell = null;
    }
}, false);


var setBestScore = function(n) {
    localStorage.setItem('best_score', n);
};

var bestScore = function() {
  return parseInt(localStorage.getItem('best_score') || 0, 10);
};

var updateBestScore = function() {
    document.getElementById('best-score').innerText = bestScore();
};

var checkFinish = function() {
    if (board.hasBlocks()) return;
    board.drawFinish();
    if (score > bestScore()) {
        setBestScore(score);
        updateBestScore();
    }
};

var init = function() {
    updateBestScore();
    newGame();
};

var togglePause = function() {
    paused = !paused;
    if (paused) {
        board.drawPaused();
        document.getElementById('pause').innerText = 'Continue';
    }
    else {
        board.draw();
        document.getElementById('pause').innerText = 'Pause';
    }
};


Array.prototype.unique = function() {
    return this.filter(function(value, index, self) {
        return self.indexOf(value) === index;
    });
};

Array.prototype.randomElement = function() {
    return this[Math.floor(Math.random() * this.length)];
};


init();




