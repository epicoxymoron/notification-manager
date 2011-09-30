all:
	coffee -cb src/*.coffee
	coffee -cb test/*.coffee
	docco src/*.coffee
