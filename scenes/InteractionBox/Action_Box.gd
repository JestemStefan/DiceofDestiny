extends Area2D
class_name ActionBox

enum Action_type{ATTACK, BLOCK, HEAL}
#export(Action_type) var Action = Action_type.ATTACK
var ActionBox_Type: int = Action_type.ATTACK

onready var tween_size: Tween = $Tween_Size
signal actionbox_triggered

var assigned_dice = null

func _ready():
	yield(get_tree(), "idle_frame")
	
	var _err = connect("actionbox_triggered", 
			GameController.current_encounter, 
			"_on_Action_Box_actionbox_triggered")


func get_actionbox_type():
	return ActionBox_Type


func set_actionbox_type(type: int, isPlayer: bool = true):
	ActionBox_Type = type
	update_actionbox(isPlayer)


func update_actionbox(isPlayer: bool):
	if isPlayer:
		match ActionBox_Type:
			
			Action_type.ATTACK: 
				$Box_Sprite.frame = 5
				
			Action_type.BLOCK: 
				$Box_Sprite.frame = 3
				
			Action_type.HEAL: 
				$Box_Sprite.frame = 4
	
	else:
		match ActionBox_Type:
			
			Action_type.ATTACK: 
				$Box_Sprite.frame = 2
				
			Action_type.BLOCK: 
				$Box_Sprite.frame = 0
				
			Action_type.HEAL: 
				$Box_Sprite.frame = 1

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


func assign_dice(dice):
	
	if assigned_dice != null:
		assigned_dice.dice.last_position = dice.initial_position
		assigned_dice.enter_state(dice.State.DRAG)
		
		
	
	else:
		assigned_dice = dice
		$UseButton.disabled = false


func release_dice():
	print("dice released")
	assigned_dice = null
	$UseButton.disabled = true


func _on_Action_Box_mouse_entered():
	var _err_tween = tween_size.interpolate_property($Box_Sprite, "scale", null, Vector2(1.9, 1.9), 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	var _tween_start = tween_size.start()
	
	if GameController.current_encounter.current_turn == GameController.current_encounter.Turn.PLAYER:
		GameController.current_encounter.picked_action = self
	

func _on_Action_Box_mouse_exited():
	var _err_tween = tween_size.interpolate_property($Box_Sprite, "scale", null, Vector2(2, 2), 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	var _tween_start = tween_size.start()
	
	
	if GameController.current_encounter.picked_action == self and GameController.current_encounter.current_turn == GameController.current_encounter.Turn.PLAYER:
		GameController.current_encounter.picked_action = null
		



func _on_UseButton_button_up():
	
	var action_name: String
	
	match ActionBox_Type:
		
		Action_type.ATTACK:
			action_name = "Attack"
		
		Action_type.BLOCK:
			action_name = "Block"
		
		Action_type.HEAL:
			action_name = "Heal"
	
	$UseButton.disabled = true
	emit_signal("actionbox_triggered", action_name, assigned_dice.get_dice_value())
	assigned_dice.enter_state(assigned_dice.State.USED)
