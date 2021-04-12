extends Area2D
class_name BoardTile

enum TileState {CLOSED, OPEN, CURRENT}
var current_tilestate: int = TileState.CLOSED

enum TileTypes{EMPTY_TILE, FIGHT_TILE, CHEST_TILE}
export(TileTypes) var Tile_Type = TileTypes.EMPTY_TILE

export(Array, NodePath) var connected_tiles

export var isStartTile: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	#var err = connect("input_event", self, "_on_Board_Tile_input_event")
	
	yield(get_tree(), "idle_frame")
	if isStartTile:
		enter_state(TileState.OPEN)
		GameController.update_open_tiles([self])
		GameController.move_to_tile(self)
	
	update_tile_type()

func enter_state(new_state):
	current_tilestate = new_state
	
	match current_tilestate:
		TileState.CLOSED:
			$TileSprite.self_modulate = Color.white
			$InteractionButton.visible = false
		
		TileState.OPEN:
			$TileSprite.self_modulate = Color.greenyellow
			$InteractionButton.visible = false
			
		
		TileState.CURRENT:
			GameController.current_board_tile = self
			
			
			match Tile_Type:
				TileTypes.EMPTY_TILE:
					$InteractionButton.visible = false
				
				TileTypes.FIGHT_TILE:
					$InteractionButton.visible = true
				
				TileTypes.CHEST_TILE:
					$InteractionButton.visible = true
	


func open_tile():
	enter_state(TileState.OPEN)


func close_tile():
	enter_state(TileState.CLOSED)


func set_as_current_tile():
	enter_state(TileState.CURRENT)
	

func update_tile_type(new_type: int = Tile_Type):
	Tile_Type = new_type
	
	match Tile_Type:
		TileTypes.EMPTY_TILE:
			$TileSprite.frame = 3
		
		TileTypes.FIGHT_TILE:
			$TileSprite.frame = 1
		
		TileTypes.CHEST_TILE:
			$TileSprite.frame = 0


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




func _on_Board_Tile_mouse_entered():
	if current_tilestate != TileState.CURRENT and GameController.current_game_state == GameController.GameState.BOARD_WAITING:
		$Tween.interpolate_property($TileSprite, "scale", $TileSprite.get_scale(), Vector2(1.5, 1.5), 0.25, Tween.TRANS_CUBIC, Tween.EASE_IN)
		$Tween.start()

	


func _on_Board_Tile_mouse_exited():
	$Tween.interpolate_property($TileSprite, "scale", $TileSprite.get_scale(), Vector2(1, 1), 0.25, Tween.TRANS_CUBIC, Tween.EASE_IN)
	$Tween.start()

	


func _on_InteractionButton_button_up():
	GameController.start_encounter("Fight")
