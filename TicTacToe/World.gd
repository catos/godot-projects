extends Node

const Tile = preload("res://Tile.tscn")

var width = 3
var height = 3

var board = []

func _ready():
	setup_board()
#	print(board)
#	spawn_tiles()

func setup_board():
	var array = []
	for y in height:
#		array.append([])
		for x in width:
#			array[y].append(0)
			var tile = Tile.instance()
			tile.position = Vector2(x * 9, y * 9)
			self.add_child(tile)
	
#	return array


#func spawn_tiles():
#	for y in board:
#		for x in board[y]:
#			var tile = Tile.instance()
#			tile.position = Vector2(x * 9, y * 9)
#			self.add_child(tile)
