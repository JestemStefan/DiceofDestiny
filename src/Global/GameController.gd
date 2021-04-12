extends Node

enum GameState{BOARD_WAITING, BOARD_TRAVELING, ENCOUNTER}
var current_game_state: int = GameState.BOARD_WAITING

var player: Node2D

var board_layer: CanvasLayer
var current_board: Node2D
var current_board_tile: BoardTile
var all_tiles: Array
var open_tiles: Array

var encounter_layer: CanvasLayer
var current_encounter: Encounter

onready var fight_encounter_instance = preload("res://scenes/Encounters/FightEncounter.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func enter_state(new_state):
	current_game_state = new_state
	
	match current_game_state:
		GameState.BOARD_WAITING:
			current_board.show()
			
			if current_encounter != null:
				current_encounter.hide()
				
		GameState.BOARD_TRAVELING:
			pass
		
		GameState.ENCOUNTER:
			current_board.hide()
			current_encounter.show()
			


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
	
	close_opened_tiles()
	
	
	yield(tween, "tween_completed")
	tween.call_deferred("free")
	
	tile.open_connected_tiles()
	tile.set_as_current_tile()
	
	enter_state(GameState.BOARD_WAITING)


func start_encounter(encounter_type: String):
	
	match encounter_type:
		"Fight":
			
			var encounter: Encounter = fight_encounter_instance.instance()
			encounter_layer.add_child(encounter)
			
			encounter.start_encounter()
			
	enter_state(GameState.ENCOUNTER)
	

func end_encounter():
	current_encounter.call_deferred("free")
	current_encounter = null
	
	enter_state(GameState.BOARD_WAITING)
	current_board_tile.update_tile_type(current_board_tile.TileTypes.EMPTY_TILE)
	current_board_tile.enter_state(current_board_tile.TileState.CURRENT)
