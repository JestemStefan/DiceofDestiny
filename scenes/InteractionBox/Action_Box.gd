extends Area2D
class_name ActionBox

enum Action_type{ATTACK, BLOCK, HEAL}
#export(Action_type) var Action = Action_type.ATTACK
var ActionBox_Type: int = Action_type.ATTACK

onready var tween_size: Tween = $Tween_Size
signal actionbox_triggered


func _ready():
	yield(get_tree(), "idle_frame")
	
	var _err = connect("actionbox_triggered", 
			GameController.current_encounter, 
			"_on_Action_Box_actionbox_triggered")


func get_actionbox_type():
	return ActionBox_Type


func set_actionbox_type(type: int):
	print(type)
	ActionBox_Type = type
	update_actionbox()


func update_actionbox():
	print(ActionBox_Type)
	match ActionBox_Type:
		
		Action_type.ATTACK: $Box_Sprite.frame = 2
		Action_type.BLOCK: $Box_Sprite.frame = 0
		Action_type.HEAL: $Box_Sprite.frame = 1


func use_dice(dice_value: int):
	
	var action_name: String
	
	match ActionBox_Type:
		
		Action_type.ATTACK:
			action_name = "Attack"
		
		Action_type.BLOCK:
			action_name = "Block"
		
		Action_type.HEAL:
			action_name = "Heal"

	emit_signal("actionbox_triggered", action_name, dice_value)


func _on_Action_Box_mouse_entered():
	var _err_tween = tween_size.interpolate_property(self, "scale", Vector2.ONE, Vector2(1.2, 1.2), 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	var _tween_start = tween_size.start()


func _on_Action_Box_mouse_exited():
	var _err_tween = tween_size.interpolate_property(self, "scale", null, Vector2.ONE, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	var _tween_start = tween_size.start()
