extends Area2D
class_name BoardTile

export var isStartTile: bool = false

enum TileState {CLOSED, OPEN, CURRENT}

var current_tilestate: int = TileState.CLOSED

export(Array, NodePath) var connected_tiles

# Called when the node enters the scene tree for the first time.
func _ready():
	yield(get_tree(), "idle_frame")
	if isStartTile:
		enter_state(TileState.OPEN)
		GameController.update_open_tiles([self])
		GameController.move_to_tile(self)
		


func enter_state(new_state):
	current_tilestate = new_state
	
	match current_tilestate:
		TileState.CLOSED:
			$icon.self_modulate = Color.white
		
		TileState.OPEN:
			$icon.self_modulate = Color.yellow
			
		
		TileState.CURRENT:
			GameController.current_board_tile = self
	


func open_tile():
	enter_state(TileState.OPEN)


func close_tile():
	enter_state(TileState.CLOSED)


func set_as_current_tile():
	enter_state(TileState.CURRENT)
	

func open_connected_tiles():
	var list_of_opened_tiles: Array = []
	
	for connected_tile in connected_tiles:
		var tile_to_open = get_node(connected_tile)
		
		tile_to_open.open_tile()
		list_of_opened_tiles.append(tile_to_open)
	
	GameController.update_open_tiles(list_of_opened_tiles)


func _on_Board_Tile_input_event(_viewport, event, _shape_idx):
	
	if event is InputEventMouseButton:
		if event.is_pressed() and GameController.current_game_state == GameController.GameState.BOARD_WAITING:
			
			match event.button_index:
				1:
					match current_tilestate:
						TileState.CLOSED:
							pass
						
						TileState.OPEN:
							GameController.move_to_tile(self)
						
						TileState.CURRENT:
							pass


