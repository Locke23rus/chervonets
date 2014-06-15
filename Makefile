
COFFEE = coffee
OUT = game.js
SRC = src/*.coffee

dev:
	$(COFFEE) -j $(OUT) -mcbw $(SRC)

build:
	$(COFFEE) -j $(OUT) -mcb $(SRC)
	./node_modules/.bin/uglifyjs visibility.min.js polyfills.js $(OUT) -o index.min.js

.PHONY: dev build
