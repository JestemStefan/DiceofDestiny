tool
extends Area2D
class_name BoardTile

enum TileState {CLOSED, OPEN, CURRENT}
var current_tilestate: int = TileState.CLOSED

enum TileTypes{EMPTY_TILE, FIGHT_TILE, BOSS_TILE, REST_TILE, DM_TILE}
export(TileTypes) var Tile_Type = TileTypes.EMPTY_TILE setget update_tile_type

enum EnvironmentTypes{FOREST, ISLAND, DESERT, SWAMP, BOSS, DM}
export(EnvironmentTypes) var environment = EnvironmentTypes.FOREST

export(Resource) var enemy_to_fight

export(Array, NodePath) var connected_tiles

export var isStartTile: bool = false
export var isLocked: bool = true

# Called when the node enters the scene tree for the first time.
func _ready():
	#var err = connect("input_event", self, "_on_Board_Tile_input_event")
	
	yield(get_tree(), "idle_frame")
	
	update_tile_type()
	
	if isStartTile:
		enter_state(TileState.OPEN)
		GameController.update_open_tiles([self])
		GameController.move_to_tile(self)
		GameController.last_rest_tile = self
	#else:
		#enter_state(TileState.CLOSED)

func enter_state(new_state):
	current_tilestate = new_state
	
	match current_tilestate:
		TileState.CLOSED:
			if isLocked:
				$TileSprite.self_modulate = Color(0.3, 0.3, 0.3, 1)
			else:
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
				
				TileTypes.BOSS_TILE:
					$InteractionButton.visible = true
					
				TileTypes.REST_TILE:
					$InteractionButton.visible = true
				
				TileTypes.DM_TILE:
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
			match environment:
				EnvironmentTypes.FOREST: $TileSprite.frame = 3
				EnvironmentTypes.ISLAND: $TileSprite.frame = 2
				EnvironmentTypes.DESERT: $TileSprite.frame = 5
				EnvironmentTypes.SWAMP: $TileSprite.frame = 4
				EnvironmentTypes.BOSS: $TileSprite.frame = 2
				EnvironmentTypes.DM: $TileSprite.frame = 2
			
		
		TileTypes.FIGHT_TILE:
			$TileSprite.frame = 1
			$InteractionButton.text = "Fight"
		
		TileTypes.BOSS_TILE:
			$TileSprite.frame = 7
			$InteractionButton.text = "Boss"
		
		TileTypes.REST_TILE:
			match environment:
				EnvironmentTypes.FOREST: $TileSprite.frame = 9
				EnvironmentTypes.ISLAND: $TileSprite.frame = 10
				EnvironmentTypes.DESERT: $TileSprite.frame = 11
				EnvironmentTypes.SWAMP: $TileSprite.frame = 10
			
			$InteractionButton.text = "Rest"
		
		TileTypes.DM_TILE:
			$TileSprite.frame = 8
			$InteractionButton.text = "BOSS"

func unlock_tiles():
	var list_of_tiles_to_unlock: Array = []
	
	for connected_tile in connected_tiles:
		var tile_to_unlock = get_node(connected_tile)
		if tile_to_unlock.isLocked == true:
			
			tile_to_unlock.open_tile()
			tile_to_unlock.isLocked = false
			
		list_of_tiles_to_unlock.append(tile_to_unlock)
	
	GameController.update_open_tiles(list_of_tiles_to_unlock)


func open_connected_tiles():
	var list_of_opened_tiles: Array = []
	
	for connected_tile in connected_tiles:
		var tile_to_open = get_node(connected_tile)
		if tile_to_open.isLocked == false or GameState.isCheater:
			tile_to_open.open_tile()
			list_of_opened_tiles.append(tile_to_open)
	
	GameController.update_open_tiles(list_of_opened_tiles)



func _on_Board_Tile_input_event(_viewport, event, _shape_idx):
	
	if event is InputEventMouseButton:
		if event.is_pressed() and GameController.current_game_state == GameController.Game_State.BOARD_WAITING:
			
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
	if current_tilestate != TileState.CURRENT and GameController.current_game_state == GameController.Game_State.BOARD_WAITING and !isLocked:
		$Tween.interpolate_property($TileSprite, "scale", $TileSprite.get_scale(), Vector2(1.5, 1.5), 0.25, Tween.TRANS_CUBIC, Tween.EASE_IN)
		$Tween.start()




func _on_Board_Tile_mouse_exited():
	$Tween.interpolate_property($TileSprite, "scale", $TileSprite.get_scale(), Vector2(1, 1), 0.25, Tween.TRANS_CUBIC, Tween.EASE_IN)
	$Tween.start()

	


func _on_InteractionButton_button_up():
	
	match Tile_Type:
		TileTypes.EMPTY_TILE:
			$InteractionButton.hide()
		
		TileTypes.FIGHT_TILE:
			GameController.start_encounter("Fight", enemy_to_fight, environment)
			$InteractionButton.hide()
		
		TileTypes.BOSS_TILE:
			GameController.start_encounter("Fight", enemy_to_fight, environment)
			$InteractionButton.hide()
			
		TileTypes.REST_TILE:
			GameController.start_encounter("Rest", enemy_to_fight, environment)
			GameController.last_rest_tile = self
			#$InteractionButton.hide()
		
		TileTypes.DM_TILE:
			GameController.start_encounter("Fight", enemy_to_fight, environment)
			$InteractionButton.hide()
	
	
