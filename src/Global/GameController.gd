extends Node

enum Game_State{BOARD_WAITING, BOARD_TRAVELING, ENCOUNTER}
var current_game_state: int = Game_State.BOARD_WAITING

var player: Node2D

var board_layer: CanvasLayer
var current_board: BoardMap
var current_board_tile: BoardTile
var all_tiles: Array
var open_tiles: Array

var encounter_layer: CanvasLayer
var current_encounter: Encounter

onready var fight_encounter_instance = preload("res://scenes/Encounters/FightEncounter.tscn")

var transition_layer: TransitionLayer

func _ready():
	pass


func enter_state(new_state):
	current_game_state = new_state
	
	match current_game_state:
		Game_State.BOARD_WAITING:
			current_board.cover(false)
			
			if current_encounter != null:
				current_encounter.hide()
				
		Game_State.BOARD_TRAVELING:
			pass
		
		Game_State.ENCOUNTER:
			current_board.cover(true)
			current_encounter.show()
			

# make selected tile available to travel
func update_open_tiles(tile_list: Array):
	open_tiles = tile_list


func close_opened_tiles():
	for tile_to_close in open_tiles:
		tile_to_close.close_tile()


func move_to_tile(tile: BoardTile):
	enter_state(Game_State.BOARD_TRAVELING)
	
	var tween = Tween.new()
	
	if current_board_tile != null:
		current_board_tile.enter_state(BoardTile.TileState.CLOSED)
	
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
	
	enter_state(Game_State.BOARD_WAITING)


func start_encounter(encounter_type: String, enemy_data: Resource, env: int):
	
	var transition_tween: Tween = transition_layer.make_transition_black_in()
	yield(transition_tween, "tween_completed")
	
	match encounter_type:
		"Fight":
			
			var encounter: Encounter = fight_encounter_instance.instance()
			encounter_layer.add_child(encounter)
			
			encounter.enemy_stats = enemy_data
			encounter.encounter_environment = env
			encounter.start_encounter()
	
			enter_state(Game_State.ENCOUNTER)
			
		"Rest":
			GameState.player_health = GameState.player_max_health

	transition_tween = transition_layer.make_transition_black_out()
	yield(transition_tween, "tween_completed")
	transition_layer.transition_black_hide()


func end_encounter():
	# Transition to black
	var transition_tween: Tween = transition_layer.make_transition_black_in()
	yield(transition_tween, "tween_completed")
	
	# Delete encounter
	current_encounter.call_deferred("free")
	current_encounter = null
	
	# Prepare the board
	enter_state(Game_State.BOARD_WAITING)
	current_board_tile.update_tile_type(current_board_tile.TileTypes.EMPTY_TILE)
	current_board_tile.enter_state(current_board_tile.TileState.CURRENT)
	
	# Transition out of black
	transition_tween = transition_layer.make_transition_black_out()
	yield(transition_tween, "tween_completed")
	transition_layer.transition_black_hide()
