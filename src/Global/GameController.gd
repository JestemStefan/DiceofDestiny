extends Node

enum GameState{BOARD_WAITING, BOARD_TRAVELING}
var current_game_state: int = GameState.BOARD_WAITING

var player: Node2D

var current_board_tile: BoardTile

var all_tiles: Array
var open_tiles: Array


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func enter_state(new_state):
	current_game_state = new_state


func update_open_tiles(tile_list: Array):
	open_tiles = tile_list


func close_opened_tiles():
	for tile_to_close in open_tiles:
		tile_to_close.close_tile()


func move_to_tile(tile: BoardTile):
	enter_state(GameState.BOARD_TRAVELING)
	
	print("Trying to move to tile: " + str(tile.get_name()))
	
	var tween = Tween.new()
	add_child(tween)
	tween.interpolate_property(
								player, "global_position", 
								player.global_position, tile.global_position, 1,
								Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	tween.start()
	
	yield(tween, "tween_completed")
	tween.call_deferred("free")
	
	close_opened_tiles()
	tile.open_connected_tiles()
	tile.set_as_current_tile()
	
	enter_state(GameState.BOARD_WAITING)
	
