extends Node2D

var action_box_instance: PackedScene = preload("res://scenes/InteractionBox/ActionBox.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	var skill_list: Array = GameState.get_player_skill_list()
	
	var i: int = 0
	for skill in skill_list:
		
		create_action_box(skill, Vector2(0, len(skill_list) * -32 + i * 64))
		i += 1
	
	update_healthbar()
	
	
func create_action_box(skill_name: String, box_position: Vector2):
	
	var action_box:ActionBox = action_box_instance.instance()
	$Skills.add_child(action_box)
	action_box.position = box_position
	
	match skill_name:
		"Attack":
			action_box.set_actionbox_type(action_box.Action_type.ATTACK)
		
		"Block":
			action_box.set_actionbox_type(action_box.Action_type.BLOCK)
	
	
func update_healthbar():
	$PlayerHealth.max_value = GameState.player_max_health
	$PlayerHealth.value = GameState.player_health
