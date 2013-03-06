
COFFEE = coffee
OUT = index.js
SRC = src/*.coffee

all: clean compile

dev:
	$(COFFEE) -j $(OUT) -mcbw $(SRC)

compile:
	$(COFFEE) -j $(OUT) -mcb $(SRC)

clean:
	rm -f $(OUT)

.PHONY: dev compile clean
