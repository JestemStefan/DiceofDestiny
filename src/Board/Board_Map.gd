extends Node2D
class_name BoardMap


var board_tiles: Array


# Called when the node enters the scene tree for the first time.
func _ready():
	board_tiles = $Board_Tiles.get_children()
	GameController.all_tiles = board_tiles
	GameController.current_board = self


func cover(on_off: bool):
	$MapOverlay.visible = on_off
