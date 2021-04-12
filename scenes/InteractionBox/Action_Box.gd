extends Area2D
class_name ActionBox

enum Action_type{ATTACK, BLOCK}
#export(Action_type) var Action = Action_type.ATTACK
var ActionBox_Type: int = Action_type.ATTACK

signal actionbox_triggered


func _ready():
	yield(get_tree(), "idle_frame")
	#print(GameController.current_encounter.get_name())
	
	var _err = connect("actionbox_triggered", 
			GameController.current_encounter, 
			"_on_Action_Box_actionbox_triggered")


func get_actionbox_type():
	return ActionBox_Type


func set_actionbox_type(type: int):
	ActionBox_Type = type
	update_actionbox()


func update_actionbox():
	match ActionBox_Type:
		
		Action_type.ATTACK: $Box_Sprite.self_modulate = Color.lightcoral
		Action_type.BLOCK: $Box_Sprite.self_modulate = Color.lightblue


func use_dice(dice_value: int):
	
	var action_name: String
	
	match ActionBox_Type:
		
		Action_type.ATTACK:
			action_name = "Attack"
		
		Action_type.BLOCK:
			action_name = "Block"

	emit_signal("actionbox_triggered", action_name, dice_value)
